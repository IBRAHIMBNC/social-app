import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String name;
  final String id;
  final String email;
  final String bio;
  final String photoUrl;
  final DateTime timeStamp;
  final bool isAdmin;
  bool isStudentOrg;
  AppUser({
    required this.timeStamp,
    required this.id,
    required this.bio,
    required this.name,
    required this.email,
    required this.photoUrl,
    this.isAdmin = false,
    this.isStudentOrg = false,
  });

  factory AppUser.toDocument(DocumentSnapshot doc) {
    return AppUser(
      isStudentOrg: doc.get('isStudentOrg'),
      isAdmin: doc.get('isAdmin'),
      photoUrl: doc.get('photoUrl'),
      id: doc.get('userId'),
      bio: doc.get('bio'),
      name: doc.get('name'),
      email: doc.get('email'),
      timeStamp: DateTime.parse(doc.get('timeStamp')),
    );
  }
}
