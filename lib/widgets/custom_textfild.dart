import 'package:flutter/material.dart';

class CustomTextfild extends StatelessWidget {
  @override
  final String? hinttext;
  final Function(String)? onChanged;

  const CustomTextfild({super.key, this.hinttext, this.onChanged});
  Widget build(BuildContext context) {
    return TextFormField(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,

      style: TextStyle(color: Colors.black),
      validator: (value) {
        if (value!.isEmpty) {
          return "this field is required";
        }
      },
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: Color(0xFFF5F9FC),
        hint: Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            hinttext ?? "",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: Colors.grey, width: 1.3),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: Color(0xFF41BFAA), width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),

        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
      ),
    );
  }
}
