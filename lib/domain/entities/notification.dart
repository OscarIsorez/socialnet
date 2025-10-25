import 'package:equatable/equatable.dart';

enum NotificationType { friendRequest, message, eventUpdate, activityInvite }

class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.content,
    this.data = const <String, dynamic>{},
    this.isRead = false,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final NotificationType type;
  final String content;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime createdAt;

  AppNotification copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? content,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      content: content ?? this.content,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    type,
    content,
    data,
    isRead,
    createdAt,
  ];
}
