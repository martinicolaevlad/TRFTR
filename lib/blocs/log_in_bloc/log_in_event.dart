part of 'log_in_bloc.dart';

abstract class LogInEvent extends Equatable {
  const LogInEvent();

  @override
  List<Object> get props => [];
}

class LogInRequired extends LogInEvent{
  final String email;
  final String password;

  const LogInRequired(this.email, this.password);
}

class LogOutRequired extends LogInEvent{

  const LogOutRequired();
}