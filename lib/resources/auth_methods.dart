import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:instagram_flutter/resources/storage_methods.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
        await _firestore.collection("users").doc(cred.user!.uid).set({
          "username": username,
          "uid": cred.user!.uid,
          "email": email,
          "password": password,
          "bio": bio,
          "followers": [],
          "following": [],
          'photoUrl': photoUrl,
        });

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
      }else {
        res = e.toString();
      }
    } catch (e) {
      res = e.toString();
    }
    return res;
  }
}
