import 'dart:io';
import 'dart:developer' as developer;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../blog_model.dart';

abstract interface class BlogRemoteDataSource{
  Future<BlogModel> uploadBlog(BlogModel blog);

  Future<String> uploadBlogImage({
    required File image,
    required BlogModel blog,
  });

  Future<List<BlogModel>> getAllBlogs({
    required int page,
    int limit,
  });

  Future<bool> toggleLikeBlog(String blogId);

  /// All blogs a given user has posted, used on the profile page.
  Future<List<BlogModel>> getUserBlogs(String posterId);

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
  }) async {
    try {
      // #region debug-point E:upload-image-start
      developer.log(
        '[DEBUG] uploadBlogImage start blogId=${blog.id} path=${image.path} type=${image.runtimeType}',
        name: 'blog-upload-web',
      );
      // #endregion
      /// bucket implemented & call 
      await supabaseClient.storage.from('blogs_images').upload(
        blog.id,
        image,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
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

      /// fetching one page of blogs, most recently updated first
      final blogs = await supabaseClient
          .from('blogs')
          .select()
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

}
