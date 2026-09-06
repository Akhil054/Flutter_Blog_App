import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/common/cubits/app_user/app_user_cubit.dart';
import '../../../../core/common/Widgets/show_snakbar.dart';
import '../../../../core/common/entites/user.dart';
import '../../../../init_depdencies.dart';
import '../../../../theme/pallete.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../blog/presentation/widgets/blog_summary_tile.dart';
import '../cubit/profile_cubit.dart';

class ProfilePage extends StatelessWidget {
  /// created an static route so this page can be reached with a plain
  /// Navigator.push, same pattern as the rest of the app's pages
  static Route<void> route() => MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (_) => serviceLocator<ProfileCubit>(),
          child: const ProfilePage(),
        ),
      );

  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userState = context.watch<AppUserCubit>().state;

    /// Logging out flips AppUserCubit to logged-out while this page is
    /// still the active route (it was pushed on top of BlogPage), which
    /// would otherwise leave the guard below showing a blank body forever.
    /// Pop back here so the app underneath - already swapped to LoginPage -
    /// becomes visible. This has to wrap both branches below, not just the
    /// logged-in one, since it's the AppUserLoggedIn->AppUserInitial flip
    /// itself that puts us in the blank-body branch.
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial) {
          Navigator.pop(context);
        }
      },
      child: userState is! AppUserLoggedIn
          ? const Scaffold(body: SizedBox.shrink())
          : _buildProfile(context, userState.user),
    );
  }

  Widget _buildProfile(BuildContext context, User user) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileError) {
            showSnackBar(context, state.message);
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 12),
                CircleAvatar(
                  radius: 48,
                  backgroundColor: AppPalette.gradient1,
                  child: Text(
                    _initialsOf(user.name.isNotEmpty ? user.name : user.email),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppPalette.whiteColor,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  user.name.isNotEmpty ? user.name : 'Unnamed user',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppPalette.greyColor,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                _BlogsPostedCard(state: state, posterId: user.id),
                const SizedBox(height: 32),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Your blogs',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(height: 8),
                _YourBlogsSection(state: state, posterId: user.id),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppPalette.errorColor,
                      side: const BorderSide(color: AppPalette.errorColor),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      context.read<AuthBloc>().add(AuthLogOut());
                    },
                    icon: const Icon(Icons.logout_outlined),
                    label: const Text('Logout'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _initialsOf(String source) {
    final trimmed = source.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed[0].toUpperCase();
  }
}

class _BlogsPostedCard extends StatefulWidget {
  final ProfileState state;
  final String posterId;

  const _BlogsPostedCard({required this.state, required this.posterId});

  @override
  State<_BlogsPostedCard> createState() => _BlogsPostedCardState();
}

class _BlogsPostedCardState extends State<_BlogsPostedCard> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().loadUserBlogs(widget.posterId);
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final isLoading = state is ProfileInitial || state is ProfileLoading;
    final count = state is ProfileLoaded ? state.blogsCount : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppPalette.borderColor
              : AppPalette.lightBorderColor,
        ),
      ),
      child: Column(
        children: [
          isLoading
              ? const SizedBox(
                  height: 28,
                  width: 28,
                  child: CircularProgressIndicator(strokeWidth: 3),
                )
              : Text(
                  '${count ?? 0}',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
          const SizedBox(height: 6),
          const Text('Blogs posted'),
        ],
      ),
    );
  }
}

/// The list of blogs the current user has posted, each shown via the
/// compact [BlogSummaryTile] (title + like count only - no image/author,
/// since the author is always this same user here).
class _YourBlogsSection extends StatelessWidget {
  final ProfileState state;
  final String posterId;

  const _YourBlogsSection({required this.state, required this.posterId});

  @override
  Widget build(BuildContext context) {
    if (state is ProfileInitial || state is ProfileLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
        ),
      );
    }

    if (state is! ProfileLoaded) return const SizedBox.shrink();

    final blogs = (state as ProfileLoaded).blogs;
    if (blogs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text("You haven't posted any blogs yet."),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < blogs.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          BlogSummaryTile(
            blog: blogs[i],
            onChanged: () => context.read<ProfileCubit>().loadUserBlogs(posterId),
          ),
        ],
      ],
    );
  }
}
