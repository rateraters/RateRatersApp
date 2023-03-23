// ignore_for_file: avoid_print

import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:rate_raters/SecScreen/addbotcomment.dart';
import 'package:rate_raters/SecScreen/comment.dart';
import 'package:rate_raters/services/database.dart';
import 'package:uuid/uuid.dart';

import '../blocs/auth_blocs.dart';

class ReviewsScreen extends StatefulWidget {
  final String movieUid;
  const ReviewsScreen({super.key, required this.movieUid});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final FirebaseStorage storage = FirebaseStorage.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final uuid = const Uuid();
  bool? admin = false;
  final TextEditingController comment = TextEditingController();
  final TextEditingController movieTitle = TextEditingController();
  String userUid = '1vkmwCTExfNwFgC8fanZOHmUqC52';
  late StreamSubscription<User?> loginStateSubscription;
  bool? checkLogin;
  bool? checkEmpty = false;
  double rating = 1;


  String getRatingString() {
    return '$rating';
  }

  Future<void> refreshList() async {
    await Future.delayed(const Duration(seconds: 1, milliseconds: 2));
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
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(userUid)
            .snapshots().take(1)
            ,
        builder: (context,
            AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
          var userName = snapshot.data?.get('fullName');
          var profileUid = snapshot.data?.get('profileUrl');
          var favMovies = snapshot.data?['favMovies'];
          snapshot.data?.data()?.forEach((key, value) {
            if (key == 'admin') {
              admin = value == '';
            }
          });
          if (!snapshot.hasData) {
            return Container();
          }
          return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection("movies")
                  .doc(widget.movieUid)
                  .snapshots().take(1)
                  ,
              builder: (context, snapshot) {
                snapshot.data?.data()?.forEach((key, value) {
                  if (key == 'usersComment') {
                    checkEmpty = value.length == 0;
                  }
                });
                var stars1 = snapshot.data?.data()?['1Stars'];
                var countStars1 = stars1?.length ?? 0;

                var stars2 = snapshot.data?.data()?['2Stars'];
                var countStars2 = stars2?.length ?? 0;

                var stars3 = snapshot.data?.data()?['3Stars'];
                var countStars3 = stars3?.length ?? 0;

                var stars4 = snapshot.data?.data()?['4Stars'];
                var countStars4 = stars4?.length ?? 0;

                var stars5 = snapshot.data?.data()?['5Stars'];
                var countStars5 = stars5?.length ?? 0;
                int totalVotes = countStars1 +
                    countStars2 +
                    countStars3 +
                    countStars4 +
                    countStars5;
                double overallRating = totalVotes == 0
                    ? 0
                    : (countStars1 +
                            2 * countStars2 +
                            3 * countStars3 +
                            4 * countStars4 +
                            5 * countStars5) /
                        totalVotes;
                var title = snapshot.data?.get('title');
                var profileUrl = snapshot.data?.get('profile');
                var id = snapshot.data?.get('id');
                final usersComment = snapshot.data?['usersComment'];
                final usersComment1 = snapshot.data?['usersComment'];
                usersComment1?.shuffle();
                usersComment?.shuffle();

                final upvote = snapshot.data?['upvote'];
                final countUpVote = upvote?.length;
                //For CouracelSlider
                List<Widget> commentItems = List<Widget>.generate(
                  usersComment?.length.clamp(0, 7) ?? 0,
                  (index) => StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("usersComment")
                          .doc(usersComment[index])
                          .snapshots().take(1)
                          ,
                      builder: (context, AsyncSnapshot snapshot) {
                        var name = snapshot.data?.get('name');
                        var comment = snapshot.data?.get('comment');
                        var profile = snapshot.data?.get('profile');
                        if (!snapshot.hasData) {
                          return Container();
                        }
                        return FutureBuilder(
                            future: downloadURL(profile),
                            builder: (BuildContext context,
                                AsyncSnapshot<String> snapshot) {
                              if (snapshot.connectionState ==
                                      ConnectionState.done &&
                                  snapshot.hasData) {
                                return Container(
                                  width: 310,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: Colors.white70,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 1,
                                        blurRadius: 3,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          12.0, //Left
                                          10.0, //top
                                          0.0, //right
                                          10.0, //bottom
                                        ),
                                        child: SizedBox(
                                          height: 55,
                                          width: 55,
                                          child: FittedBox(
                                            fit: BoxFit.contain,
                                            child: CircleAvatar(
                                              backgroundColor:
                                                  Colors.transparent,
                                              backgroundImage:
                                                  NetworkImage(snapshot.data!),
                                              radius: 10.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Center(
                                        child: Text(
                                          name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 11),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      SizedBox(
                                        width: 270,
                                        child: Center(
                                          child: Text(
                                            comment,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 15),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return Container();
                            });
                      }),
                );
                return StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("movies")
                        .doc('Model')
                        .snapshots().take(1)
                        ,
                    builder:
                        (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                      final inTheater = snapshot.data?['inTheater'];
                      if (!snapshot.hasData) {
                        return Container();
                      }

                      return DefaultTabController(
                          length: 2,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Scaffold(
                              floatingActionButton: Builder(builder: (context) {
                                return checkLogin == true
                                    ? FloatingActionButton(
                                        onPressed: () => Navigator.push(
                                            context,
                                            PageTransition(
                                                type: PageTransitionType.fade,
                                                child: Comment(
                                                    movieUid: id,
                                                    userName: userName,
                                                    profileUid: profileUid,
                                                    title: title,
                                                    profileUrl: profileUrl))),
                                        backgroundColor: Colors.grey,
                                        elevation: 0,
                                        child: const Icon(Icons.add,
                                            color: Colors.white, size: 35),
                                      )
                                    : Container();
                              }),
                              backgroundColor: Colors.black45,
                              body: NestedScrollView(
                                
                                headerSliverBuilder: (BuildContext context,
                                    bool innerBoxIsScrolled) {
                                  return <Widget>[
                                    SliverAppBar(
                                      actions: <Widget>[
                                        checkLogin == true
                                            ? IconButton(
                                                color: Colors.white,
                                                tooltip: 'Rate',
                                                icon: const Icon(
                                                    Icons.rate_review_outlined),
                                                iconSize: 25,
                                                onPressed: () =>
                                                    {bottomSheet()})
                                            : Container(),
                                        IconButton(
                                            color: Colors.white,
                                            tooltip: 'Reload',
                                            icon: const Icon(
                                                Icons.replay_outlined),
                                            iconSize: 25,
                                            onPressed: () => {DataBase().refresh(context, id)}),
                                        checkLogin == true
                                            ? IconButton(
                                                color: Colors.white,
                                                icon: Icon(upvote
                                                            .toString()
                                                            .contains(
                                                                userUid) ==
                                                        true
                                                    ? Icons.thumb_up
                                                    : Icons
                                                        .thumb_up_alt_outlined),
                                                iconSize: 25,
                                                onPressed: () => {
                                                  if (upvote
                                                      .toString()
                                                      .contains(userUid))
                                                    {
                                                      toast(),
                                                      firestore
                                                          .collection("movies")
                                                          .doc(widget.movieUid)
                                                          .update({
                                                        'upvote': FieldValue
                                                            .arrayRemove(
                                                                [userUid])
                                                      })
                                                    }
                                                  else
                                                    {
                                                      toast(),
                                                      firestore
                                                          .collection("movies")
                                                          .doc(widget.movieUid)
                                                          .update({
                                                        'upvote': FieldValue
                                                            .arrayUnion(
                                                                [userUid])
                                                      })
                                                    }
                                                },
                                              )
                                            : Container(),
                                        checkLogin == true
                                            ? IconButton(
                                                color: Colors.white,
                                                icon: Icon(favMovies
                                                            .toString()
                                                            .contains(widget
                                                                .movieUid) ==
                                                        true
                                                    ? Icons.star
                                                    : Icons.star_border),
                                                iconSize: 25,
                                                onPressed: () => {
                                                  if (favMovies
                                                      .toString()
                                                      .contains(
                                                          widget.movieUid))
                                                    {
                                                      toast(),
                                                      firestore
                                                          .collection("users")
                                                          .doc(userUid)
                                                          .update({
                                                        'favMovies': FieldValue
                                                            .arrayRemove([
                                                          widget.movieUid
                                                        ])
                                                      })
                                                    }
                                                  else
                                                    {
                                                      toast(),
                                                      firestore
                                                          .collection("users")
                                                          .doc(userUid)
                                                          .update({
                                                        'favMovies': FieldValue
                                                            .arrayUnion([
                                                          widget.movieUid
                                                        ])
                                                      })
                                                    }
                                                },
                                              )
                                            : Container()
                                      ],
                                      iconTheme: const IconThemeData(
                                        color: Colors.white,
                                      ),
                                      systemOverlayStyle:
                                          const SystemUiOverlayStyle(
                                              statusBarColor: Colors.black45,
                                              statusBarIconBrightness:
                                                  Brightness.light,
                                              statusBarBrightness:
                                                  Brightness.light),
                                      backgroundColor: Colors.transparent,
                                      centerTitle: true,
                                      titleTextStyle: const TextStyle(
                                        color: Colors.black,
                                      ),
                                      elevation: 0.0,
                                    ),
                                  ];
                                },
                                body: RefreshIndicator(
                                  onRefresh: () => refreshList()
                                      .then((value) => DataBase().refresh(context, id)),
                                  child: ScrollConfiguration(
                                    behavior: const ScrollBehavior()
                                        .copyWith(overscroll: false),
                                    child: GestureDetector(
                                      onHorizontalDragEnd:
                                          (DragEndDetails details) {
                                        if (details.primaryVelocity! > 0) {
                                          Navigator.pop(context);
                                        } else if (details.primaryVelocity! <
                                            0) {}
                                      },
                                      //List view
                                      child: ListView(
                                        children: [
                                         
                                          Column(
                                            children: [
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              FutureBuilder(
                                                  future:
                                                      downloadURL1(profileUrl),
                                                  builder:
                                                      (BuildContext context,
                                                          AsyncSnapshot<String>
                                                              snapshot) {
                                                    if (snapshot.connectionState ==
                                                            ConnectionState
                                                                .done &&
                                                        snapshot.hasData) {
                                                      return SizedBox(
                                                          width: 170,
                                                          height: 170,
                                                          child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10.0),
                                                              child: Image.network(
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  snapshot
                                                                      .data!)));
                                                    }
                                                    if (snapshot.connectionState ==
                                                            ConnectionState
                                                                .waiting ||
                                                        snapshot.hasData) {
                                                      return const SizedBox(
                                                        width: 170,
                                                        height: 170,
                                                      );
                                                    }
                                                    return Container();
                                                  }),
                                              const SizedBox(
                                                height: 8,
                                              ),
                                              RatingBar.builder(
                                                ignoreGestures: true,
                                                unratedColor: Colors.white,
                                                initialRating: overallRating,
                                                direction: Axis.horizontal,
                                                allowHalfRating: true,
                                                itemCount: 5,
                                                itemSize: 30,
                                                itemPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 3.0),
                                                itemBuilder: (context, _) =>
                                                    const Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                ),
                                                onRatingUpdate:
                                                    (double value) {},
                                              ),
                                              const SizedBox(
                                                height: 15,
                                              ),
                                              Center(
                                                child: GestureDetector(
                                                  onLongPress: () =>
                                                      openDialog1(),
                                                  child: SizedBox(
                                                    width: 270,
                                                    child: Center(
                                                      child: Text(title,
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize:
                                                                      15.0)),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              GestureDetector(
                                                onTap: () => openDialog3(
                                                    countUpVote,
                                                    countStars1,
                                                    countStars2,
                                                    countStars3,
                                                    countStars4,
                                                    countStars5,
                                                    overallRating),
                                                child: Center(
                                                    child: Container(
                                                  width: 100,
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white70,
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                10)),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.grey
                                                            .withOpacity(0.5),
                                                        spreadRadius: 1,
                                                        blurRadius: 3,
                                                        offset:
                                                            const Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                  child: const Center(
                                                    child: Text(
                                                      'See Ratings',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          decoration:
                                                              TextDecoration
                                                                  .underline,
                                                          fontSize: 13),
                                                    ),
                                                  ),
                                                )),
                                              ),
                                              const SizedBox(
                                                height: 15,
                                              ),
                                              admin!
                                                  ? Container()
                                                  : Column(
                                                      children: [
                                                        Center(
                                                          child: ElevatedButton(
                                                            onPressed: () =>
                                                                openDialog2(widget
                                                                    .movieUid),
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              foregroundColor:
                                                                  Colors.black,
                                                              backgroundColor:
                                                                  Colors.grey,
                                                              elevation: 0.0,
                                                              shape:
                                                                  const RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .zero,
                                                              ),
                                                            ),
                                                            child: const Text(
                                                                'Edit'),
                                                          ),
                                                        ),
                                                        Center(
                                                          child: ElevatedButton(
                                                            onPressed: () => {
                                                              if (inTheater
                                                                  .toString()
                                                                  .contains(widget
                                                                      .movieUid))
                                                                {
                                                                  toast(),
                                                                  firestore
                                                                      .collection(
                                                                          "movies")
                                                                      .doc(
                                                                          'Model')
                                                                      .update({
                                                                    'inTheater':
                                                                        FieldValue
                                                                            .arrayRemove([
                                                                      widget
                                                                          .movieUid
                                                                    ])
                                                                  })
                                                                }
                                                              else
                                                                {
                                                                  toast(),
                                                                  firestore
                                                                      .collection(
                                                                          "movies")
                                                                      .doc(
                                                                          'Model')
                                                                      .update({
                                                                    'inTheater':
                                                                        FieldValue
                                                                            .arrayUnion([
                                                                      widget
                                                                          .movieUid
                                                                    ])
                                                                  })
                                                                }
                                                            },
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              foregroundColor:
                                                                  Colors.black,
                                                              backgroundColor:
                                                                  Colors.grey,
                                                              elevation: 0.0,
                                                              shape:
                                                                  const RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .zero,
                                                              ),
                                                            ),
                                                            child: Text(inTheater
                                                                        .toString()
                                                                        .contains(
                                                                            widget.movieUid) ==
                                                                    true
                                                                ? 'Remove movie from "inTheater"'
                                                                : 'Add movie to "inTheater"'),
                                                          ),
                                                        ),
                                                   Center(
                                                          child: ElevatedButton(
                                                            onPressed: () => Navigator.push(
      context,
      PageTransition(
         type: PageTransitionType.rightToLeft, child:  BotComment(movieUid: id,))),
    
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              foregroundColor:
                                                                  Colors.black,
                                                              backgroundColor:
                                                                  Colors.grey,
                                                              elevation: 0.0,
                                                              shape:
                                                                  const RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .zero,
                                                              ),
                                                            ),
                                                            child: const Text(
                                                                'Add bot comment'),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                              checkEmpty!
                                                  ? Container()
                                                  : CarouselSlider(
                                                      options: CarouselOptions(
                                                          autoPlay: true,
                                                          reverse: false,
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          autoPlayInterval:
                                                              const Duration(
                                                                  seconds: 6),
                                                          autoPlayAnimationDuration:
                                                              const Duration(
                                                                  seconds: 2),
                                                          height: 200),
                                                      items: commentItems,
                                                    ),
                                              const SizedBox(
                                                height: 50,
                                              ),
                                              checkEmpty!
                                                  ? GestureDetector(
                                                      onTap: () =>
                                                          checkLogin == true
                                                              ? Navigator.push(
                                            context,
                                            PageTransition(
                                                type: PageTransitionType.fade,
                                                child: Comment(
                                                    movieUid: id,
                                                    userName: userName,
                                                    profileUid: profileUid,
                                                    title: title,
                                                    profileUrl: profileUrl)))
                                                              : {},
                                                      child: const Center(
                                                          child: Text(
                                                        'No comment yet. Be the first to comment',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      )))
                                                  : LazyLoadScrollView(
                                                     onEndOfPage: () => {},
                                                    child: ListView.builder(
                                                        reverse: false,
                                                        physics:
                                                            const BouncingScrollPhysics(),
                                                        itemCount: usersComment1
                                                                ?.length ??
                                                            0,
                                                        shrinkWrap: true,
                                                        itemBuilder:
                                                            (context, index) {
                                                          return StreamBuilder(
                                                              stream: FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      "usersComment")
                                                                  .doc(
                                                                      usersComment1[
                                                                          index])
                                                                  .snapshots().take(1)
                                                                  ,
                                                              builder: (context,
                                                                  AsyncSnapshot<
                                                                          DocumentSnapshot>
                                                                      snapshot) {
                                                                var name = snapshot
                                                                    .data
                                                                    ?.get('name');
                                                                var comment = snapshot
                                                                    .data
                                                                    ?.get(
                                                                        'comment');
                                                                var profile = snapshot
                                                                    .data
                                                                    ?.get(
                                                                        'profile');
                                                                final vote =
                                                                    snapshot.data?[
                                                                        'vote'];
                                                                final countVote =
                                                                    vote?.length ??
                                                                        0;
                                                                if (!snapshot
                                                                    .hasData) {
                                                                  return Container();
                                                                }
                                                                return FutureBuilder(
                                                                    future:
                                                                        downloadURL(
                                                                            profile),
                                                                    builder: (BuildContext
                                                                            context,
                                                                        AsyncSnapshot<
                                                                                String>
                                                                            snapshot) {
                                                                      if (snapshot.connectionState ==
                                                                              ConnectionState
                                                                                  .done &&
                                                                          snapshot
                                                                              .hasData) {
                                                                        return Padding(
                                                                          padding:
                                                                              const EdgeInsets.only(bottom: 15.0),
                                                                          child:
                                                                              Container(
                                                                            width:
                                                                                260,
                                                                            height:
                                                                                90,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              color:
                                                                                  Colors.white70,
                                                                              borderRadius:
                                                                                  const BorderRadius.all(Radius.circular(10)),
                                                                              boxShadow: [
                                                                                BoxShadow(
                                                                                  color: Colors.grey.withOpacity(0.5),
                                                                                  spreadRadius: 1,
                                                                                  blurRadius: 3,
                                                                                  offset: const Offset(0, 2),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            child:
                                                                                Column(
                                                                              mainAxisAlignment:
                                                                                  MainAxisAlignment.center,
                                                                              children: [
                                                                                Row(
                                                                                  children: [
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.fromLTRB(
                                                                                        12.0, //Left
                                                                                        10.0, //top
                                                                                        0.0, //right
                                                                                        10.0, //bottom
                                                                                      ),
                                                                                      child: SizedBox(
                                                                                        height: 55,
                                                                                        width: 55,
                                                                                        child: FittedBox(
                                                                                          fit: BoxFit.contain,
                                                                                          child: CircleAvatar(
                                                                                            backgroundColor: Colors.transparent,
                                                                                            backgroundImage: NetworkImage(snapshot.data!),
                                                                                            radius: 10.0,
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.only(left: 15.0),
                                                                                      child: Column(
                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                                        children: [
                                                                                          Text(
                                                                                            name,
                                                                                            style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 11),
                                                                                          ),
                                                                                          const SizedBox(
                                                                                            height: 8,
                                                                                          ),
                                                                                          SizedBox(
                                                                                            width: 270,
                                                                                            child: Text(
                                                                                              comment,
                                                                                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                    Column(
                                                                                      children: [
                                                                                        IconButton(
                                                                                            icon: Icon(vote.toString().contains(userUid) == true ? Icons.upload : Icons.upload_outlined),
                                                                                            iconSize: 25,
                                                                                            onPressed: () => {
                                                                                                  checkLogin == true
                                                                                                      ? {
                                                                                                          if (vote.toString().contains(userUid))
                                                                                                            {
                                                                                                              toast(),
                                                                                                              firestore.collection("usersComment").doc(usersComment1[index]).update({
                                                                                                                'vote': FieldValue.arrayRemove([userUid])
                                                                                                              })
                                                                                                            }
                                                                                                          else
                                                                                                            {
                                                                                                              toast(),
                                                                                                              firestore.collection("usersComment").doc(usersComment1[index]).update({
                                                                                                                'vote': FieldValue.arrayUnion([userUid])
                                                                                                              })
                                                                                                            }
                                                                                                        }
                                                                                                      : {}
                                                                                                }),
                                                                                        ////
                                                                                        Text(
                                                                                          countVote.toString(),
                                                                                          style: const TextStyle(color: Colors.grey, fontSize: 9),
                                                                                        )
                                                                                      ],
                                                                                    )
                                                                                  ],
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        );
                                                                      }
                                                                      return Container();
                                                                    });
                                                              });
                                                        }),
                                                  ),
                                              const SizedBox(
                                                height: 50,
                                              ),
                                            ],
                                          ),
                                      
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ));
                    });
              });
        });
  }

//Add comment
  Future openDialog(userName, profileUid, title, profileUrl) => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            //title: const Center(child: Text('')),
            content: SizedBox(
              width: 100,
              height: 100,
              child: Column(
                children: [
                  const SizedBox(
                    height: 11,
                  ),
                  TextFormField(
                    controller: comment,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(80),
                    ],
                    decoration: const InputDecoration(
                        errorStyle: TextStyle(color: Colors.grey),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        hintText: 'Your though?',
                        hintStyle: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
            actions: [
              OutlinedButton(
                onPressed: () => {
                  if (comment.text == '')
                    {'No text input'}
                  else
                    {
                      toast(),
                      Navigator.pop(context),
                      DataBase()
                          .addComment(
                              userUid,
                              comment.text,
                              userName,
                              profileUid,
                              widget.movieUid,
                              uuid.v1(),
                              title,
                              profileUrl)
                          .then((value) => comment.clear())
                    }
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(width: 5.0, color: Colors.transparent),
                ),
                child: const Text(
                  'Send',
                  style: TextStyle(color: Colors.grey, fontSize: 16.0),
                ),
              ),
            ],
          ));

//rate stars
  Future bottomSheet() => showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          width: 900,
          height: 150,
          child: Column(
            children: [
              Container(
                width: 70,
                height: 11,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(20),
                  ),
                  border: Border.all(
                    width: 1,
                  ),
                ),
              ),
              const SizedBox(
                height: 17,
              ),
              RatingBar.builder(
                itemSize: 40,
                glowColor: Colors.white,
                unratedColor: Colors.grey,
                initialRating: 1,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (newRating) {
                  rating = newRating;
                },
              ),
              const SizedBox(
                height: 30,
              ),
              Center(
                child: GestureDetector(
                  onTap: () => {
                    toast(),
                    Navigator.pop(context),
                    DataBase().rateStars(widget.movieUid, getRatingString(),userUid)
                  },
                  child: const Text(
                    'Confirm',
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        );
      });

//Dialog show ratings
  Future openDialog3(upvoteCount, countStars1, countStars2, countStars3,
          countStars4, countStars5, overallRating) =>
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                backgroundColor: Colors.grey,
                title: const Center(
                    child: Text(
                  'Users Rating',
                  style: TextStyle(color: Colors.white),
                )),
                content: SizedBox(
                  height: 180,
                  child: Column(
                    children: [
                      Text(
                        'Overall rating: ${overallRating.toStringAsFixed(1)}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text(
                        '($upvoteCount) Liked this movie',
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber),
                          Text(
                            "($countStars1)",
                            style: const TextStyle(color: Colors.white),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber),
                          const Icon(Icons.star, color: Colors.amber),
                          Text(
                            "($countStars2)",
                            style: const TextStyle(color: Colors.white),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber),
                          const Icon(Icons.star, color: Colors.amber),
                          const Icon(Icons.star, color: Colors.amber),
                          Text(
                            "($countStars3)",
                            style: const TextStyle(color: Colors.white),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          const Icon(Icons.star, color: Colors.amber),
                          const Icon(Icons.star, color: Colors.amber),
                          const Icon(Icons.star, color: Colors.amber),
                          Text(
                            "($countStars4)",
                            style: const TextStyle(color: Colors.white),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber),
                          const Icon(Icons.star, color: Colors.amber),
                          const Icon(Icons.star, color: Colors.amber),
                          const Icon(Icons.star, color: Colors.amber),
                          const Icon(Icons.star, color: Colors.amber),
                          Text(
                            "($countStars5)",
                            style: const TextStyle(color: Colors.white),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                actions: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                          width: 5.0, color: Colors.transparent),
                    ),
                    child: const Text(
                      'Ok',
                      style:
                          TextStyle(color: Colors.greenAccent, fontSize: 16.0),
                    ),
                  ),
                ],
              ));

//Dialog show movie info
  Future openDialog1() => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: const Center(child: Text('Movie Info')),
            content: SizedBox(
              height: 100,
              child: Column(
                children: [
                  (SelectableText(
                      // ignore: prefer_interpolation_to_compose_strings
                      'Movie Uid:'
                              '\n' +
                          widget.movieUid)),
                ],
              ),
            ),
            actions: [
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(width: 5.0, color: Colors.transparent),
                ),
                child: const Text(
                  'Ok',
                  style: TextStyle(color: Colors.grey, fontSize: 16.0),
                ),
              ),
            ],
          ));

//Edit movie title
  Future openDialog2(movieUid) => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            content: SizedBox(
              width: 100,
              height: 100,
              child: Column(
                children: [
                  const SizedBox(
                    height: 11,
                  ),
                  TextFormField(
                    controller: movieTitle,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                        errorStyle: TextStyle(color: Colors.grey),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        hintText: 'New Movie Title',
                        hintStyle: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
            actions: [
              OutlinedButton(
                onPressed: () => {
                  toast(),
                  Navigator.pop(context),
                  firestore
                      .collection("movies")
                      .doc(movieUid)
                      .update({'title': movieTitle.text})
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(width: 5.0, color: Colors.transparent),
                ),
                child: const Text(
                  'Send',
                  style: TextStyle(color: Colors.grey, fontSize: 16.0),
                ),
              ),
            ],
          ));

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

  Future<String> downloadURL1(String profileUrl) async {
    try {
      String downloadURL =
          await storage.ref('movieimages/$profileUrl').getDownloadURL();
      print(downloadURL);
      return downloadURL;
    } on FirebaseException catch (e) {
      print(e);
    }
    return downloadURL1(profileUrl);
  }
}
