import 'package:flutter/material.dart';

class Taskitem_Model{
   final String title;
  final String subtitle;
  final IconData leadingIcon;
  final Color iconColor;
  final bool isCompleted;

  
const Taskitem_Model({
    required this.title,
    required this.subtitle,
    required this.leadingIcon,
    required this.iconColor,
    this.isCompleted = false,
  });
}