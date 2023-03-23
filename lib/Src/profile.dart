// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:rate_raters/SecScreen/randommovie.dart';
import 'package:rate_raters/SecScreen/suggestcomment.dart';
import 'package:rate_raters/Src/add.dart';
import 'package:rate_raters/Src/home.dart';
import 'package:rate_raters/services/database.dart';
import '../SecScreen/showpic.dart';
import '../blocs/auth_blocs.dart';

class Profile extends StatefulWidget {
  const Profile({
    Key? key,
  }) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final ImagePicker picker = ImagePicker();
  late StreamSubscription<User?> loginStateSubscription;
  String fileName = '';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String path = '';
  String userUid = FirebaseAuth.instance.currentUser!.uid;
  File? imageFile;
  final FirebaseStorage storage = FirebaseStorage.instance;
  bool? admin = false;
  bool? downloadUrl;
  bool? checkComment;
  bool? checkFullName = false;
  late String fullName1;
  List list5 = ['1', '2', '3', '4'];
  static final customCacheManager = CacheManager(Config(
    'customCacheKey',
    stalePeriod: const Duration(days: 3),
    maxNrOfCacheObjects: 100,
  ));

  Future<void> refreshList() async {
    await Future.delayed(const Duration(seconds: 1, milliseconds: 2));
  }

