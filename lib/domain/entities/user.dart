import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.email,
    required this.profileName,
    this.photoUrl,
    this.isPublic = true,
    this.interests = const [],
    this.friendIds = const [],
    required this.createdAt,
  });

  final String id;
  final String email;
  final String profileName;
  final String? photoUrl;
  final bool isPublic;
  final List<String> interests;
  final List<String> friendIds;
  final DateTime createdAt;

  User copyWith({
    String? id,
    String? email,
    String? profileName,
    String? photoUrl,
    bool? isPublic,
    List<String>? interests,
    List<String>? friendIds,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      profileName: profileName ?? this.profileName,
      photoUrl: photoUrl ?? this.photoUrl,
      isPublic: isPublic ?? this.isPublic,
      interests: interests ?? this.interests,
      friendIds: friendIds ?? this.friendIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    email,
    profileName,
    photoUrl,
    isPublic,
    interests,
    friendIds,
    createdAt,
  ];
}
