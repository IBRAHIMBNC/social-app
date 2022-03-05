import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:soical_app_pro/models/users.dart';

GoogleSignIn googleSignIn = GoogleSignIn();

final usersRef = FirebaseFirestore.instance.collection('users');

class Auth with ChangeNotifier {
  AppUser? currentUser;

  Future<bool> loginWithGoogle() async {
    GoogleSignInAccount? response = await googleSignIn.signIn();

    if (response != null) {
      DocumentSnapshot userData = await usersRef.doc(response.id).get();
      if (!userData.exists) {
        await usersRef.doc(response.id).set({
          'isAdmin': false,
          'isStudentOrg': false,
          'userId': response.id,
          'photoUrl': response.photoUrl,
          'name': response.displayName,
          'email': response.email,
          'bio': '',
          'timeStamp': DateTime.now().toIso8601String()
        });
        userData = await usersRef.doc(response.id).get();
      }
      currentUser = AppUser.toDocument(userData);
      return true;
    }

    return false;
  }

  Future<bool> autoLogin() async {
    final GoogleSignInAccount? response = await googleSignIn.signInSilently();
    if (response != null) {
      DocumentSnapshot doc = await usersRef.doc(response.id).get();
      currentUser = AppUser.toDocument(doc);
      return true;
    } else {
      final auth = FirebaseAuth.instance;
      if (auth.currentUser != null) {
        String id = FirebaseAuth.instance.currentUser!.uid;
        final userData = await usersRef.doc(id).get();

        currentUser = AppUser.toDocument(userData);
        return true;
      }

      return false;
    }
  }
}
