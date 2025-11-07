import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_role.dart';
import 'user_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();

  // Hardcoded admin email
  static const String adminEmail = 'admin@inventory.com';

  // Current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with email and password
  Future<UserCredential> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No user found with this email');
      } else if (e.code == 'wrong-password') {
        throw Exception('Incorrect password');
      } else if (e.code == 'invalid-email') {
        throw Exception('Invalid email address');
      } else if (e.code == 'user-disabled') {
        throw Exception('This account has been disabled');
      } else {
        throw Exception('Login failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  // Sign up with email and password
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      // Create Firebase Auth account
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Update display name
      await credential.user?.updateDisplayName(displayName);

      // Determine role: admin if email matches, otherwise viewer
      final role = email.trim() == adminEmail ? UserRole.admin : UserRole.viewer;

      // Create user profile in Firestore
      await _userService.createUserProfile(
        userId: credential.user!.uid,
        email: email.trim(),
        displayName: displayName,
        role: role,
      );

      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception('Password is too weak (minimum 6 characters)');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('An account already exists with this email');
      } else if (e.code == 'invalid-email') {
        throw Exception('Invalid email address');
      } else {
        throw Exception('Sign up failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get user role
  Future<UserRole> getUserRole() async {
    final user = currentUser;
    if (user == null) return UserRole.viewer;

    // Check if admin by email
    if (user.email == adminEmail) {
      return UserRole.admin;
    }

    // Get role from Firestore
    return await _userService.getUserRole(user.uid);
  }

  // Get display name
  Future<String> getDisplayName() async {
    final user = currentUser;
    if (user == null) return 'Guest';

    // Try to get from Firebase Auth first
    if (user.displayName != null && user.displayName!.isNotEmpty) {
      return user.displayName!;
    }

    // Otherwise get from Firestore
    return await _userService.getDisplayName(user.uid);
  }

  // Check if current user is admin
  Future<bool> isAdmin() async {
    final role = await getUserRole();
    return role == UserRole.admin;
  }

  // Get admin credentials for display
  static String getAdminEmail() => adminEmail;
  static String getAdminPasswordHint() => 'Use your admin password';
}