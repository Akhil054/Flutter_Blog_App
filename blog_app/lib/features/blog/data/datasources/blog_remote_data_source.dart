import 'dart:io';
import 'dart:developer' as developer;
import 'package:blog_app/error/exception.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../blog_model.dart';

abstract interface class BlogRemoteDataSource{
  Future<BlogModel> uploadBlog(BlogModel blog);

  Future<String> uploadBlogImage({
    required File image,
    required BlogModel blog,
  });
  /// Returning the blog from db to user 
  Future<List<BlogModel>> getAllBlogs();
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
      on PostgrestException catch(e){
        throw Exception(e.message);
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

      /// bucket called here 
      return supabaseClient.storage.from('blogs_images').getPublicUrl(blog.id);
    } 

    ///Storage Exception is thrown when the image upload fails
    on StorageException catch(e) {
        throw ServerException(e.message);
    }

    catch (e) {
      // #region debug-point G:upload-image-error
      developer.log(
        '[DEBUG] uploadBlogImage failed blogId=${blog.id} error=$e',
        name: 'blog-upload-web',
      );

      throw Exception(e.toString());
    }
    
  }

/// Returning the blog from db to user 
  @override
  Future<List<BlogModel>> getAllBlogs() async {
   
   try{
      /// get the data from blogs table and then go towards profiles table to get the name of the user who posted the blog
    final blogs = await supabaseClient.from('blogs').select('*, profiles(name)');
      /// mapping the data to the blog model and returning the list of blogs
    return blogs.map((blog) => BlogModel.fromJson(blog).copyWith(
      posterName: blog['profiles']?['name'] as String?,
    )).toList();
   }
    on PostgrestException catch(e){
          throw Exception(e.message);
    }
   catch(e){
    throw Exception(e.toString());
   }

  }
}
