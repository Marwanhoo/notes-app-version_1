import 'package:flutter/material.dart';

showLoading(context) {
  return showDialog(
    context: context,
    builder: (_) => const AlertDialog(
      content: Row(
        children: [
          CircularProgressIndicator(),
          SizedBox(
            width: 20,
          ),
          Text("Loading"),
        ],
      ),
    ),
  );
}

void navigateAndFinish(context, widget) => Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => widget,
      ),
      (route) => false,
    );

validateRequiredField(String? value, String fieldName) {
  if (value == null || value.isEmpty) {
    return 'Please enter $fieldName';
  }
  if (value.length > 200) {
    return "Please enter $fieldName less than 200 characters";
  }
  if (value.length < 3) {
    return "Please enter $fieldName more than 3 characters";
  }
}
