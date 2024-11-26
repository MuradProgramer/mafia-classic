import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mafia_classic/models/models.dart';
import 'package:mafia_classic/repositories/repositories.dart';

part 'sign_in_event.dart';
part 'sign_in_state.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  final AuthRepository authRepository;

  SignInBloc({required this.authRepository}) : super(SignInInitial()) {
    on<SignInRequested>(_onSignInRequested);
  }

  void _onSignInRequested(SignInRequested event, Emitter<SignInState> emit) async {
    emit(SignInLoading());
    try {
      final user = await authRepository.signIn(event.email, event.password);
      emit(SignInSuccess(user: user));
    } catch (e) {
      emit(SignInFailure(error: e.toString()));
    }
  }
}
