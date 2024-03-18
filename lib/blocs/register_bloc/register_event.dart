part of 'register_bloc.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object> get props => [];
}

class RegisterRequired extends RegisterEvent{
  final MyUser user;
  final String password;

  const RegisterRequired(this.user, this.password);
}