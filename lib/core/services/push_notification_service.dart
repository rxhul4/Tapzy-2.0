import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:tapzy/core/constants/apiConstants.dart';
import 'package:tapzy/core/network/network_repository.dart';
import 'package:tapzy/core/utils/preference_helper.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {}
  if (kDebugMode) {
    print("Handling a background message: ${message.messageId}");
  }
}

class PushNotificationService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  /// Called when a push arrives while the app is in the foreground (e.g. contact shared).
  static VoidCallback? onForegroundMessage;

  static Future<void> initialize() async {
    try {
      if (Platform.isIOS) {
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: 'AIzaSyDlH6HA3A16ctWLpRnr-U27i-3Fzh6S_wk',
            appId: '1:397800132885:ios:fc03a07f9adde0e870991c',
            messagingSenderId: '397800132885',
            projectId: 'tapzy-nfc',
            storageBucket: 'tapzy-nfc.firebasestorage.app',
            iosBundleId: 'com.tapzy.xyz',
          ),
        );
      } else {
        await Firebase.initializeApp();
      }

      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      // Request notification permissions
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (kDebugMode) {
        print('User granted permission: ${settings.authorizationStatus}');
      }

      // Foreground message listener
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('Got a message whilst in the foreground!');
          print('Message data: ${message.data}');
        }
        onForegroundMessage?.call();
      });

      // Handle message clicks when app is in background or closed
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('Notification clicked / opened the app!');
        }
        onForegroundMessage?.call();
      });
    } catch (e) {
      if (kDebugMode) {
        print(
            "Firebase Messaging is not configured or failed to initialize: $e");
      }
    }
  }

  static Future<void> registerDeviceToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      if (token == null) return;

      if (kDebugMode) {
        print("FCM Token: $token");
      }

      // Store in preferences locally
      await PreferenceHelper.setString("fcm_token", token);

      // Call API to register on server if logged in
      String? userId = PreferenceHelper.getString(PreferenceHelper.USER_ID);
      String? authToken =
          PreferenceHelper.getString(PreferenceHelper.AUTH_TOKEN);

      if (userId != null &&
          userId.isNotEmpty &&
          authToken != null &&
          authToken.isNotEmpty) {
        final response = await callPostMethod(
          ApiConstants.registerFcmToken,
          {
            'fcm_token': token,
            'device_type': kIsWeb
                ? 'web'
                : (defaultTargetPlatform == TargetPlatform.iOS
                    ? 'ios'
                    : 'android'),
            'user_id': userId,
          },
        );
        if (kDebugMode) {
          print("FCM Token Registration Response: $response");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error registering FCM token: $e");
      }
    }
  }
}
