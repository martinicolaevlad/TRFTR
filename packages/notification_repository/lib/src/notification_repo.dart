import 'models/models.dart'; // Ensure this path imports the Notification model correctly

abstract class NotificationRepo {

  Stream<List<MyNotification>> getNotificationsByUserId(String userId);
}
