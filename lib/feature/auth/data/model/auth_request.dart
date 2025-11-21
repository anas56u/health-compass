class LoginRequest {
  final String? email;
  final String? password;

  LoginRequest({this.email, this.password});

  factory LoginRequest.fromJson(Map<String, dynamic> json) {
    return LoginRequest(email: json['email'], password: json['password']);
  }
  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}

class RegisterRequest {
  final String email;
  final String password;
  final String kidName;
  final String parentFirstName;
  final String parentLastName;
  final String country;
  final String birthdate; // expected format: dd-MM-yyyy
  final int gender; // 0/1

  RegisterRequest({
    required this.email,
    required this.password,
    required this.kidName,
    required this.parentFirstName,
    required this.parentLastName,
    required this.country,
    required this.birthdate,
    required this.gender,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'kid_name': kidName,
      'p_first_name': parentFirstName,
      'p_last_name': parentLastName,
      'country': country,
      'birthdate': birthdate,
      'gender': gender,
    };
  }
}

class VerifyEmailRequest {
  final String verifyCode;

  VerifyEmailRequest({required this.verifyCode});

  Map<String, dynamic> toJson() {
    return {'verify_code': verifyCode};
  }
}
