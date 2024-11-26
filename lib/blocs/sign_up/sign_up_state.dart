part of 'sign_up_bloc.dart';

abstract class SignUpState extends Equatable {
  const SignUpState();

  @override
  List<Object> get props => [];
}

class SignUpInitial extends SignUpState {}

class SignUpLoading extends SignUpState {}

class SignUpSuccess extends SignUpState {
  final User user;

  const SignUpSuccess({required this.user});

  @override
  List<Object> get props => [user];
}

class SignUpFailure extends SignUpState {
  final String error;

  const SignUpFailure({required this.error});

  @override
  List<Object> get props => [error];
}
