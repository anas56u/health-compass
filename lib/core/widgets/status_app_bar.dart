import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health_compass/core/themes/app_gradient.dart';

class StatusBarGradient extends StatelessWidget {
  const StatusBarGradient({super.key});

  @override
  Widget build(BuildContext context) {
    // تأكد من جعل أيقونات StatusBar بيضاء
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
    );

    // ارتفاع StatusBar حسب الجهاز
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    // استخدام gradient حسب gender theme
    final statusBarGradient = AppGradient.logoGradient;

    return Container(
      height: statusBarHeight,
      decoration: BoxDecoration(gradient: statusBarGradient),
    );
  }
}
