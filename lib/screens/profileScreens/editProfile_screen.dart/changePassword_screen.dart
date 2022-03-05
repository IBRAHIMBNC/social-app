// ignore_for_file: file_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:soical_app_pro/constants.dart';
import 'package:soical_app_pro/screens/auth_screens.dart/login_screen.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _key = GlobalKey();
  final _oldPasswordCon = TextEditingController();
  final _newPasswordCon = TextEditingController();
  final _confirmPasswornCon = TextEditingController();

  String oldPassword = '';
  String newPassword = '';

  bool wrongPassword = true;

  void onSubmit() async {
    FocusScope.of(context).unfocus();
    await validateOldPassword();
    _key.currentState!.save();
    if (_key.currentState!.validate()) {
      _confirmPasswornCon.clear();
      _newPasswordCon.clear();
      _oldPasswordCon.clear();
      auth.currentUser!.updatePassword(newPassword);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Password successfully updated '),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ));
      Navigator.of(context).pop();
    }
  }

  Future<void> validateOldPassword() async {
    String email = auth.currentUser!.email.toString();
    String pass = _oldPasswordCon.text.trim().toString();
    AuthCredential cred =
        EmailAuthProvider.credential(email: email, password: pass);

    try {
      final credential =
          await auth.currentUser!.reauthenticateWithCredential(cred);
      wrongPassword = false;
    } catch (e) {
      if (e.toString().contains('wrong-password')) {}
    }
  }

  @override
  void dispose() {
    _newPasswordCon.dispose();
    _oldPasswordCon.dispose();
    _confirmPasswornCon.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: const Text(
          'Change Passowrd',
        ),
        centerTitle: true,
      ),
      body: Container(
          height: size.height,
          width: size.width,
          child: Form(
            key: _key,
            child: Column(
              children: [
                TextFieldContainer(
                  size: size,
                  child: TextFormField(
                    obscureText: true,
                    controller: _oldPasswordCon,
                    validator: (oldPass) {
                      if (wrongPassword) {
                        return 'Old password is incorrect';
                      }
                    },
                    decoration: InputDecoration(
                        border: InputBorder.none, hintText: 'Old password'),
                  ),
                ),
                TextFieldContainer(
                    size: size,
                    child: TextFormField(
                      obscureText: true,
                      controller: _newPasswordCon,
                      decoration: InputDecoration(
                          border: InputBorder.none, hintText: 'New password'),
                      onSaved: (val) {
                        newPassword = val!.trim().toString();
                      },
                      validator: (val) {
                        val = val!.trim().toString();
                        if (val.length < 8) {
                          return 'Password must be at least 8 characters';
                        }
                      },
                    )),
                TextFieldContainer(
                    size: size,
                    child: TextFormField(
                      controller: _confirmPasswornCon,
                      obscureText: true,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Confirm password'),
                      validator: (val) {
                        String pass = _newPasswordCon.text.trim().toString();
                        if (val!.trim().toString() != pass) {
                          return 'Password does not match';
                        }
                      },
                    )),
                ElevatedButton(
                  onPressed: onSubmit,
                  child: Text('UPDATE'),
                  style: ElevatedButton.styleFrom(
                      primary: kPrimaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      fixedSize: Size(size.width * 0.8, size.height * 0.06)),
                )
              ],
            ),
          )),
    );
  }
}
