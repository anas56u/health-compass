// lib/feature/achievements/data/models/challenge_model.dart

import 'package:flutter/material.dart';

enum ChallengeType { daily, weekly, monthly }

class ChallengeModel {
  final String id;
  final String title;
  final String subtitle;
  final int points;
  final ChallengeType type; // نوع التحدي: يومي، أسبوعي، شهري
  final int totalSteps; // العدد الكلي المطلوب (مثلاً 7 أيام)
  final int currentSteps; // ما أنجزه المستخدم (مثلاً 5 أيام)
  final IconData icon;
  final Color color;
  
  // خاصية محسوبة (Computed Property) لمعرفة هل اكتمل التحدي أم لا
  bool get isCompleted => currentSteps >= totalSteps;

  // خاصية لحساب النسبة المئوية للإنجاز
  double get progressPercent => (currentSteps / totalSteps).clamp(0.0, 1.0);
  ChallengeModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    int? points,
    ChallengeType? type,
    int? totalSteps,
    int? currentSteps,
    IconData? icon,
    Color? color,
  }) {
    return ChallengeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      points: points ?? this.points,
      type: type ?? this.type,
      totalSteps: totalSteps ?? this.totalSteps,
      currentSteps: currentSteps ?? this.currentSteps, // هنا التغيير المهم
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }

  const ChallengeModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.points,
    required this.type,
    required this.totalSteps,
    required this.currentSteps,
    required this.icon,
    required this.color,
  });
}