import 'package:flutter/material.dart';
import 'package:loahstudio/constants/colors.dart';

class ConfigTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;

  const ConfigTextField({
    super.key,
    required this.label,
    required this.controller,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors.grey),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.pinkStrong),
          ),
        ),
        style: TextStyle(color: AppColors.brown),
      ),
    );
  }
}