// import 'package:dio/dio.dart';

// import 'api_error_model.dart';

// class ApiErrorHandler {
//   static ApiErrorModel handle(dynamic error) {
//     if (error is DioException) {
//       switch (error.type) {
//         case DioExceptionType.connectionError:
//           return ApiErrorModel(
//             errorMessage: ErrorData(
//               message: 'Connection to server failed',
//               code: 500,
//             ),
//             status: false,
//           );
//         case DioExceptionType.cancel:
//           return ApiErrorModel(
//             errorMessage: ErrorData(
//               message: "Request to the server was cancelled",
//               code: 499,
//             ),
//             status: false,
//           );
//         case DioExceptionType.connectionTimeout:
//           return ApiErrorModel(
//             errorMessage: ErrorData(
//               message: "Connection timeout with the server",
//               code: 408,
//             ),
//             status: false,
//           );
//         case DioExceptionType.unknown:
//           return ApiErrorModel(
//             errorMessage: ErrorData(
//               message:
//                   "Connection to the server failed due to internet connection",
//               code: 0,
//             ),
//             status: false,
//           );
//         case DioExceptionType.receiveTimeout:
//           return ApiErrorModel(
//             errorMessage: ErrorData(
//               message: "Receive timeout in connection with the server",
//               code: 408,
//             ),
//             status: false,
//           );
//         case DioExceptionType.badResponse:
//           return _handleError(error.response?.statusCode, error.response?.data);
//         case DioExceptionType.sendTimeout:
//           return ApiErrorModel(
//             errorMessage: ErrorData(
//               message: "Send timeout in connection with the server",
//               code: 408,
//             ),
//             status: false,
//           );
//         default:
//           return ApiErrorModel(
//             errorMessage: ErrorData(message: "Something went wrong", code: 500),
//             status: false,
//           );
//       }
//     } else {
//       return ApiErrorModel(
//         errorMessage: ErrorData(message: 'Unknown error occurred', code: 500),
//         status: false,
//       );
//     }
//   }

//   static ApiErrorModel _handleError(int? statusCode, dynamic response) {
//     String message = 'Unknown error occurred';
//     int code = statusCode ?? 500;

//     try {
//       if (response is Map<String, dynamic>) {
//         // Legacy shape: { error: { description, statusCode } }
//         final legacyError = response['error'];
//         if (legacyError is Map<String, dynamic>) {
//           final legacyMsg = legacyError['description'];
//           final legacyCode = legacyError['statusCode'];
//           if (legacyMsg is String && legacyMsg.isNotEmpty) {
//             message = legacyMsg;
//           }
//           if (legacyCode is int) {
//             code = legacyCode;
//           } else if (legacyCode is num) {
//             code = legacyCode.toInt();
//           }
//         }

//         // Common shape: { message: String, errors: Map/List }
//         final topMessage = response['message'];
//         if (topMessage is String && topMessage.isNotEmpty) {
//           message = topMessage;
//         }

//         final errorsField = response['errors'];
//         final errorsString = _stringifyErrors(errorsField);
//         if (errorsString != null && errorsString.isNotEmpty) {
//           // Prefer detailed field errors; append to top-level if both exist.
//           message = (message.isNotEmpty && message != errorsString)
//               ? '$message\n$errorsString'
//               : errorsString;
//         }

//         // Fallback code discovery
//         final topCode = response['statusCode'];
//         if (topCode is int) {
//           code = topCode;
//         } else if (topCode is num) {
//           code = topCode.toInt();
//         }
//       } else if (response is String && response.isNotEmpty) {
//         message = response;
//       }
//     } catch (_) {
//       // Keep safe defaults when parsing fails.
//     }

//     return ApiErrorModel(
//       errorMessage: ErrorData(message: message, code: code),
//       status: false,
//       // Do not attempt to mirror backend 'data' for error responses; leave null
//       data: null,
//     );
//   }

//   static String? _stringifyErrors(dynamic errorsField) {
//     if (errorsField == null) return null;

//     // Shape: { field: ["msg1", "msg2"], ... }
//     if (errorsField is Map) {
//       final buffer = StringBuffer();
//       errorsField.forEach((key, value) {
//         if (value is List) {
//           for (final item in value) {
//             if (item is String && item.isNotEmpty) {
//               buffer.writeln(item);
//             }
//           }
//         } else if (value is String && value.isNotEmpty) {
//           buffer.writeln(value);
//         }
//       });
//       final result = buffer.toString().trim();
//       return result.isEmpty ? null : result;
//     }

//     // Shape: ["msg1", "msg2"]
//     if (errorsField is List) {
//       final parts = errorsField.whereType<String>().where((e) => e.isNotEmpty);
//       final result = parts.join('\n').trim();
//       return result.isEmpty ? null : result;
//     }

//     // Fallback: single string
//     if (errorsField is String && errorsField.isNotEmpty) {
//       return errorsField;
//     }

//     return null;
//   }
// }
