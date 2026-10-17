import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/notification_cubit.dart';
import '../pages/notifications_page.dart';

/// App bar bell with an unread-count badge; opens the notifications list.
class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context) {
    final unread = context.select<NotificationCubit, int>(
      (cubit) => cubit.state.unreadCount,
    );

    return IconButton(
      tooltip: 'Notifications',
      onPressed: () => Navigator.push(context, NotificationsPage.route()),
      icon: Badge(
        isLabelVisible: unread > 0,
        label: Text(unread > 99 ? '99+' : '$unread'),
        child: Icon(
          unread > 0 ? Icons.notifications : Icons.notifications_none,
        ),
      ),
    );
  }
}
