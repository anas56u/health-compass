// import 'package:flutter/material.dart';
// import 'package:kid_flix_app/features/profile/data/model/profile_model.dart';

// class TimeRestrictionHelper {
//   /// Check if current time is within any of the allowed time ranges
//   static bool isTimeAllowed(List<UserTimeActive>? timeActiveList) {
//     if (timeActiveList == null || timeActiveList.isEmpty) {
//       // If no time restrictions, allow access
//       return true;
//     }

//     final now = DateTime.now();
//     final currentTime = TimeOfDay.fromDateTime(now);

//     for (var timeActive in timeActiveList) {
//       if (timeActive.start != null && timeActive.end != null) {
//         final startTime = _parseTime(timeActive.start!);
//         final endTime = _parseTime(timeActive.end!);

//         if (startTime != null && endTime != null) {
//           if (_isTimeInRange(currentTime, startTime, endTime)) {
//             return true;
//           }
//         }
//       }
//     }

//     return false;
//   }

//   /// Parse time string (HH:mm:ss or HH:mm) to TimeOfDay
//   static TimeOfDay? _parseTime(String timeString) {
//     try {
//       final parts = timeString.split(':');
//       if (parts.length >= 2) {
//         final hour = int.parse(parts[0]);
//         final minute = int.parse(parts[1]);
//         return TimeOfDay(hour: hour, minute: minute);
//       }
//     } catch (e) {
//       return null;
//     }
//     return null;
//   }

//   /// Check if current time is within the range [start, end]
//   static bool _isTimeInRange(
//     TimeOfDay current,
//     TimeOfDay start,
//     TimeOfDay end,
//   ) {
//     final currentMinutes = current.hour * 60 + current.minute;
//     final startMinutes = start.hour * 60 + start.minute;
//     final endMinutes = end.hour * 60 + end.minute;

//     // Handle case where end time is next day (e.g., 22:00 to 02:00)
//     if (endMinutes < startMinutes) {
//       return currentMinutes >= startMinutes || currentMinutes <= endMinutes;
//     }

//     return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
//   }
// }
