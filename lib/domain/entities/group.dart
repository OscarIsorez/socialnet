import 'package:equatable/equatable.dart';

class Group extends Equatable {
  const Group({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.creatorId,
    required this.memberIds,
    required this.createdAt,
    this.isPublic = false,
  });

  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final String creatorId;
  final List<String> memberIds;
  final DateTime createdAt;
  final bool isPublic;

  Group copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? creatorId,
    List<String>? memberIds,
    DateTime? createdAt,
    bool? isPublic,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      creatorId: creatorId ?? this.creatorId,
      memberIds: memberIds ?? this.memberIds,
      createdAt: createdAt ?? this.createdAt,
      isPublic: isPublic ?? this.isPublic,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    imageUrl,
    creatorId,
    memberIds,
    createdAt,
    isPublic,
  ];
}
