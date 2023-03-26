import 'package:clipboard/clipboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SuggestComment extends StatefulWidget {
  const SuggestComment({super.key});

  @override
  State<SuggestComment> createState() => _SuggestCommentState();
}

class _SuggestCommentState extends State<SuggestComment> {
  String loading = '';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController title = TextEditingController();
  String pasteValue = '';

  Future<void> toast() async {
    Fluttertoast.showToast(
      msg: 'Done!',
      gravity: ToastGravity.TOP,
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: Colors.transparent,
      textColor: Colors.black,
    );
  }

  void _pasteText() {
    FlutterClipboard.paste().then((value) {
      setState(() {
        title.text = value;
        pasteValue = value;
      });
    });
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

          final suggestedComment = snapshot.data?['suggestedComment'];
          var countsuggestedComment = suggestedComment?.length;

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
              title: Text('Add Suggested Comment ($countsuggestedComment)'),
              centerTitle: true,
              titleTextStyle: const TextStyle(
                color: Colors.black,
              ),
              elevation: 0.0,
            ),
            backgroundColor: Colors.white,
            body: ListView(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: title,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                            errorStyle: TextStyle(color: Colors.grey),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                            hintText: 'Suggested Comment',
                            hintStyle: TextStyle(fontSize: 12)),
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () => _pasteText(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            width: 5.0, color: Colors.transparent),
                      ),
                      child: const Text(
                        'Paste',
                      ),
                    ),
                  ],
                ),
                loading == ''
                    ? Center(
                        child: ElevatedButton(
                          onPressed: () => {
                            if (title.text.length < 6)
                              {
                                Fluttertoast.showToast(
                                  msg: 'Too short!!',
                                  gravity: ToastGravity.TOP,
                                  toastLength: Toast.LENGTH_SHORT,
                                  backgroundColor: Colors.grey[400],
                                  textColor: Colors.black,
                                )
                              }
                            else
                              {
                                setState(() {
                                  loading = 'None';
                                }),
                                Fluttertoast.showToast(
                                  msg: 'Done',
                                  gravity: ToastGravity.TOP,
                                  toastLength: Toast.LENGTH_SHORT,
                                  backgroundColor: Colors.grey[400],
                                  textColor: Colors.black,
                                ),
                                firestore
                                    .collection("movies")
                                    .doc('Model')
                                    .update({
                                  'suggestedComment':
                                      FieldValue.arrayUnion([title.text])
                                }).then(
                                  (value) => setState(() {
                                    title.text = '';
                                    loading = '';
                                  }),
                                )
                              }
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
                    : const Center(child: Text('Loading...')),
                const SizedBox(
                  height: 10,
                ),
                const Divider(
                  color: Colors.grey,
                ),
                 ListView.builder(
                    reverse: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: suggestedComment?.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () => openDialog1(suggestedComment[index]),
                        child: SizedBox(
                          height: 50,
                          child: Text(suggestedComment[index])),
                      );
                    }),
              ],
            ),
          );
        });
  }
    Future openDialog1(commentTitle) => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            backgroundColor: Colors.grey,
            actions: [
              OutlinedButton(
                onPressed: () => {
                  toast(),
                  Navigator.pop(context),
                 firestore.collection("movies").doc('Model').update({
        'suggestedComment': FieldValue.arrayRemove([commentTitle])
      }).then((value) => setState(() {
        
      }))
      
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
}
