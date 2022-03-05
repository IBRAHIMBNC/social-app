import 'package:flutter/material.dart';
import 'package:soical_app_pro/constants.dart';
import 'package:soical_app_pro/screens/admin_orginization_screens/studentOrg_screen.dart';
import 'package:soical_app_pro/widgets/page_slide_transition.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: const Text('Admin Settings'),
      ),
      body: SizedBox(
        width: double.infinity,
        height: size.height,
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context)
                    .push(PageSlideTransition(child: const StudentOrgScreen()));
              },
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 5,
                child: const ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  leading: CircleAvatar(
                    child: Icon(
                      Icons.add_moderator,
                    ),
                  ),
                  title: Text('Student Organization'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
