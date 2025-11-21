import 'package:flutter/material.dart';

class CustomTextfild extends StatelessWidget {
  @override
  final String? hinttext;
  final Function(String)? onChanged;
  final TextEditingController? controller;
  const CustomTextfild({
    super.key,
    this.hinttext,
    this.onChanged,
    this.controller,
  });
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
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
        fillColor: const Color(0xFFE2E8F0),
        hint: Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            hinttext ?? "",
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.3),
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
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
    );
  }
}
