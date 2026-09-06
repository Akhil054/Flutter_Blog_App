import 'dart:io';

import 'package:fpdart/fpdart.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../error/failures.dart';
import '../entites/blog.dart';
import '../repository/blog_repository.dart';

class UpdateBlog implements UseCase<Blog, UpdateBlogParams> {
  final BlogRepository blogRepository;
  UpdateBlog(this.blogRepository);

  @override
  Future<Either<Failure, Blog>> call(UpdateBlogParams params) async {
    return await blogRepository.updateBlog(
      blogId: params.blogId,
      title: params.title,
      content: params.content,
      topics: params.topics,
      newImage: params.newImage,
    );
  }
}

class UpdateBlogParams {
  final String blogId;
  final String title;
  final String content;
  final List<String> topics;
  final File? newImage;

  UpdateBlogParams({
    required this.blogId,
    required this.title,
    required this.content,
    required this.topics,
    this.newImage,
  });
}
