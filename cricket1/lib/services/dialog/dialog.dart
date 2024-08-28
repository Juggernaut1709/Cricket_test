import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final String message;

  CustomDialog({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            // Add your logic here
            Navigator.of(context).pop();
          },
          child: Text('OK'),
        ),
      ],
    );
  }
}
