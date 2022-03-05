import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String ownerId;
  final String text;
  final Timestamp timeStamp;
  final String ownerProfile;
  final String ownerName;

  Comment(this.ownerId, this.text, this.timeStamp, this.ownerProfile,
      this.ownerName);

  factory Comment.fromDoc(DocumentSnapshot doc) {
    return Comment(doc.get('ownerId'), doc.get('text'), doc.get('timeStamp'),
        doc.get('ownerProfile'), doc.get('ownerName'));
  }
}
