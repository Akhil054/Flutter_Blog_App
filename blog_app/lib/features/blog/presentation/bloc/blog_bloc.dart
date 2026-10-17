import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import '../../domain/entites/blog.dart';
import '../../domain/useCases/delete_blog.dart';
import '../../domain/useCases/get_all_blogs.dart';
import '../../domain/useCases/get_blog_by_id.dart';
import '../../domain/useCases/toggle_like_blog.dart';
import '../../domain/useCases/update_blog.dart';
import '../../domain/useCases/upload_blog.dart';
import '../../domain/useCases/watch_new_blogs.dart';
part 'blog_event.dart';
part 'blog_state.dart';

class BlogBloc extends Bloc<BlogEvent, BlogState> {
  final UploadBlog uploadBlog;
  final GetAllBlogs getAllBlogs;
  final ToggleLikeBlog toggleLikeBlog;
  final UpdateBlog updateBlog;
  final DeleteBlog deleteBlog;
  final GetBlogById getBlogById;
  final WatchNewBlogs watchNewBlogs;

  /// Realtime subscription for blogs other users post; restarted on every
  /// BlogWatchNewBlogs so a logout -> login doesn't leave two running
  StreamSubscription<String>? _newBlogsSubscription;

  static const int pageLimit = 10;
  int _page = 0;

  BlogBloc({
    required this.uploadBlog,
    required this.getAllBlogs,
    required this.toggleLikeBlog,
    required this.updateBlog,
    required this.deleteBlog,
    required this.getBlogById,
    required this.watchNewBlogs,
  }) : super(BlogInitial()) {
    on<BlogUpload>(_onBlogUpload);
    on<BlogFetchAllBlogs>(_onFetchAllBlogs);
    on<BlogFetchMoreBlogs>(_onFetchMoreBlogs);
    on<BlogToggleLike>(_onToggleLike);
    on<BlogUpdate>(_onBlogUpdate);
    on<BlogDelete>(_onBlogDelete);
    on<BlogWatchNewBlogs>(_onWatchNewBlogs);
    on<BlogNewBlogPosted>(_onNewBlogPosted);
  }

  @override
  Future<void> close() async {
    await _newBlogsSubscription?.cancel();
    return super.close();
  }

  void _onBlogUpload(BlogUpload event, Emitter<BlogState> emit) async {
    emit(BlogLoading());
    final res = await uploadBlog(UploadBlogParams(
        posterId: event.posterId,
        title: event.title,
        content: event.content,
        image: event.image,
        topics: event.topics,
        summary: event.summary,
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
            /// blogs prepended live (BlogNewBlogPosted) shift the server-side
            /// offsets, so the next page can repeat one we already have
            final knownIds = current.blogs.map((blog) => blog.id).toSet();
            emit(BlogDisplaySuccess(
              [...current.blogs, ...r.where((blog) => !knownIds.contains(blog.id))],
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

  Future<void> _onWatchNewBlogs(BlogWatchNewBlogs event, Emitter<BlogState> emit) async {
    await _newBlogsSubscription?.cancel();
    _newBlogsSubscription = watchNewBlogs().listen(
      (blogId) => add(BlogNewBlogPosted(blogId: blogId)),
    );
  }

  /// adds a blog someone just posted to the top of the feed, so the home
  /// page refreshes itself without a pull-to-refresh
  void _onNewBlogPosted(BlogNewBlogPosted event, Emitter<BlogState> emit) async {
    if (state is! BlogDisplaySuccess) return;
    final res = await getBlogById(event.blogId);

    /// re-read the state - it may have changed while the blog was loading
    final current = state;
    if (current is! BlogDisplaySuccess) return;
    res.fold(
          (_) {},
          (blog) {
            if (current.blogs.any((b) => b.id == blog.id)) return;
            emit(BlogDisplaySuccess(
              [blog, ...current.blogs],
              hasReachedMax: current.hasReachedMax,
              isLoadingMore: current.isLoadingMore,
            ));
          },
    );
  }
}
