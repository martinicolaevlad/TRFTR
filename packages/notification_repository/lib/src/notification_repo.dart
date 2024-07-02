import 'models/models.dart';

abstract class NotificationRepo {

  Stream<List<MyNotification>> getNotificationsByUserId(String userId);
}
