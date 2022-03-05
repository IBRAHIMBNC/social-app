import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soical_app_pro/constants.dart';
import 'package:soical_app_pro/models/post.dart';
import 'package:soical_app_pro/models/timlinePost.dart';
import 'package:soical_app_pro/models/users.dart';
import 'package:soical_app_pro/providers/auth.dart';
import 'package:soical_app_pro/screens/massenger_screens.dart/messenger_screen.dart';
import 'package:soical_app_pro/widgets/page_slide_transition.dart';
import 'package:soical_app_pro/widgets/post.dart';
import 'package:soical_app_pro/widgets/transition.dart';

import 'createPost_screen.dart';

class TimelineScreen extends StatelessWidget {
  const TimelineScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final auth = Provider.of<Auth>(context, listen: false).currentUser;
    return Scaffold(
      backgroundColor: Colors.black12,
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context)
                    .push(PageSlideTransition(child: MessengerScreen()));
              },
              icon: const Icon(Icons.messenger_rounded))
        ],
        backgroundColor: kPrimaryColor,
        title: const Text('Timeline'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('timeline')
            .orderBy('timeStamp', descending: true)
            .snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final List<QueryDocumentSnapshot<Map<String, dynamic>>> docData =
              snapshot.data!.docs;
          final List<TimelinePost> timelinePosts = [];

          // snapshot.data!.docs.forEach((QueryDocumentSnapshot doc) {
          //   timelinePosts.add(Post.fromDoc(doc));
          // });
          for (var doc in docData) {
            timelinePosts.add(TimelinePost.fromDoc(doc));
          }

          return Container(
              margin: const EdgeInsets.only(top: 5),
              child: timelinePosts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(width: 6)),
                            child: const Icon(
                              Icons.photo_camera_outlined,
                              size: 70,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Text(
                            'No Posts Yet',
                            style: TextStyle(fontSize: 30),
                          )
                        ],
                      ),
                    )
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      separatorBuilder: (context, ind) => const SizedBox(
                        height: 0,
                      ),
                      itemBuilder: (ctx, ind) {
                        return PostWidget(
                          isAdminPost: timelinePosts[ind].isAdminPost,
                          isStudentOrgPost: timelinePosts[ind].isStudentOrgPost,
                          ownerId: timelinePosts[ind].ownerId,
                          likes: timelinePosts[ind].likes,
                          isOwnerPost: timelinePosts[ind].ownerId == auth!.id
                              ? true
                              : false,
                          description: timelinePosts[ind].discreption,
                          imageUrl: timelinePosts[ind].mediaUrl,
                          name: timelinePosts[ind].ownerName,
                          profilePic: timelinePosts[ind].profilePic,
                          timeStamp: timelinePosts[ind].timeStamp,
                          postId: timelinePosts[ind].postId,
                        );
                      },
                      itemCount: timelinePosts.length,
                    ));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(PageTransition(
              child: const CreatePostScreen(), curve: Curves.easeIn));
        },
        child: const Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
      ),
    );
  }
}
