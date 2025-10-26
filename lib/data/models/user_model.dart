import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.profileName,
    super.photoUrl,
    super.isPublic,
    super.interests,
    super.friendIds,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      profileName: json['profileName'] as String,
      photoUrl: json['photoUrl'] as String?,
      isPublic: json['isPublic'] as bool? ?? true,
      interests: (json['interests'] as List<dynamic>? ?? const [])
          .cast<String>(),
      friendIds: (json['friendIds'] as List<dynamic>? ?? const [])
          .cast<String>(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      profileName: user.profileName,
      photoUrl: user.photoUrl,
      isPublic: user.isPublic,
      interests: List<String>.from(user.interests),
      friendIds: List<String>.from(user.friendIds),
      createdAt: user.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'profileName': profileName,
      'photoUrl': photoUrl,
      'isPublic': isPublic,
      'interests': interests,
      'friendIds': friendIds,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? profileName,
    String? photoUrl,
    bool? isPublic,
    List<String>? interests,
    List<String>? friendIds,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      profileName: profileName ?? this.profileName,
      photoUrl: photoUrl ?? this.photoUrl,
      isPublic: isPublic ?? this.isPublic,
      interests: interests ?? List<String>.from(this.interests),
      friendIds: friendIds ?? List<String>.from(this.friendIds),
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
