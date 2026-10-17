import 'package:flutter/material.dart';

import '../../../core/common/Widgets/show_snakbar.dart';
import '../../../init_depdencies.dart';
import '../../blog/domain/useCases/get_blog_by_id.dart';
import '../../blog/presentation/pages/blog_detailPage.dart';

/// Loads the blog a notification points at and opens its detail page.
/// Shared by the notifications list and by tapping a system notification.
Future<void> openNotificationBlog(BuildContext context, String blogId) async {
  final res = await serviceLocator<GetBlogById>()(blogId);
  if (!context.mounted) return;

  res.fold(
    (failure) => showSnackBar(context, failure.message),
    (blog) => Navigator.push(context, BlogDetailpage.route(blog)),
  );
}
