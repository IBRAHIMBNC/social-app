import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soical_app_pro/models/users.dart';
import 'package:soical_app_pro/providers/auth.dart';
import 'package:soical_app_pro/screens/profileScreens/editProfile_screen.dart/edit_profile_screen.dart';
import 'package:soical_app_pro/screens/profileScreens/followers_screen.dart';
import 'package:soical_app_pro/screens/profileScreens/following_screen.dart';
import 'package:soical_app_pro/widgets/page_slide_transition.dart';

final followersRef = FirebaseFirestore.instance.collection('followers');
final followingRef = FirebaseFirestore.instance.collection('following');

class ProfileDetails extends StatefulWidget {
  final int postCount;
  final bool isOwnerProfile;
  final AppUser anotherUser;

  const ProfileDetails({
    Key? key,
    required this.postCount,
    required this.isOwnerProfile,
    required this.anotherUser,
  }) : super(key: key);

  @override
  State<ProfileDetails> createState() => _ProfileDetailsState();
}

class _ProfileDetailsState extends State<ProfileDetails> {
  bool isFollow = false;
  bool isloading = true;
  AppUser? currentUser;
  int followingCount = 0;
  int followersCount = 0;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> followersList = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> followingList = [];

  @override
  void initState() {
    currentUser = Provider.of<Auth>(context, listen: false).currentUser;
    getFollowering();
    getFollowers();
    checkFollow();
    super.initState();
  }

  Future<void> getFollowers() async {
    String id = widget.isOwnerProfile ? currentUser!.id : widget.anotherUser.id;
    final QuerySnapshot<Map<String, dynamic>> followersData = await followersRef
        .doc(id)
        .collection('followersDetail')
        .orderBy('timeStamp', descending: true)
        .get()
        .then((value) {
      if (mounted) {
        setState(() {
          followersCount = value.docs.length;
        });
      }
      return value;
    });
    followersList = followersData.docs;
  }

  Future<void> getFollowering() async {
    String id = widget.isOwnerProfile ? currentUser!.id : widget.anotherUser.id;
    final QuerySnapshot<Map<String, dynamic>> followingData = await followingRef
        .doc(id)
        .collection('followingDetails')
        .orderBy('timeStamp', descending: true)
        .get()
        .then((value) {
      if (mounted) {
        setState(() {
          followingCount = value.docs.length;
        });
      }
      return value;
    });
    followingList = followingData.docs;
  }

  Future<void> checkFollow() async {
    final followUser = await followingRef
        .doc(currentUser!.id)
        .collection('followingDetails')
        .doc(widget.anotherUser.id)
        .get();
    if (mounted) {
      setState(() {
        isFollow = followUser.exists;
        isloading = false;
      });
    }
  }

  void editProfile(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (ctx) => const EditProfileScreen()));
  }

  Future<void> follow(AppUser currentUser) async {
    setState(() {
      isFollow = !isFollow;
    });
    getFollowers();
    getFollowering();
    await followersRef
        .doc(widget.anotherUser.id)
        .collection('followersDetail')
        .doc(currentUser.id)
        .set({
      'userId': currentUser.id,
      'name': currentUser.name,
      'photoUrl': currentUser.photoUrl,
      'timeStamp': Timestamp.now()
    });
    await followingRef
        .doc(currentUser.id)
        .collection('followingDetails')
        .doc(widget.anotherUser.id)
        .set({
      'userId': widget.anotherUser.id,
      'name': widget.anotherUser.name,
      'photoUrl': widget.anotherUser.photoUrl,
      'timeStamp': Timestamp.now()
    });
  }

  Future<void> unFollow(AppUser currentUser) async {
    setState(() {
      isFollow = !isFollow;
    });
    getFollowers();
    getFollowering();
    await followersRef
        .doc(widget.anotherUser.id)
        .collection('followersDetail')
        .doc(currentUser.id)
        .delete();
    await followingRef
        .doc(currentUser.id)
        .collection('followingDetails')
        .doc(widget.anotherUser.id)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      height: size.height,
      margin: const EdgeInsets.only(bottom: 10, left: 2, right: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.7),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
        borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        children: [
          if (isloading) const LinearProgressIndicator(),
          Container(
            width: size.width,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: size.width * 0.28,
                  height: size.height * 0.19,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: CachedNetworkImageProvider(
                            widget.isOwnerProfile
                                ? currentUser!.photoUrl
                                : widget.anotherUser.photoUrl),
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 10, left: 5),
                        child: Text(
                            widget.isOwnerProfile
                                ? currentUser!.name
                                : widget.anotherUser.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                SizedBox(
                  width: size.width * 0.58,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                              margin: const EdgeInsets.only(right: 5, left: 5),
                              child: Counter(
                                  title: 'Posts', count: widget.postCount)),
                          TextButton(
                              style: TextButton.styleFrom(),
                              onPressed: () {
                                Navigator.of(context)
                                    .push(PageSlideTransition(
                                        child: FollowerScreen(
                                            followersList: followersList)))
                                    .then((value) {
                                  getFollowers();
                                });
                              },
                              child: Counter(
                                  title: 'Followers', count: followersCount)),
                          TextButton(
                              style: TextButton.styleFrom(),
                              onPressed: () {
                                Navigator.of(context)
                                    .push(PageSlideTransition(
                                        child: FollowingScreen(
                                            followingList: followingList)))
                                    .then((value) {
                                  getFollowering();
                                });
                              },
                              child: Counter(
                                count: followingCount,
                                title: 'Following',
                              ))
                        ],
                      ),
                      GestureDetector(
                          onTap: () => widget.isOwnerProfile
                              ? editProfile(context)
                              : isFollow
                                  ? unFollow(currentUser!)
                                  : follow(currentUser!),
                          child: Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.only(top: 5),
                            decoration: BoxDecoration(
                              border: isFollow ? Border.all() : null,
                              borderRadius: BorderRadius.circular(10),
                              color: isFollow ? Colors.white : Colors.blue,
                            ),
                            height: 35,
                            width: double.infinity,
                            child: widget.isOwnerProfile
                                ? const Text(
                                    'Edit Profile',
                                    style: TextStyle(color: Colors.white),
                                  )
                                : isFollow
                                    ? const Text(
                                        'Unfollow',
                                        style: TextStyle(color: Colors.black),
                                      )
                                    : const Text(
                                        'Follow',
                                        style: TextStyle(color: Colors.white),
                                      ),
                          ))
                    ],
                  ),
                )
              ],
            ),

            // Padding(
            //     padding: const EdgeInsets.only(top: 2),
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.start,
            //       children: [
            //         Icon(
            //           Icons.fire_extinguisher,
            //           color: Colors.grey,
            //         ),
            //         Text('Organizer',
            //             style: TextStyle(
            //               fontWeight: FontWeight.bold,
            //               color: Colors.grey,
            //               fontSize: 15,
            //             )),
            //       ],
            //     )),
          ),
        ],
      ),
    );
  }
}

class Counter extends StatelessWidget {
  final String title;
  final int count;

  const Counter({Key? key, required this.title, required this.count})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(title, style: const TextStyle(fontSize: 16, color: Colors.grey)),
      ],
    );
  }
}
