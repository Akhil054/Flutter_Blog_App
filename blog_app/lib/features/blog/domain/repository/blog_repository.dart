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

  /// All blogs a given user has posted, used on the profile page.
  Future<Either<Failure, List<Blog>>> getUserBlogs(String posterId);

  /// Updates a blog the current user posted. Pass `newImage` only when the
  /// user picked a replacement picture - otherwise the existing image stays.
  Future<Either<Failure, Blog>> updateBlog({
    required String blogId,
    required String title,
    required String content,
    required List<String> topics,
    File? newImage,
  });

  /// Deletes a blog the current user posted.
  Future<Either<Failure, void>> deleteBlog(String blogId);

}