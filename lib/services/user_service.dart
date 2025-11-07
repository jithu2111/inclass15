import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_role.dart';

class UserService {
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');

  // Create user profile in Firestore
  Future<void> createUserProfile({
    required String userId,
    required String email,
    required String displayName,
    required UserRole role,
  }) async {
    try {
      await _usersCollection.doc(userId).set({
        'email': email,
        'displayName': displayName,
        'role': role.name, // 'admin' or 'viewer'
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to create user profile: $e');
    }
  }

  // Get user role from Firestore
  Future<UserRole> getUserRole(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();

      if (!doc.exists) {
        // Default to viewer if profile doesn't exist
        return UserRole.viewer;
      }

      final data = doc.data() as Map<String, dynamic>;
      final roleString = data['role'] as String?;

      if (roleString == 'admin') {
        return UserRole.admin;
      } else {
        return UserRole.viewer;
      }
    } catch (e) {
      // Default to viewer on error
      return UserRole.viewer;
    }
  }

  // Check if user profile exists
  Future<bool> userProfileExists(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // Get user display name
  Future<String> getDisplayName(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data['displayName'] as String? ?? 'User';
      }
      return 'User';
    } catch (e) {
      return 'User';
    }
  }

  // Optional: Update user role (for future admin panel)
  Future<void> updateUserRole(String userId, UserRole role) async {
    try {
      await _usersCollection.doc(userId).update({
        'role': role.name,
      });
    } catch (e) {
      throw Exception('Failed to update user role: $e');
    }
  }
}