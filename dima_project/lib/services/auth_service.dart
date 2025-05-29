import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/database_service.dart';

class AuthService {
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static String? _uid;
  static String get uid => _uid ?? '';

  static void setUid(String uid) {
    _uid = uid;
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    debugPrint("Trying to Login...");
    await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);

    setUid(_firebaseAuth.currentUser!.uid);
    debugPrint("Signed In with uuid: ${_firebaseAuth.currentUser!.uid}");
    return;
  }

  Future<void> signOut() async {
    try {
      return await _firebaseAuth.signOut();
    } catch (e) {
      debugPrint("Error Signing Out: $e");
    }
  }

  Future<User?> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    if (googleAuth != null) {
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      setUid(_firebaseAuth.currentUser!.uid);

      return userCredential.user;
    } else {
      return null;
    }
  }

  Future<void> registerUser(UserData user, Uint8List imagePath) async {
    // Register the user
    UserCredential userCredential =
        await _firebaseAuth.createUserWithEmailAndPassword(
            email: user.email, password: user.password!);

    debugPrint('User Registered: ${userCredential.user!.uid}');
    await DatabaseService()
        .registerUserWithUUID(user, userCredential.user!.uid, imagePath);
  }

  Future<void> deleteUser() {
    return _firebaseAuth.currentUser!.delete();
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<bool> reauthenticateUser(String email, String password) {
    final User user = _firebaseAuth.currentUser!;
    final AuthCredential credential =
        EmailAuthProvider.credential(email: email, password: password);

    return user.reauthenticateWithCredential(credential).then((value) {
      return true;
    }).catchError((error) {
      return false;
    });
  }

  Future<bool> reauthenticateUserWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      if (googleAuth != null) {
        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken,
        );
        await _firebaseAuth.currentUser!
            .reauthenticateWithCredential(credential);

        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
