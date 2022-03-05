import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:soical_app_pro/models/exception_handl.dart';
import 'package:soical_app_pro/providers/auth.dart';
import 'package:soical_app_pro/screens/home_screen.dart';
import 'package:soical_app_pro/widgets/forms.dart';
import 'package:soical_app_pro/widgets/transition.dart';

import '../../constants.dart';

import 'login_screen.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authPro = Provider.of<Auth>(context, listen: false);
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: Stack(
            alignment: Alignment.center,
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
              SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: size.height * 0.035,
                    ),
                    const Text(
                      "Sign up",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    SizedBox(
                      height: size.height * 0.025,
                    ),
                    SvgPicture.asset(
                      'assets/icons/signup.svg',
                      width: size.width * 0.5,
                    ),
                    FormsWid(size: size),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have account?",
                          style: TextStyle(color: kPrimaryColor),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => LoginScreen()));
                            },
                            child: const Text(
                              " Log in",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: kPrimaryColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const OrDivider(),
                    GestureDetector(
                      onTap: () async {
                        try {
                          final response = await authPro.loginWithGoogle();
                          if (response) {
                            Navigator.of(context).pop();
                            Navigator.pushReplacement(
                                context,
                                PageTransition(
                                    child: const HomeScreen(),
                                    curve: Curves.fastLinearToSlowEaseIn));
                          }
                        } catch (err) {
                          showErrorDial(
                              context, err.toString(), 'An error occurred');
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                            border: Border.all(), shape: BoxShape.circle),
                        child: SvgPicture.asset(
                          'assets/icons/google-plus.svg',
                          height: size.height * 0.03,
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class OrDivider extends StatelessWidget {
  const OrDivider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width * 0.8,
      child: Row(
        children: const [
          Expanded(
            child: Divider(
              height: 1.5,
              color: kPrimaryColor,
            ),
          ),
          Text(
            'OR',
            style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Divider(
              height: 1.5,
              color: kPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
