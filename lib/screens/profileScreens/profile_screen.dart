import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soical_app_pro/constants.dart';
import 'package:soical_app_pro/models/post.dart';
import 'package:soical_app_pro/models/users.dart';
import 'package:soical_app_pro/providers/auth.dart';
import 'package:soical_app_pro/widgets/post.dart';
import 'package:soical_app_pro/widgets/profile_details.dart';

class ProfileScreen extends StatelessWidget {
  final bool isOwnerProfile;
  AppUser anotherUser;

  ProfileScreen(
      {Key? key, required this.isOwnerProfile, required this.anotherUser})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final postsData = Provider.of<Posts>(context);
    final auth = Provider.of<Auth>(context, listen: false);

    return Scaffold(
      appBar: !isOwnerProfile
          ? AppBar(
              title: Text(anotherUser.name.toUpperCase()),
              centerTitle: true,
              backgroundColor: kPrimaryColor,
            )
          : AppBar(
              title: Text(
                'Profile',
              ),
              centerTitle: true,
              backgroundColor: kPrimaryColor,
            ),
      body: Container(
        // padding: MediaQuery.of(context).padding,
        height: size.height,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: FutureBuilder(
                future: isOwnerProfile
                    ? postsData.fetchPosts()
                    : postsData.fetchPosts(anotherUser.id),
                builder: (ctx, futureSnap) {
                  if (futureSnap.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  List<Post> posts = postsData.userPosts;

                  return Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        ProfileDetails(
                          anotherUser: anotherUser,
                          isOwnerProfile: isOwnerProfile,
                          postCount: posts.length,
                        ),
                        Container(
                          color: Colors.black26,
                          height: 2,
                          width: double.infinity,
                        ),
                        // When there is no post
                        if (posts.isEmpty)
                          Column(
                            children: [
                              if (posts.length == 0)
                                Column(
                                  children: [
                                    SizedBox(
                                      height: size.height * 0.1,
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(15),
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(width: 6)),
                                      child: Icon(
                                        Icons.photo_camera_outlined,
                                        size: 70,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    const Text(
                                      'No Posts Yet',
                                      style: TextStyle(fontSize: 30),
                                    )
                                  ],
                                )
                            ],
                          ), // When there is no post
                        Expanded(
                          child: ListView.builder(
                            itemBuilder: (ctx, ind) {
                              return PostWidget(
                                isAdminPost: true,
                                isStudentOrgPost: true,
                                ownerId: posts[ind].ownerId,
                                likes: posts[ind].likes,
                                isOwnerPost: isOwnerProfile,
                                description: posts[ind].discreption,
                                imageUrl: posts[ind].mediaUrl,
                                name: isOwnerProfile
                                    ? auth.currentUser!.name
                                    : anotherUser.name,
                                profilePic: isOwnerProfile
                                    ? auth.currentUser!.photoUrl
                                    : anotherUser.photoUrl,
                                timeStamp: posts[ind].timeStamp,
                                postId: posts[ind].postId,
                              );
                            },
                            itemCount: posts.length,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
