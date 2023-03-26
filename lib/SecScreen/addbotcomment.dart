import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:rate_raters/services/database.dart';
import 'package:username_gen/username_gen.dart';
import 'package:uuid/uuid.dart';

class BotComment extends StatefulWidget {
  final String movieUid;
  const BotComment({super.key, required this.movieUid});

  @override
  State<BotComment> createState() => _BotCommentState();
}

class _BotCommentState extends State<BotComment> {
  String loading = '';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final uuid = const Uuid();
  double rating = 1;


  String getRatingString() {
    return '$rating';
  }

  String generateUsername() {
    final username = UsernameGen().generate();
    return username;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("movies")
            .doc(widget.movieUid)
            .snapshots().take(1)
            ,
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          var title = snapshot.data?.get('title');
          var profileUrl = snapshot.data?.get('profile');
          final botComment = snapshot.data?['botComment'];
          var countBotComment = botComment?.length;
          final botLikes = snapshot.data?['botLikes'];
          var countBotLikes = botLikes?.length;
          final botStars = snapshot.data?['botStars'];
          var countBotStars = botStars?.length;
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
                final suggestComment = snapshot.data?["suggestedComment"];
                suggestComment?.shuffle();
                return Scaffold(
                  appBar: AppBar(
                    iconTheme: const IconThemeData(
                      color: Colors.black,
                    ),
                    systemOverlayStyle: const SystemUiOverlayStyle(
                        statusBarColor: Colors.white,
                        statusBarIconBrightness: Brightness.dark,
                        statusBarBrightness: Brightness.light),
                    backgroundColor: Colors.white,
                    title: const Text('Add Bot Comment'),
                    centerTitle: true,
                    titleTextStyle: const TextStyle(
                      color: Colors.black,
                    ),
                    elevation: 0.0,
                  ),
                  backgroundColor: Colors.white,
                  body: ListView(
                    children: [
              
                      const Center(
                          child: Text(
                        'Bot name:',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      )),
                      Center(child: Text(generateUsername())),
                      ListView.builder(
                          reverse: true,
                          physics: const BouncingScrollPhysics(),
                          itemCount: 1,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                const Center(
                                    child: Text(
                                  'Random Comment:',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                )),
                                Center(child: Text(suggestComment[index])),
                                const Text(
                                  'Count bot comment:',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                ),
                                Text('($countBotComment)'),
                                loading == ''
                                    ? Center(
                                        child: ElevatedButton(
                                          onPressed: () => {
                                            loading = 'None',
                                            addComment(
                                                    suggestComment[index],
                                                    generateUsername(),
                                                    widget.movieUid,
                                                    uuid.v4(),
                                                    title,
                                                    profileUrl)
                                                .then(
                                                    (value) => setState(() {}))
                                                .then(
                                                  (value) => loading = '',
                                                )
                                          },
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: Colors.black,
                                            backgroundColor: Colors.white,
                                            elevation: 0.0,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.zero,
                                            ),
                                          ),
                                          child: const Text('Upload'),
                                        ),
                                      )
                                    : const Center(child: Text('Uploading...')),
                              ],
                            );
                          }),
                      const SizedBox(
                        height: 10,
                      ),
                      IconButton(
                          color: Colors.grey,
                          tooltip: 'Reload',
                          icon: const Icon(Icons.replay_outlined),
                          iconSize: 25,
                          onPressed: () => setState(() {})),
                      const SizedBox(
                        height: 10,
                      ),
                      const Divider(
                        color: Colors.grey,
                      ),
                      const Center(child: Text('Add bot stars')),
                      Center(child: Text('($countBotStars)')),
                      Center(
                        child: RatingBar.builder(
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
                      ),
                      loading == ''
                          ? Center(
                              child: ElevatedButton(
                                onPressed: () => {
                                  loading = 'None',
                                   firestore
                                      .collection("movies")
                                      .doc(widget.movieUid)
                                      .update({
                                        'botStars': FieldValue.arrayUnion([uuid.v4()])
                                      }),
                                  DataBase().rateStars(widget.movieUid, getRatingString(),uuid.v4())
                                      .then((value) => setState(() {}))
                                      .then(
                                        (value) => loading = '',
                                      )
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.black,
                                  backgroundColor: Colors.white,
                                  elevation: 0.0,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                  ),
                                ),
                                child: const Text('Upload'),
                              ),
                            )
                          : const Center(child: Text('Uploading...')),
                      const SizedBox(
                        height: 10,
                      ),
                      const Divider(
                        color: Colors.grey,
                      ),
                      const Center(child: Text('Add bot Likes')),
                      Center(child: Text('($countBotLikes)')),
                      loading == ''
                          ? Center(
                              child: ElevatedButton(
                                onPressed: () => {
                                  loading = 'None',
                                  firestore
                                      .collection("movies")
                                      .doc(widget.movieUid)
                                      .update({
                                        'botLikes': FieldValue.arrayUnion([uuid.v4()])
                                      }),
                                       firestore
                                      .collection("movies")
                                      .doc(widget.movieUid)
                                      .update({
                                        'upvote': FieldValue.arrayUnion([uuid.v4()])
                                      })
                                      .then((value) => setState(() {}))
                                      .then(
                                        (value) => loading = '',
                                      )
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.black,
                                  backgroundColor: Colors.white,
                                  elevation: 0.0,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                  ),
                                ),
                                child: const Text('Upload'),
                              ),
                            )
                          : const Center(child: Text('Uploading...')),
                    ],
                  ),
                );
              });
        });
  }

  //Add comment
  Future<String> addComment(
    String comment,
    String userName,
    String movieUid,
    String uuid,
    String movieName,
    String movieProfile,
  ) async {
    List<String> list = [];
    String retVal = "error";
    try {
      await firestore.collection("usersComment").doc(uuid).set({
        'name': userName,
        'profile': 'profil.png',
        'comment': comment,
        'vote': list,
        'movieProfile': movieProfile,
        'movie': movieName,
        'movieUid': movieUid,
      });

      ///
      await firestore.collection("movies").doc(movieUid).update({
        'usersComment': FieldValue.arrayUnion([uuid])
      });
      await firestore.collection("movies").doc(movieUid).update({
        'botComment': FieldValue.arrayUnion([uuid])
      });
    } on FirebaseException catch (e) {
      // ignore: avoid_print
      print(e);
    }
    return retVal;
  }
}
