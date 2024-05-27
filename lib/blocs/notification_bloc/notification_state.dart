part of 'notification_bloc.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();
}

class NotificationInitial extends NotificationState {
  @override
  List<Object> get props => [];
}

class NotificationLoading extends NotificationState {
  @override
  List<Object> get props => [];
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
