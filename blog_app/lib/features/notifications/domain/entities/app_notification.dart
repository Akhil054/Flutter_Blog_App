enum NotificationType {
  /// someone liked one of your blogs
  like,

  /// someone posted a new blog
  newBlog,
}

/// One entry in the user's notification list - written server-side by the
/// database triggers on blog_likes / blogs inserts.
class AppNotification {
  final String id;
  final NotificationType type;
  final String? blogId;
  final String? actorId;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
    this.blogId,
    this.actorId,
  });

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      type: type,
      blogId: blogId,
      actorId: actorId,
      title: title,
      body: body,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}
