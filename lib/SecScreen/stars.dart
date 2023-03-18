import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rate_raters/services/database.dart';

class RatingStars extends StatefulWidget {
  final String movieUid;
  const RatingStars({super.key, required this.movieUid});

  @override
  State<RatingStars> createState() => _RatingStarsState();
}

class _RatingStarsState extends State<RatingStars> {
  double rating = 1;

  String getRatingString() {
    return '$rating';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          centerTitle: true,
           iconTheme: const IconThemeData(
                color: Colors.white,
              ),
          systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.dark),
        ),
        backgroundColor: Colors.black87,
        body: 
               ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                 
                  const SizedBox(
                    height: 300,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      RatingBar.builder(
                        glowColor: Colors.black,
                        unratedColor: Colors.white,
                        initialRating: 1,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: false,
                        itemCount: 5,
                        itemPadding:
                            const EdgeInsets.symmetric(horizontal: 4.0),
                        itemBuilder: (context, _) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (newRating) {
                          setState(() {
                            rating = newRating;
                          });
                        },
                      ),
                      Text(
                        getRatingString().substring(0, 1),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Center(
                        child: GestureDetector(
                          onTap: ()  =>   DataBase()
                              .rateStars(widget.movieUid, getRatingString())
                              .then((value) => Navigator.pop(context))
                              .then((value) => Fluttertoast.showToast(
                                    msg: 'Done!!',
                                    gravity: ToastGravity.TOP,
                                    toastLength:
                                        Toast.LENGTH_SHORT, //duration 5sec
                                    backgroundColor: Colors.grey[400],
                                    textColor: Colors.black,
                                  )),
                          child: const Text('Confirm',style: TextStyle(
                            fontSize: 15,
                            color: Colors.white),),
                        ),
                      ),
                     
                    ],
                  ),
                ],
              )
      ),
    );
  }
}
