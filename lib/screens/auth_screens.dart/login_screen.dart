import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:soical_app_pro/constants.dart';
import 'package:soical_app_pro/models/exception_handl.dart';
import 'package:soical_app_pro/models/users.dart';
import 'package:soical_app_pro/providers/auth.dart';
import 'package:soical_app_pro/screens/auth_screens.dart/signup_screen.dart';
import 'package:soical_app_pro/screens/auth_screens.dart/welcome_screen.dart';
import 'package:soical_app_pro/screens/home_screen.dart';

import 'package:soical_app_pro/widgets/transition.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  bool isHide = true;
  String? email;
  String? password;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void passVisible() {
    setState(() {
      isHide = !isHide;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void login() async {
    User _user;
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
    } else {
      return;
    }
    try {
      final response = await _auth.signInWithEmailAndPassword(
          email: email!, password: password!);

      _user = response.user!;

      if (!_user.emailVerified) {
        showErrorDial(context, 'Please verify your email', 'Login');
        return;
      }
      DocumentSnapshot userData = await usersRef.doc(_user.uid).get();
      if (!userData.exists) {
        usersRef.doc(_user.uid).set({
          'isAdmin': false,
          'isStudentOrg': false,
          'userId': _user.uid,
          'name': _user.displayName,
          'email': _user.email,
          'photoUrl': _user.photoURL,
          'bio': '',
          'timeStamp': DateTime.now().toIso8601String()
        });
        userData = await usersRef.doc(_user.uid).get();
      }
      final authPro = Provider.of<Auth>(context, listen: false);
      authPro.currentUser = AppUser.toDocument(userData);
      Navigator.of(context).pop();
      Navigator.pushReplacement(context,
          PageTransition(child: const HomeScreen(), curve: Curves.decelerate));
    } catch (error) {
      String msg = error.toString();
      if (msg.contains('user-not-found')) {
        msg = 'Could not find any user with this email';
      }
      if (msg.contains('wrong-password')) {
        msg = 'The password you enter is incorrect';
      }
      if (msg.contains('A network error')) {
        msg = 'Please check your internet connection';
      }

      showErrorDial(context, msg, 'Login');
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    'assets/images/main_top.png',
                    width: size.width * 0.35,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Image.asset(
                    'assets/images/login_bottom.png',
                    width: size.width * 0.4,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'LOGIN',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    SizedBox(height: size.height * 0.035),
                    SvgPicture.asset(
                      'assets/icons/login.svg',
                      height: size.height * 0.4,
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFieldContainer(
                            size: size,
                            child: TextFormField(
                              decoration: const InputDecoration(
                                  hintText: 'Your Email',
                                  icon: Icon(
                                    Icons.email,
                                    color: kPrimaryColor,
                                  ),
                                  border: InputBorder.none),
                              validator: (value) {
                                if (value == null) {
                                  return "Email can't be empty";
                                } else if (!value.contains('@') &&
                                    !value.contains('.com')) {
                                  return 'Enter a valid email';
                                } else {
                                  return null;
                                }
                              },
                              onSaved: (value) {
                                email = value;
                              },
                            ),
                          ),
                          TextFieldContainer(
                            size: size,
                            child: TextFormField(
                              textAlign: TextAlign.start,
                              obscureText: isHide,
                              decoration: InputDecoration(
                                  suffix: GestureDetector(
                                    onTap: passVisible,
                                    child: const Icon(
                                      Icons.visibility,
                                      color: kPrimaryColor,
                                      size: 20,
                                    ),
                                  ),
                                  hintText: 'Password',
                                  icon: const Icon(
                                    Icons.lock,
                                    color: kPrimaryColor,
                                  ),
                                  border: InputBorder.none),
                              onSaved: (value) {
                                password = value;
                              },
                              validator: (value) {
                                if (value == '') {
                                  return 'Please enter your password';
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    RoundedButton(
                        text: 'LOGIN',
                        color: kPrimaryColor,
                        textColor: Colors.white,
                        press: login),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have account?",
                          style: TextStyle(color: kPrimaryColor),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const SignupScreen())),
                          child: const Text(
                            " Sign up",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: kPrimaryColor),
                          ),
                        )
                      ],
                    )
                  ],
                )
              ],
            )),
      ),
    );
  }
}

class TextFieldContainer extends StatelessWidget {
  final Widget child;
  const TextFieldContainer({
    Key? key,
    required this.size,
    required this.child,
  }) : super(key: key);

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: kPrimaryLightColor,
      ),
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      width: size.width * 0.9,
      child: child,
    );
  }
}
