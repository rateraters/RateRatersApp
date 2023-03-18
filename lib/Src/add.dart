import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rate_raters/services/database.dart';
import 'package:uuid/uuid.dart';

class AddMovie extends StatefulWidget {
  const AddMovie({
    Key? key,
  }) : super(key: key);

  @override
  State<AddMovie> createState() => _AddMovieState();
}

class _AddMovieState extends State<AddMovie> {
  String userUid = FirebaseAuth.instance.currentUser!.uid;
  final ImagePicker picker = ImagePicker();
  String fileName = '';
  String path = '';
  File? imageFile;
  String? title;
  String loading = '';
  final uuid = const Uuid();

  @override
  Widget build(BuildContext context) {
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
          title: const Text('Add Movie'),
          centerTitle: true,
          titleTextStyle: const TextStyle(
            color: Colors.black,
          ),
          elevation: 0.0,
        ),
        backgroundColor: Colors.white,
        body: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
          fileName ==''
          ? GestureDetector(
            onTap:() => selectFile(),
            child: const Center(child: Text('Select file')))
          : Column(
                  children: [
                    Center(child: Text(fileName)),
                    Center(
                        child: GestureDetector(
                          onTap: () => selectFile(),
                          child: SizedBox(
                          height: 130,
                          width: 130,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: CircleAvatar(
                              backgroundColor: Colors.transparent,
                              backgroundImage: FileImage(imageFile!),
                              radius: 10.0,
                            ),
                          ),
                                              ),
                        )),
                  ],
                ),
            TextFormField(
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                  errorStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  hintText: 'Movie title',
                  hintStyle: TextStyle(fontSize: 12)),
              onChanged: (value) {
                setState(() {
                  title = value.trim();
                });
              },
            ),
            const SizedBox(
              height: 12,
            ),
            loading == ''
                ? Center(
                    child: ElevatedButton(
                      onPressed: () => {
                        if (fileName == '' ||
                            imageFile == null ||
                            title!.isEmpty)
                          {
                            Fluttertoast.showToast(
                              msg: 'Please fill out the necessary details',
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
                            DataBase()
                                .addMovie(
                                    title, fileName, path, userUid, uuid.v1())
                                .then((value) => Navigator.pop(context))
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
                      child: const Text('Upload'),
                    ),
                  )
                : const Text('Processing...')
          ],
        ));
  }

  void selectFile() async {
    final XFile? results =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 25);

    if (results != null) {
      path = results.path;
      fileName = uuid.v4();
      //storage.uploadFile(path, fileName);
      setState(() {});
      // ignore: avoid_print
      print(fileName);
      // ignore: avoid_print
      print(path);
    } else {
      // ignore: avoid_print
      print('No image picked');
    }
    setState(() {
      imageFile = File(results!.path);
    });
  }
}
