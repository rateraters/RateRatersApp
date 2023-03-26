// ignore_for_file: avoid_print

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:rate_raters/Src/reviews.dart';

import '../SecScreen/bannerads.dart';
import '../blocs/auth_blocs.dart';

class AllMovieScreen extends StatefulWidget {
  const AllMovieScreen({super.key});

  @override
  State<AllMovieScreen> createState() => _AllMovieScreenState();
}

class _AllMovieScreenState extends State<AllMovieScreen> {
  final FirebaseStorage storage = FirebaseStorage.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late StreamSubscription<User?> loginStateSubscription;
  List list5 = ['1', '2', '3', '4'];
  String userUid = 'Model';
  bool? checkLogin;
  late final InterstitialAd interstitialAd;
  final String interstitialAdUnitId = "ca-app-pub-3940256099942544/1033173712";

  Future<void> toast1() async {
    Fluttertoast.showToast(
      msg: 'Movie has been added',
      gravity: ToastGravity.TOP,
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: Colors.transparent,
      textColor: Colors.white,
    );
  }

  @override
  void initState() {
    final authBloc = Provider.of<AuthBloc>(context, listen: false);
    loginStateSubscription = authBloc.currentUser.listen((fbUser) {
      if (fbUser != null) {
        if (mounted) {
          //User login
          checkLogin = true;
          setState(() {
            userUid = FirebaseAuth.instance.currentUser!.uid;
          });
        }
      } else {
        if (mounted) {
          //User not login
          checkLogin = false;
        }
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    loginStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("movies")
            .doc('Model')
            .snapshots()
            .take(1),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          var listMovies = snapshot.data?["listMovies"];
          listMovies?.shuffle();
          return GestureDetector(
            onHorizontalDragEnd: (DragEndDetails details) {
              if (details.primaryVelocity! > 0) {
                Navigator.pop(context);
              } else if (details.primaryVelocity! < 0) {}
            },
            child: Scaffold(
              backgroundColor: Colors.grey[850],
              body: NestedScrollView(
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverAppBar(
                      iconTheme: const IconThemeData(
                        color: Colors.white,
                      ),
                      systemOverlayStyle: SystemUiOverlayStyle(
                          statusBarColor: Colors.grey[850],
                          statusBarIconBrightness: Brightness.light,
                          statusBarBrightness: Brightness.light),
                      backgroundColor: Colors.grey[850],
                      title: const Text('All movies'),
                      centerTitle: true,
                      titleTextStyle: const TextStyle(
                        color: Colors.white,
                      ),
                      elevation: 0.0,
                    ),
                  ];
                },
                body: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    const SizedBox(
                        width: 300,
                        height: 100,
                        child: AdScreen(
                          nameOrigin: 'Reviews',
                        )),
                    const SizedBox(
                      height: 15,
                    ),
                    GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                mainAxisSpacing: 11.0,
                                crossAxisSpacing: 5.0,
                                crossAxisCount: 2),
                        reverse: false,
                        physics: const BouncingScrollPhysics(),
                        itemCount: listMovies?.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection("movies")
                                  .doc(listMovies[index])
                                  .snapshots()
                                  .take(1),
                              builder: (context,
                                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                                var file = snapshot.data?['profile'];
                                var title = snapshot.data?['title'];
                                if (snapshot.data == null) {
                                  return Container();
                                }
                                return LazyLoadScrollView(
                                  onEndOfPage: () {},
                                  child: FutureBuilder(
                                      future: downloadURL(file),
                                      builder: (BuildContext context,
                                          AsyncSnapshot<String> snapshot) {
                                        if (snapshot.connectionState ==
                                                ConnectionState.done &&
                                            snapshot.hasData) {
                                          return GestureDetector(
                                            onLongPress: () => checkLogin ==
                                                    true
                                                ? openDialog(
                                                    listMovies[index], userUid)
                                                : '',
                                            onTap: () => {
                                              Navigator.push(
                                                context,
                                                PageTransition(
                                                    type:
                                                        PageTransitionType.fade,
                                                    child: ReviewsScreen(
                                                      movieUid:
                                                          listMovies[index],
                                                    )),
                                              )
                                            },
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                    width: 180,
                                                    height: 180,
                                                    child: Image.network(
                                                        snapshot.data!)),
                                                const SizedBox(
                                                  height: 8,
                                                ),
                                                SizedBox(
                                                  width: 270,
                                                  child: Center(
                                                    child: FittedBox(
                                                      fit: BoxFit.contain,
                                                      child: Text(
                                                        title,
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
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
                    const Center(
                                child: SizedBox(
                                    width: 320,
                                    height: 120,
                                    child: AdScreen(
                                      nameOrigin: 'random',
                                    )),
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
                  toast1(),
                  Navigator.pop(context),
                  firestore.collection("users").doc(userUid).update({
                    'favMovies': FieldValue.arrayUnion([movieUid])
                  })
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(width: 5.0, color: Colors.transparent),
                ),
                child: const Text(
                  'Add to favourite',
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
      print(downloadURL);
      return downloadURL;
    } on FirebaseException catch (e) {
      print(e);
    }
    return downloadURL(file);
  }
}
