import 'package:flutter/material.dart';

class CustomTextfild extends StatelessWidget {
  final String? hinttext;
  final Function(String)? onChanged;
  final TextEditingController? controller;

  // ✅ 1. أضفنا المتغير هنا
  final bool obscureText;

  const CustomTextfild({
    super.key,
    this.hinttext,
    this.onChanged,
    this.controller,
    // ✅ 2. أضفناه في الكونستركتور مع قيمة افتراضية false
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,

      // ✅ 3. مررنا القيمة للـ TextFormField ليقوم بالإخفاء عند الحاجة
      obscureText: obscureText,

      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
      style: const TextStyle(color: Colors.black), // يفضل إضافة const
      validator: (value) {
        if (value!.isEmpty) {
          return "this field is required";
        }
        return null; // يجب إرجاع null إذا كان التحقق صحيحاً
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
          borderRadius: BorderRadius.circular(17), // توحيد الحواف
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
    );
  }
}
