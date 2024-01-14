import 'dart:typed_data';
import 'package:uuid/uuid.dart';
import 'package:uuid/v1.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_flutter/models/post.dart';
import 'package:instagram_flutter/resources/storage_methods.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //upload post
  Future<String> uploadPost(
    String caption,
    Uint8List file,
    String uid,
    String username,
    String profileImage,
  ) async {
    String res = "Some eroor occured";
    try {
      String photoUrl =
          await StorageMethods().uploadImageToStorage('posts', file, true);

      String postId = const Uuid().v1();

      Post post = Post(
        caption: caption,
        uid: uid,
        username: username,
        postId: postId,
        datePublished: DateTime.now(),
        postUrl: photoUrl,
        profileImage: profileImage,
        likes: [],
      );

      _firestore.collection('posts').doc(postId).set(
            post.toJson(),
          );

      res = 'success';
      return res;
    } catch (err) {
      res = err.toString();
      return res;
    }
  }
}
