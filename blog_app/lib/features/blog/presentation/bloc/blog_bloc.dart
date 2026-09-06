import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import '../../domain/entites/blog.dart';
import '../../domain/useCases/delete_blog.dart';
import '../../domain/useCases/get_all_blogs.dart';
import '../../domain/useCases/toggle_like_blog.dart';
import '../../domain/useCases/update_blog.dart';
import '../../domain/useCases/upload_blog.dart';
part 'blog_event.dart';
part 'blog_state.dart';

class BlogBloc extends Bloc<BlogEvent, BlogState> {
  final UploadBlog uploadBlog;
  final GetAllBlogs getAllBlogs;
  final ToggleLikeBlog toggleLikeBlog;
  final UpdateBlog updateBlog;
  final DeleteBlog deleteBlog;

  static const int pageLimit = 10;
  int _page = 0;

  BlogBloc({
    required this.uploadBlog,
    required this.getAllBlogs,
    required this.toggleLikeBlog,
    required this.updateBlog,
    required this.deleteBlog,
  }) : super(BlogInitial()) {
    on<BlogUpload>(_onBlogUpload);
    on<BlogFetchAllBlogs>(_onFetchAllBlogs);
    on<BlogFetchMoreBlogs>(_onFetchMoreBlogs);
    on<BlogToggleLike>(_onToggleLike);
    on<BlogUpdate>(_onBlogUpdate);
    on<BlogDelete>(_onBlogDelete);
  }

  void _onBlogUpload(BlogUpload event, Emitter<BlogState> emit) async {
    emit(BlogLoading());
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
    /// only show the full-page loader on a cold load; a pull-to-refresh
    /// keeps the existing list on screen while RefreshIndicator shows its own spinner
    if (state is! BlogDisplaySuccess) {
      emit(BlogLoading());
    }

    _page = 0;
    final res = await getAllBlogs(GetAllBlogsParams(page: _page, limit: pageLimit));
    res.fold(
          (l) => emit(BlogFailure(l.message)),
          (r) => emit(BlogDisplaySuccess(r, hasReachedMax: r.length < pageLimit)),
    );
  }

  void _onFetchMoreBlogs(BlogFetchMoreBlogs event, Emitter<BlogState> emit) async {
    final current = state;
    if (current is! BlogDisplaySuccess || current.hasReachedMax || current.isLoadingMore) {
      return;
    }

    emit(BlogDisplaySuccess(current.blogs, isLoadingMore: true));

    final nextPage = _page + 1;
    final res = await getAllBlogs(GetAllBlogsParams(page: nextPage, limit: pageLimit));
    res.fold(
          (l) => emit(BlogFailure(l.message)),
          (r) {
            _page = nextPage;
            emit(BlogDisplaySuccess(
              [...current.blogs, ...r],
              hasReachedMax: r.length < pageLimit,
            ));
          },
    );
  }

  void _onToggleLike(BlogToggleLike event, Emitter<BlogState> emit) async {
    final current = state;
    if (current is! BlogDisplaySuccess) return;

    /// optimistic update so the tap feels instant; reverted below on failure
    final optimisticBlogs = current.blogs.map((blog) {
      if (blog.id != event.blogId) return blog;
      return blog.copyWith(
        isLiked: !blog.isLiked,
        likesCount: blog.isLiked ? blog.likesCount - 1 : blog.likesCount + 1,
      );
    }).toList();

    emit(BlogDisplaySuccess(optimisticBlogs, hasReachedMax: current.hasReachedMax));

    final res = await toggleLikeBlog(event.blogId);
    res.fold(
          (l) => emit(BlogDisplaySuccess(current.blogs, hasReachedMax: current.hasReachedMax)),
          (_) {},
    );
  }

  void _onBlogUpdate(BlogUpdate event, Emitter<BlogState> emit) async {
    emit(BlogLoading());
    final res = await updateBlog(UpdateBlogParams(
      blogId: event.blogId,
      title: event.title,
      content: event.content,
      topics: event.topics,
      newImage: event.newImage,
    ));
    res.fold(
          (l) => emit(BlogFailure(l.message)),
          (updated) => emit(BlogUpdateSuccess(updated)),
    );
  }

  void _onBlogDelete(BlogDelete event, Emitter<BlogState> emit) async {
    emit(BlogLoading());
    final res = await deleteBlog(event.blogId);
    res.fold(
          (l) => emit(BlogFailure(l.message)),
          (_) => emit(BlogDeleteSuccess()),
    );
  }
}
