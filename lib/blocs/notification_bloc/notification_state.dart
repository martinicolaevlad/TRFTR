part of 'notification_bloc.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState{
  final List<MyNotification> notifications;

  const NotificationLoaded({this.notifications = const <MyNotification>[]});

  @override
  List<Object?> get props => [notifications];
}

class NotificationSuccess extends NotificationState {
  final MyNotification notification;

  const NotificationSuccess(this.notification);

  @override
  List<Object?> get props => [notification];
}

class NotificationListSuccess extends NotificationState {
  final List<MyNotification> notifications;

  const NotificationListSuccess(this.notifications);

  @override
  List<Object?> get props => [notifications];
}

class NotificationDeleted extends NotificationState {
  @override
  List<Object> get props => [];
}

class NotificationFailure extends NotificationState {
  @override
  List<Object> get props => [];
}