  @override
  void initState() {
    final authBloc = Provider.of<AuthBloc>(context, listen: false);
    loginStateSubscription = authBloc.currentUser.listen((fbUser) {
      if (fbUser == null) {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const Home()),
              (route) => false);
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
    final authBloc = Provider.of<AuthBloc>(context);
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userUid)
            .snapshots(),
        builder: (context, snapshot) {
          var profileName = snapshot.data?.get('profileUrl');
          var userEmail = snapshot.data?.get('email');
          var downloadUrlProfile = snapshot.data?.get('downloadUrl');
          var fullName = snapshot.data?.get('fullName');
          final commentUid = snapshot.data?['comment'] ?? 0;
          var accountCreated = snapshot.data
              ?.get('accountCreated')
              .toDate()
              .toString()
              .substring(0, 16);
          snapshot.data?.data()?.forEach((key, value) {
            if (key == 'downloadUrl') {
              downloadUrl = value == '';
            }
            if (key == 'downloadUrl') {
              checkComment = value?.length == 0;
            }
            if (key == 'admin') {
              admin = value == '';
            }
            if (key == 'fullName') {
              checkFullName = value == '';
            }
          });
          if (snapshot.data == null) {
            return Container();
          }
          return Scaffold(
            appBar: AppBar(
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.question_mark_rounded),
                  iconSize: 25,
                  color: Colors.white,
                  onPressed: () => {
                    Navigator.push(
                      context,
                      PageTransition(
                          type: PageTransitionType.fade,
                          child: const ReandomScreen()),
                    )
                  },
                ),
              ],
              iconTheme: const IconThemeData(
                color: Colors.white,
              ),
              systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarColor: Colors.grey[850],
                  statusBarIconBrightness: Brightness.light,
                  statusBarBrightness: Brightness.light),
              backgroundColor: Colors.grey[850],
              title: const Text('Profile'),
              centerTitle: true,
              titleTextStyle: const TextStyle(
                color: Colors.white,
              ),
              elevation: 0.0,
            ),
            backgroundColor: Colors.grey[850],
            body: GestureDetector(
              onHorizontalDragEnd: (DragEndDetails details) {
                if (details.primaryVelocity! > 0) {
                } else if (details.primaryVelocity! < 0) {
                  Navigator.pop(context);
                }
              },
              child: RefreshIndicator(
                onRefresh: () => refreshList().then((value) => setState(() {})),
                child: ListView(
                  children: [
                    Column(
                      children: [
                        Row(
                          children: [
                            const SizedBox(
                              width: 10,
                            ),
                            downloadUrl!
                                ? FutureBuilder(
                                    future: downloadURL(profileName),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<String> snapshot) {
                                      if (snapshot.connectionState ==
                                              ConnectionState.done &&
                                          snapshot.hasData) {
                                        return Center(
                                            child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10.0),
                                          child: SizedBox(
                                            height: 100,
                                            width: 100,
                                            child: FittedBox(
                                              fit: BoxFit.contain,
                                              child: GestureDetector(
                                                  child: CircleAvatar(
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    backgroundImage:
                                                        NetworkImage(
                                                            snapshot.data!),
                                                    radius: 10.0,
                                                  ),
                                                  onTap: () => {
                                                        bottomSheet(profileName)
                                                      }),
                                            ),
                                          ),
                                        ));
                                      }
                                      if (snapshot.connectionState ==
                                              ConnectionState.waiting ||
                                          snapshot.hasData) {
                                        return const SpinKitDualRing(
                                          size: 40,
                                          color: Colors.grey,
                                        );
                                      }
                                      return const SizedBox(
                                        height: 100,
                                        width: 100,
                                      );
                                    })
                                : fileName == ''
                                    ? GestureDetector(
                                        onLongPress: () => Navigator.of(context)
                                            .push(PageTransition(
                                                type: PageTransitionType.fade,
                                                child: ShowPictureScreen(
                                                  photoUrl: profileName,
                                                ))),
                                        onTap: () => bottomSheet(profileName),
                                        child: CachedNetworkImage(
                                          cacheManager: customCacheManager,
                                          key: UniqueKey(),
                                          imageUrl: downloadUrlProfile,
                                          imageBuilder:
                                              (context, imageProvider) =>
                                                  SizedBox(
                                            height: 100,
                                            width: 100,
                                            child: FittedBox(
                                              fit: BoxFit.contain,
                                              child: CircleAvatar(
                                                backgroundColor:
                                                    Colors.transparent,
                                                backgroundImage: imageProvider,
                                                radius: 10.0,
                                              ),
                                            ),
                                          ),
                                          placeholder: (context, url) =>
                                              const SizedBox(
                                            height: 100,
                                            width: 100,
                                          ),
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.error),
                                        ),
                                      )
                                    : Center(
                                        child: SizedBox(
                                        height: 100,
                                        width: 100,
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: CircleAvatar(
                                            backgroundColor: Colors.transparent,
                                            backgroundImage:
                                                FileImage(imageFile!),
                                            radius: 10.0,
                                          ),
                                        ),
                                      )),
                            const SizedBox(
                              width: 50,
                            ),
                            checkFullName!
                                ? Center(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 5.0),
                                      child: GestureDetector(
                                          onLongPress: () => openDialog(userUid,
                                              accountCreated, userEmail),
                                          onTap: () => bottomSheet1(),
                                          child: const Text('No display name',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15.0))),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      GestureDetector(
                                          onLongPress: () => openDialog(userUid,
                                              accountCreated, userEmail),
                                          onTap: () => bottomSheet1(),
                                          child: SizedBox(
                                            width: 190,
                                            child: Text(fullName,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.white,
                                                    fontSize: 17.0)),
                                          )),
                                      IconButton(
                                        icon: const Icon(Icons.logout),
                                        color: Colors.white,
                                        iconSize: 25,
                                        onPressed: () async =>
                                            {await authBloc.logout()},
                                      ),
                                    ],
                                  ),
                          ],
                        ),

                        admin!
                            ? Container()
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: () => Navigator.push(
                                        context,
                                        PageTransition(
                                            type:
                                                PageTransitionType.rightToLeft,
                                            child: const AddMovie())),
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: Colors.grey,
                                      elevation: 0.0,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.zero,
                                      ),
                                    ),
                                    child: const Text('Add Movies'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.push(
                                        context,
                                        PageTransition(
                                            type:
                                                PageTransitionType.rightToLeft,
                                            child: const SuggestComment())),
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: Colors.grey,
                                      elevation: 0.0,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.zero,
                                      ),
                                    ),
                                    child: const Text('Add Comment'),
                                  ),
                                ],
                              ),
                        const SizedBox(
                          height: 50,
                        ),
                        const Center(
                          child: Text('My comment',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 15.0)),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        //My comment
                        checkComment!
                            ? const Text(
                                'No comment found.',
                                style: TextStyle(color: Colors.white),
                              )
                            : ListView.builder(
                                reverse: true,
                                physics: const BouncingScrollPhysics(),
                                itemCount: commentUid?.length,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  return StreamBuilder(
                                      stream: FirebaseFirestore.instance
                                          .collection("usersComment")
                                          .doc(commentUid[index])
                                          .snapshots(),
                                      builder: (context,
                                          AsyncSnapshot<DocumentSnapshot>
                                              snapshot) {
                                        var name = snapshot.data?.get('name');
                                        var comment =
                                            snapshot.data?.get('comment');
                                        var movieName =
                                            snapshot.data?.get('movie');
                                        var profile =
                                            snapshot.data?.get('profile');
                                        var movieUid =
                                            snapshot.data?.get('movieUid');
                                        var movieProfile =
                                            snapshot.data?.get('movieProfile');
                                        final vote =
                                            snapshot.data?['vote'] ?? list5;
                                        final countVote = vote?.length;
                                        if (!snapshot.hasData) {
                                          return Container();
                                        }
                                        return FutureBuilder(
                                            future: downloadURL(profile),
                                            builder: (BuildContext context,
                                                AsyncSnapshot<String>
                                                    snapshot) {
                                              if (snapshot.connectionState ==
                                                      ConnectionState.done &&
                                                  snapshot.hasData) {
                                                return Column(
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () => openDialog1(
                                                        movieUid,
                                                        commentUid[index],
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Stack(
                                                            children: [
                                                              SizedBox(
                                                                height: 60,
                                                                width: 60,
                                                                child:
                                                                    FittedBox(
                                                                  fit: BoxFit
                                                                      .contain,
                                                                  child:
                                                                      CircleAvatar(
                                                                    backgroundColor:
                                                                        Colors
                                                                            .transparent,
                                                                    backgroundImage:
                                                                        NetworkImage(
                                                                            snapshot.data!),
                                                                    radius:
                                                                        10.0,
                                                                  ),
                                                                ),
                                                              ),
                                                              //movie Profile
                                                              FutureBuilder(
                                                                  future: downloadURL1(
                                                                      movieProfile),
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
                                                                            const EdgeInsets.only(
                                                                          left:
                                                                              15.0, //Left
                                                                          top:
                                                                              20.0, //top
                                                                        ),
                                                                        child:
                                                                            SizedBox(
                                                                          height:
                                                                              47,
                                                                          width:
                                                                              47,
                                                                          child:
                                                                              FittedBox(
                                                                            fit:
                                                                                BoxFit.contain,
                                                                            child:
                                                                                CircleAvatar(
                                                                              backgroundColor: Colors.transparent,
                                                                              backgroundImage: NetworkImage(snapshot.data!),
                                                                              radius: 10.0,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      );
                                                                    }
                                                                    if (snapshot.connectionState ==
                                                                            ConnectionState
                                                                                .waiting ||
                                                                        snapshot
                                                                            .hasData) {
                                                                      return Container();
                                                                    }
                                                                    return Container();
                                                                  }),
                                                            ],
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 15.0),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                SizedBox(
                                                                  width: 300,
                                                                  child: Text(
                                                                    '$name  ($movieName)',
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w400,
                                                                        fontSize:
                                                                            11),
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
                                                                        color: Colors
                                                                            .white,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w700,
                                                                        fontSize:
                                                                            15),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 10,
                                                                ),
                                                                Text(
                                                                  'Vote: $countVote',
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          10,
                                                                      color: Colors
                                                                          .white),
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
                                                return ListView.builder(
                                                    physics:
                                                        const BouncingScrollPhysics(),
                                                    itemCount:
                                                        commentUid?.length,
                                                    shrinkWrap: true,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return const SizedBox(
                                                        height: 25,
                                                      );
                                                    });
                                              }
                                              return Container();
                                            });
                                      });
                                }),
                        const SizedBox(
                          height: 17,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  void selectFile(profileName) async {
    final XFile? results =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 25);

    if (results != null) {
      path = results.path;
      fileName = results.name;
      bottomSheet(profileName);
      //storage.uploadFile(path, fileName);
      setState(() {});
      print(fileName);
      print(path);
    } else {
      print('No image picked');
    }
    setState(() {
      imageFile = File(results!.path);
    });
  }

  Future<String> downloadURL(String imageName) async {
    try {
      String downloadURL =
          await storage.ref('images/$imageName').getDownloadURL();
      await firestore.collection("users").doc(userUid).update({
        'downloadUrl': downloadURL,
      });
      print(downloadURL);
      return downloadURL;
    } on FirebaseException catch (e) {
      print(e);
    }
    return downloadURL(imageName);
  }

