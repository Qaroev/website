import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notification_permissions/notification_permissions.dart' as pr;
import 'package:permission_handler/permission_handler.dart';
import 'package:website/webview_page.dart';

import 'firebase_options.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  "high_importance_channel",
  "High Importance Notifications",
  importance: Importance.high,
);
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

@pragma("vm:entry-point")
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  var title = message.data['title'];
  var body = message.data["body"];
  if (title != null && body != null) {
    flutterLocalNotificationsPlugin.show(
        0,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            icon: '@drawable/ic_stat_ecoplantagro__2',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker',
            playSound: true,
            showWhen: true,
          ),
        ),
        payload: '');
  }
  print('Handling a background message ${message.messageId}');
}

bool isLogin = false;
var id = -1;

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseMessaging.instance.getAPNSToken();
  FirebaseMessaging.instance.requestPermission();
  // final PermissionStatus status = await Permission.notification.request();
  // if (status.isGranted) {
  // } else if (status.isDenied) {
  //   Permission.notification.request();
  // } else if (status.isPermanentlyDenied) {
  //   // Notification permissions permanently denied, open app settings
  //   await openAppSettings();
  // }
  Future<pr.PermissionStatus> permissionStatus =
      pr.NotificationPermissions.getNotificationPermissionStatus();
  print(permissionStatus);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
    print("FirebaseMessaging.getInitialMessage");
    if (message != null) {}
  });
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    var initializationSettingsAndroid = const AndroidInitializationSettings(
        '@drawable/ic_stat_ecoplantagro__2');

    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse? notificationResponse) async {
      if (notificationResponse != null) {}
    });
    var title = message.data['title'];
    var body = message.data["body"];
    if (title != null && body != null) {
      flutterLocalNotificationsPlugin.show(
          0,
          title,
          body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              icon: '@drawable/ic_stat_ecoplantagro__2',
              importance: Importance.max,
              priority: Priority.high,
              ticker: 'ticker',
              playSound: true,
              showWhen: true,
            ),
          ),
          payload: '');
    }
  });
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    var title = message.data['title'];
    var body = message.data["body"];
    if (title != null && body != null) {
      flutterLocalNotificationsPlugin.show(
          0,
          title,
          body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              icon: '@drawable/ic_stat_ecoplantagro__2',
              importance: Importance.max,
              priority: Priority.high,
              ticker: 'ticker',
              playSound: true,
              showWhen: true,
            ),
          ),
          payload: '');
    }
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WebviewPage(),
    );
  }
}
