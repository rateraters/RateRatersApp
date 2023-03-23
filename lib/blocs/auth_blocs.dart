// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:page_transition/page_transition.dart';
import 'package:rate_raters/Src/home.dart';
import '../Services/auth_services.dart';
import '../Services/database.dart';
import '../Src/login.dart';
import '../model/user_model.dart';

class AuthBloc {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String uid;
  AuthBloc({required this.uid});
  final auth = FirebaseAuth.instance;
  final authService = AuthService();
  final googleSignin = GoogleSignIn(scopes: [
    'email',
  ]);
  final now = Timestamp.now().toDate().toString().substring(0, 16);

  Stream<User?> get currentUser => authService.currentUser;

  ///google signin
  loginGoogle(BuildContext context) async {
    String retVal = "error";
    try {
      final GoogleSignInAccount? googleUser = await googleSignin.signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth?.idToken, accessToken: googleAuth?.accessToken);
      UserCredential authResult =
          await authService.signInWithCredential(credential);
  
      if (authResult.additionalUserInfo!.isNewUser) {
        UserModel user = UserModel(
          uid: authResult.user!.uid,
          email: authResult.user!.email!,
          fullName: authResult.user!.displayName!,
          profileUrl: '',
          admin: '',
          downloadUrl: '',
          accountCreated: now,
          favMovies: [],
          comment: [],
        );
        String returnString = await DataBase().createUser(user);
        Navigator.pushAndRemoveUntil(
            context,
            PageTransition(
                type: PageTransitionType.rightToLeft, child: const Home()),
            (route) => false);
        if (returnString == "success") {
          retVal = "success";
        }
      } else {
        Navigator.pushAndRemoveUntil(
            context,
            PageTransition(
                type: PageTransitionType.rightToLeft, child: const Home()),
            (route) => false);
      }
      retVal = "success";
    } on PlatformException catch (e) {
      // ignore: avoid_print
      print(e);
    }
    return retVal;
  }

  //delete acc With Google
  deleteAcc(BuildContext context, String password) async {
    final user = FirebaseAuth.instance.currentUser;
    final credential =
        EmailAuthProvider.credential(email: user!.email!, password: password);
    try {
      await FirebaseAuth.instance.currentUser
          ?.reauthenticateWithCredential(credential);
      FirebaseAuth.instance.currentUser?.delete();
      FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
      googleSignin.disconnect();
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false);
      Fluttertoast.showToast(
        msg: 'Your account has been deleted',
        gravity: ToastGravity.TOP,
        toastLength: Toast.LENGTH_LONG, //duration 5sec
        backgroundColor: Colors.grey[400],
        textColor: Colors.black,
      );
    } on FirebaseAuthException {
      Fluttertoast.showToast(
        msg: 'Wrong password',
        gravity: ToastGravity.TOP,
        toastLength: Toast.LENGTH_LONG, //duration 5sec
        backgroundColor: Colors.grey[400],
        textColor: Colors.black,
      );
    }
  }

//Sign Out With Google
  logout() async {
    try {
      await googleSignin.disconnect();
      await auth.signOut();
    } on PlatformException {
      auth.signOut();
    }
  }
}
