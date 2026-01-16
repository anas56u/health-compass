part of 'login_cubit.dart';

@immutable
sealed class LoginState {}

final class LoginInitial extends LoginState {}

final class LoginLoading extends LoginState {}

final class LoginSuccess extends LoginState {
  final String message;
  final User? user;
  final String userType;
  final String route;
  final String permission;

  LoginSuccess({
    required this.message,
    this.user,
    required this.userType,
    required this.route,
    this.permission = 'interactive',
  });
}

final class LoginFailure extends LoginState {
  final String error;

  LoginFailure({required this.error});
}
