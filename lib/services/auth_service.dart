import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http; // For fetching IP address
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For storing user details

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch the user's IP address
  Future<String> _getIpAddress() async {
    try {
      final response =
          await http.get(Uri.parse('https://api64.ipify.org?format=json'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['ip'] ?? 'Unknown IP';
      }
      return 'Unknown IP';
    } catch (e) {
      return 'Unknown IP';
    }
  }

  // Log user activity to Firestore
  Future<void> _logUserActivity({
    required String userId,
    required String email,
    required String action,
    required String description,
  }) async {
    final ipAddress = await _getIpAddress();
    final now = DateTime.now();
    final date = '${now.year}-${now.month}-${now.day}';
    final time = '${now.hour}:${now.minute}';

    await _firestore.collection('userActivities').doc(userId).set({
      'userId': userId,
      'email': email,
      'ipAddress': ipAddress,
      'date': date,
      'time': time,
      'action': action,
      'description': description,
    }, SetOptions(merge: true));
  }

  // Sign up with email and password
  Future<String?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      // Send email verification
      await user?.sendEmailVerification();

      // Update user profile with name
      await user?.updateDisplayName(name);

      // Log user activity as Online
      if (user != null) {
        await _logUserActivity(
          userId: user.uid,
          email: email,
          action: 'Online',
          description: 'User signed up and is now online.',
        );
      }

      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'The account already exists for that email.';
      }
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // Sign in with email and password
  Future<String?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null && !user.emailVerified) {
        await _auth.signOut();
        return 'Please verify your email first.';
      }

      // Log user activity as Online
      if (user != null) {
        await _logUserActivity(
          userId: user.uid,
          email: email,
          action: 'Online',
          description: 'User signed in and is now online.',
        );
      }

      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided.';
      }
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> signOut() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _logUserActivity(
          userId: user.uid,
          email: user.email ?? 'Unknown Email',
          action: 'Offline',
          description: 'User signed out and is now offline.',
        );
      }

      await _auth.signOut();
    } catch (e) {
      log('Error signing out: $e');
    }
  }
}
