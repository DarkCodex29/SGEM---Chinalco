import 'package:flutter/material.dart';
import 'package:get/get.dart';

extension ContextSnackBar on BuildContext {
  void errorSnackbar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.red),
        ),
        backgroundColor: Colors.white.withOpacity(0.6),
      ),
    );
  }

  void snackbar(String title, String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
    );
  }
}
