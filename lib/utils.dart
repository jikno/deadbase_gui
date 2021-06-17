import 'package:flutter/material.dart';

void notifyUser(BuildContext context, String message, {bool success = false, bool failure = false}) {
  final snackbar = SnackBar(
    content: Row(
      children: [
        success
            ? Icon(
                Icons.check,
                color: Colors.green,
              )
            : failure
                ? Icon(
                    Icons.close,
                    color: Colors.red,
                  )
                : Icon(Icons.info, color: Colors.blue),
        SizedBox(
          width: 10,
        ),
        Text(message)
      ],
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackbar);
}
