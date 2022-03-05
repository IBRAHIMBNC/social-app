import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:soical_app_pro/constants.dart';
import 'package:soical_app_pro/models/chatMessege.dart';
import 'package:soical_app_pro/models/post.dart';
import 'package:soical_app_pro/providers/auth.dart';
import 'package:soical_app_pro/screens/auth_screens.dart/splash_screen.dart';
import 'package:soical_app_pro/screens/auth_screens.dart/welcome_screen.dart';
import 'package:soical_app_pro/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => Auth(),
          ),
          ChangeNotifierProvider(
            create: (_) => Posts(),
          ),
          ChangeNotifierProvider(
            create: (_) => Chat(),
          ),
        ],
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Social App',
            theme: ThemeData(
                primaryColor: kPrimaryColor,
                scaffoldBackgroundColor: Colors.white),
            home: Consumer<Auth>(
              builder: (ctx, auth, _) => FutureBuilder(
                builder: (ctx, futureSnap) {
                  if (futureSnap.connectionState == ConnectionState.waiting) {
                    return const SplashScreen();
                  }
                  if (futureSnap.hasData) {
                    if (futureSnap.data == true) {
                      return const HomeScreen();
                    }
                  }
                  return StreamBuilder(
                      builder: (ctx, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const SplashScreen();
                        }
                        if (snap.hasData && auth.currentUser != null) {
                          return const HomeScreen();
                        }

                        return const WelcomeScreen();
                      },
                      stream: FirebaseAuth.instance.authStateChanges());
                },
                future: auth.autoLogin(),
              ),
            )));
  }
}
