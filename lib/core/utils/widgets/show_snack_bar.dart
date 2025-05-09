import 'package:flutter/material.dart';

void showSnackBar(
  BuildContext context, {
  required String content,
  Color color = Colors.red,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(content),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
    ),
  );
} 