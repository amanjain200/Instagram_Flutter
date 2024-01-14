import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:instagram_flutter/models/user.dart' as model;
import 'package:instagram_flutter/resources/storage_methods.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //get current user
  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;
    DocumentSnapshot documentSnapshot =
        await _firestore.collection("users").doc(currentUser.uid).get();

    return model.User.fromSnap(documentSnapshot);
  }

  //sign up user
  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    required String bio,
    required Uint8List file,
  }) async {
    String res = "Some eroor occured";
    try {
      if (email.isNotEmpty &&
          password.isNotEmpty &&
          username.isNotEmpty &&
          bio.isNotEmpty) {
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        print(cred.user!.uid);

        String photoUrl = await StorageMethods()
            .uploadImageToStorage("profile_pic", file, false);

        //add user to our firebase database
        model.User user = model.User(
          email: email,
          uid: cred.user!.uid,
          photoUrl: photoUrl,
          username: username,
          bio: bio,
          followers: [],
          following: [],
        );

        await _firestore
            .collection("users")
            .doc(cred.user!.uid)
            .set(user.toJson());

        res = "success";
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        res = 'The email address is not valid';
      } else if (e.code == 'weak-password') {
        res = 'The password is too weak';
      } else if (e.code == 'email-already-in-use') {
        res = 'The account already exists for that email';
      }
      res = e.toString();
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

//logging in user
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some eroor occured";
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        UserCredential cred = await _auth.signInWithEmailAndPassword(
            email: email, password: password);

        print(cred.user!.uid);

        res = "success";
      } else {
        res = "Please enter email and password";
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        res = 'The email address is not valid';
      } else if (e.code == 'wrong-password') {
        res = 'The password is incorrect';
      } else if (e.code == 'user-not-found') {
        res = 'No user found for that email';
      } else {
        res = e.toString();
      }
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  //adding the post
  Future<String> addPost({
    required String caption,
    required Uint8List file,
  }) async {
    String res = 'Some Error Occured';

    try {
      if (caption.isNotEmpty && file != null) {
        String photoUrl =
            await StorageMethods().uploadImageToStorage('post_pic', file, true);

        res = "success";
      }
    } catch (e) {
      res = e.toString();
    }

    return res;
  }
}
