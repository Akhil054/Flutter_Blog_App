import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/common/Widgets/loader.dart';
import '../../../../core/common/Widgets/show_snakbar.dart';
import '../../domain/entities/app_notification.dart';
import '../cubit/notification_cubit.dart';
import '../open_notification_blog.dart';

class NotificationsPage extends StatelessWidget {
  static Route<void> route() =>
      MaterialPageRoute(builder: (context) => const NotificationsPage());

  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          BlocSelector<NotificationCubit, NotificationState, int>(
            selector: (state) => state.unreadCount,
            builder: (context, unread) => TextButton(
              onPressed: unread == 0
                  ? null
                  : () => context.read<NotificationCubit>().markAllAsRead(),
              child: const Text('Mark all read'),
            ),
          ),
        ],
      ),
      body: BlocConsumer<NotificationCubit, NotificationState>(
        listenWhen: (previous, current) =>
            current.error != null && previous.error != current.error,
        listener: (context, state) => showSnackBar(context, state.error!),
        builder: (context, state) {
          if (state.isLoading && state.notifications.isEmpty) {
            return const Loader();
          }

          final cubit = context.read<NotificationCubit>();

          if (state.notifications.isEmpty) {
            return RefreshIndicator(
              onRefresh: cubit.load,
              child: ListView(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.35),
                  const Center(child: Text('No notifications yet.')),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: cubit.load,
            child: ListView.separated(
              itemCount: state.notifications.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notification = state.notifications[index];
                return _NotificationTile(
                  notification: notification,
                  onTap: () {
                    cubit.markAsRead(notification.id);
                    final blogId = notification.blogId;
                    if (blogId != null) openNotificationBlog(context, blogId);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const _NotificationTile({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLike = notification.type == NotificationType.like;

    return ListTile(
      onTap: onTap,
      tileColor: notification.isRead
          ? null
          : colorScheme.primary.withValues(alpha: 0.08),
      leading: CircleAvatar(
        backgroundColor: isLike
            ? Colors.redAccent.withValues(alpha: 0.15)
            : colorScheme.primary.withValues(alpha: 0.15),
        child: Icon(
          isLike ? Icons.favorite : Icons.article_outlined,
          color: isLike ? Colors.redAccent : colorScheme.primary,
        ),
      ),
      title: Text(
        notification.title,
        style: TextStyle(
          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      subtitle: Text(
        [
          if (notification.body.isNotEmpty) '"${notification.body}"',
          _timeAgo(notification.createdAt),
        ].join(' · '),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: notification.isRead
          ? null
          : Icon(Icons.circle, size: 10, color: colorScheme.primary),
    );
  }

  static String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${time.day}/${time.month}/${time.year}';
  }
}
