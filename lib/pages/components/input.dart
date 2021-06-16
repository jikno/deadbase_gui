import 'package:flutter/material.dart';

class Input extends StatelessWidget {
  final bool autocorrect;
  final bool obscureText;
  final String? error;
  final String? label;
  final Function(String)? onChanged;
  final String value;

  Input({
    this.obscureText = false,
    this.autocorrect = true,
    this.error,
    this.label,
    this.onChanged,
    this.value = '',
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
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
