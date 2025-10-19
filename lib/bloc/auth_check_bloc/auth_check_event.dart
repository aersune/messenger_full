part of 'auth_check_bloc.dart';

@immutable
sealed class AuthCheckEvent {}



class AuthCheckRequested extends AuthCheckEvent {}

class AuthSignInRequested extends AuthCheckEvent {}

class AuthSignedOut extends AuthCheckEvent {}
