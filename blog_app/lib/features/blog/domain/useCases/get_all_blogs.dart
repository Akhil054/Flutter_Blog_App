import 'package:blog_app/core/usecase/usecase.dart';
import 'package:blog_app/error/failures.dart';
import 'package:blog_app/features/blog/domain/entites/blog.dart';
import 'package:blog_app/features/blog/domain/repository/blog_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetAllBlogs implements UseCase<List<Blog>, NoParams> {
   final BlogRepository blogrepository;

   GetAllBlogs(this.blogrepository);

   @override
   Future<Either<Failure, List<Blog>>> call(NoParams params) async {
     return await blogrepository.getAllBlogs();
   }

 }