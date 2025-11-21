// import 'api_constants.dart';

// class DioFactory {
//   static Dio? _dio;

//   static Dio getDio({bool withAuth = true}) {
//     if (_dio == null) {
//       _dio = Dio();
//       _dio!.options.baseUrl = ApiConstants.baseUrl;
//       _dio!.options.headers = {
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//         'Accept-Language': 'en',
//       };
//       // Allow HTTP 3xx responses and follow redirects so 302 does not throw
//       _dio!.options.followRedirects = true;
//       _dio!.options.validateStatus = (status) {
//         if (status == null) return false;
//         // Accept all statuses in 200..399 range
//         return status >= 200 && status < 400;
//       };

//       _dio!.interceptors.add(
//         PrettyDioLogger(
//           request: true,
//           requestHeader: true,
//           requestBody: true,
//           responseHeader: true,
//           responseBody: true,
//           error: true,
//           compact: false,
//           maxWidth: 90,
//         ),
//       );
//     }
//     return _dio!;
//   }

//   static void setAuthHeader(String accessToken) {
//     _dio?.options.headers['Authorization'] = 'Bearer $accessToken';
//   }

//   static void setCookieHeader(String refreshToken) {
//     _dio?.options.headers['Cookie'] = 'RefreshToken=$refreshToken';
//   }
// }
