import 'dart:io';
import 'dart:developer' as developer;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../blog_model.dart';

abstract interface class BlogRemoteDataSource{
  Future<BlogModel> uploadBlog(BlogModel blog);

  Future<String> uploadBlogImage({
    required File image,
    required BlogModel blog,
    bool upsert = false,
  });

  Future<List<BlogModel>> getAllBlogs({
    required int page,
    int limit,
  });

  Future<bool> toggleLikeBlog(String blogId);

  /// All blogs a given user has posted, used on the profile page.
  Future<List<BlogModel>> getUserBlogs(String posterId);

  /// Updates a blog's title/content/topics, and its image if `newImage` is
  /// given. Returns the updated row.
  Future<BlogModel> updateBlog({
    required String blogId,
    required String title,
    required String content,
    required List<String> topics,
    File? newImage,
  });

  Future<void> deleteBlog(String blogId);

}

class BlogRemoteDataSourceImpl implements BlogRemoteDataSource{

  /// Calling supabase client to upload the blog to the database
  final SupabaseClient supabaseClient;
  BlogRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<BlogModel> uploadBlog(BlogModel blog) async {
    try{
      ///inserting the blog data to the supabase database
      final blogData = await supabaseClient.from('blogs').insert(blog.toJson()).select();

      return BlogModel.fromJson(blogData.first);
    }
    catch(e){
      throw Exception(e.toString());
    }
  }

  @override
  Future<String> uploadBlogImage({
    required File image,
    required BlogModel blog,
    bool upsert = false,
  }) async {
    try {
      // #region debug-point E:upload-image-start
      developer.log(
        '[DEBUG] uploadBlogImage start blogId=${blog.id} path=${image.path} type=${image.runtimeType}',
        name: 'blog-upload-web',
      );
      // #endregion
      /// bucket implemented & call - upsert:true lets editing a blog
      /// overwrite the file already stored at this blog's id
      await supabaseClient.storage.from('blogs_images').upload(
        blog.id,
        image,
        fileOptions: FileOptions(cacheControl: '3600', upsert: upsert),
      );

      // #region debug-point F:upload-image-success
      developer.log(
        '[DEBUG] uploadBlogImage success blogId=${blog.id}',
        name: 'blog-upload-web',
      );
      // #endregion
      /// bucket called here 
      return supabaseClient.storage.from('blogs_images').getPublicUrl(blog.id);
    } catch (e) {
      // #region debug-point G:upload-image-error
      developer.log(
        '[DEBUG] uploadBlogImage failed blogId=${blog.id} error=$e',
        name: 'blog-upload-web',
      );
      // #endregion
      throw Exception(e.toString());
    }
  }

