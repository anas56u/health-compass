import 'package:flutter/material.dart';

class AppShadows {
  // Private constructor to prevent instantiation
  AppShadows._();

  // ============ Original Shadow ============
  static const BoxShadow shadow1 = BoxShadow(
    color: Colors.black26,
    blurRadius: 10,
    offset: Offset(0, 5),
  );

  // ============ New Shadows from Design ============

  // Shadow 1: box-shadow: 0px 0px 4px 0px #00000040;
  // استخدم للحدود الخفيفة والـ borders
  static const BoxShadow lightShadow = BoxShadow(
    color: Color(0x40000000), // #00000040 - Black with 25% opacity
    blurRadius: 4,
    offset: Offset(0, 0),
    spreadRadius: 0,
  );

  // Shadow 2: box-shadow: 0px 4px 114px 0px #3B599845;
  // استخدم للـ cards والـ elevated elements
  static const BoxShadow deepBlueShadow = BoxShadow(
    color: Color(0x453B5998), // #3B599845 - Deep blue with 27% opacity
    blurRadius: 114,
    offset: Offset(0, 4),
    spreadRadius: 0,
  );

  // Shadow 3: box-shadow: 0px 7px 15px 0px #397AFF66;
  // استخدم للـ buttons والعناصر التفاعلية - Primary Blue Shadow
  static const BoxShadow primaryBlueShadow = BoxShadow(
    color: Color(0x66397AFF), // #397AFF66 - Primary blue with 40% opacity
    blurRadius: 15,
    offset: Offset(0, 7),
    spreadRadius: 0,
  );

  // ============ Additional Useful Shadows ============

  // Shadow للـ buttons (قديم - استخدم primaryBlueShadow بدلاً منه)
  static const BoxShadow buttonShadow = BoxShadow(
    color: Color(0x403397FF), // Primary blue with 25% opacity
    blurRadius: 10,
    offset: Offset(0, 4),
    spreadRadius: 0,
  );

  // Shadow للـ cards (متوسط)
  static const BoxShadow cardShadow = BoxShadow(
    color: Color(0x1A000000), // Black with 10% opacity
    blurRadius: 8,
    offset: Offset(0, 2),
    spreadRadius: 0,
  );

  // Shadow للـ elevated cards (أقوى)
  static const BoxShadow elevatedCardShadow = BoxShadow(
    color: Color(0x33000000), // Black with 20% opacity
    blurRadius: 16,
    offset: Offset(0, 4),
    spreadRadius: 0,
  );

  // Shadow للـ bottom sheets و dialogs
  static const BoxShadow modalShadow = BoxShadow(
    color: Color(0x4D000000), // Black with 30% opacity
    blurRadius: 24,
    offset: Offset(0, 8),
    spreadRadius: 0,
  );

  // Shadow للـ app bar
  static const BoxShadow appBarShadow = BoxShadow(
    color: Color(0x0D000000), // Black with 5% opacity
    blurRadius: 4,
    offset: Offset(0, 2),
    spreadRadius: 0,
  );

  // ============ Shadow Lists for Multiple Shadows ============

  // List للـ buttons مع تأثير مزدوج (محدّث)
  static const List<BoxShadow> buttonShadows = [
    BoxShadow(
      color: Color(0x40000000), // Outer shadow
      blurRadius: 4,
      offset: Offset(0, 0),
    ),
    BoxShadow(
      color: Color(0x66397AFF), // Primary blue shadow - NEW
      blurRadius: 15,
      offset: Offset(0, 7),
    ),
  ];

  // List للـ buttons (نسخة أخف)
  static const List<BoxShadow> buttonShadowsLight = [
    BoxShadow(
      color: Color(0x1A000000), // Very light outer shadow
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x66397AFF), // Primary blue shadow
      blurRadius: 15,
      offset: Offset(0, 7),
    ),
  ];

  // List للـ cards مع depth
  static const List<BoxShadow> cardDepthShadows = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 2)),
    BoxShadow(color: Color(0x453B5998), blurRadius: 114, offset: Offset(0, 4)),
  ];

  // List للـ floating action button
  static const List<BoxShadow> fabShadows = [
    BoxShadow(color: Color(0x40000000), blurRadius: 8, offset: Offset(0, 4)),
    BoxShadow(
      color: Color(0x40D56DEE), // Purple shadow
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];

  // List للـ interactive cards (NEW)
  static const List<BoxShadow> interactiveCardShadows = [
    BoxShadow(color: Color(0x40000000), blurRadius: 4, offset: Offset(0, 0)),
    BoxShadow(
      color: Color(0x66397AFF), // Primary blue shadow
      blurRadius: 15,
      offset: Offset(0, 7),
    ),
  ];
}

// ============ كيفية الاستخدام ============

//! 1. Shadow واحد:
// Container(
//   decoration: BoxDecoration(
//     color: Colors.white,
//     borderRadius: BorderRadius.circular(16),
//     boxShadow: [AppShadows.lightShadow],
//   ),
//   child: YourWidget(),
// )

//! 2. استخدام الـ Primary Blue Shadow الجديد:
// Container(
//   decoration: BoxDecoration(
//     color: Colors.white,
//     borderRadius: BorderRadius.circular(16),
//     boxShadow: [AppShadows.primaryBlueShadow],
//   ),
//   child: YourWidget(),
// )

//! 3. Multiple Shadows:
// Container(
//   decoration: BoxDecoration(
//     color: Colors.white,
//     borderRadius: BorderRadius.circular(16),
//     boxShadow: AppShadows.cardDepthShadows, // List من shadows
//   ),
//   child: YourWidget(),
// )

//! 4. في الـ Custom Button (محدّث):
// // في custom_button.dart
// boxShadow: [AppShadows.primaryBlueShadow], // Single shadow
// // أو
// boxShadow: AppShadows.buttonShadows, // للتأثير المزدوج (محدّث)

//! 5. في الـ Cards التفاعلية:
// Card(
//   elevation: 0, // إلغاء الـ elevation الافتراضي
//   child: Container(
//     decoration: BoxDecoration(
//       borderRadius: BorderRadius.circular(16),
//       boxShadow: AppShadows.interactiveCardShadows, // NEW
//     ),
//     child: YourContent(),
//   ),
// )

//! 6. للـ Elevated Button مع hover effect:
// AnimatedContainer(
//   duration: Duration(milliseconds: 200),
//   decoration: BoxDecoration(
//     borderRadius: BorderRadius.circular(16),
//     boxShadow: isHovered 
//         ? AppShadows.buttonShadows 
//         : [AppShadows.primaryBlueShadow],
//   ),
//   child: YourButton(),
// )
