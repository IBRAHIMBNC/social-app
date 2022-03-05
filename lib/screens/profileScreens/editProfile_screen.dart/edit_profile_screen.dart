import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:soical_app_pro/constants.dart';
import 'package:soical_app_pro/providers/auth.dart';
import 'package:soical_app_pro/screens/profileScreens/editProfile_screen.dart/changePassword_screen.dart';
import 'package:soical_app_pro/screens/profileScreens/editProfile_screen.dart/changeProfile_screen.dart';
import 'package:soical_app_pro/screens/profileScreens/editProfile_screen.dart/changename_screen.dart';
import 'package:soical_app_pro/widgets/page_slide_transition.dart';
import 'package:soical_app_pro/widgets/transition.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: const Text('Edit Profile'),
        centerTitle: true,
      ),
      body: Container(
        height: size.height,
        width: size.width,
        child: Column(
          children: [
            EditProfileElement(
              title: 'Change Name',
              handler: () {
                Navigator.of(context)
                    .push(PageSlideTransition(child: ChangeNameScreen()));
              },
            ),
            if (googleSignIn.currentUser == null)
              EditProfileElement(
                  title: 'Change password',
                  handler: () {
                    Navigator.of(context).push(
                        PageSlideTransition(child: ChangePasswordScreen()));
                  }),
            EditProfileElement(
                title: 'Change profile',
                handler: () {
                  Navigator.of(context)
                      .push(PageSlideTransition(child: ChangeProfileScreen()));
                }),
          ],
        ),
      ),
    );
  }
}

class EditProfileElement extends StatelessWidget {
  final String title;
  final Function handler;
  const EditProfileElement(
      {Key? key, required this.title, required this.handler})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          handler();
        },
        child: Card(
          elevation: 4,
          child: ListTile(
            title: Text(title),
            trailing: Icon(Icons.keyboard_arrow_right),
          ),
        ));
  }
}
