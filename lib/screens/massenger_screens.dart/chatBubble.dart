import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:soical_app_pro/constants.dart';

class ChatBubble extends StatelessWidget {
  final bool isOwner;
  final String text;
  final Timestamp timestamp;
  const ChatBubble(
      {Key? key,
      required this.isOwner,
      required this.text,
      required this.timestamp})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          isOwner ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (isOwner)
          Opacity(
            opacity: 0.6,
            child: Text(DateFormat('hh:mm a').format(timestamp.toDate())),
          ),
        const SizedBox(
          width: 10,
        ),
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                  color: isOwner ? kPrimaryColor : kPrimaryLightColor,
                  borderRadius: BorderRadius.circular(20)),
              child: Text(text,
                  style: TextStyle(
                      color: isOwner ? Colors.white : Colors.black,
                      fontSize: 15)),
            ),
          ],
        ),
        const SizedBox(
          width: 10,
        ),
        if (!isOwner)
          Opacity(
            opacity: 0.6,
            child: Text(DateFormat('hh:mm a').format(timestamp.toDate())),
          ),
      ],
    );
  }
}
