// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rate_raters/services/database.dart';

class MyComment extends StatefulWidget {
  const MyComment({super.key});

  @override
  State<MyComment> createState() => _MyCommentState();
}

class _MyCommentState extends State<MyComment> {
  String userUid = FirebaseAuth.instance.currentUser!.uid;
  final FirebaseStorage storage = FirebaseStorage.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  TextEditingController comment = TextEditingController();
  List list5 = ['1', '2', '3', '4'];


  Future<void> toast() async {
    Fluttertoast.showToast(
      msg: 'Your comment has been updated',
      gravity: ToastGravity.TOP,
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: Colors.transparent,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(userUid)
            .snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
      var commentUid = snapshot.data?['comment'];
          if (!snapshot.hasData) {
            return Container();
          }
          return Scaffold(
            backgroundColor: Colors.grey[850],
            body: ListView.builder(
                reverse: false,
                physics: const BouncingScrollPhysics(),
                itemCount: commentUid?.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("usersComment")
                          .doc(commentUid[index])
                          .snapshots(),
                      builder:
                          (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                        var name = snapshot.data?.get('name');
                        var comment = snapshot.data?.get('comment');
                        var movieName = snapshot.data?.get('movie');
                        var profile = snapshot.data?.get('profile');
                        var movieUid = snapshot.data?.get('movieUid');
                        var movieProfile = snapshot.data?.get('movieProfile');
                        final vote = snapshot.data?['vote']??list5;
                        final countVote = vote?.length;
                        if (!snapshot.hasData) {
                          return Container();
                        }
                        return Stack(
                          children: [
                            FutureBuilder(
                                future: downloadURL(profile),
                                builder: (BuildContext context,
                                    AsyncSnapshot<String> snapshot) {
                                  if (snapshot.connectionState ==
                                          ConnectionState.done &&
                                      snapshot.hasData) {
                                    return Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () => openDialog(
                                            movieUid,
                                            commentUid[index],
                                          ),
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                  12.0, //Left
                                                  10.0, //top
                                                  0.0, //right
                                                  10.0, //bottom
                                                ),
                                                child: SizedBox(
                                                  height: 60,
                                                  width: 60,
                                                  child: FittedBox(
                                                    fit: BoxFit.contain,
                                                    child: CircleAvatar(
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      backgroundImage:
                                                          NetworkImage(
                                                              snapshot.data!),
                                                      radius: 10.0,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 15.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      width: 300,
                                                      child: Text(
                                                        '$name  ($movieName)',
                                                        style: const TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 11),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    SizedBox(
                                                      width: 250,
                                                      child: Text(
                                                        comment,
                                                        style: const TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: 15),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Text(
                                                      'Vote: $countVote',
                                                      style: const TextStyle(
                                                          fontSize: 10,
                                                          color: Colors.white),
                                                    ),
                                                    const SizedBox(
                                                      height: 15,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 15,
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                  if (snapshot.connectionState ==
                                          ConnectionState.waiting ||
                                      snapshot.hasData) {
                                    return Container();
                                  }
                                  return Container();
                                }),
                            //movie Profile
                            FutureBuilder(
                                future: downloadURL1(movieProfile),
                                builder: (BuildContext context,
                                    AsyncSnapshot<String> snapshot) {
                                  if (snapshot.connectionState ==
                                          ConnectionState.done &&
                                      snapshot.hasData) {
                                    return Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        30.0, //Left
                                        30.0, //top
                                        0.0, //right
                                        10.0, //bottom
                                      ),
                                      child: SizedBox(
                                        height: 47,
                                        width: 47,
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: CircleAvatar(
                                            backgroundColor: Colors.transparent,
                                            backgroundImage:
                                                NetworkImage(snapshot.data!),
                                            radius: 10.0,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  if (snapshot.connectionState ==
                                          ConnectionState.waiting ||
                                      snapshot.hasData) {
                                    return Container();
                                  }
                                  return Container();
                                }),
                          ],
                        );
                      });
                }),
          );
        });
  }

  Future openDialog(movieUid, commentUid) => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            actions: [
              OutlinedButton(
                onPressed: () => {
                  Navigator.pop(context),
                  DataBase().deleteComment(movieUid, commentUid)
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(width: 5.0, color: Colors.transparent),
                ),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red, fontSize: 16.0),
                ),
              ),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(width: 5.0, color: Colors.transparent),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey, fontSize: 16.0),
                ),
              ),
            ],
          ));

  Future<String> downloadURL1(String file) async {
    try {
      String downloadURL =
          await storage.ref('movieimages/$file').getDownloadURL();
      print(downloadURL);
      return downloadURL;
    } on FirebaseException catch (e) {
      print(e);
    }
    return downloadURL(file);
  }

  Future<String> downloadURL(String imageName) async {
    try {
      String downloadURL =
          await storage.ref('images/$imageName').getDownloadURL();

      print(downloadURL);
      return downloadURL;
    } on FirebaseException catch (e) {
      print(e);
    }
    return downloadURL(imageName);
  }
}
