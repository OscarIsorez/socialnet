import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/error/exceptions.dart';
import '../../models/user_model.dart';
import 'auth_remote_datasource.dart';

class FirebaseAuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;
  bool _isGoogleSignInInitialized = false;

  FirebaseAuthRemoteDataSourceImpl({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
    required GoogleSignIn googleSignIn,
  }) : _firebaseAuth = firebaseAuth,
       _firestore = firestore,
       _googleSignIn = googleSignIn;

  /// Initialize Google Sign-In (required for v7+)
  Future<void> _initializeGoogleSignIn() async {
    if (!_isGoogleSignInInitialized) {
      try {
        await _handleWebPlatform();
        await _googleSignIn.initialize();
        _isGoogleSignInInitialized = true;
      } catch (e) {
        throw AuthException(message: 'Failed to initialize Google Sign-In: $e');
      }
    }
  }

  /// Handle web platform specific requirements
  Future<void> _handleWebPlatform() async {
    if (kIsWeb) {
      // Web has different initialization requirements
      await _googleSignIn.initialize();
      // Note: Web platform may use different authentication flow
    }
  }

  @override
  Future<UserModel> signIn(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw const AuthException(message: 'User not found after sign in');
      }

      return _mapFirebaseUserToUserModel(user);
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: _mapFirebaseAuthErrorMessage(e));
    } catch (e) {
      throw AuthException(message: 'An unexpected error occurred: $e');
    }
  }

  @override
  Future<UserModel> signUp(
    String email,
    String password,
    String profileName,
  ) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw const AuthException(message: 'User not created');
      }

      // Update the user's display name
      await user.updateDisplayName(profileName);
      await user.reload();

      final userModel = _mapFirebaseUserToUserModel(
        user,
        profileName: profileName,
      );

      // Synchronize with Firestore
      await _syncUserWithFirestore(userModel);

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: _mapFirebaseAuthErrorMessage(e));
    } catch (e) {
      throw AuthException(message: 'An unexpected error occurred: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;

      // Try to get user from Firestore first
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        final data = userDoc.data()!;

        final jsonData = _convertFirestoreData({'id': userDoc.id, ...data});
        return UserModel.fromJson(jsonData);
      } else {
        // If not in Firestore, create from Firebase Auth and sync
        await user.reload();
        final refreshedUser = _firebaseAuth.currentUser;
        if (refreshedUser != null) {
          final userModel = _mapFirebaseUserToUserModel(refreshedUser);
          await _syncUserWithFirestore(userModel);
          return userModel;
        }
        return null;
      }
    } catch (e) {
      // Return null if there's any error getting current user
      return null;
    }
  }

  /// Synchronize user data with Firestore
  Future<void> _syncUserWithFirestore(UserModel user) async {
    try {
      final userDoc = _firestore.collection('users').doc(user.id);

      // Check if user already exists
      final existingDoc = await userDoc.get();

      if (existingDoc.exists) {
        // User exists, only update basic fields from auth
        await userDoc.update({
          'email': user.email,
          'profileName': user.profileName,
          'photoUrl': user.photoUrl,
          'lastLoginAt': FieldValue.serverTimestamp(),
        });
      } else {
        // New user, create full document
        final userData = user.toJson();
        userData.remove('id'); // Don't store ID in document data
        userData['createdAt'] = FieldValue.serverTimestamp();
        userData['lastLoginAt'] = FieldValue.serverTimestamp();

        await userDoc.set(userData);
      }
    } catch (e) {
      // Log error but don't throw - auth should succeed even if Firestore sync fails
      print('Warning: Failed to sync user with Firestore: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([_firebaseAuth.signOut(), _googleSignIn.signOut()]);
    } catch (e) {
      throw AuthException(message: 'Error signing out: $e');
    }
  }

  /// Sign in with Google
  @override
  Future<UserModel> signInWithGoogle() async {
    await _initializeGoogleSignIn();

    try {
      GoogleSignInAccount googleUser;

      if (kIsWeb || !_googleSignIn.supportsAuthenticate()) {
        // For web or platforms that don't support authenticate()
        // Try lightweight authentication first
        final result = _googleSignIn.attemptLightweightAuthentication();

        GoogleSignInAccount? account;
        if (result is Future<GoogleSignInAccount?>) {
          account = await result;
        } else {
          account = result as GoogleSignInAccount?;
        }

        if (account == null) {
          throw const AuthException(message: 'Google sign-in was cancelled');
        }
        googleUser = account;
      } else {
        // For mobile platforms that support authenticate()
        googleUser = await _googleSignIn.authenticate(
          scopeHint: ['email', 'profile'],
        );
      }

      // Get authentication details (synchronous in v7)
      final googleAuth = googleUser.authentication;

      // For v7, we need to get tokens from authorizationClient
      final authClient = _googleSignIn.authorizationClient;
      final authorization = await authClient.authorizationForScopes([
        'email',
        'profile',
      ]);

      // Create Firebase credential with tokens
      final credential = GoogleAuthProvider.credential(
        accessToken: authorization?.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential);

      final user = userCredential.user;
      if (user == null) {
        throw const AuthException(
          message: 'User not found after Google sign in',
        );
      }

      final userModel = _mapFirebaseUserToUserModel(user);

      // Synchronize with Firestore
      await _syncUserWithFirestore(userModel);

      return userModel;
    } on GoogleSignInException catch (e) {
      throw AuthException(
        message:
            'Google Sign-In error: ${e.code.name}${e.description != null ? ' - ${e.description}' : ''}',
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: _mapFirebaseAuthErrorMessage(e));
    } catch (e) {
      throw AuthException(
        message: 'An unexpected error occurred during Google sign in: $e',
      );
    }
  }

  /// Reset password
  @override
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: _mapFirebaseAuthErrorMessage(e));
    } catch (e) {
      throw AuthException(message: 'An unexpected error occurred: $e');
    }
  }

  /// Convert Firestore data types to JSON-compatible types
  Map<String, dynamic> _convertFirestoreData(Map<String, dynamic> data) {
    final converted = <String, dynamic>{};

    for (final entry in data.entries) {
      if (entry.value is Timestamp) {
        // Convert Firestore Timestamp to ISO 8601 string
        converted[entry.key] = (entry.value as Timestamp)
            .toDate()
            .toIso8601String();
      } else {
        converted[entry.key] = entry.value;
      }
    }

    return converted;
  }

  UserModel _mapFirebaseUserToUserModel(User user, {String? profileName}) {
    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      profileName: profileName ?? user.displayName ?? 'User',
      photoUrl: user.photoURL,
      isPublic: true, // Default to public, can be changed later
      interests: const [], // Will be loaded separately if needed
      friendIds: const [], // Will be loaded separately if needed
      createdAt: user.metadata.creationTime ?? DateTime.now(),
    );
  }

  String _mapFirebaseAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Aucun compte trouvé avec cette adresse email.';
      case 'wrong-password':
        return 'Mot de passe incorrect.';
      case 'email-already-in-use':
        return 'Un compte existe déjà avec cette adresse email.';
      case 'weak-password':
        return 'Le mot de passe est trop faible.';
      case 'invalid-email':
        return 'Adresse email invalide.';
      case 'user-disabled':
        return 'Ce compte a été désactivé.';
      case 'too-many-requests':
        return 'Trop de tentatives. Veuillez réessayer plus tard.';
      case 'operation-not-allowed':
        return 'Cette opération n\'est pas autorisée.';
      case 'invalid-credential':
        return 'Identifiants invalides.';
      default:
        return e.message ?? 'Une erreur d\'authentification est survenue.';
    }
  }
}
