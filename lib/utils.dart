import 'package:flutter/material.dart';
import './state.dart';

class NoScaffoldContextException implements Exception {}

void notifyUser(String message, {bool success = false, bool failure = false}) {
  if (scaffoldContext == null) throw NoScaffoldContextException();

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

  ScaffoldMessenger.of(scaffoldContext!).showSnackBar(snackbar);
}
