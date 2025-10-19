part of 'auth_check_bloc.dart';

@immutable
sealed class AuthCheckState {}

final class AuthCheckInitial extends AuthCheckState {}



class Authenticated extends AuthCheckState {
  final String email;
  Authenticated(this.email);
}

class Unauthenticated extends AuthCheckState {}

class AuthLoading extends AuthCheckState {}