import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soical_app_pro/models/comment.dart';
import 'package:soical_app_pro/models/users.dart';
import 'package:soical_app_pro/providers/auth.dart';
import 'package:soical_app_pro/screens/coment_screen/comment_widget.dart';

class CommentScreen extends StatefulWidget {
  final String postId;
  const CommentScreen({Key? key, required this.postId}) : super(key: key);

  @override
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final _commentController = TextEditingController();
  final commentsRef = FirebaseFirestore.instance.collection('comments');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _commentController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> postComment(AppUser currentUser) async {
    FocusScope.of(context).unfocus();
    String text = _commentController.text;
    _commentController.clear();
    await commentsRef.doc(widget.postId).collection('postComments').add({
      'ownerId': currentUser.id,
      'text': text,
      'timeStamp': Timestamp.now(),
      'ownerProfile': currentUser.photoUrl,
      'ownerName': currentUser.name
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final currentUser = Provider.of<Auth>(context, listen: false).currentUser;
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Comments',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Container(
        width: size.width,
        height: size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const SizedBox(
              height: 15,
            ),
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('comments')
                    .doc(widget.postId)
                    .collection('postComments')
                    .orderBy('timeStamp', descending: false)
                    .snapshots(),
                builder: (context,
                    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                        snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  List<Comment> temp = [];
                  snapshot.data!.docs.forEach((comment) {
                    temp.add(Comment.fromDoc(comment));
                  });
                  List<Comment> comments = temp;
                  return Expanded(
                      child: ListView.separated(
                          itemBuilder: (ctx, ind) {
                            return CommentWidget(comment: comments[ind]);
                          },
                          separatorBuilder: (ctx, ind) => const SizedBox(
                                height: 10,
                              ),
                          itemCount: comments.length));
                }),
            Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.black12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: const InputDecoration(
                            hintText: 'Write a comment...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(left: 20)),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => postComment(currentUser!),
                      child: const Icon(Icons.send),
                    ),
                    const SizedBox(
                      width: 10,
                    )
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
