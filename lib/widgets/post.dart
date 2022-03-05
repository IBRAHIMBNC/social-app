import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soical_app_pro/models/post.dart';
import 'package:soical_app_pro/models/users.dart';
import 'package:soical_app_pro/providers/auth.dart';
import 'package:soical_app_pro/screens/coment_screen/comments_screen.dart';
import 'package:soical_app_pro/screens/profileScreens/newProfile_screen.dart';
import 'package:soical_app_pro/widgets/page_slide_transition.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostWidget extends StatefulWidget {
  final bool isAdminPost;
  final bool isStudentOrgPost;
  final String imageUrl;
  final String ownerId;
  final String postId;
  final String profilePic;
  final String name;
  final Timestamp timeStamp;
  final String description;
  final bool isOwnerPost;
  final Map<String, dynamic> likes;

  const PostWidget({
    Key? key,
    required this.imageUrl,
    required this.name,
    required this.timeStamp,
    required this.description,
    required this.profilePic,
    required this.postId,
    required this.isOwnerPost,
    required this.likes,
    required this.ownerId,
    required this.isAdminPost,
    required this.isStudentOrgPost,
  }) : super(key: key);

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool isLiked = false;
  int likesCount = 0;
  final postRef = FirebaseFirestore.instance.collection('posts');
  Map<String, dynamic> tempLikes = {};
  AppUser? postOwner;
  List<String> dropDownList = ['Delete', 'Edit post'];
  bool isLoading = true;

  @override
  void initState() {
    print(isLiked);
    tempLikes = widget.likes;
    String id = Provider.of<Auth>(context, listen: false).currentUser!.id;
    if (tempLikes.containsKey(id) && tempLikes.isNotEmpty) {
      isLiked = tempLikes[id];
    } else {
      isLiked = false;
    }
    tempLikes.forEach((key, value) {
      if (value) likesCount++;
    });
    // TODO: implement initState
    super.initState();
  }

  Future<void> likePost() async {
    String id = Provider.of<Auth>(context, listen: false).currentUser!.id;
    if (isLiked) {
      setState(() {
        isLiked = false;
        likesCount -= 1;
      });
      tempLikes.update(id, (value) => false);

      await FirebaseFirestore.instance
          .collection('timeline')
          .doc(widget.postId)
          .update({'likes': tempLikes});
      await postRef
          .doc(widget.ownerId)
          .collection('usersPosts')
          .doc(widget.postId)
          .update({'likes': tempLikes});
    } else {
      setState(() {
        likesCount += 1;
        isLiked = true;
      });

      tempLikes.update(
        id,
        (val) => true,
        ifAbsent: () => true,
      );
      await FirebaseFirestore.instance
          .collection('timeline')
          .doc(widget.postId)
          .update({'likes': tempLikes});
      await postRef
          .doc(widget.ownerId)
          .collection('usersPosts')
          .doc(widget.postId)
          .update({'likes': tempLikes});
    }
  }

  Future<void> deletePost(
      String val, BuildContext context, AppUser user) async {
    final post = Provider.of<Posts>(context, listen: false);
    bool result = false;
    result = await showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop(true);
                  },
                  child: const Text('Yes')),
              TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop(false);
                  },
                  child: const Text('No'))
            ],
            content: const Text('Are you sure you want to delete this post?'),
            title: const Text('Delete post'),
          );
        });
    String userId = user.id;
    if (user.isAdmin) {
      userId = widget.ownerId;
    }
    if (user.isStudentOrg) {
      userId = widget.ownerId;
    }
    if (val.toString() == 'delete' && result) {
      post.deletePost(widget.postId);
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(userId)
          .collection('usersPosts')
          .doc(widget.postId)
          .delete();
      FirebaseFirestore.instance
          .collection('timeline')
          .doc(widget.postId)
          .delete();

      final comments = await FirebaseFirestore.instance
          .collection('comments')
          .doc(widget.postId)
          .collection('postComments')
          .get();
      for (var element in comments.docs) {
        FirebaseFirestore.instance
            .collection('comments')
            .doc(widget.postId)
            .collection('postComments')
            .doc(element.id)
            .delete();
      }

      if (widget.imageUrl.trim().isNotEmpty) {
        await FirebaseStorage.instance
            .ref()
            .child('postsMedia')
            .child(widget.postId + '.jpg')
            .delete();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<Auth>(context, listen: false).currentUser;
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
          alignment: Alignment.topLeft,
          width: double.infinity,
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: GestureDetector(
                    onTap: () => viewProfile(currentUser!),
                    child: CircleAvatar(
                      backgroundImage:
                          CachedNetworkImageProvider(widget.profilePic),
                      radius: 24,
                    ),
                  ),
                  title: GestureDetector(
                    onTap: () => viewProfile(currentUser!),
                    child: Text(
                      widget.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  subtitle: Text(timeago.format(widget.timeStamp.toDate())),
                  // trailing: GestureDetector(
                  //   child: Icon(Icons.more_vert),
                  //   onTap: postDropDown,
                  // ),
                  trailing: widget.isOwnerPost ||
                          currentUser!.isAdmin ||
                          (!widget.isStudentOrgPost &&
                              currentUser.isStudentOrg &&
                              !widget.isAdminPost)
                      ? DropdownButton(
                          onTap: () {},
                          icon: const Icon(Icons.more_vert),
                          underline: const SizedBox(),
                          items: [
                            DropdownMenuItem(
                              child: Row(
                                children: const [
                                  Icon(
                                    Icons.delete,
                                    color: Colors.black,
                                  ),
                                  SizedBox(width: 10),
                                  Text('Delete')
                                ],
                              ),
                              value: 'delete',
                            ),
                          ],
                          onChanged: (value) => deletePost(
                              value.toString(), context, currentUser!),
                        )
                      : null,
                ),
                if (widget.description.trim().isNotEmpty)
                  Container(
                    width: double.infinity,
                    child: Text(widget.description),
                    margin: EdgeInsets.only(bottom: 5, left: 15),
                  ),
                if (widget.imageUrl.trim().isNotEmpty)
                  Center(
                    child: CachedNetworkImage(
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      imageUrl: widget.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    TextButton.icon(
                        onPressed: likePost,
                        icon: isLiked
                            ? const Icon(
                                Icons.favorite,
                                color: Colors.pink,
                                size: 30,
                              )
                            : const Icon(
                                Icons.favorite_border,
                                color: Colors.pink,
                                size: 30,
                              ),
                        label: Text(
                          '$likesCount likes',
                          style: const TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        )),
                    const SizedBox(
                      width: 20,
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).push(PageSlideTransition(
                          child: CommentScreen(
                            postId: widget.postId,
                          ),
                        ));
                      },
                      icon: const Icon(
                        Icons.message,
                        color: Colors.blue,
                        size: 30,
                      ),
                    )
                  ],
                ),
              ],
            ),
          )),
    );
  }

  Future<void> viewProfile(AppUser currentUser) async {
    if (widget.isOwnerPost) {
      Navigator.of(context).push(PageSlideTransition(
          child: NewProfileScreen(
        isOwnerProfile: true,
        userProfile: currentUser,
      )));
    } else {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.ownerId)
          .get();
      final anotherUser = AppUser.toDocument(userDoc);
      Navigator.of(context).push(PageSlideTransition(
          child: NewProfileScreen(
        isOwnerProfile: false,
        userProfile: anotherUser,
      )));
    }
  }
}
