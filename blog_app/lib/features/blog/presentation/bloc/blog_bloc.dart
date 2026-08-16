import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entites/blog.dart';
import '../../domain/useCases/get_all_blogs.dart';
import '../../domain/useCases/upload_blog.dart';
part 'blog_event.dart';
part 'blog_state.dart';

class BlogBloc extends Bloc<BlogEvent, BlogState> {
  final UploadBlog uploadBlog;
  final GetAllBlogs getAllBlogs;

  BlogBloc({
    required this.uploadBlog,
    required this.getAllBlogs,
  }) : super(BlogInitial()) {
    on<BlogEvent>((_, emit) => emit(BlogLoading()));
    on<BlogUpload>(_onBlogUpload);
    on<BlogFetchAllBlogs>(_onFetchAllBlogs);
  }

  void _onBlogUpload(BlogUpload event, Emitter<BlogState> emit) async {
    final res = await uploadBlog(UploadBlogParams(
        posterId: event.posterId,
        title: event.title,
        content: event.content,
        image: event.image,
        topics: event.topics
    ),
    );
    res.fold(
          (l) => emit(BlogFailure(l.message)),
          (r) => emit(BlogSuccess(),
          ),
    );
  }

  void _onFetchAllBlogs(BlogFetchAllBlogs event, Emitter<BlogState> emit) async {
    final res = await getAllBlogs(NoParams());
    res.fold(
          (l) => emit(BlogFailure(l.message)),
          (r) => emit(BlogDisplaySuccess(r)),
    );
  }
}
