part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  @override
  List<Object?> get props => [];
}

final class HomeInitial extends HomeState {
  @override
  List<Object> get props => [];
}
class HomeLoading extends HomeState {}

class HomeUserLoaded extends HomeState {
  final UserData currentUser;
  HomeUserLoaded(this.currentUser);

  @override
  List<Object?> get props => [currentUser];
}


class HomeLoaded extends HomeState {
  final List<QueryDocumentSnapshot> users;
  final Map<dynamic, dynamic> userStatus;
  final UserData currentUser;
  HomeLoaded({
    required this.users,
    required this.userStatus,
    required this.currentUser,
  });

  @override
  List<Object?> get props => [users, userStatus, currentUser];
}


class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}