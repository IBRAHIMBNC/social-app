import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:soical_app_pro/providers/auth.dart';

class Post {
  final Timestamp timeStamp;
  final String discreption;
  final String mediaUrl;
  final String ownerId;
  final String postId;
  final Map<String, dynamic> likes;

  Post({
    required this.timeStamp,
    required this.discreption,
    required this.mediaUrl,
    required this.ownerId,
    required this.postId,
    required this.likes,
  });

  factory Post.fromDoc(DocumentSnapshot doc) {
    return Post(
      timeStamp: doc.get('timeStamp'),
      discreption: doc.get('description'),
      mediaUrl: doc.get('mediaUrl'),
      ownerId: doc.get('ownerId'),
      postId: doc.get('postId'),
      likes: doc.get('likes'),
    );
  }
}

class Posts with ChangeNotifier {
  List<Post> _userPosts = [];
  final postRef = FirebaseFirestore.instance.collection('posts');

  Future<String> userId() async {
    String id = '';
    if (googleSignIn.currentUser != null) {
      id = googleSignIn.currentUser!.id;
      return id;
    }
    id = FirebaseAuth.instance.currentUser != null
        ? FirebaseAuth.instance.currentUser!.uid
        : googleSignIn.currentUser!.id;
    return id;
  }

  List<Post> get userPosts {
    return [..._userPosts];
  }

  Future<void> fetchPosts([String findUserId = '']) async {
    String id = '';
    if (findUserId.trim().isNotEmpty) {
      id = findUserId;
    } else {
      id = await userId();
    }
    final userPostsIns = postRef.doc(id).collection('usersPosts');
    final posts =
        await userPostsIns.orderBy('timeStamp', descending: true).get();
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = posts.docs;
    final List<Post> temp = [];
    for (var doc in docs) {
      temp.add(Post.fromDoc(doc));
    }
    _userPosts = temp;
  }

  void deletePost(String postId) {
    _userPosts.removeWhere((p) => p.postId == postId);
    notifyListeners();
  }

  void addPost(Post p) {
    _userPosts.add(p);
    notifyListeners();
  }
}
