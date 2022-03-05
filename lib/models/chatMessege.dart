import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class TextMessage {
  final String text;
  final String id;
  final bool isOwner;
  final Timestamp timeStamp;

  TextMessage({
    required this.id,
    required this.text,
    required this.isOwner,
    required this.timeStamp,
  });

  factory TextMessage.fromDoc(DocumentSnapshot doc) {
    return TextMessage(
        id: doc.get('id'),
        text: doc.get('text'),
        isOwner: doc.get('isOwner'),
        timeStamp: doc.get('timeStamp'));
  }
}

class Chat with ChangeNotifier {
  List<TextMessage> _userChat = [];
  final chatsRef = FirebaseFirestore.instance.collection('chats');

  List<TextMessage> get userChat {
    return [..._userChat];
  }

  Future<void> fetchMesseges(
      {String? currentUserId, required String senderId}) async {
    final chatDocs = await chatsRef
        .doc(currentUserId)
        .collection('userChats')
        .doc(senderId)
        .collection('messeges')
        .get();
    List<TextMessage> temp = [];
    for (var doc in chatDocs.docs) {
      temp.add(TextMessage.fromDoc(doc));
    }
    _userChat = temp;
  }

  void makeList(List<QueryDocumentSnapshot<Map<String, dynamic>>> list) {
    List<TextMessage> temp = [];
    for (var doc in list) {
      temp.add(TextMessage.fromDoc(doc));
    }
    _userChat = temp;
  }
}
