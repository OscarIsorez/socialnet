import '../../domain/entities/event.dart';
import '../../domain/entities/location_point.dart';

class EventModel extends Event {
  const EventModel({
    required super.id,
    required super.creatorId,
    required super.title,
    required super.description,
    required super.category,
    required super.subCategory,
    required LocationPoint location,
    super.photoUrl,
    super.startTime,
    super.endTime,
    super.isActive,
    super.verificationCount,
    required super.createdAt,
  }) : super(location: location);

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String,
      creatorId: json['creatorId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: EventCategory.values.firstWhere(
        (value) => value.name == json['category'],
      ),
      subCategory: EventSubCategory.values.firstWhere(
        (value) => value.name == json['subCategory'],
      ),
      location: LocationPoint(
        latitude: (json['location']['lat'] as num).toDouble(),
        longitude: (json['location']['lng'] as num).toDouble(),
      ),
      photoUrl: json['photoUrl'] as String?,
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String)
          : null,
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? true,
      verificationCount: json['verificationCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  factory EventModel.fromEntity(Event event) {
    return EventModel(
      id: event.id,
      creatorId: event.creatorId,
      title: event.title,
      description: event.description,
      category: event.category,
      subCategory: event.subCategory,
      location: event.location,
      photoUrl: event.photoUrl,
      startTime: event.startTime,
      endTime: event.endTime,
      isActive: event.isActive,
      verificationCount: event.verificationCount,
      createdAt: event.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creatorId': creatorId,
      'title': title,
      'description': description,
      'category': category.name,
      'subCategory': subCategory.name,
      'location': {'lat': location.latitude, 'lng': location.longitude},
      'photoUrl': photoUrl,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'isActive': isActive,
      'verificationCount': verificationCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  EventModel copyWith({
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
    return EventModel(
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
}
