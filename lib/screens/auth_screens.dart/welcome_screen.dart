import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:soical_app_pro/constants.dart';
import 'package:soical_app_pro/screens/auth_screens.dart/signup_screen.dart';
import 'package:soical_app_pro/widgets/transition.dart';

import 'login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: size.height,
          width: double.infinity,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                child: Image.asset('assets/images/main_top.png'),
                width: size.width * 0.35,
              ),
              Positioned(
                width: size.width * 0.35,
                bottom: 0,
                left: 0,
                child: Image.asset("assets/images/main_bottom.png"),
              ),
              Container(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'WELCOME TO SOCIAL APP',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: size.height * 0.05,
                    ),
                    SvgPicture.asset(
                      'assets/icons/chat.svg',
                      width: size.width * 0.8,
                    ),
                    SizedBox(
                      height: size.height * 0.05,
                    ),
                    RoundedButton(
                      text: 'LOGIN',
                      color: kPrimaryColor,
                      textColor: Colors.white,
                      press: () => Navigator.push(
                          context,
                          PageTransition(
                              child: LoginScreen(), curve: Curves.bounceInOut)),
                    ),
                    RoundedButton(
                      text: 'SIGNUP',
                      color: kPrimaryLightColor,
                      textColor: Colors.black,
                      press: () => Navigator.push(
                          context,
                          PageTransition(
                              child: SignupScreen(),
                              curve: Curves.bounceInOut)),
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

class RoundedButton extends StatelessWidget {
  final String text;
  final Color color, textColor;
  final Function? press;
  const RoundedButton({
    Key? key,
    required this.text,
    required this.color,
    required this.textColor,
    required this.press,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      width: size.width * 0.85,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: ElevatedButton(
          onPressed: press != null ? () => press!() : null,
          child: Text(
            text,
            style: TextStyle(color: textColor, fontSize: 16),
          ),
          // ignore: prefer_const_constructors
          style: ButtonStyle(
              backgroundColor:
                  MaterialStateColor.resolveWith((states) => color),
              padding: MaterialStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 20)),
              shape: MaterialStateProperty.all(const BeveledRectangleBorder()),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap),
        ),
      ),
    );
  }
}
