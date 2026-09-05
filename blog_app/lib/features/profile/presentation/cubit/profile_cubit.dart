import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blog/domain/useCases/get_user_blogs_count.dart';

part 'profile_state.dart';

/// Small page-scoped cubit for the Profile page - the only thing it needs
/// beyond what AppUserCubit already holds (name, email) is how many blogs
/// the current user has posted.
class ProfileCubit extends Cubit<ProfileState> {
  final GetUserBlogsCount _getUserBlogsCount;

  ProfileCubit({required GetUserBlogsCount getUserBlogsCount})
      : _getUserBlogsCount = getUserBlogsCount,
        super(ProfileInitial());

  Future<void> loadBlogsCount(String posterId) async {
    emit(ProfileLoading());
    final res = await _getUserBlogsCount(GetUserBlogsCountParams(posterId: posterId));
    res.fold(
      (failure) => emit(ProfileError(failure.message)),
      (count) => emit(ProfileLoaded(count)),
    );
  }
}
