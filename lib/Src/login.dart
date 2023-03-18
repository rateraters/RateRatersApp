import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../blocs/auth_blocs.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final authBloc = Provider.of<AuthBloc>(context);
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
        title: Text(
          'RateRaters',
          style: GoogleFonts.bangers(fontSize: 20),
        ),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Color(0xffEA828E),
        ),
        elevation: 0.0,
      ),
      backgroundColor: Colors.grey[850],
      body: GestureDetector(
        onHorizontalDragEnd: (DragEndDetails details) {
          if (details.primaryVelocity! > 0) {
            Navigator.pop(context);
          } else if (details.primaryVelocity! < 0) {
            Navigator.pop(context);
          }
        },
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            const SizedBox(
              height: 20,
            ),
            const Center(
                child: Text(
              'Log in/ Sign up',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25,
                color: Colors.white,
              ),
            )),
            const SizedBox(
              height: 15,
            ),
            const Center(
              child: Text(
                'Comment on your favourite movies.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Image.asset('assets/images/logo3.png'),
            const Text(
              'Note:\nto make the app look more simple and easy to access we decided to remove Facebook and email signin.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Center(
              child: SignInButton(
                Buttons.Google,
                onPressed: () async => {await authBloc.loginGoogle(context)},
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () async => {
                // ignore: deprecated_member_use
                await launch('https://rateraters.github.io/terms.html')
              },
              child: const Text(
                'By continue means that you accept our Terms and User privacy policy.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
