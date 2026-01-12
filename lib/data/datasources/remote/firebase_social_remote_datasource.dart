import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/error/exceptions.dart';
import '../../models/user_model.dart';
import 'social_remote_datasource.dart';

class FirebaseSocialRemoteDataSource implements SocialRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  FirebaseSocialRemoteDataSource({
    required FirebaseFirestore firestore,
    required FirebaseAuth firebaseAuth,
  }) : _firestore = firestore,
       _firebaseAuth = firebaseAuth;

  @override
  Future<UserModel> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (!doc.exists) {
        throw const NotFoundException('User not found');
      }

      final data = doc.data()!;
      return UserModel.fromJson({'id': doc.id, ...data});
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to get user profile: ${e.message}',
      );
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw ServerException(message: 'An unexpected error occurred: $e');
    }
  }

  @override
  Future<UserModel> updateProfile(UserModel user) async {
    try {
      // Only allow updating own profile
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw const AuthException(message: 'User not authenticated');
      }

      if (currentUser.uid != user.id) {
        throw const AuthException(
          message: 'Cannot update another user\'s profile',
        );
      }

      final userDoc = _firestore.collection('users').doc(user.id);

      // Convert UserModel to Map for Firestore, excluding the id field
      final userData = user.toJson();
      userData.remove('id'); // Don't store ID in document data

      await userDoc.update(userData);

      // Return updated user by fetching from Firestore
      return await getUserProfile(user.id);
    } on FirebaseException catch (e) {
      throw ServerException(message: 'Failed to update profile: ${e.message}');
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException(message: 'An unexpected error occurred: $e');
    }
  }

  @override
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      if (query.trim().isEmpty) return [];

      // Firebase doesn't support full-text search, so we'll search by profile name
      // In a real app, you might want to use Algolia or similar for better search
      final snapshot = await _firestore
          .collection('users')
          .where('isPublic', isEqualTo: true)
          .orderBy('profileName')
          .startAt([query])
          .endAt(['$query\uf8ff'])
          .limit(20)
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(message: 'Failed to search users: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'An unexpected error occurred: $e');
    }
  }

  @override
  Future<void> sendFriendRequest(String fromUserId, String toUserId) async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null || currentUser.uid != fromUserId) {
        throw const AuthException(message: 'User not authenticated');
      }

      // Check if request already exists
      final existingRequest = await _firestore
          .collection('friend_requests')
          .where('fromUserId', isEqualTo: fromUserId)
          .where('toUserId', isEqualTo: toUserId)
          .get();

      if (existingRequest.docs.isNotEmpty) {
        throw const ValidationException('Friend request already sent');
      }

      // Create friend request
      await _firestore.collection('friend_requests').add({
        'fromUserId': fromUserId,
        'toUserId': toUserId,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to send friend request: ${e.message}',
      );
    } catch (e) {
      if (e is AuthException || e is ValidationException) rethrow;
      throw ServerException(message: 'An unexpected error occurred: $e');
    }
  }

  @override
  Future<void> respondToFriendRequest(String requestId, String status) async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw const AuthException(message: 'User not authenticated');
      }

      // Get the friend request
      final requestDoc = await _firestore
          .collection('friend_requests')
          .doc(requestId)
          .get();

      if (!requestDoc.exists) {
        throw const NotFoundException('Friend request not found');
      }

      final requestData = requestDoc.data()!;

      // Verify current user is the recipient
      if (requestData['toUserId'] != currentUser.uid) {
        throw const AuthException(
          message: 'Cannot respond to this friend request',
        );
      }

      // Update request status
      await requestDoc.reference.update({
        'status': status,
        'respondedAt': FieldValue.serverTimestamp(),
      });

      // If accepted, add to friends lists
      if (status == 'accepted') {
        final fromUserId = requestData['fromUserId'] as String;
        final toUserId = requestData['toUserId'] as String;

        // Use batch write for consistency
        final batch = _firestore.batch();

        // Add to both users' friend lists
        final fromUserRef = _firestore.collection('users').doc(fromUserId);
        final toUserRef = _firestore.collection('users').doc(toUserId);

        batch.update(fromUserRef, {
          'friendIds': FieldValue.arrayUnion([toUserId]),
        });

        batch.update(toUserRef, {
          'friendIds': FieldValue.arrayUnion([fromUserId]),
        });

        await batch.commit();
      }
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to respond to friend request: ${e.message}',
      );
    } catch (e) {
      if (e is AuthException || e is NotFoundException) rethrow;
      throw ServerException(message: 'An unexpected error occurred: $e');
    }
  }

  @override
  Future<List<UserModel>> getFriends(String userId) async {
    try {
      // Get user document to get friend IDs
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        throw const NotFoundException('User not found');
      }

      final userData = userDoc.data()!;
      final friendIds = List<String>.from(userData['friendIds'] ?? []);

      if (friendIds.isEmpty) return [];

      // Firestore 'in' query limit is 10, so we might need to batch
      final List<UserModel> friends = [];

      for (int i = 0; i < friendIds.length; i += 10) {
        final batch = friendIds.skip(i).take(10).toList();

        final friendsQuery = await _firestore
            .collection('users')
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        final batchFriends = friendsQuery.docs
            .map((doc) => UserModel.fromJson({'id': doc.id, ...doc.data()}))
            .toList();

        friends.addAll(batchFriends);
      }

      return friends;
    } on FirebaseException catch (e) {
      throw ServerException(message: 'Failed to get friends: ${e.message}');
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw ServerException(message: 'An unexpected error occurred: $e');
    }
  }
}
