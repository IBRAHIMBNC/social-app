import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soical_app_pro/constants.dart';
import 'package:soical_app_pro/models/post.dart';
import 'package:soical_app_pro/models/users.dart';
import 'package:soical_app_pro/providers/auth.dart';
import 'package:soical_app_pro/widgets/post.dart';
import 'package:soical_app_pro/widgets/profile_details.dart';

class NewProfileScreen extends StatelessWidget {
  final bool isOwnerProfile;
  AppUser userProfile;

  NewProfileScreen(
      {Key? key, required this.isOwnerProfile, required this.userProfile})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final postsData = Provider.of<Posts>(context);
    final auth = Provider.of<Auth>(context, listen: false);

    return Scaffold(
      appBar: !isOwnerProfile
          ? AppBar(
              title: Text(
                userProfile.name.toUpperCase(),
              ),
              centerTitle: true,
              backgroundColor: kPrimaryColor,
            )
          : AppBar(
              backgroundColor: kPrimaryColor,
              title: const Text(
                'Profile',
              ),
              centerTitle: true,
            ),
      body: FutureBuilder(
        future: isOwnerProfile
            ? postsData.fetchPosts()
            : postsData.fetchPosts(userProfile.id),
        builder: (ctx, futureSnap) {
          if (futureSnap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Center(child: CircularProgressIndicator()),
            );
          }
          List<Post> posts = postsData.userPosts;
          return NestedScrollView(
            headerSliverBuilder: (ctx, inner) => [
              SliverAppBar(
                elevation: 10,
                centerTitle: true,
                backgroundColor: Colors.white,
                expandedHeight: 185,
                flexibleSpace: FlexibleSpaceBar(
                  background: ProfileDetails(
                    anotherUser: userProfile,
                    isOwnerProfile: isOwnerProfile,
                    postCount: posts.length,
                  ),
                ),
              )
            ],
            body: posts.isEmpty
                ? Column(
                    children: [
                      if (posts.isEmpty)
                        Column(
                          children: [
                            SizedBox(
                              height: size.height * 0.1,
                            ),
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
                        )
                    ],
                  )
                : Container(
                    margin: const EdgeInsets.only(top: 5),
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      separatorBuilder: (context, ind) => const SizedBox(
                        height: 0,
                      ),
                      itemBuilder: (ctx, ind) {
                        return PostWidget(
                          isAdminPost: userProfile.isAdmin,
                          isStudentOrgPost: userProfile.isStudentOrg,
                          ownerId: posts[ind].ownerId,
                          likes: posts[ind].likes,
                          isOwnerPost: isOwnerProfile,
                          description: posts[ind].discreption,
                          imageUrl: posts[ind].mediaUrl,
                          name: userProfile.name,
                          profilePic: userProfile.photoUrl,
                          timeStamp: posts[ind].timeStamp,
                          postId: posts[ind].postId,
                        );
                      },
                      itemCount: posts.length,
                    ),
                  ),
          );
        },
      ),
    );
  }
}
