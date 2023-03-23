import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String uid;
  String email;
  String fullName;
  String admin;
  String downloadUrl;
  String accountCreated;
  List<String> favMovies;
  List<String> comment;
  String profileUrl;

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.profileUrl,
    required this.admin,
    required this.comment,
    required this.downloadUrl,
    required this.accountCreated,
    required this.favMovies,
  });

  /*  UserModel.fromDocumentSnapshot({required DocumentSnapshot doc})
      : uid = doc.id,
        email = (doc.data() as Map<String, dynamic>)["email"],
        accountCreated = (doc.data() as Map<String, dynamic>)["accountCreated"],
        fullName = (doc.data() as Map<String, dynamic>)["fullName"],
        groupId = (doc.data() as Map<String, dynamic>)["groupId"],
        provider = (doc.data() as Map<String, dynamic>)["provider"],
        groupLeader = (doc.data() as Map<String, dynamic>)["groupLeader"],
        groupName = (doc.data() as Map<String, dynamic>)["groupName"]; */

  factory UserModel.fromDocumentSnapshot({required DocumentSnapshot doc}) {
    return UserModel(
      uid: doc.id,
      email: (doc.data() as Map<String, dynamic>)["email"],
      fullName: (doc.data() as Map<String, dynamic>)["fullName"],
      admin: (doc.data() as Map<String, dynamic>)["admin"],
      downloadUrl: (doc.data() as Map<String, dynamic>)["downloadUrl"],
      accountCreated: (doc.data() as Map<String, dynamic>)["accountCreated"],
      profileUrl: (doc.data() as Map<String, dynamic>)["profileUrl"],
       comment: (doc.data() as Map<String, dynamic>)["comment"],
      favMovies: (doc.data() as Map<String, dynamic>)["favMovies"],
    );
  }
}