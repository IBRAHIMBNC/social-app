import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:soical_app_pro/constants.dart';
import 'package:soical_app_pro/models/users.dart';
import 'package:soical_app_pro/widgets/page_slide_transition.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'newProfile_screen.dart';

class FollowerScreen extends StatelessWidget {
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> followersList;
  const FollowerScreen({Key? key, required this.followersList})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // iconTheme: IconThemeData(color: Colors.black),
        // backgroundColor: Colors.white,
        backgroundColor: kPrimaryColor,
        title: const Text(
          'Followers',
          // style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Container(
          margin: const EdgeInsets.only(top: 10),
          child: ListView.separated(
              itemBuilder: (context, index) {
                Timestamp date = followersList[index].get('timeStamp');
                return GestureDetector(
                  onTap: () async {
                    final profileData = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(followersList[index].get('userId'))
                        .get();
                    AppUser anotherUser = AppUser.toDocument(profileData);
                    Navigator.of(context).push(PageSlideTransition(
                        child: NewProfileScreen(
                      isOwnerProfile: false,
                      userProfile: anotherUser,
                    )));
                  },
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundImage: CachedNetworkImageProvider(
                          followersList[index].get('photoUrl')),
                    ),
                    title: Text(
                      followersList[index].get('name').toString().toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(timeago.format(date.toDate())),
                  ),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(
                    height: 5,
                  ),
              itemCount: followersList.length)),
    );
  }
}
