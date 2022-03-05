import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:soical_app_pro/constants.dart';
import 'package:soical_app_pro/screens/auth_screens.dart/welcome_screen.dart';

import 'package:soical_app_pro/widgets/transition.dart';

import 'login_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;

  const EmailVerificationScreen({Key? key, required this.email})
      : super(key: key);

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? user;

  @override
  void initState() {
    user = _auth.currentUser;
    user!.sendEmailVerification();

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        body: SizedBox(
      height: size.height,
      width: size.width,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: Image.asset(
              'assets/images/signup_top.png',
              width: size.width * 0.35,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Image.asset(
              'assets/images/main_bottom.png',
              width: size.width * 0.3,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/email_icon.png',
                  width: size.width * 0.3,
                ),
                SizedBox(
                  height: size.height * 0.05,
                ),
                const Text(
                  'Verify your email address',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  margin: EdgeInsets.symmetric(horizontal: 22),
                  child: RichText(
                      textAlign: TextAlign.center,
                      softWrap: true,
                      text: TextSpan(children: [
                        const TextSpan(
                          text:
                              'Please click on the link that has just been sent to email ',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                        TextSpan(
                            text: '${widget.email}',
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                        const TextSpan(
                          text: ' to verify your account. ',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        )
                      ])),
                ),
                const SizedBox(
                  height: 20,
                ),
                RoundedButton(
                    text: 'Continue',
                    color: kPrimaryColor.withOpacity(0.7),
                    textColor: Colors.white,
                    press: () => Navigator.pushReplacement(
                        context,
                        PageTransition(
                            child: LoginScreen(), curve: Curves.decelerate)))
              ],
            ),
          )
        ],
      ),
    ));
  }
}
