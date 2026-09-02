import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data_portal_survey/common/http/api_provider.dart';
import 'package:data_portal_survey/features/auth/resource/auth_repository.dart';
import 'package:data_portal_survey/features/engagement/resource/engagement_repository.dart';
import 'package:data_portal_survey/features/notification/resource/notification_repository.dart';
import 'package:data_portal_survey/features/notification/service/notification_badge_sync.dart';
import 'package:data_portal_survey/features/notification/service/notification_lifecycle_observer.dart';
import 'package:data_portal_survey/features/notification/service/push_notification_service.dart';
import 'package:data_portal_survey/features/notification/service/push_token_repository.dart';
import 'package:data_portal_survey/features/notification/service/notification_session_sync.dart';
import 'package:data_portal_survey/features/auth/service/auth_session_sync.dart';

/// Wires push notification dependencies after repositories are available.
class NotificationBootstrap extends StatefulWidget {
  final Widget child;

  const NotificationBootstrap({super.key, required this.child});

  @override
  State<NotificationBootstrap> createState() => _NotificationBootstrapState();
}

class _NotificationBootstrapState extends State<NotificationBootstrap> {
  final NotificationLifecycleObserver _lifecycleObserver =
      NotificationLifecycleObserver();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(_lifecycleObserver);
    WidgetsBinding.instance.addPostFrameCallback((_) => _configure());
  }

  Future<void> _configure() async {
    if (!mounted) return;

    final authRepository = RepositoryProvider.of<AuthRepository>(context);
    final apiProvider = RepositoryProvider.of<ApiProvider>(context);
    final engagementRepository =
        RepositoryProvider.of<EngagementRepository>(context);
    final notificationRepository =
        RepositoryProvider.of<NotificationRepository>(context);

    NotificationSessionSync.configure(authRepository: authRepository);
    AuthSessionSync.configure(authRepository: authRepository);

    NotificationBadgeSync.instance.configure(
      repository: notificationRepository,
    );

    PushNotificationService.instance.configure(
      tokenRepository: PushTokenRepository(apiProvider: apiProvider),
      notificationRepository: notificationRepository,
      engagementRepository: engagementRepository,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecycleObserver);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
