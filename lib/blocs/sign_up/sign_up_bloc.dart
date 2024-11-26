import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mafia_classic/models/models.dart';
import 'package:mafia_classic/repositories/repositories.dart';

part 'sign_up_event.dart';
part 'sign_up_state.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final AuthRepository authRepository;

  SignUpBloc({required this.authRepository}) : super(SignUpInitial()) {
    on<SignUpRequested>(_onSignUpRequested);
  }

  void _onSignUpRequested(SignUpRequested event, Emitter<SignUpState> emit) async {
    emit(SignUpLoading());
    try {
      final user = await authRepository.signUp(event.nickname, event.email, event.password);
      emit(SignUpSuccess(user: user));
    } catch (e) {
      emit(SignUpFailure(error: e.toString()));
    }
  }
}
