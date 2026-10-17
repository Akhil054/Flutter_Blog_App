import '../../domain/entities/app_notification.dart';

/// converts a `notifications` table row into an [AppNotification]
class AppNotificationModel extends AppNotification {
  AppNotificationModel({
    required super.id,
    required super.type,
    required super.title,
    required super.body,
    required super.isRead,
    required super.createdAt,
    super.blogId,
    super.actorId,
  });

  factory AppNotificationModel.fromJson(Map<String, dynamic> map) {
    return AppNotificationModel(
      id: map['id'] as String? ?? '',
      type: map['type'] == 'like' ? NotificationType.like : NotificationType.newBlog,
      blogId: map['blog_id'] as String?,
      actorId: map['actor_id'] as String?,
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      isRead: map['is_read'] as bool? ?? false,
      createdAt: map['created_at'] == null
          ? DateTime.now()
          : DateTime.parse(map['created_at'] as String).toLocal(),
    );
  }
}
