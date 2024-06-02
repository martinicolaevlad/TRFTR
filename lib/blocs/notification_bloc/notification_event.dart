part of 'notification_bloc.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object> get props => [];
}

class LoadNotifications extends NotificationEvent{
  final String userId;
  const LoadNotifications(this.userId);

}

class UpdateNotifications extends NotificationEvent{
  final List<MyNotification> notifications;

  UpdateNotifications(this.notifications);

  @override
  List<Object> get props => [notifications];

}

class GetNotificationsByUserId extends NotificationEvent {
  final String userId;

  const GetNotificationsByUserId(this.userId);

  @override
  List<Object> get props => [userId];
}

class CancelNotificationStream extends NotificationEvent {

}
