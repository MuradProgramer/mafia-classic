part of 'sign_in_bloc.dart';

abstract class SignInEvent extends Equatable {
  const SignInEvent();

  @override
  List<Object> get props => [];
}

class SignInRequested extends SignInEvent {
  final String email;
  final String password;

  const SignInRequested(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}
