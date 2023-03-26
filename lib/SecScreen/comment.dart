import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';

import '../Services/database.dart';
import 'bannerads.dart';

class Comment extends StatefulWidget {
  final String movieUid;
  final String userName;
  final String profileUid;
  final String title;
  final String profileUrl;
  const Comment(
      {super.key,
      required this.movieUid,
      required this.userName,
      required this.profileUid,
      required this.title,
      required this.profileUrl});

  @override
  State<Comment> createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  double rating = 1;
  String userUid = FirebaseAuth.instance.currentUser!.uid;
  final uuid = const Uuid();
  final TextEditingController comment = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    _focusNode.requestFocus();
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  String getRatingString() {
    return '$rating';
  }

  Future<void> toast() async {
    Fluttertoast.showToast(
      msg: 'Done!! refresh to see change',
      gravity: ToastGravity.TOP,
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: Colors.transparent,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection("movies")
            .doc('Model')
            .snapshots()
            .take(1),
        builder: (context, snapshot) {
          final suggestComment = snapshot.data?["suggestedComment"];
          suggestComment?.shuffle();
          if (!snapshot.hasData) {
            return const Text(
              'error',
              style: TextStyle(color: Colors.white, fontSize: 16.0),
            );
          }
          return GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0.0,
                  centerTitle: true,
                  iconTheme: const IconThemeData(
                    color: Colors.white,
                  ),
                  systemOverlayStyle: const SystemUiOverlayStyle(
                      statusBarColor: Colors.transparent,
                      statusBarIconBrightness: Brightness.light,
                      statusBarBrightness: Brightness.dark),
                ),
                backgroundColor: Colors.black87,
                body: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                     const SizedBox(
                        width: 300,
                        height: 100,
                        child: AdScreen(
                          nameOrigin: 'Home',
                        )),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                      child: TextFormField(
                        style: const TextStyle(color: Colors.white),
                        focusNode: _focusNode,
                        controller: comment,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(80),
                        ],
                        decoration: const InputDecoration(
                            errorStyle: TextStyle(color: Colors.grey),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                            hintText: 'Your though?',
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 15)),
                      ),
                    ),
                    Center(
                      child: ElevatedButton(
                        onPressed: () => {
                          if (comment.text.length <6)
                            Fluttertoast.showToast(
      msg: 'Too short',
      gravity: ToastGravity.TOP,
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: Colors.transparent,
      textColor: Colors.white,
    )
                          else
                            {
                             
                              toast(),
                              Navigator.pop(context),
                              DataBase()
                                  .addComment(
                                      userUid,
                                      comment.text,
                                      widget.userName,
                                      widget.profileUid,
                                      widget.movieUid,
                                      uuid.v1(),
                                      widget.title,
                                      widget.profileUrl)
                                  .then((value) => comment.clear())
                            }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.transparent,
                          elevation: 0.0,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        child: const Text('Send'),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    const Center(
                        child: Text(
                      'Suggested',
                      style: TextStyle(color: Colors.white),
                    )),
                    const SizedBox(
                      height: 15,
                    ),
                    ListView.builder(
                        reverse: true,
                        physics: const BouncingScrollPhysics(),
                        itemCount: 5,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 5.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: ElevatedButton(
                                    onPressed: () =>
                                        {comment.text = suggestComment[index]},
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.black,
                                      backgroundColor: Colors.blue[300],
                                      elevation: 0.0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: Text(
                                      suggestComment[index],
                                      style: const TextStyle(
                                          fontSize: 11, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                    const SizedBox(
                      height: 10,
                    ),
                    IconButton(
                        color: Colors.white,
                        tooltip: 'Reload',
                        icon: const Icon(Icons.replay_outlined),
                        iconSize: 25,
                        onPressed: () => setState(() {})),
               
                  ],
                )),
          );
        });
  }
}
