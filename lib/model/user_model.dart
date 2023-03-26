import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String uid;
  String email;
  String fullName;
  String admin;
  String accountCreated;
  List<String> favMovies;
  List<String> comment;
  List<String> addedMovies;
  String profileUrl;
  String string1;
  String string2;
  String string3;
  String string4;
  String string5;
  List<String> list1;
  List<String> list2;
  List<String> list3;
  List<String> list4;
  List<String> list5;





  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.profileUrl,
    required this.admin,
    required this.comment,
    required this.addedMovies,
    required this.accountCreated,
    required this.favMovies,
    required this.string1,
    required this.string2,
    required this.string3,
    required this.string4,
    required this.string5,
    required this.list1,
    required this.list2,
    required this.list3,
    required this.list4,
    required this.list5,


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
      accountCreated: (doc.data() as Map<String, dynamic>)["accountCreated"],
      profileUrl: (doc.data() as Map<String, dynamic>)["profileUrl"],
      comment: (doc.data() as Map<String, dynamic>)["comment"],
      addedMovies: (doc.data() as Map<String, dynamic>)["addedMovies"],
      favMovies: (doc.data() as Map<String, dynamic>)["favMovies"],
      string1: (doc.data() as Map<String, dynamic>)["string1"],
      string2: (doc.data() as Map<String, dynamic>)["string2"],
      string3: (doc.data() as Map<String, dynamic>)["string3"],
      string4: (doc.data() as Map<String, dynamic>)["string4"],
      string5: (doc.data() as Map<String, dynamic>)["string5"],
      list1: (doc.data() as Map<String, dynamic>)["list1"],
      list2: (doc.data() as Map<String, dynamic>)["list2"],
      list3: (doc.data() as Map<String, dynamic>)["list3"],
      list4: (doc.data() as Map<String, dynamic>)["list4"],
      list5: (doc.data() as Map<String, dynamic>)["list5"],


    );
  }
}