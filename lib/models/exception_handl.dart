import 'package:flutter/material.dart';

Future<void> showErrorDial(BuildContext context, String msg, String screen) {
  return showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          content: Text(msg),
          title: Text('$screen failed'),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(), child: Text('OK'))
          ],
        );
      });
}
