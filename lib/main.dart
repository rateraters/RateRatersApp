// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:rate_raters/SecScreen/whitesrc.dart';
import 'blocs/auth_blocs.dart';
import 'model/user_model.dart';

Future<void> firebaseMessagingBackgroundHandler(message) async {
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(const MyApp());
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final now = Timestamp.now().toDate().toString().substring(0, 16);
    return MultiProvider(
      providers: [
        Provider(create: (_) => AuthBloc(uid: '')),
        Provider(
            create: (_) => UserModel(
                uid: 'uid',
                email: 'email',
                fullName: 'fullName',
                profileUrl: 'profileUrl',
                admin: '',
                accountCreated: now,
                addedMovies: [],
                favMovies: [],
                comment: [],
                string1: '',
                string2: '',
                string3: '',
                string4: '',
                string5: '',
                list1: [],
                list2: [],
                list3: [],
                list4: [],
                list5: [])),
        Provider(create: (_) => User),
      ],
      child: MaterialApp(
        title: 'RateRaters',
        theme: ThemeData.light(),
        home: const WhiteScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
