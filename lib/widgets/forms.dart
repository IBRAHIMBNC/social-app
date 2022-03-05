import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:soical_app_pro/models/exception_handl.dart';
import 'package:soical_app_pro/providers/auth.dart';
import 'package:soical_app_pro/screens/auth_screens.dart/login_screen.dart';
import 'package:soical_app_pro/screens/auth_screens.dart/verifing_email_screen.dart';
import 'package:soical_app_pro/screens/auth_screens.dart/welcome_screen.dart';

import 'package:soical_app_pro/widgets/transition.dart';

import '../constants.dart';

class FormsWid extends StatefulWidget {
  final Size size;
  const FormsWid({Key? key, required this.size}) : super(key: key);

  @override
  _FormsWidState createState() => _FormsWidState();
}

class _FormsWidState extends State<FormsWid> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  String? email;
  String? password;
  String? fullName;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isHide = true;

  void onSave() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        await _auth.createUserWithEmailAndPassword(
            email: email!, password: password!);

        User _user;

        _user = _auth.currentUser!;
        print(_user.uid);
        _user.updatePhotoURL(
            'https://firebasestorage.googleapis.com/v0/b/socialappforproj.appspot.com/o/profile_placeholder.png?alt=media&token=a4f222ab-aa8e-4d08-ae51-49b76f30f8dc');
        _user.updateDisplayName(fullName);

        Navigator.pushReplacement(
            context,
            PageTransition(
                child: EmailVerificationScreen(
                  email: email!,
                ),
                curve: Curves.easeInSine));
      } catch (err) {
        String msg = err.toString();
        if (msg.contains('A network error')) {
          msg = 'Please check your internet connection';
        }
        if (msg.contains('email-already-in-use')) {
          msg = 'The email you entered is already exists';
        }
        showErrorDial(context, msg, 'Signup');
      }
    }
  }

  void passVisible() {
    setState(() {
      _isHide = !_isHide;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
          autovalidateMode: AutovalidateMode.disabled,
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFieldContainer(
                size: widget.size,
                child: TextFormField(
                  decoration: const InputDecoration(
                      hintText: 'Full name',
                      icon: Icon(
                        Icons.person,
                        color: kPrimaryColor,
                      ),
                      border: InputBorder.none),
                  onSaved: (val) {
                    fullName = val;
                  },
                  validator: (value) {
                    if (value == null) return 'Enter you name';
                  },
                ),
              ),
              TextFieldContainer(
                size: widget.size,
                child: TextFormField(
                  decoration: const InputDecoration(
                      hintText: 'Email',
                      icon: Icon(
                        Icons.email,
                        color: kPrimaryColor,
                      ),
                      border: InputBorder.none),
                  onSaved: (val) {
                    email = val;
                  },
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
                ),
              ),
              TextFieldContainer(
                size: widget.size,
                child: TextFormField(
                  obscureText: _isHide,
                  decoration: InputDecoration(
                      suffix: GestureDetector(
                          onTap: passVisible,
                          child: const Icon(
                            Icons.visibility,
                            color: kPrimaryColor,
                            size: 20,
                          )),
                      hintText: 'Password',
                      icon: const Icon(
                        Icons.lock,
                        color: kPrimaryColor,
                      ),
                      border: InputBorder.none),
                  onSaved: (val) {
                    password = val;
                  },
                  validator: (value) {
                    if (value == null || value.length < 8) {
                      return "Password must be at least 8 characters";
                    } else {
                      return null;
                    }
                  },
                ),
              ),
              RoundedButton(
                text: 'SIGN UP',
                color: kPrimaryColor,
                textColor: Colors.white,
                press: () {
                  try {
                    onSave();
                  } catch (e) {
                    print(e);
                  }
                },
              ),
            ],
          )),
    );
  }
}
