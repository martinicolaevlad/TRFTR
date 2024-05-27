import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notification_repository/notification_repository.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepo _notificationRepo;

  NotificationBloc({required NotificationRepo notificationRepo})
      : _notificationRepo = notificationRepo,
        super(NotificationInitial()) {

    on<GetNotificationsByUserId>((event, emit) async {
      emit(NotificationLoading());
      try {
        List<MyNotification> notifications = await _notificationRepo.getNotificationsByUserId(event.userId);
        emit(NotificationListSuccess(notifications));
      } catch (e) {
        emit(NotificationFailure());
      }
    });
  }
}
