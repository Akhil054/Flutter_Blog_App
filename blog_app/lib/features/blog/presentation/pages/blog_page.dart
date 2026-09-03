import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/common/Widgets/loader.dart';
import '../../../../core/common/Widgets/show_snakbar.dart';
import '../../../../core/common/cubits/theme/theme_cubit.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../domain/entites/blog.dart';
import '../bloc/blog_bloc.dart';
import '../widgets/blog_card.dart';
import '../widgets/searchBar.dart';
import 'add_new_blog.dart';

class BlogPage extends StatefulWidget {
  ///created an static route will be using in add new bloc page
  static route() => MaterialPageRoute(builder: (context) => const BlogPage());

  const BlogPage({super.key});

  @override
  State<BlogPage> createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  /// current text typed into the search bar, used to filter the fetched blogs
  String searchQuery = '';

  /// last known-good list of blogs; kept around so a transient error (e.g. a
  /// failed like or a failed pull-to-refresh) doesn't blank the whole page
  List<Blog> _blogs = [];
  bool _hasReachedMax = false;

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    /// fetch all blogs as soon as this page is shown
    context.read<BlogBloc>().add(BlogFetchAllBlogs());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// loads the next page once the user nears the bottom of the list;
  /// skipped while a search filter is active since search only covers
  /// blogs already loaded in memory
  void _onScroll() {
    if (_hasReachedMax || searchQuery.trim().isNotEmpty) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      context.read<BlogBloc>().add(BlogFetchMoreBlogs());
    }
  }

  Future<void> _onRefresh() async {
    context.read<BlogBloc>().add(BlogFetchAllBlogs());
    await context.read<BlogBloc>().stream.firstWhere(
          (state) => state is BlogDisplaySuccess || state is BlogFailure,
        );
  }

  /// keeps blogs whose title, content, author or topics contain the query,
  /// case-insensitively, so a single letter or a full word both work
  List<Blog> _filterBlogs(List<Blog> blogs) {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) return blogs;

    return blogs.where((blog) {
      return blog.title.toLowerCase().contains(query) ||
          blog.content.toLowerCase().contains(query) ||
          blog.author.toLowerCase().contains(query) ||
          blog.topics.any((topic) => topic.toLowerCase().contains(query));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: const Text('Blog App'),
        actions:[
          IconButton(
            onPressed:() {
              Navigator.push(context, AddNewBlog.route());
            },
            icon: const Icon(CupertinoIcons.add_circled),
          ),
          IconButton(
            icon: Icon(
              context.watch<ThemeCubit>().state == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () => context.read<ThemeCubit>().toggleTheme(),
          ),
          IconButton(
            onPressed:(){
              Navigator.push(context, LoginPage.route());
            },
            icon: const Icon(Icons.logout_outlined),
          ),
        ],
      ),

      body: Column(
        children: [
          BlogSearchBar(
            onChanged: (query) => setState(() => searchQuery = query),
          ),
          Expanded(
            child: BlocConsumer<BlogBloc, BlogState>(
              listener: (context, state) {
                if (state is BlogFailure) {
                  showSnackBar(context, state.error);
                }
                if (state is BlogDisplaySuccess) {
                  setState(() {
                    _blogs = state.blogs;
                    _hasReachedMax = state.hasReachedMax;
                  });
                }
              },
              builder: (context, state) {
                if (state is BlogLoading && _blogs.isEmpty) {
                  return const Loader();
                }

                final blogs = _filterBlogs(_blogs);
                final isLoadingMore = state is BlogDisplaySuccess && state.isLoadingMore;

                if (blogs.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: ListView(
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.35),
                        Center(
                          child: Text(
                            _blogs.isEmpty
                                ? 'No blogs yet.'
                                : 'No blogs match "$searchQuery".',
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: blogs.length + (isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= blogs.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final blog = blogs[index];
                      final colors = [
                        Colors.deepPurple,
                        Colors.indigo,
                        Colors.teal,
                      ];
                      return BlogCard(
                        blog: blog,
                        color: colors[index % colors.length],
                        onLikeTap: () => context
                            .read<BlogBloc>()
                            .add(BlogToggleLike(blogId: blog.id)),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
