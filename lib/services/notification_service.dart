import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../app_keys.dart';
import '../firebase_options.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';
import '../screens/course_detail_screen.dart';

import 'package:provider/provider.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  debugPrint('[BACKGROUND] Notification received');
  debugPrint('[BACKGROUND] Title: ${message.notification?.title}');
  debugPrint('[BACKGROUND] Body: ${message.notification?.body}');
  debugPrint('[BACKGROUND] Data: ${message.data}');
}

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  bool _initialized = false;

  Future<AuthorizationStatus> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint(
      'Notification permission: '
      '${settings.authorizationStatus.name}',
    );

    return settings.authorizationStatus;
  }

  Future<void> init() async {
    if (_initialized) return;

    await requestPermission();

    _messaging.onRegistered.listen((installationId) {
      debugPrint(
        '[FCM] Firebase Installation ID obtained: '
        '${installationId.isNotEmpty}',
      );
    });

    await _messaging.register();

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('[FOREGROUND] Notification received');
      debugPrint('Title: ${message.notification?.title}');
      debugPrint('Body: ${message.notification?.body}');
      debugPrint('Data: ${message.data}');

      final title = message.notification?.title ?? 'Notifikasi';
      final body = message.notification?.body ?? '';

      messengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('$title\n$body'),
          duration: const Duration(seconds: 5),
        ),
      );
    });

    _initialized = true;
  }

  void setupInteractedMessage() {
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _handleNotificationTap(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  void _handleNotificationTap(RemoteMessage message) {
    final courseId = int.tryParse(message.data['course_id']?.toString() ?? '');

    if (courseId == null) {
      debugPrint('[NOTIFICATION TAP] course_id tidak valid');
      return;
    }

    final context = navigatorKey.currentContext;

    if (context == null) {
      debugPrint('[NOTIFICATION TAP] Context belum tersedia');
      return;
    }

    final provider = context.read<CourseProvider>();

    Course? selectedCourse;

    for (final course in provider.courses) {
      if (course.id == courseId) {
        selectedCourse = course;
        break;
      }
    }

    if (selectedCourse == null) {
      debugPrint('[NOTIFICATION TAP] Course tidak ditemukan');
      return;
    }

    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => CourseDetailScreen(course: selectedCourse!),
      ),
    );
  }
}
