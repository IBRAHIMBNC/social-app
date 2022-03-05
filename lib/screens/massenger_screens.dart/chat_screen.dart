import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soical_app_pro/constants.dart';
import 'package:soical_app_pro/models/chatMessege.dart';
import 'package:soical_app_pro/models/users.dart';
import 'package:soical_app_pro/providers/auth.dart';

import 'chatBubble.dart';

class ChatScreen extends StatefulWidget {
  final String userId;
  final String phtoUrl;
  final String name;
  const ChatScreen(
      {Key? key,
      required this.userId,
      required this.phtoUrl,
      required this.name})
      : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _fieldController = TextEditingController();
  final chatsRef = FirebaseFirestore.instance.collection('chats');

  @override
  void initState() {
    String currentUserId =
        Provider.of<Auth>(context, listen: false).currentUser!.id;
    chatsRef.doc(currentUserId).collection('userChats').doc(widget.userId).set({
      'userId': widget.userId,
      'photoUrl': widget.phtoUrl,
      'name': widget.name
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _fieldController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> onSend(AppUser currentUser) async {
    String msg = _fieldController.text;
    _fieldController.clear();

    final textMsg = TextMessage(
        id: '', text: msg, isOwner: true, timeStamp: Timestamp.now());
    await chatsRef
        .doc(currentUser.id)
        .collection('userChats')
        .doc(widget.userId)
        .collection('messeges')
        .add({
      'text': textMsg.text,
      'isOwner': textMsg.isOwner,
      'timeStamp': textMsg.timeStamp,
      'id': ''
    }).then((val) {
      chatsRef
          .doc(currentUser.id)
          .collection('userChats')
          .doc(widget.userId)
          .collection('messeges')
          .doc(val.id)
          .update({'id': val.id});
    });

    await chatsRef
        .doc(widget.userId)
        .collection('userChats')
        .doc(currentUser.id)
        .collection('messeges')
        .add({
      'text': textMsg.text,
      'isOwner': !textMsg.isOwner,
      'timeStamp': textMsg.timeStamp,
      'id': ''
    }).then((val) {
      chatsRef
          .doc(widget.userId)
          .collection('userChats')
          .doc(currentUser.id)
          .collection('messeges')
          .doc(val.id)
          .update({'id': val.id});
    });

    await chatsRef
        .doc(widget.userId)
        .collection('userChats')
        .doc(currentUser.id)
        .get()
        .then((value) {
      if (!value.exists) {
        chatsRef
            .doc(widget.userId)
            .collection('userChats')
            .doc(currentUser.id)
            .set({
          'userId': currentUser.id,
          'photoUrl': currentUser.photoUrl,
          'name': currentUser.name
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<Auth>(context, listen: false).currentUser!;
    final chat = Provider.of<Chat>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: kPrimaryColor,
        title: Row(
          children: [
            InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: const Icon(
                  Icons.arrow_back,
                  size: 30,
                )),
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(widget.phtoUrl),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Text(widget.name),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
                padding: const EdgeInsets.all(10),
                child: StreamBuilder(
                  stream: chatsRef
                      .doc(currentUser.id)
                      .collection('userChats')
                      .doc(widget.userId)
                      .collection('messeges')
                      .orderBy('timeStamp')
                      .snapshots(),
                  builder: (context,
                      AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                          snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    chat.makeList(snapshot.data!.docs);
                    return ListView.separated(
                      itemCount: chat.userChat.length,
                      itemBuilder: (context, index) {
                        final messeges = chat.userChat;
                        return ChatBubble(
                          timestamp: messeges[index].timeStamp,
                          isOwner: messeges[index].isOwner,
                          text: messeges[index].text,
                        );
                      },
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 5),
                    );
                  },
                )),
          ),
          Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: kPrimaryLightColor),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onSubmitted: (val) => onSend(currentUser),
                      controller: _fieldController,
                      decoration: const InputDecoration(
                          hintText: 'Type a messege',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(left: 20)),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      onSend(currentUser);
                    },
                    child: const Icon(Icons.send),
                  ),
                  const SizedBox(
                    width: 10,
                  )
                ],
              ))
        ],
      ),
    );
  }
}
