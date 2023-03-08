import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:mx_companion_v1/controllers/auth_controller.dart';
import 'package:mx_companion_v1/main.dart';
import '../firebase_ref/references.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:http/http.dart' as http;

class HelperNotification {
  static Future<void> initInfo(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var androidInitialize =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    //var iosInitialize = const IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
      android: androidInitialize,
      //iOS: iosInitialize,
    );
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {},
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    tz.initializeTimeZones();

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      showNotification(message, flutterLocalNotificationsPlugin);

      if (Get.find<AuthController>().getUser() != null) {
        sendNotificationToFirebase(
            message.notification?.title,
            message.notification?.body,
            Get.find<AuthController>().getUser()!.uid,
            message.data['type']);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      try {
        if (message.notification?.title != null &&
            message.notification?.body != null) {
          if (Get.find<AuthController>().getUser() != null &&
              Get.find<AuthController>().getUser()!.emailVerified) {
            Get.find<AuthController>().navigateToHome();
          } else if (Get.find<AuthController>().getUser()!.emailVerified ==
              false) {
            Get.find<AuthController>().navigateToVerify();
          }
        }
      } catch (e) {
        return;
      }
    });
  }

  static Future<void> sendNotificationToFirebase(
      String? title, String? body, String uid, String? type) async {
    try {
      var batch = FirebaseFirestore.instance.batch();

      batch.set(userRF.doc(uid).collection('user_notifications').doc(), {
        'notification_title': title,
        'notification_body': body,
        "type": type ?? "",
        'created': DateTime.now(),
      });
      batch.commit();
    } catch (e) {
      return;
    }
  }

  static Future<void> showNotification(
      RemoteMessage message, FlutterLocalNotificationsPlugin flp) async {
    BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
      message.notification!.body.toString(),
      htmlFormatBigText: true,
      contentTitle: message.notification!.title.toString(),
      htmlFormatContentTitle: true,
    );

    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'MX Companion',
      'MX Companion',
      importance: Importance.high,
      styleInformation: bigTextStyleInformation,
      priority: Priority.high,
      playSound: true,
    );

    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      //iOS: IOSNotificationDetails(),
    );

    await flp.show(
      0,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
      payload: message.data['body'],
    );
  }

  static Future<void> sendSuccessMessage(
      String userId, String body, String title, String type) async {
    DocumentSnapshot snap = await userRF
        .doc(userId)
        .collection('user_device_token')
        .doc('device_token')
        .get();
    String token = snap['device_token'];
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=${dotenv.env['MESSAGING_API_KEY']}'
        },
        body: jsonEncode(
          <String, dynamic>{
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'status': 'done',
              'type': type,
              'body': body,
              'title': title
            },
            'notification': <String, dynamic>{
              'title': title,
              'body': body,
              'android_channel_id': 'Mx Companion'
            },
            'to': token,
          },
        ),
      );
    } catch (e) {
      return;
    }
  }

  static Future<void> scheduleNotifications(
      int id,
      String title,
      String body,
      DateTime time,
      String uid,
      String paperId
      ) async {
    try {

      BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
        body,
        htmlFormatBigText: true,
        contentTitle: title,
        htmlFormatContentTitle: true,
      );

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(time, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'MX Companion',
            'MX Companion',
            importance: Importance.max,
            priority: Priority.high,
            styleInformation: bigTextStyleInformation,
          ),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidAllowWhileIdle: true,
      );

      try {
        var batch = FirebaseFirestore.instance.batch();
        batch.set(userRF.doc(uid).collection('user_schedule').doc(paperId), {
          "reminder_id": id,
          "isSet": true,
          'created': DateTime.now(),
        });
        batch.commit();
      } catch (e) {
        return;
      }

      Get.find<AuthController>().showSnackBar(
          'Reminder set! You will be notified on ${time.toString().substring(0, 10)} at ${time.toString().substring(11, 16)}.');
    } catch (e) {
      print('Notification: $e');
      Get.find<AuthController>().showSnackBar(
          'Unable to schedule notification. Please select a valid date and time.');
    }
  }

  static Future<void> scheduleLocalNotifications(
      int id, String title, String body, DateTime time) async {
    try {
      BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
        body,
        htmlFormatBigText: true,
        contentTitle: title,
        htmlFormatContentTitle: true,
      );

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(time, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'MX Companion',
            'MX Companion',
            importance: Importance.max,
            priority: Priority.high,
            styleInformation: bigTextStyleInformation,
          ),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidAllowWhileIdle: true,
      );
    } catch (e) {
      return;
    }
  }

  static Future<void> cancelScheduledNotification(int id) async {
    try {
      await flutterLocalNotificationsPlugin.cancel(id);
      Get.find<AuthController>().showSnackBar('Reminder removed.');
    } catch(e){
      Get.find<AuthController>().showSnackBar('Operation failed.');
    }
  }

  static Future<bool> isPendingNotification(
    int notificationId,
  ) async {
    final List<PendingNotificationRequest> pendingNotificationRequests =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    for(var notification in pendingNotificationRequests){
      if(notificationId == notification.id){
        return true;
      }
    }
    return false;
  }

  static Future<void> cancelAllReminder() async {
    try {
      await flutterLocalNotificationsPlugin.cancelAll();
      Get.find<AuthController>().showSnackBar('All reminders cancelled.');
    } catch(e){
      Get.find<AuthController>().showSnackBar('Operation failed.');
    }
  }
}
