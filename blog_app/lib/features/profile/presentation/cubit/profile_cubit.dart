import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blog/domain/entites/blog.dart';
import '../../../blog/domain/useCases/get_user_blogs.dart';

part 'profile_state.dart';

/// Small page-scoped cubit for the Profile page - the only thing it needs
/// beyond what AppUserCubit already holds (name, email) is the list of
/// blogs the current user has posted; the count shown on the page is just
/// that list's length, so there's no separate count query to keep in sync.
class ProfileCubit extends Cubit<ProfileState> {
  final GetUserBlogs _getUserBlogs;

  ProfileCubit({required GetUserBlogs getUserBlogs})
      : _getUserBlogs = getUserBlogs,
        super(ProfileInitial());

  Future<void> loadUserBlogs(String posterId) async {
    emit(ProfileLoading());
    final res = await _getUserBlogs(posterId);
    res.fold(
      (failure) => emit(ProfileError(failure.message)),
      (blogs) => emit(ProfileLoaded(blogs)),
    );
  }
}
