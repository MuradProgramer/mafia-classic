part of 'sign_up_bloc.dart';

abstract class SignUpEvent extends Equatable {
  const SignUpEvent();

  @override
  List<Object> get props => [];
}

class SignUpRequested extends SignUpEvent {
  final String nickname;
  final String email;
  final String password;

  const SignUpRequested(this.nickname, this.email, this.password);

  @override
  List<Object> get props => [nickname, email, password];
}
