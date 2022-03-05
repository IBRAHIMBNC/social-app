import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:soical_app_pro/constants.dart';
import 'package:soical_app_pro/providers/auth.dart';
import 'package:soical_app_pro/screens/admin_orginization_screens/Admin_screen.dart';
import 'package:soical_app_pro/screens/auth_screens.dart/welcome_screen.dart';
import 'package:soical_app_pro/screens/notification_screen.dart';
import 'package:soical_app_pro/screens/profileScreens/newProfile_screen.dart';
import 'package:soical_app_pro/screens/profileScreens/profile_screen.dart';
import 'package:soical_app_pro/screens/search_screen.dart';
import 'package:soical_app_pro/screens/timline_screen.dart';

import 'package:soical_app_pro/widgets/transition.dart';

import 'createPost_screen.dart';

final fireStoreIns = FirebaseFirestore.instance.collection('users');

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PageController? pageCon;
  int currentInd = 0;

  @override
  void initState() {
    pageCon = PageController(initialPage: 0);

    super.initState();
  }

  @override
  void dispose() {
    pageCon!.dispose();
    super.dispose();
  }

  void pageChange(int ind) {
    pageCon!.jumpToPage(ind);
    setState(() {
      currentInd = ind;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final auth = Provider.of<Auth>(context);
    return Scaffold(
      body: PageView(
        onPageChanged: pageChange,
        children: [
          if (auth.currentUser!.isAdmin) const AdminDashboard(),
          const TimelineScreen(),
          const SearchScreen(),
          const NotificationScreen(),
          NewProfileScreen(
            userProfile: Provider.of<Auth>(context, listen: false).currentUser!,
            isOwnerProfile: true,
          )
        ],
        controller: pageCon,
      ),
      bottomNavigationBar: BottomNavigationBar(
        iconSize: 30,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: false,
        showSelectedLabels: true,
        selectedItemColor: kPrimaryColor,
        unselectedItemColor: Colors.grey,
        items: [
          if (auth.currentUser!.isAdmin)
            const BottomNavigationBarItem(
                icon: Icon(Icons.admin_panel_settings), label: 'Admin'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.timeline), label: 'Timeline'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.search), label: 'Search'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.notifications_active), label: 'Notificattions'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.account_circle), label: 'Profile'),
        ],
        currentIndex: currentInd,
        onTap: pageChange,
      ),
    );
  }
}
