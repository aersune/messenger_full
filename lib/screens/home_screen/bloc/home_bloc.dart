import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../../model/user.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final FirebaseDatabase realtimeDb;

  HomeBloc({
    required this.auth,
    required this.firestore,
    required this.realtimeDb,
  }) : super(HomeInitial()) {
    on<LoadCurrentUserEvent>(_onLoadCurrentUser);
    on<LoadUsersEvent>(_onLoadUsers);
  }

  Future<void> _onLoadCurrentUser(
      LoadCurrentUserEvent event, Emitter<HomeState> emit) async {
    try {
      emit(HomeLoading());
      final user = auth.currentUser;
      final doc = await firestore.collection('users').doc(user!.uid).get();
      final userData = UserData.fromJson(doc.data()!);
      emit(HomeUserLoaded(userData));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> _onLoadUsers(
      LoadUsersEvent event, Emitter<HomeState> emit) async {
    try {
      final currentUser = auth.currentUser;
      final currentUserDoc =
      await firestore.collection('users').doc(currentUser!.uid).get();
      final currentUserData = UserData.fromJson(currentUserDoc.data()!);

      final usersStream = firestore.collection('users').snapshots();

      await emit.forEach(
        usersStream,
        onData: (snapshot) {
          return HomeLoaded(
            users: snapshot.docs,
            userStatus: {},
            currentUser: currentUserData,
          );
        },
      );
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}