// ضعه في ملف: lib/feature/achievements/data/model/reward_model.dart
import 'package:flutter/material.dart';

class RewardModel {
  final String title;
  final String subtitle;
  final int pointsCost; // تكلفة المكافأة بالنقاط (رقم وليس نص)
  final IconData icon;

  const RewardModel({
    required this.title,
    required this.subtitle,
    required this.pointsCost,
    required this.icon,
  });
}