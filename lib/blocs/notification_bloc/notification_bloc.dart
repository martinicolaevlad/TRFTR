import 'dart:async';
import 'dart:developer';
import 'dart:ffi';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notification_repository/notification_repository.dart';
import 'package:sh_app/blocs/my_user_bloc/my_user_bloc.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepo _notificationRepo;
  StreamSubscription? _notificationSubscription;

  NotificationBloc({required NotificationRepo notificationRepo})
      : _notificationRepo = notificationRepo,
        super(NotificationInitial()) {

    on<LoadNotifications>((event, emit) async {
      emit(NotificationLoading());
      await _notificationSubscription?.cancel();
      _notificationSubscription = _notificationRepo.getNotificationsByUserId(event.userId).listen(
              (notifications) {
            add(UpdateNotifications(notifications));
          },
          onError: (error) {
            emit(NotificationFailure());
            log('Error retrieving notifications: ${error.toString()}');
          }
      );
    });

    on<UpdateNotifications>((event, emit) {
      emit(NotificationLoaded(notifications: event.notifications));
    });

    on<CancelNotificationStream>((event, emit) async{
      await _notificationSubscription?.cancel();
      emit(NotificationInitial());
    });
  }

  @override
  Future<void> close() async{
    await _notificationSubscription?.cancel();
    return super.close();
  }
}
