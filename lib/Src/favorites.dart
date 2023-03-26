import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:page_transition/page_transition.dart';
import 'package:rate_raters/Src/reviews.dart';
import 'package:rate_raters/Src/search.dart';

import '../SecScreen/bannerads.dart';

class MyFavourite extends StatefulWidget {
  const MyFavourite({super.key});

  @override
  State<MyFavourite> createState() => _MyFavouriteState();
}

class _MyFavouriteState extends State<MyFavourite> {
  String userUid = FirebaseAuth.instance.currentUser!.uid;
  final FirebaseStorage storage = FirebaseStorage.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool? checkEmpty;

  Future<void> refreshList() async {
    await Future.delayed(const Duration(seconds: 1, milliseconds: 2));
  }

  Future<void> toast() async {
    Fluttertoast.showToast(
      msg: 'Movie has been removed',
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
            .collection("users")
            .doc(userUid)
            .snapshots()
            .take(1),
        builder: (context, snapshot) {
          var favMovies = snapshot.data?['favMovies'];
          snapshot.data?.data()?.forEach((key, value) {
            if (key == 'favMovies') {
              checkEmpty = value.length == 0;
            }
          });
          if (!snapshot.hasData) {
            return Container();
          }
          return GestureDetector(
            onHorizontalDragEnd: (DragEndDetails details) {
              if (details.primaryVelocity! > 0) {
                Navigator.pop(context);
              } else if (details.primaryVelocity! < 0) {}
            },
            child: Scaffold(
              appBar: AppBar(
                iconTheme: const IconThemeData(
                  color: Colors.white,
                ),
                systemOverlayStyle: SystemUiOverlayStyle(
                    statusBarColor: Colors.grey[850],
                    statusBarIconBrightness: Brightness.light,
                    statusBarBrightness: Brightness.light),
                backgroundColor: Colors.grey[850],
                title: const Text('My Favourites'),
                centerTitle: true,
                titleTextStyle: const TextStyle(
                  color: Colors.white,
                ),
                elevation: 0.0,
              ),
              backgroundColor: Colors.grey[850],
              body: RefreshIndicator(
                onRefresh: () => refreshList().then((value) => setState(() {})),
                child: ListView(
                  children: [
                    const SizedBox(
                        width: 300,
                        height: 100,
                        child: AdScreen(
                          nameOrigin: 'Profile',
                        )),
                    Column(
                      children: [
                        checkEmpty!
                            ? const Center(
                                child: Padding(
                                padding: EdgeInsets.only(bottom: 15.0),
                                child: Text(
                                  'ว่าง.',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ))
                            : GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisSpacing: 5.0,
                                        crossAxisCount: 2),
                                reverse: false,
                                physics: const BouncingScrollPhysics(),
                                itemCount: favMovies.length,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  return StreamBuilder(
                                      stream: FirebaseFirestore.instance
                                          .collection("movies")
                                          .doc(favMovies[index])
                                          .snapshots()
                                          .take(1),
                                      builder: (context,
                                          AsyncSnapshot<DocumentSnapshot>
                                              snapshot) {
                                        var file = snapshot.data?['profile'];
                                        var title = snapshot.data?['title'];
                                        if (snapshot.data == null) {
                                          return Container();
                                        }
                                        return LazyLoadScrollView(
                                          onEndOfPage: () {  },
                                          child: FutureBuilder(
                                              future: downloadURL(file),
                                              builder: (BuildContext context,
                                                  AsyncSnapshot<String>
                                                      snapshot) {
                                                if (snapshot.connectionState ==
                                                        ConnectionState.done &&
                                                    snapshot.hasData) {
                                                  return GestureDetector(
                                                    onLongPress: () => openDialog(
                                                        favMovies[index],
                                                        userUid),
                                                    onTap: () => {
                                                      Navigator.push(
                                                        context,
                                                        PageTransition(
                                                            type:
                                                                PageTransitionType
                                                                    .rightToLeft,
                                                            child: ReviewsScreen(
                                                              movieUid: favMovies[
                                                                  index],
                                                            )),
                                                      )
                                                    },
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        SizedBox(
                                                            width: 150,
                                                            height: 150,
                                                            child: Image.network(
                                                                snapshot.data!)),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  top: 10.0),
                                                          child: Center(
                                                            child: Text(
                                                              title,
                                                              style:
                                                                  const TextStyle(
                                                                      color: Colors
                                                                          .white),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
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
                                        );
                                      });
                                }),
                        Center(
                            child: GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.rightToLeft,
                                child: const SearchScreen()),
                          ),
                          child: const Text(
                            'ค้นหา',
                            style: TextStyle(fontSize: 15, color: Colors.white),
                          ),
                        ))
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

//Add to my favourite
  Future openDialog(movieUid, userUid) => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            backgroundColor: Colors.grey,
            actions: [
              OutlinedButton(
                onPressed: () => {
                  toast(),
                  Navigator.pop(context),
                  firestore.collection("users").doc(userUid).update({
                    'favMovies': FieldValue.arrayRemove([movieUid])
                  })
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(width: 5.0, color: Colors.transparent),
                ),
                child: const Text(
                  'Remove',
                  style: TextStyle(color: Colors.amber, fontSize: 16.0),
                ),
              ),
              OutlinedButton(
                onPressed: () => {
                  Navigator.pop(context),
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(width: 5.0, color: Colors.transparent),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.greenAccent, fontSize: 16.0),
                ),
              ),
            ],
          ));

  Future<String> downloadURL(String file) async {
    try {
      String downloadURL =
          await storage.ref('movieimages/$file').getDownloadURL();
      // ignore: avoid_print
      print(downloadURL);
      return downloadURL;
    } on FirebaseException catch (e) {
      // ignore: avoid_print
      print(e);
    }
    return downloadURL(file);
  }
}
