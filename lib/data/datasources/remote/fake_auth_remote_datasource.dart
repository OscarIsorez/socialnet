import 'dart:async';

import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../models/user_model.dart';
import 'auth_remote_datasource.dart';

class FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  FakeAuthRemoteDataSource() {
    final demoUser = UserModel(
      id: _uuid.v4(),
      email: 'demo@redemton.com',
      profileName: 'Demo Explorer',
      photoUrl: null,
      isPublic: true,
      interests: const ['music', 'sports'],
      friendIds: const ['user456'],
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    );

    _users[demoUser.email.toLowerCase()] = _FakeUserRecord(
      user: demoUser,
      password: 'password123',
    );
  }

  final Map<String, _FakeUserRecord> _users = <String, _FakeUserRecord>{};
  final Uuid _uuid = const Uuid();
  String? _currentUserEmail;

  @override
  Future<UserModel> signIn(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));

    final record = _users[email.trim().toLowerCase()];
    if (record == null || record.password != password) {
      throw const AuthException(message: 'Invalid credentials');
    }

    _currentUserEmail = record.user.email.toLowerCase();
    return record.user;
  }

  @override
  Future<UserModel> signUp(
    String email,
    String password,
    String profileName,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 550));

    final key = email.trim().toLowerCase();
    if (_users.containsKey(key)) {
      throw ValidationException('An account already exists for $key');
    }

    if (password.length < AppConstants.passwordMinLength) {
      throw ValidationException(
        'Password must be at least ${AppConstants.passwordMinLength} characters',
      );
    }

    final user = UserModel(
      id: _uuid.v4(),
      email: key,
      profileName: profileName.trim(),
      photoUrl: null,
      isPublic: true,
      interests: const [],
      friendIds: const [],
      createdAt: DateTime.now(),
    );

    _users[key] = _FakeUserRecord(user: user, password: password);
    _currentUserEmail = key;
    return user;
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _currentUserEmail = null;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final key = _currentUserEmail;
    if (key == null) {
      return null;
    }
    return _users[key]?.user;
  }
}

class _FakeUserRecord {
  _FakeUserRecord({required this.user, required this.password});

  final UserModel user;
  final String password;
}
