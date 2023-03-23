import 'dart:io';

import 'package:clipboard/clipboard.dart';
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
  final TextEditingController title = TextEditingController();
  String loading = '';
  String imgSize = 'None';
  int imgSize2 = 100;
  final uuid = const Uuid();  
  String pasteValue = '';


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
            fileName == ''
                ? GestureDetector(
                    onTap: () => selectFile(),
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
                            child: Image.file(imageFile!)
                          ),
                        ),
                      )),
                    ],
                  ),
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
                        hintText: 'Movie title',
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
            const SizedBox(
              height: 12,
            ),
            Text(imgSize),
            Text(imgSize2.toString()),
            const Text('Notice: \nImage has more than 100 KB can`t be upload'),
            loading == ''
                ? Center(
                    child: ElevatedButton(
                      onPressed: () => {
                        if (fileName == '' ||
                            imageFile == null ||
                            title.text.isEmpty)
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
                            if(imgSize2 > 100){
                              Fluttertoast.showToast(
                              msg: 'Image has more than 100 KB (Can`t be upload)',
                              gravity: ToastGravity.TOP,
                              toastLength: Toast.LENGTH_SHORT,
                              backgroundColor: Colors.grey[400],
                              textColor: Colors.black,
                            )
                            }else{
                            setState(() {
                              loading = 'None';
                            }),
                            DataBase()
                                .addMovie(
                                    title.text, fileName, path, userUid, uuid.v1())
                                .then((value) => Navigator.pop(context))
                          }}
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
    final XFile? results = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 15,
    );

    if (results != null) {
      path = results.path;
      fileName = uuid.v4();
      setState(() {});
      final File file = File(results.path);
      final int fileSizeInBytes = await file.length();
      final int imageInt = fileSizeInBytes ~/ 1024;
      final double fileSizeInKB = fileSizeInBytes / 1024;
      final double fileSizeInMB = fileSizeInKB / 1024;
      imgSize =
          'Size: ${fileSizeInKB.toStringAsFixed(1)} KB or ${fileSizeInMB.toStringAsFixed(2)} MB';
      //String fileSizeString = fileSizeInKB.toStringAsFixed(1);
      imgSize2 = imageInt; 
     
    } else {
      // ignore: avoid_print
      print('No image picked');
    }
    setState(() {
      imageFile = File(results!.path);
    });
  }
}
