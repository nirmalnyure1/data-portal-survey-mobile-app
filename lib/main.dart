import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:data_portal_survey/common/wrapper/multi_bloc_wrapper.dart';
import 'package:data_portal_survey/common/wrapper/multi_repository_wrapper.dart';
import 'package:data_portal_survey/common/wrapper/update_wrapper.dart';
import 'package:data_portal_survey/features/notification/service/fcm_background_handler.dart';
import 'package:data_portal_survey/features/notification/service/notification_bootstrap.dart';
import 'package:data_portal_survey/features/notification/service/push_notification_service.dart';
import 'package:data_portal_survey/firebase_options.dart';
import 'common/config/config.dart';
import 'common/theme/theme.dart';
import 'common/utils/toast_message_utils.dart';
import 'navigation/navigation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await PushNotificationService.instance.initialize();
  AppConfig.setEnvironment(Environment.dev);
  ThemeManager().loadThemeMode();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    AppNavigator.init(_appRouter.navigatorKey);

    return AnimatedBuilder(
      animation: ThemeManager(),
      builder: (context, child) {
        return MultiRepositoryWrapper(
          env: AppConfig.currentEnv!,
          child: MultiBlocWrapper(
            child: NotificationBootstrap(
              child: UpdateWrapper(
                child: MaterialApp.router(
                  title: AppConfig.currentEnv?.appName,
                  scaffoldMessengerKey: ToastMessageUtils.messengerKey,
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  themeMode: ThemeManager().themeMode,
                  routerConfig: _appRouter.config(),
                  debugShowCheckedModeBanner: false,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
