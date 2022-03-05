import 'package:cloud_firestore/cloud_firestore.dart';

class TimelinePost {
  final String profilePic;
  final String ownerName;
  final Timestamp timeStamp;
  final String discreption;
  final String mediaUrl;
  final String ownerId;
  final String postId;
  final bool isAdminPost;
  final bool isStudentOrgPost;
  final Map<String, dynamic> likes;

  TimelinePost({
    required this.timeStamp,
    required this.discreption,
    required this.mediaUrl,
    required this.ownerId,
    required this.postId,
    required this.likes,
    required this.profilePic,
    required this.ownerName,
    required this.isAdminPost,
    required this.isStudentOrgPost,
  });

  factory TimelinePost.fromDoc(DocumentSnapshot doc) {
    return TimelinePost(
      isStudentOrgPost: doc.get('isStudentOrgPost'),
      isAdminPost: doc.get('isAdminPost'),
      profilePic: doc.get('profilePic'),
      ownerName: doc.get('ownerName'),
      timeStamp: doc.get('timeStamp'),
      discreption: doc.get('description'),
      mediaUrl: doc.get('mediaUrl'),
      ownerId: doc.get('ownerId'),
      postId: doc.get('postId'),
      likes: doc.get('likes'),
    );
  }
}
