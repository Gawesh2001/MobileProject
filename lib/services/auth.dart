// ignore_for_file: avoid_print

import 'package:gofinder/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthServices {
  // Firebase instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Create a UserModel from Firebase User object
  UserModel? _userWithFirebaseUserUid(User? user) {
    return user != null ? UserModel(uid: user.uid) : null;
  }

  // Stream for authentication state changes
  Stream<UserModel?> get user {
    return _auth.authStateChanges().map(_userWithFirebaseUserUid);
  }

  // Sign in anonymously
  Future<User?> signInAnonymouse() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User? user = result.user;
      return user; // Return the actual User object
    } catch (err) {
      print("Error during anonymous sign-in: ${err.toString()}");
      return null;
    }
  }

  Future<void> resetPassword(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  // Sign in with email and password
  Future<UserModel?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      return _userWithFirebaseUserUid(user); // Return the UserModel
    } catch (err) {
      String errorMessage = "An error occurred during sign-in.";
      if (err is FirebaseAuthException) {
        switch (err.code) {
          case 'user-not-found':
            errorMessage = 'No user found for that email.';
            break;
          case 'wrong-password':
            errorMessage = 'Incorrect password.';
            break;
          case 'invalid-email':
            errorMessage = 'The email address is invalid.';
            break;
          default:
            errorMessage = err.message ?? 'Unknown error occurred.';
        }
      }
      print("Error during sign-in: $errorMessage");
      return null; // Return null if sign-in fails
    }
  }

  // Register with email and password
  Future<UserModel?> registerWithEmailAndPassword(
      String email, String password, String fullName) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      return _userWithFirebaseUserUid(user); // Return the UserModel
    } catch (err) {
      String errorMessage = "An error occurred during registration.";
      if (err is FirebaseAuthException) {
        switch (err.code) {
          case 'weak-password':
            errorMessage = 'The password provided is too weak.';
            break;
          case 'email-already-in-use':
            errorMessage =
                'The email is already in use. Please use another email.';
            break;
          case 'invalid-email':
            errorMessage = 'The email address is invalid.';
            break;
          default:
            errorMessage = err.message ?? 'Unknown error occurred.';
        }
      }
      print("Error during registration: $errorMessage");
      return null; // Return null if registration fails
    }
  }

  // Sign in with Google
  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User cancelled the sign-in

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      User? user = result.user;

      return _userWithFirebaseUserUid(user); // Return the UserModel
    } catch (err) {
      print("Error during Google sign-in: ${err.toString()}");
      return null;
    }
  }

  // Sign out method
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (err) {
      print("Error during sign out: ${err.toString()}");
      return;
    }
  }
}
