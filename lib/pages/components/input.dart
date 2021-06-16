import 'package:flutter/material.dart';

class Input extends StatelessWidget {
  final bool autocorrect;
  final bool obscureText;
  final String? error;
  final String? label;
  final Function(String)? onChanged;

  Input({
    this.obscureText = false,
    this.autocorrect = true,
    this.error,
    this.label,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      autocorrect: autocorrect,
      decoration: InputDecoration(
        fillColor: Colors.grey[250],
        border: OutlineInputBorder(),
        labelText: this.label,
        errorText: error,
      ),
      obscureText: obscureText,
      onChanged: onChanged,
    );
  }
}
