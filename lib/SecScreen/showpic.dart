import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:pinch_zoom_release_unzoom/pinch_zoom_release_unzoom.dart';

class ShowPictureScreen extends StatelessWidget {
  final String photoUrl;
  ShowPictureScreen({Key? key, required this.photoUrl}) : super(key: key);

  final FirebaseStorage storage = FirebaseStorage.instance;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black45,
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            const SizedBox(
              height: 170,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FutureBuilder(
                    future: downloadURL(photoUrl),
                    builder:
                        (BuildContext context, AsyncSnapshot<String> snapshot) {
                      if (snapshot.connectionState == ConnectionState.done &&
                          snapshot.hasData) {
                        return PinchZoomReleaseUnzoomWidget(
                            child: Image.network(snapshot.data!));
                      }
                      return Container();
                    }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<String> downloadURL(String photoUrl) async {
    try {
      String downloadURL =
          await storage.ref('images/$photoUrl').getDownloadURL();
      // ignore: avoid_print
      print(downloadURL);
      return downloadURL;
    } on FirebaseException catch (e) {
      // ignore: avoid_print
      print(e);
    }
    return downloadURL(photoUrl);
  }
}