  @override
  Future<List<BlogModel>> getAllBlogs({
    required int page,
    int limit = 10,
  }) async {
    try {
      final start = page * limit;
      final end = start + limit - 1;

      /// the main feed is "other people's blogs" - your own posts show up
      /// on your profile page instead, so exclude them here at the query
      /// level (before .range()) so page sizes/pagination stay accurate
      final currentUserId = supabaseClient.auth.currentUser?.id;
      var query = supabaseClient.from('blogs').select();
      if (currentUserId != null) {
        query = query.neq('poster_id', currentUserId);
      }

      /// fetching one page of blogs, most recently updated first
      final blogs = await query
          .order('updated_at', ascending: false)
          .range(start, end);

      final blogModels = blogs.map((blog) => BlogModel.fromJson(blog)).toList();
      if (blogModels.isEmpty) return blogModels;

      /// fetching the poster's name for each unique posterId so the UI can
      /// show "who wrote this" without a DB-level foreign key join
      final posterIds = blogModels.map((blog) => blog.posterId).toSet().toList();
      final users = await supabaseClient
          .from('profiles')
          .select('id, name')
          .inFilter('id', posterIds);

      final nameByPosterId = {
        for (final user in users)
          if (user['id'] != null) user['id'] as String: (user['name'] as String?) ?? 'Anonymous',
      };

      final withLikes = await _attachLikes(blogModels);

      return withLikes
          .map((blog) => blog.copyWith(
                author: nameByPosterId[blog.posterId] ?? 'Anonymous',
              ))
          .toList();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<List<BlogModel>> getUserBlogs(String posterId) async {
    try {
      final blogs = await supabaseClient
          .from('blogs')
          .select()
          .eq('poster_id', posterId)
          .order('updated_at', ascending: false);

      final blogModels = blogs.map((blog) => BlogModel.fromJson(blog)).toList();
      if (blogModels.isEmpty) return blogModels;

      /// the poster is already known (it's the current user), so skip the
      /// profiles join that getAllBlogs needs and just attach likes
      return _attachLikes(blogModels);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// fetches likes for the given blogs and returns them with `likesCount`
  /// and `isLiked` (for the current user) filled in; shared by getAllBlogs
  /// and getUserBlogs so the like-aggregation logic lives in one place
  Future<List<BlogModel>> _attachLikes(List<BlogModel> blogModels) async {
    final blogIds = blogModels.map((blog) => blog.id).toList();
    final likeRows = await supabaseClient
        .from('blog_likes')
        .select('blog_id, user_id')
        .inFilter('blog_id', blogIds);

    final currentUserId = supabaseClient.auth.currentUser?.id;
    final likeCountByBlogId = <String, int>{};
    final likedBlogIds = <String>{};
    for (final row in likeRows) {
      final blogId = row['blog_id'] as String?;
      if (blogId == null) continue;
      likeCountByBlogId[blogId] = (likeCountByBlogId[blogId] ?? 0) + 1;
      if (row['user_id'] == currentUserId) likedBlogIds.add(blogId);
    }

    return blogModels
        .map((blog) => blog.copyWith(
              likesCount: likeCountByBlogId[blog.id] ?? 0,
              isLiked: likedBlogIds.contains(blog.id),
            ))
        .toList();
  }

  @override
  Future<bool> toggleLikeBlog(String blogId) async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) throw Exception('You must be logged in to like a blog');

      final existing = await supabaseClient
          .from('blog_likes')
          .select()
          .eq('blog_id', blogId)
          .eq('user_id', userId);

      if (existing.isNotEmpty) {
        await supabaseClient
            .from('blog_likes')
            .delete()
            .eq('blog_id', blogId)
            .eq('user_id', userId);
        return false;
      } else {
        await supabaseClient.from('blog_likes').insert({
          'blog_id': blogId,
          'user_id': userId,
        });
        return true;
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<BlogModel> updateBlog({
    required String blogId,
    required String title,
    required String content,
    required List<String> topics,
    File? newImage,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'title': title,
        'content': content,
        'topics': topics,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (newImage != null) {
        /// overwrite the file already stored at this blog's id (upsert)
        /// rather than uploading a new one under a new path
        final placeholder = BlogModel(
          id: blogId,
          posterId: '',
          title: title,
          content: content,
          imageUrl: '',
          topics: topics,
          updatedAt: DateTime.now(),
        );
        final publicUrl = await uploadBlogImage(
          image: newImage,
          blog: placeholder,
          upsert: true,
        );
        /// the public URL for a given path never changes, so overwriting the
        /// file there would otherwise keep serving the old image from any
        /// HTTP/image cache keyed by that URL - a cache-busting query param
        /// forces callers to actually refetch it
        updateData['image_url'] =
            '$publicUrl?updated=${DateTime.now().millisecondsSinceEpoch}';
      }

      final updated = await supabaseClient
          .from('blogs')
          .update(updateData)
          .eq('id', blogId)
          .select();

      if (updated.isEmpty) {
        throw Exception('Blog not found or you do not have permission to edit it');
      }

      return BlogModel.fromJson(updated.first);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> deleteBlog(String blogId) async {
    try {
      /// best-effort - if the file's already gone (or was never uploaded)
      /// this shouldn't block deleting the actual blog row
      try {
        await supabaseClient.storage.from('blogs_images').remove([blogId]);
      } catch (_) {}

      /// blog_likes rows for this blog are removed automatically via the
      /// table's ON DELETE CASCADE foreign key
      await supabaseClient.from('blogs').delete().eq('id', blogId);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

}
