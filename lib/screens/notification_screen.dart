import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soical_app_pro/constants.dart';
import 'package:soical_app_pro/providers/auth.dart';
import 'package:soical_app_pro/widgets/transition.dart';

import 'auth_screens.dart/welcome_screen.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        actions: [
          IconButton(
              onPressed: () async {
                Navigator.pushReplacement(
                    context,
                    PageTransition(
                        child: const WelcomeScreen(),
                        curve: Curves.fastOutSlowIn));
                auth.currentUser = null;
                await googleSignIn.signOut();
                await FirebaseAuth.instance.signOut();
              },
              icon: const Icon(Icons.exit_to_app))
        ],
      ),
      body: Center(
        child: Text('Notification'),
      ),
    );
  }
}
