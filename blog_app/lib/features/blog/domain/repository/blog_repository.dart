import 'dart:io';
import 'package:fpdart/fpdart.dart';
import '../../../../error/failures.dart';
import '../entites/blog.dart';

/// write one function to upload blog and return either failure or blog
abstract interface class BlogRepository{
  Future<Either<Failure, Blog>> uploadBlog({
    //asking user required content here
    required File image, 
    required String title, 
    required String content, 
    required String posterId,
    required List<String> topics,
  });

  Future<Either<Failure, List<Blog>>> getAllBlogs({
    required int page,
    int limit,
  });

  /// toggles the current user's like on a blog; returns the new liked state
  Future<Either<Failure, bool>> toggleLikeBlog(String blogId);

  /// Number of blogs a given user has posted, used on the profile page.
  Future<Either<Failure, int>> getUserBlogsCount(String posterId);

}