//Dialog show Uid
  Future openDialog(userUid, accountCreated, userEmail) => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: const Center(child: Text('User Info')),
            content: (SelectableText(
                // ignore: prefer_interpolation_to_compose_strings
                'User Uid:'
                        '\n' +
                    userUid +
                    '\nJoined at:\n' +
                    accountCreated +
                    '\nEmail:\n' +
                    userEmail)),
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

//Change display name
  Future bottomSheet1() => showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          width: 900,
          height: 200,
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
                height: 11,
              ),
              TextFormField(
                inputFormatters: [
                  LengthLimitingTextInputFormatter(20),
                ],
                decoration: const InputDecoration(
                    errorStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    hintText: 'New Display Name',
                    hintStyle: TextStyle(fontSize: 12)),
                onChanged: (value) {
                  setState(() {
                    fullName1 = value.trim();
                  });
                },
              ),
              ElevatedButton(
                onPressed: () async => {
                  await firestore.collection("users").doc(userUid).update({
                    'fullName': fullName1,
                  }),
                  Navigator.pop(context)
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.grey,
                  elevation: 0.0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                child: const Text('Confirm'),
              ),
            ],
          ),
        );
      });

//Change profile picture
  Future bottomSheet(profileName) => showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
            width: 900,
            height: 200,
            child: fileName == ''
                ? Column(
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
                        height: 11,
                      ),
                      ElevatedButton(
                        onPressed: () async => {
                          selectFile(profileName),
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.grey,
                          elevation: 0.0,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        child: const Text('Gallery'),
                      ),
                    ],
                  )
                : Column(
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
                        height: 11,
                      ),
                      ElevatedButton(
                        onPressed: () async => {
                          profileName == 'profil.png'
                              ? {
                                  Fluttertoast.showToast(
                                    msg: 'Done!! Please wait a minute',
                                    gravity: ToastGravity.TOP,
                                    toastLength: Toast.LENGTH_SHORT,
                                    backgroundColor: Colors.transparent,
                                    textColor: Colors.white,
                                  ),
                                  DataBase().uploadImage(path, fileName).then(
                                        (value) => firestore
                                            .collection("users")
                                            .doc(userUid)
                                            .update({
                                          'downloadUrl': '',
                                        }),
                                      ),
                                  Navigator.pop(context),
                                  fileName = '',
                                  path = '',
                                }
                              : {
                                  Fluttertoast.showToast(
                                    msg: 'Done!! refresh to see change',
                                    gravity: ToastGravity.TOP,
                                    toastLength: Toast.LENGTH_SHORT,
                                    backgroundColor: Colors.transparent,
                                    textColor: Colors.black,
                                  ),
                                  firestore
                                      .collection("users")
                                      .doc(userUid)
                                      .update({
                                    'downloadUrl': '',
                                  }),
                                  DataBase().uploadImage(path, fileName),
                                  Navigator.pop(context),
                                  fileName = '',
                                  path = '',
                                }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.grey,
                          elevation: 0.0,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        child: const Text('Confirm'),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            {fileName = '', path = '', Navigator.pop(context)},
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.grey,
                          elevation: 0.0,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ],
                  ));
      });
  Future openDialog1(movieUid, commentUid) => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            backgroundColor: Colors.grey,
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
                  style: TextStyle(color: Colors.greenAccent, fontSize: 16.0),
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
}
