import 'dart:io';
import 'package:blog_app/core/constants/constant.dart';
import 'package:blog_app/core/network/connection_checker.dart';
import 'package:blog_app/error/exception.dart';
import 'package:blog_app/error/failures.dart';
import 'package:blog_app/features/blog/data/blog_model.dart';
import 'package:blog_app/features/blog/domain/entites/blog.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

import '../../domain/repository/blog_repository.dart';
import '../datasources/blog_remote_data_source.dart';

/// This is the implementation of the BlogRepository interface. It provides methods to 
/// interact with the blog data source, such as fetching blog posts, creating new posts, updating existing posts, and deleting posts. The implementation may use various data sources like APIs, databases, or local storage to perform these operations.

class BlogRepositoryImpl implements BlogRepository{

  /// contact db for uploaded and access of image
  final BlogRemoteDataSource blogRemoteDataSource;
  final ConnectionChecker connectionChecker;
  BlogRepositoryImpl(this.blogRemoteDataSource, this.connectionChecker);

  @override
  Future<Either<Failure, Blog>> uploadBlog({
    required File image, 
    required String title, 
    required String content, 
    required String posterId, 
    required List<String> topics,
  })  async {
    try{
      if(!await (connectionChecker.isConnected)){
        return left(Failure(Constants.noConnErrorMsg));
      }
      /// created an blog model based on above one..
      /// uuid package is been taken for gen of random id
      BlogModel blogModel = BlogModel(
        id: const Uuid().v1(),
        posterId: posterId,
        title: title,
        content: content,
        imageUrl: '',
        topics: topics,
        updatedAt: DateTime.now(),
        posterName: null,
      );

      /// access to db & call uploadImage function & saving the imageURL and possing to blog Model so its get uploaded to db
      final imageUrl = await blogRemoteDataSource.uploadBlogImage(
          image: image,
          blog: blogModel
      );

      /// created an copywith blogModel from blog class & given to BlogModel so we can assing 'ImageUrl' variable in this ImageUrl
      blogModel = blogModel.copyWith(
        imageUrl: imageUrl,
      );

      ///saving to db
      // ignore: non_constant_identifier_names
      final UploadBlog = await blogRemoteDataSource.uploadBlog(blogModel);
      return right(UploadBlog);
      
    }
    on ServerException catch (e){
      return left(Failure(e.message));
    }
  }

//// This function is used to get all the blogs from the database. It returns a list of Blog objects.
  @override
  Future<Either<Failure, List<Blog>>> getAllBlogs() async {
    try{
      /// access to blogRepoDS & call getAll Blog func 
      final blogs = await blogRemoteDataSource.getAllBlogs();
      return right(blogs);
      
    }
    on ServerException catch (e){
      return left(Failure(e.message));
    }
 
  }
}