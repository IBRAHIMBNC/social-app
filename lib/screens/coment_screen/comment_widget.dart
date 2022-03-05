import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:soical_app_pro/models/comment.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentWidget extends StatelessWidget {
  final Comment comment;
  const CommentWidget({Key? key, required this.comment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(comment.ownerProfile),
          ),
          const SizedBox(width: 10),
          Container(
              width: size.width * 0.6,
              decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(15)),
              padding: const EdgeInsets.only(
                  top: 10, right: 20, left: 10, bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comment.ownerName,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Text(
                      comment.text,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Text(
                    timeago.format(
                      comment.timeStamp.toDate(),
                    ),
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 14, color: Colors.black38),
                  ),
                ],
              ))
        ],
      ),
    );
  }
}
