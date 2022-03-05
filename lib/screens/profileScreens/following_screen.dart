import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soical_app_pro/models/users.dart';
import 'package:soical_app_pro/providers/auth.dart';
import 'package:soical_app_pro/screens/profileScreens/newProfile_screen.dart';
import 'package:soical_app_pro/widgets/page_slide_transition.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../constants.dart';

class FollowingScreen extends StatefulWidget {
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> followingList;
  const FollowingScreen({Key? key, required this.followingList})
      : super(key: key);

  @override
  State<FollowingScreen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  final followingRef = FirebaseFirestore.instance.collection('following');
  final followersRef = FirebaseFirestore.instance.collection('followers');

  Future<void> unFollow(String followUserId) async {
    String currentUserId =
        Provider.of<Auth>(context, listen: false).currentUser!.id;
    setState(() {
      widget.followingList
          .removeWhere((item) => item.get('userId') == followUserId);
    });
    followingRef
        .doc(currentUserId)
        .collection('followingDetails')
        .doc(followUserId)
        .delete();
    followersRef
        .doc(followUserId)
        .collection('followersDetail')
        .doc(currentUserId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: const Text(
          'following',
        ),
        centerTitle: true,
      ),
      body: Container(
          margin: const EdgeInsets.only(top: 10),
          child: ListView.separated(
              itemBuilder: (context, index) {
                Timestamp date = widget.followingList[index].get('timeStamp');
                return GestureDetector(
                  onTap: () async {
                    final profileData = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(widget.followingList[index].get('userId'))
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
                          widget.followingList[index].get('photoUrl')),
                    ),
                    title: Text(
                      widget.followingList[index]
                          .get('name')
                          .toString()
                          .toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(timeago.format(date.toDate())),
                    // trailing: OutlinedButton(
                    //   child: const Text(
                    //     'Unfollow',
                    //     style: TextStyle(color: Colors.black),
                    //   ),
                    //   onPressed: () =>
                    //       unFollow(widget.followingList[index].get('userId')),
                    // ),
                  ),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(
                    height: 5,
                  ),
              itemCount: widget.followingList.length)),
    );
  }
}
