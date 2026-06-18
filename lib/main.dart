import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:asian_mart_app/core/l10n/app_localizations.dart';
import 'package:asian_mart_app/core/network/api_client.dart';
import 'package:asian_mart_app/core/state/app_controller.dart';
import 'package:asian_mart_app/core/theme/app_theme.dart';
import 'package:asian_mart_app/firebase_options.dart';
import 'package:asian_mart_app/presentation/admin/admin_home_page.dart';
import 'package:asian_mart_app/presentation/delivery/delivery_home_page.dart';
import 'package:asian_mart_app/presentation/shell/storefront_shell.dart';

final _localNotifications = FlutterLocalNotificationsPlugin();

const _androidChannel = AndroidNotificationChannel(
  'asian_mart_high_importance',
  'Asian Mart 알림',
  description: '주문, 배송, 이벤트 알림',
  importance: Importance.high,
);

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

Future<void> _initLocalNotifications() async {
  const androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosSettings = DarwinInitializationSettings();
  const settings =
      InitializationSettings(android: androidSettings, iOS: iosSettings);

  await _localNotifications.initialize(settings);

  await _localNotifications
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(_androidChannel);
}

void _showForegroundNotification(RemoteMessage message) {
  final notification = message.notification;
  final android = message.notification?.android;
  if (notification == null) {
    return;
  }

  _localNotifications.show(
    notification.hashCode,
    notification.title,
    notification.body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        _androidChannel.id,
        _androidChannel.name,
        channelDescription: _androidChannel.description,
        icon: android?.smallIcon ?? '@mipmap/ic_launcher',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
    ),
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _initLocalNotifications();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const AsiaMartApp());
}

class AsiaMartApp extends StatefulWidget {
  const AsiaMartApp({super.key});

  static void setLocale(BuildContext context, Locale locale) {
    context.findAncestorStateOfType<_AsiaMartAppState>()?.setLocale(locale);
  }

  @override
  State<AsiaMartApp> createState() => _AsiaMartAppState();
}

class _AsiaMartAppState extends State<AsiaMartApp> {
  Locale _locale = const Locale('ko');
  late final AppController _controller;

  void setLocale(Locale locale) {
    setState(() => _locale = locale);
    _controller.setLanguageCode(locale.languageCode.toUpperCase());
  }

  @override
  void initState() {
    super.initState();
    _controller = AppController(
      ApiClient(),
      const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
      ),
    )..bootstrap();
    _initFcm();
  }

  Future<void> _initFcm() async {
    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // FCM 기기 토큰을 컨트롤러에 주입(로그인 시 서버 등록). 갱신도 반영.
    // iOS 실기기는 APNs 토큰이 먼저 잡혀야 getToken()이 성공한다.
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final apns = await messaging.getAPNSToken();
        debugPrint('[FCM] APNs token: ${apns ?? "(null — APNs 미설정/시뮬레이터)"}');
      }
      final fcmToken = await messaging.getToken();
      if (fcmToken != null) {
        debugPrint('[FCM] device token = $fcmToken');
        _controller.setFcmToken(fcmToken);
      } else {
        debugPrint('[FCM] getToken() returned null — 토큰 발급 실패(등록 불가)');
      }
    } catch (e) {
      debugPrint('[FCM] getToken() 실패: $e');
    }
    messaging.onTokenRefresh.listen(_controller.setFcmToken);

    FirebaseMessaging.onMessage.listen(_showForegroundNotification);
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('[FCM] opened: ${message.notification?.title}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Asia Mart',
      theme: AppTheme.light,
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (_controller.isAdmin) {
            return AdminHomePage(controller: _controller);
          }
          if (_controller.isDeliver) {
            return DeliveryHomePage(controller: _controller);
          }
          return StorefrontShell(controller: _controller);
        },
      ),
    );
  }
}
