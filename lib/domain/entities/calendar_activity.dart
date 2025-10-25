import 'package:equatable/equatable.dart';

enum CalendarType { personal, professional }

enum ActivityStatus { pending, accepted, declined }

class CalendarActivity extends Equatable {
  const CalendarActivity({
    required this.id,
    required this.userId,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.type,
    this.invitedUserIds = const [],
    this.location,
    this.status = ActivityStatus.pending,
  });

  final String id;
  final String userId;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final CalendarType type;
  final List<String> invitedUserIds;
  final String? location;
  final ActivityStatus status;

  CalendarActivity copyWith({
    String? id,
    String? userId,
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    CalendarType? type,
    List<String>? invitedUserIds,
    String? location,
    ActivityStatus? status,
  }) {
    return CalendarActivity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      type: type ?? this.type,
      invitedUserIds: invitedUserIds ?? this.invitedUserIds,
      location: location ?? this.location,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    title,
    startTime,
    endTime,
    type,
    invitedUserIds,
    location,
    status,
  ];
}
