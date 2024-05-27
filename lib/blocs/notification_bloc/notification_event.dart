part of 'notification_bloc.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();
}


class GetNotificationsByUserId extends NotificationEvent {
  final String userId;

  const GetNotificationsByUserId(this.userId);

  @override
  List<Object> get props => [userId];
}
