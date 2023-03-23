import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:rate_raters/Src/reviews.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final FirebaseStorage storage = FirebaseStorage.instance;
  List searchResult = [];
  final FocusNode _focusNode = FocusNode();
  List list5 = ['1', '2', '3', '4'];
  final TextEditingController _controller = TextEditingController();

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

  Future<void> refreshList() async {
    await Future.delayed(const Duration(seconds: 1, milliseconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("movies")
            .doc('Model')
            .snapshots().take(1)
            ,
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }

          var listMovies = snapshot.data?["listMovies"] ?? list5;
          listMovies?.shuffle();
          return Scaffold(
            appBar: AppBar(
              iconTheme: const IconThemeData(
                color: Colors.white,
              ),
              systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarColor: Colors.grey[850],
                  statusBarIconBrightness: Brightness.light,
                  statusBarBrightness: Brightness.light),
              backgroundColor: Colors.grey[850],
              title: TextFormField(
                  controller: _controller,
                  style: const TextStyle(color: Colors.white),
                  focusNode: _focusNode,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                      errorStyle: TextStyle(color: Colors.grey),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      hintText: 'search',
                      hintStyle: TextStyle(color: Colors.white, fontSize: 15)),
                  onChanged: (query) {
                      search(query);
                  }),
              elevation: 0.0,
            ),
            backgroundColor: Colors.grey[850],
            body: GestureDetector(
              onHorizontalDragEnd: (DragEndDetails details) {
                if (details.primaryVelocity! > 0) {
                  Navigator.pop(context);
                } else if (details.primaryVelocity! < 0) {}
              },
              child: RefreshIndicator(
                onRefresh: () => refreshList().then((value) => setState(() {})),
                child: ListView(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    _controller.text.isEmpty
                        ? Column(
                            children: [
                              const Center(
                                  child: Text(
                                '2 movies for you',
                                style: TextStyle(color: Colors.white),
                              )),
                              const SizedBox(
                                height: 10,
                              ),
                              GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                          mainAxisSpacing: 11.0,
                                          crossAxisSpacing: 5.0,
                                          crossAxisCount: 2),
                                  reverse: false,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: 2,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    return StreamBuilder(
                                        stream: FirebaseFirestore.instance
                                            .collection("movies")
                                            .doc(listMovies[index])
                                            .snapshots().take(1)
                                            ,
                                        builder: (context,
                                            AsyncSnapshot<DocumentSnapshot>
                                                snapshot) {
                                          var file = snapshot.data?['profile'];
                                          var title = snapshot.data?['title'];
                                          if (snapshot.data == null) {
                                            return Container();
                                          }
                                          return FutureBuilder(
                                              future: downloadURL(file),
                                              builder: (BuildContext context,
                                                  AsyncSnapshot<String>
                                                      snapshot) {
                                                if (snapshot.connectionState ==
                                                        ConnectionState.done &&
                                                    snapshot.hasData) {
                                                  return GestureDetector(
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
                                                                  listMovies[
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
                                              });
                                        });
                                  }),
                            ],
                          )
                        : GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisSpacing: 5.0, crossAxisCount: 2),
                            reverse: false,
                            physics: const BouncingScrollPhysics(),
                            itemCount: searchResult.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              var file = searchResult[index]['profile'];
                              var title = searchResult[index]['title'];
                              var id = searchResult[index]['id'];
                              return FutureBuilder(
                                  future: downloadURL(file),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<String> snapshot) {
                                    if (snapshot.connectionState ==
                                            ConnectionState.done &&
                                        snapshot.hasData) {
                                      return GestureDetector(
                                        onTap: () => {
                                          Navigator.push(
                                            context,
                                            PageTransition(
                                                type: PageTransitionType.fade,
                                                child: ReviewsScreen(
                                                  movieUid: id,
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
                                                height: 150,
                                                child: Image.network(
                                                    snapshot.data!)),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10.0),
                                              child: Center(
                                                child: Text(
                                                  title,
                                                  style: const TextStyle(
                                                      color: Colors.white),
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
                            })
                  ],
                ),
              ),
            ),
          );
        });
  }

  void search(String query) async {
    final result = await FirebaseFirestore.instance
        .collection('movies')
        .where('title', isGreaterThanOrEqualTo: query)
        .get();

    setState(() {
      searchResult = result.docs.map((e) => e.data()).toList();
    });
  }

  Future<String> downloadURL(String imageName) async {
    try {
      String downloadURL =
          await storage.ref('movieimages/$imageName').getDownloadURL();
      // ignore: avoid_print
      print(downloadURL);
      return downloadURL;
    } on FirebaseException catch (e) {
      // ignore: avoid_print
      print(e);
    }
    return downloadURL(imageName);
  }
}
