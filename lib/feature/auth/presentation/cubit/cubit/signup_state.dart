abstract class SignupState {}

class SignupInitial extends SignupState {}

class SignupLoading extends SignupState {}

class SignupSuccess extends SignupState {
  final String userType;

  final String permission;

  SignupSuccess({required this.userType, required this.permission});
}

class SignupFailure extends SignupState {
  final String error;
  SignupFailure(this.error);
}
