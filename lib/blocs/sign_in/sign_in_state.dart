part of 'sign_in_bloc.dart';

abstract class SignInState extends Equatable {
  const SignInState();

  @override
  List<Object> get props => [];
}

class SignInInitial extends SignInState {}

class SignInLoading extends SignInState {}

class SignInSuccess extends SignInState {
  final User user;

  const SignInSuccess({required this.user});

  @override
  List<Object> get props => [user];
}

class SignInFailure extends SignInState {
  final String error;

  const SignInFailure({required this.error});

  @override
  List<Object> get props => [error];
}
