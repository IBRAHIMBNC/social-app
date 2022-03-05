import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soical_app_pro/constants.dart';
import 'package:soical_app_pro/models/users.dart';
import 'package:soical_app_pro/providers/auth.dart';
import 'package:soical_app_pro/screens/auth_screens.dart/login_screen.dart';

class ChangeNameScreen extends StatefulWidget {
  const ChangeNameScreen({Key? key}) : super(key: key);

  @override
  _ChangeNameScreenState createState() => _ChangeNameScreenState();
}

class _ChangeNameScreenState extends State<ChangeNameScreen> {
  final _firstNameCon = TextEditingController();
  final _lastNameCon = TextEditingController();
  final GlobalKey<FormState> _key = GlobalKey();

  User? user;

  Future<void> updateInApp(String id) async {
    String newName = _firstNameCon.text.trim().toString() +
        ' ' +
        _lastNameCon.text.trim().toString();

    _firstNameCon.clear();
    _lastNameCon.clear();
    final ref = FirebaseFirestore.instance.collection('users').doc(id);
    ref.update({'name': newName});
    final auth = Provider.of<Auth>(context, listen: false);
    final userData = await ref.get();
    auth.currentUser = AppUser.toDocument(userData);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Name successfully updated'),
      duration: Duration(seconds: 1),
      backgroundColor: Colors.green,
    ));
  }

  Future<void> updateName() async {
    if (_key.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String newName = _firstNameCon.text.trim().toString() +
            ' ' +
            _lastNameCon.text.trim().toString();
        user!.updateDisplayName(newName);
        await updateInApp(user!.uid);
      } else {
        await updateInApp(googleSignIn.currentUser!.id);
      }
    }
  }

  @override
  void dispose() {
    _firstNameCon.dispose();
    _lastNameCon.dispose();

    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: const Text('Change Name'),
        centerTitle: true,
      ),
      body: Container(
        width: size.width,
        height: size.height,
        child: Form(
          key: _key,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextFieldContainer(
                  size: size,
                  child: TextFormField(
                    validator: (val) {
                      if (val!.trim().isEmpty) {
                        return 'First name must not be empty';
                      } else if (val.trim().length < 4) {
                        return 'First name is too short';
                      } else if (val.trim().length > 12) {
                        return 'First name is too long';
                      }
                    },
                    controller: _firstNameCon,
                    decoration: InputDecoration(
                        border: InputBorder.none, hintText: 'First name'),
                  )),
              TextFieldContainer(
                  size: size,
                  child: TextFormField(
                    validator: (val) {
                      if (val!.trim().isEmpty) {
                        return 'Last name must not be empty';
                      } else if (val.trim().length < 3) {
                        return 'Last name is too short';
                      } else if (val.trim().length > 12) {
                        return 'Last name is too long';
                      }
                    },
                    controller: _lastNameCon,
                    decoration: InputDecoration(
                        border: InputBorder.none, hintText: 'Last Name'),
                  )),
              ElevatedButton(
                onPressed: updateName,
                child: Text('UPDATE'),
                style: ElevatedButton.styleFrom(
                    primary: kPrimaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    fixedSize: Size(size.width * 0.8, size.height * 0.06)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
