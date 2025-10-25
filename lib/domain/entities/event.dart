import 'package:equatable/equatable.dart';

import 'location_point.dart';

enum EventCategory { music, sports, social, problem, other }

enum EventSubCategory {
  rock,
  rap,
  jazz,
  football,
  basketball,
  waterLeak,
  meetup,
  general,
}

class Event extends Equatable {
  const Event({
    required this.id,
    required this.creatorId,
    required this.title,
    required this.description,
    required this.category,
    required this.subCategory,
    required this.location,
    this.photoUrl,
    this.startTime,
    this.endTime,
    this.isActive = true,
    this.verificationCount = 0,
    required this.createdAt,
  });

  final String id;
  final String creatorId;
  final String title;
  final String description;
  final EventCategory category;
  final EventSubCategory subCategory;
  final LocationPoint location;
  final String? photoUrl;
  final DateTime? startTime;
  final DateTime? endTime;
  final bool isActive;
  final int verificationCount;
  final DateTime createdAt;

  Event copyWith({
    String? id,
    String? creatorId,
    String? title,
    String? description,
    EventCategory? category,
    EventSubCategory? subCategory,
    LocationPoint? location,
    String? photoUrl,
    DateTime? startTime,
    DateTime? endTime,
    bool? isActive,
    int? verificationCount,
    DateTime? createdAt,
  }) {
    return Event(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      location: location ?? this.location,
      photoUrl: photoUrl ?? this.photoUrl,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isActive: isActive ?? this.isActive,
      verificationCount: verificationCount ?? this.verificationCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    creatorId,
    title,
    description,
    category,
    subCategory,
    location,
    photoUrl,
    startTime,
    endTime,
    isActive,
    verificationCount,
    createdAt,
  ];
}
