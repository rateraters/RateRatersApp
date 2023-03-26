// ignore_for_file: avoid_print

import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:new_version/new_version.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:rate_raters/SecScreen/bannerads.dart';
import 'package:rate_raters/Src/allmovie.dart';
import 'package:rate_raters/Src/favorites.dart';
import 'package:rate_raters/Src/login.dart';
import 'package:rate_raters/Src/profile.dart';
import 'package:rate_raters/Src/reviews.dart';
import 'package:rate_raters/Src/search.dart';

import '../blocs/auth_blocs.dart';

class Home extends StatefulWidget {
  const Home({
    Key? key,
  }) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FirebaseStorage storage = FirebaseStorage.instance;
  late StreamSubscription<User?> loginStateSubscription;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool? checkLogin;
  bool? admin = false;
  String userUid = 'Model';
  List list5 = ['1', '2', '3', '4'];

  Future<void> toast() async {
    Fluttertoast.showToast(
      msg: 'Movie has been add',
      gravity: ToastGravity.TOP,
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: Colors.transparent,
      textColor: Colors.white,
    );
  }

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
    _checkVersion();
    super.initState();
  }

  @override
  void dispose() {
    loginStateSubscription.cancel();
    super.dispose();
  }

  Future<void> refreshList() async {
    await Future.delayed(const Duration(seconds: 1, milliseconds: 2));
  }

  void _checkVersion() async {
    final newVersion = NewVersion(
      androidId: "com.example.rate_raters",
    );
    final status = await newVersion.getVersionStatus();
    // ignore: use_build_context_synchronously
    newVersion.showUpdateDialog(
      context: context,
      versionStatus: status!,
      dialogTitle: "UPDATE!!!",
      dismissButtonText: "Skip",
      dialogText: "Please update the app from "
          "${status.localVersion}"
          " to "
          "${status.storeVersion}",
      dismissAction: () {
        SystemNavigator.pop();
      },
      updateButtonText: "Lets update",
    ); //method to set show content call back
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(userUid)
            .snapshots()
            .take(1),
        builder: (context,
            AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
          snapshot.data?.data()?.forEach((key, value) {
            if (key == 'admin') {
              admin = value == '';
            }
          });
          if (!snapshot.hasData) {
            return Container();
          }
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

                var inTheater = snapshot.data?['inTheater'];
                inTheater = List.from(inTheater!.reversed);
                var listMovies1 = snapshot.data?["listMovies"];
                final countListMovies1 = listMovies1?.length;
                listMovies1?.shuffle();
                List<Widget> commentItems = List<Widget>.generate(
                    listMovies1?.length.clamp(0, 10) ?? 0,
                    (index) => StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection("movies")
                            .doc(listMovies1[index])
                            .snapshots()
                            .take(1),
                        builder: (context,
                            AsyncSnapshot<DocumentSnapshot> snapshot) {
                          var file = snapshot.data?['profile'];
                          var title = snapshot.data?['title'];
                          if (snapshot.data == null) {
                            return Container();
                          }
                          return FutureBuilder(
                              future: downloadURL(file),
                              builder: (BuildContext context,
                                  AsyncSnapshot<String> snapshot) {
                                if (snapshot.connectionState ==
                                        ConnectionState.done &&
                                    snapshot.hasData) {
                                  return GestureDetector(
                                    onLongPress: () => checkLogin == true
                                        ? openDialog(
                                            listMovies1[index], userUid)
                                        : '',
                                    onTap: () => {
                                      Navigator.push(
                                        context,
                                        PageTransition(
                                            type: PageTransitionType.fade,
                                            child: ReviewsScreen(
                                              movieUid: listMovies1[index],
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
                                            width: 150,
                                            height: 200,
                                            child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                child: Image.network(
                                                    fit: BoxFit.cover,
                                                    snapshot.data!))),
                                        SizedBox(
                                          height: 29,
                                          width: 270,
                                          child: Center(
                                            child: FittedBox(
                                              fit: BoxFit.contain,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 10.0),
                                                child: Text(
                                                  title,
                                                  style: GoogleFonts.cinzel(
                                                      fontSize: 13,
                                                      color: Colors.white),
                                                ),
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
                              });
                        }));
                return DefaultTabController(
                  length: 2,
                  child: Scaffold(
                    appBar: AppBar(
                      actions: <Widget>[
                        IconButton(
                          icon: const Icon(Icons.star),
                          iconSize: 25,
                          color: Colors.white,
                          onPressed: () => {
                            checkLogin == true
                                ? Navigator.push(
                                    context,
                                    PageTransition(
                                        type: PageTransitionType.rightToLeft,
                                        child: const MyFavourite()),
                                  )
                                : Navigator.push(
                                    context,
                                    PageTransition(
                                        type: PageTransitionType.rightToLeft,
                                        child: const LoginScreen()),
                                  )
                          },
                        ),
                        IconButton(
                            color: Colors.white,
                            icon: const Icon(Icons.search),
                            iconSize: 25,
                            onPressed: () => {
                                  Navigator.push(
                                    context,
                                    PageTransition(
                                        type: PageTransitionType.rightToLeft,
                                        child: const SearchScreen()),
                                  )
                                }),
                      ],
                      leading: IconButton(
                          color: Colors.white,
                          icon: const Icon(Icons.person),
                          iconSize: 25,
                          onPressed: () => {
                                checkLogin == true
                                    ? Navigator.push(
                                        context,
                                        PageTransition(
                                            type:
                                                PageTransitionType.leftToRight,
                                            child: const Profile()),
                                      )
                                    : Navigator.push(
                                        context,
                                        PageTransition(
                                            type:
                                                PageTransitionType.leftToRight,
                                            child: const LoginScreen()),
                                      )
                              }),
                      iconTheme: const IconThemeData(
                        color: Colors.black,
                      ),
                      systemOverlayStyle: SystemUiOverlayStyle(
                          statusBarColor: Colors.grey[850],
                          statusBarIconBrightness: Brightness.light,
                          statusBarBrightness: Brightness.light),
                      backgroundColor: Colors.transparent,
                      title: Text(
                        'RateRaters',
                        style: GoogleFonts.bangers(fontSize: 20),
                      ),
                      centerTitle: true,
                      titleTextStyle: const TextStyle(
                        color: Color(0xffEA828E),
                      ),
                      elevation: 0.0,
                    ),
                    backgroundColor: Colors.grey[850],
                    body: RefreshIndicator(
                      onRefresh: () =>
                          refreshList().then((value) => setState(() {})),
                      child: ScrollConfiguration(
                        behavior:
                            const ScrollBehavior().copyWith(overscroll: false),
                        child: GestureDetector(
                          onHorizontalDragEnd: (DragEndDetails details) {
                            if (details.primaryVelocity! > 0) {
                              checkLogin == true
                                  ? Navigator.push(
                                      context,
                                      PageTransition(
                                          type: PageTransitionType.leftToRight,
                                          child: const Profile()),
                                    )
                                  : Navigator.push(
                                      context,
                                      PageTransition(
                                          type: PageTransitionType.leftToRight,
                                          child: const LoginScreen()),
                                    );
                            } else if (details.primaryVelocity! < 0) {
                              Navigator.push(
                                context,
                                PageTransition(
                                    type: PageTransitionType.rightToLeft,
                                    child: const SearchScreen()),
                              );
                            }
                          },
                          child: ListView(
                            children: [
                              const Center(
                                child: SizedBox(
                                    width: 320,
                                    height: 100,
                                    child: AdScreen(
                                      nameOrigin: 'Home',
                                    )),
                              ),
                              CarouselSlider(
                                options: CarouselOptions(
                                  autoPlay: true,
                                  reverse: false,
                                  enlargeCenterPage: false,
                                  scrollDirection: Axis.horizontal,
                                  autoPlayInterval: const Duration(seconds: 6),
                                  autoPlayAnimationDuration:
                                      const Duration(seconds: 2),
                                ),
                                items: commentItems,
                              ),
                              const SizedBox(
                                height: 25,
                              ),

                              Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text('Now Showing',
                                          style: GoogleFonts.oswald(
                                              color: Colors.white,
                                              fontSize: 20.0)),
                                    ),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                    const SizedBox(
                                        width: 40,
                                        height: 40,
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: CircleAvatar(
                                              backgroundColor:
                                                  Colors.transparent,
                                              backgroundImage: AssetImage(
                                                  'assets/images/majorlogo.png')),
                                        ))
                                  ]),
                              const SizedBox(
                                height: 20,
                              ),

                              //Movies in theater
                              GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                          mainAxisSpacing: 25.0,
                                          crossAxisSpacing: 5.0,
                                          crossAxisCount: 2),
                                  reverse: false,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: inTheater?.length,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    return StreamBuilder(
                                        stream: FirebaseFirestore.instance
                                            .collection("movies")
                                            .doc(inTheater[index])
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
                                            onEndOfPage: () {},
                                            child: FutureBuilder(
                                                future: downloadURL(file),
                                                builder: (BuildContext context,
                                                    AsyncSnapshot<String>
                                                        snapshot) {
                                                  if (snapshot.connectionState ==
                                                          ConnectionState
                                                              .done &&
                                                      snapshot.hasData) {
                                                    return GestureDetector(
                                                      onLongPress: () =>
                                                          checkLogin == true
                                                              ? openDialog(
                                                                  inTheater[
                                                                      index],
                                                                  userUid)
                                                              : '',
                                                      onTap: () => {
                                                        Navigator.push(
                                                          context,
                                                          PageTransition(
                                                              type:
                                                                  PageTransitionType
                                                                      .fade,
                                                              child:
                                                                  ReviewsScreen(
                                                                movieUid:
                                                                    inTheater[
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
                                                              width: 180,
                                                              height: 180,
                                                              child: Image.network(
                                                                  snapshot
                                                                      .data!)),
                                                          const SizedBox(
                                                            height: 8,
                                                          ),
                                                          SizedBox(
                                                            width: 270,
                                                            child: Center(
                                                              child: FittedBox(
                                                                fit: BoxFit
                                                                    .contain,
                                                                child: Text(
                                                                  title,
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }
                                                  if (snapshot.connectionState ==
                                                          ConnectionState
                                                              .waiting ||
                                                      snapshot.hasData) {
                                                    return Container();
                                                  }
                                                  return Container();
                                                }),
                                          );
                                        });
                                  }),
                              const SizedBox(
                                height: 25,
                              ),
                              admin!
                                  ? Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text('All Movies',
                                          style: GoogleFonts.oswald(
                                              color: Colors.white,
                                              fontSize: 20.0)),
                                    )
                                  : checkLogin == true
                                      ? Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: Text(
                                              'All Movies ($countListMovies1)',
                                              style: GoogleFonts.oswald(
                                                  color: Colors.white,
                                                  fontSize: 20.0)),
                                        )
                                      : Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: Text('All Movies',
                                              style: GoogleFonts.oswald(
                                                  color: Colors.white,
                                                  fontSize: 20.0)),
                                        ),

                              const SizedBox(
                                  width: 320,
                                  height: 100,
                                  child: AdScreen(
                                    nameOrigin: 'Profile',
                                  )),

                              //All Movies
                              GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                          mainAxisSpacing: 11.0,
                                          crossAxisSpacing: 5.0,
                                          crossAxisCount: 2),
                                  reverse: false,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: 14,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    return StreamBuilder(
                                        stream: FirebaseFirestore.instance
                                            .collection("movies")
                                            .doc(listMovies1[index])
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
                                            onEndOfPage: () {},
                                            child: FutureBuilder(
                                                future: downloadURL(file),
                                                builder: (BuildContext context,
                                                    AsyncSnapshot<String>
                                                        snapshot) {
                                                  if (snapshot.connectionState ==
                                                          ConnectionState
                                                              .done &&
                                                      snapshot.hasData) {
                                                    return GestureDetector(
                                                      onLongPress: () =>
                                                          checkLogin == true
                                                              ? openDialog(
                                                                  listMovies1[
                                                                      index],
                                                                  userUid)
                                                              : '',
                                                      onTap: () => {
                                                        Navigator.push(
                                                          context,
                                                          PageTransition(
                                                              type:
                                                                  PageTransitionType
                                                                      .fade,
                                                              child:
                                                                  ReviewsScreen(
                                                                movieUid:
                                                                    listMovies1[
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
                                                              width: 180,
                                                              height: 180,
                                                              child: Image.network(
                                                                  snapshot
                                                                      .data!)),
                                                          const SizedBox(
                                                            height: 8,
                                                          ),
                                                             SizedBox(
                                                            width: 270,
                                                            child: Center(
                                                              child: FittedBox(
                                                                fit: BoxFit
                                                                    .contain,
                                                                child: Text(
                                                                  title,
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }
                                                  if (snapshot.connectionState ==
                                                          ConnectionState
                                                              .waiting ||
                                                      snapshot.hasData) {
                                                    return Container();
                                                  }
                                                  return Container();
                                                }),
                                          );
                                        });
                                  }),
                              const SizedBox(
                                height: 10,
                              ),
                              Center(
                                  child: GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  PageTransition(
                                      type: PageTransitionType.rightToLeft,
                                      child: const AllMovieScreen()),
                                ),
                                child: const Text(
                                  'ดูทั้งหมด',
                                  style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: Colors.white,
                                      fontSize: 15),
                                ),
                              )),
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
                    ),
                  ),
                );
              });
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
