import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/error/exceptions.dart';
import '../../models/user_model.dart';
import 'auth_remote_datasource.dart';

class FirebaseAuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  bool _isGoogleSignInInitialized = false;

  FirebaseAuthRemoteDataSourceImpl({
    required FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
  }) : _firebaseAuth = firebaseAuth,
       _googleSignIn = googleSignIn;

  /// Initialize Google Sign-In (required for v7+)
  Future<void> _initializeGoogleSignIn() async {
    if (!_isGoogleSignInInitialized) {
      try {
        await _googleSignIn.initialize();
        _isGoogleSignInInitialized = true;
      } catch (e) {
        throw AuthException(message: 'Failed to initialize Google Sign-In: $e');
      }
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

      return _mapFirebaseUserToUserModel(user, profileName: profileName);
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

      // Refresh user info to get latest data
      await user.reload();
      final refreshedUser = _firebaseAuth.currentUser;

      return refreshedUser != null
          ? _mapFirebaseUserToUserModel(refreshedUser)
          : null;
    } catch (e) {
      // Return null if there's any error getting current user
      return null;
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
      // Trigger the authentication flow using v7 API
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate(
        scopeHint: ['email', 'profile'],
      );

      // Get authorization for Firebase scopes
      final authClient = _googleSignIn.authorizationClient;
      final authorization = await authClient.authorizationForScopes(['email']);

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: authorization?.accessToken,
        idToken: googleUser.authentication.idToken,
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

      return _mapFirebaseUserToUserModel(user);
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
