import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

import '../../services/auth_services.dart';


part 'auth_check_event.dart';
part 'auth_check_state.dart';

class AuthCheckBloc extends Bloc<AuthCheckEvent, AuthCheckState> {
  final AuthService authService;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  AuthCheckBloc(this.authService) : super(AuthCheckInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignedOut>(_onSignedOut);
  }
  Future<void> _onCheckRequested(AuthCheckRequested event, Emitter<AuthCheckState> emit) async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      emit(Authenticated(user.email ?? ''));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onSignInRequested(AuthSignInRequested event, Emitter<AuthCheckState> emit) async {
    emit(AuthLoading());
    try {
      final email = await authService.signInWithGoogle();
      if (email != null) {
        emit(Authenticated(email));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(Unauthenticated());
    }
  }


  Future<void> _onSignedOut(AuthSignedOut event, Emitter<AuthCheckState> emit) async {
    await _firebaseAuth.signOut();
    emit(Unauthenticated());
  }


}
