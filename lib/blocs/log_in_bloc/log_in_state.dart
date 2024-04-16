part of 'log_in_bloc.dart';

@immutable
abstract class LogInState extends Equatable {
  const LogInState();

  @override
  List<Object> get props => [];
}

class LogInInitial extends LogInState {}

class LogInSuccess extends LogInState {}
class LogInProcess extends LogInState {}
class LogInFailure extends LogInState {
  final String? message;
  const LogInFailure({this.message});
}
