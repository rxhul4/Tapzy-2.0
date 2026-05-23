import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:tapzy/core/services/push_notification_service.dart';
import 'package:tapzy/core/utils/preference_helper.dart';
import 'package:tapzy/providers/blog_provider.dart';
import 'package:tapzy/providers/login_provider.dart';
import 'package:tapzy/providers/profiles_provider.dart';
import 'package:tapzy/providers/user_profile_provider.dart';
import 'package:tapzy/screens/splashScreen/splash_screen.dart';

import 'providers/dashboard_provider.dart';
import 'providers/scan_connect_provider.dart';
import 'providers/analytics_provider.dart';

List<SingleChildWidget> providers = [
  ChangeNotifierProvider<BlogProvider>(create: (_) => BlogProvider()),
  ChangeNotifierProvider<LoginProvider>(create: (_) => LoginProvider()),
  ChangeNotifierProvider<ProfilesProvider>(create: (_) => ProfilesProvider()),
  ChangeNotifierProvider<UserProfilesProvider>(create: (_) => UserProfilesProvider()),
  ChangeNotifierProvider<DashboardProvider>(create: (_) => DashboardProvider()),
  ChangeNotifierProvider<ScanConnectProvider>(create: (_) => ScanConnectProvider()),
  ChangeNotifierProvider<AnalyticsProvider>(create: (_) => AnalyticsProvider()),
];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PreferenceHelper.load();
  await PushNotificationService.initialize();
  runApp(
    MultiProvider(
      providers: providers,
      child: MaterialApp(
          builder: (context, child) {
            final MediaQueryData data = MediaQuery.of(context);
            return MediaQuery(
              data: data.copyWith(
                  textScaler: data.textScaler.clamp(
                      minScaleFactor: 1.0, maxScaleFactor: 1.0)),
              child: child ?? Container(),
            );
          },
          debugShowCheckedModeBanner: false,
          home: const MyApp()),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}
