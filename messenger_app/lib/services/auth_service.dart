import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  // Check if user is logged in
  Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('user_token');
    return token != null && _auth.currentUser != null;
  }

  // Sign in with email and password
  Future<bool> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      User? user = result.user;
      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_token', user.uid);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Sign in error: $e');
      return false;
    }
  }

  // Register with email and password
  Future<bool> signUp(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      User? user = result.user;
      if (user != null) {
        // Send email verification
        await user.sendEmailVerification();
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_token', user.uid);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Sign up error: $e');
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_token');
      notifyListeners();
    } catch (e) {
      print('Sign out error: $e');
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      print('Password reset error: $e');
      return false;
    }
  }
}