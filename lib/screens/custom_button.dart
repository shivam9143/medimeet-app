import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  CustomButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(label),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: TextStyle(fontSize: 16),
      ),
    );
  }
}