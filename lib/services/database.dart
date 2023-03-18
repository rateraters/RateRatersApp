import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../model/user_model.dart';

class DataBase {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;
  final userUid = FirebaseAuth.instance.currentUser!.uid;

//Create user to FB backend
  Future<String> createUser(UserModel user) async {
    List<String> list = [];
    String retVal = "error";
    try {
      await firestore.collection("users").doc(user.uid).set({
        'accountCreated': Timestamp.now(),
        'email': user.email,
        'fullName': user.fullName,
        'admin': '',
        'downloadUrl': '',
        'profileUrl': 'profil.png',
        'favMovies': list,
        'comment': list,
        user.uid: '',
      });
      retVal;
      "success";
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
    return retVal;
  }

//Add movie to FB backend
  Future<String> addMovie(title, profileUrl, path, addedBy, uuid) async {
    String retVal = "error";
    List<String> list = [];
    File file = File(path);
    try {
      await firestore.collection("movies").doc(uuid).set({
        'title': title,
        'profile': profileUrl,
        uuid: '',
        'id': uuid,
        'upvote': list,
        'usersComment': list,
        'usersName': list,
        'usersProfile': list,
        '1Stars': list,
        '2Stars': list,
        '3Stars': list,
        '4Stars': list,
        '5Stars': list,
        'addedBy': addedBy,
      });
      await firestore.collection("movies").doc('Model').update({
        'listMovies': FieldValue.arrayUnion([uuid])
      });
      await storage.ref('movieimages/$profileUrl').putFile(file);
      retVal;
      "success";
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
    return retVal;
  }

  //Add comment
  Future<String> addComment(
    String userUid,
    String comment,
    String userName,
    String profileUid,
    String movieUid,
    String uuid,
    String movieName,
    String movieProfile,
  ) async {
    List<String> list = [];
    String retVal = "error";
    try {
      await firestore.collection("usersComment").doc(uuid).set({
        'name': userName,
        'profile': profileUid,
        'comment': comment,
        'vote': list,
        'movieProfile': movieProfile,
        'movie': movieName,
        
        'movieUid': movieUid,
      });

      ///
      await firestore.collection("movies").doc(movieUid).update({
        'usersComment': FieldValue.arrayUnion([uuid])
      });

      ///
      await firestore.collection("users").doc(userUid).update({
        'comment': FieldValue.arrayUnion([uuid])
      });
    } on FirebaseException catch (e) {
      // ignore: avoid_print
      print(e);
    }
    return retVal;
  }

  //Delete My Comment
  Future<String> deleteComment(
    String movieUid,
    String commentUid,
  ) async {
    String retVal = "error";
    try {
      await firestore.collection("movies").doc(movieUid).update({
        'usersComment': FieldValue.arrayRemove([commentUid])
      });
      await firestore.collection("users").doc(userUid).update({
        'comment': FieldValue.arrayRemove([commentUid])
      });
      await firestore.collection("usersComment").doc(commentUid).delete();
    } on FirebaseException catch (e) {
      // ignore: avoid_print
      print(e);
    }
    return retVal;
  }

  //Change profile picture
  Future<String> uploadImage(
    String path,
    String fileName,
  ) async {
    File file = File(path);
    String retVal = "error";
    try {
      await firestore.collection("users").doc(userUid).update({
        'profileUrl': fileName,
      });
      await storage.ref('images/$fileName').putFile(file);
    } on FirebaseException catch (e) {
      // ignore: avoid_print
      print(e);
    }
    return retVal;
  }

  //RateStars
  Future<String> rateStars(
    String movieUid,
    String stars,
  ) async {
    String retVal = "error";
    try {
      if (stars == '1.0') {
         await firestore.collection("movies").doc(movieUid).update({
        '1Stars': FieldValue.arrayUnion([userUid])
      });
      } else {
        if (stars == '2.0') {
         await firestore.collection("movies").doc(movieUid).update({
        '2Stars': FieldValue.arrayUnion([userUid])
      });
        } else {
          if (stars == '3.0') {
           await firestore.collection("movies").doc(movieUid).update({
        '3Stars': FieldValue.arrayUnion([userUid])
      });
          } else {
            if (stars == '4.0') {
              await firestore.collection("movies").doc(movieUid).update({
        '4Stars': FieldValue.arrayUnion([userUid])
      });
            } else {
              if (stars == '5.0') {
              await firestore.collection("movies").doc(movieUid).update({
        '5Stars': FieldValue.arrayUnion([userUid])
      });
              }
            }
          }
        }
      }
    } on FirebaseException catch (e) {
      // ignore: avoid_print
      print(e);
    }
    return retVal;
  }
}
