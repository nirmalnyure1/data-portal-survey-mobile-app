import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data_portal_survey/common/config/app_config.dart';
import 'package:data_portal_survey/common/http/api_provider.dart';
import 'package:data_portal_survey/common/storage/storage.dart';
import 'package:data_portal_survey/features/auth/resource/auth_repository.dart';
import 'package:data_portal_survey/features/engagement/resource/engagement_repository.dart';
import 'package:data_portal_survey/features/home/resource/home_repository.dart';
import 'package:data_portal_survey/features/media/resource/media_repository.dart';
import 'package:data_portal_survey/features/notification/resource/all_notification_repository.dart';
import 'package:data_portal_survey/features/notification/resource/notification_repository.dart';
import 'package:data_portal_survey/features/profile/resource/profile_repository.dart';
import 'package:data_portal_survey/features/support/resource/support_repository.dart';
import 'package:data_portal_survey/features/survey/resource/household_survey_repository.dart';
import 'package:data_portal_survey/features/survey/resource/survey_repository.dart';

class MultiRepositoryWrapper extends StatelessWidget {
  final Widget child;
  final Env env;
  const MultiRepositoryWrapper({
    super.key,
    required this.child,
    required this.env,
  });
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<Env>(create: (context) => env),
        RepositoryProvider<SecureStorage>(create: (context) => SecureStorage()),
        RepositoryProvider<ApiProvider>(
          create: (context) =>
              ApiProvider(baseUrl: RepositoryProvider.of<Env>(context).baseUrl),
          lazy: true,
        ),
        RepositoryProvider<AuthRepository>(
          create: ((context) => AuthRepository(
            apiProvider: RepositoryProvider.of<ApiProvider>(context),
            secureStorage: RepositoryProvider.of<SecureStorage>(context),
          )),
          lazy: true,
        ),
        RepositoryProvider<HomeRepository>(
          create: ((context) => HomeRepository(
            apiProvider: RepositoryProvider.of<ApiProvider>(context),
            secureStorage: RepositoryProvider.of<SecureStorage>(context),
          )),
          lazy: true,
        ),
        RepositoryProvider<MediaRepository>(
          create: ((context) => MediaRepository(
            apiProvider: RepositoryProvider.of<ApiProvider>(context),
          )),
          lazy: true,
        ),
        RepositoryProvider<AllNotificationRepository>(
          create: (context) => AllNotificationRepository(),
          lazy: true,
        ),
        RepositoryProvider<NotificationRepository>(
          create: ((context) => NotificationRepository(
            apiProvider: RepositoryProvider.of<ApiProvider>(context),
            allNotificationRepository:
                RepositoryProvider.of<AllNotificationRepository>(context),
          )),
          lazy: true,
        ),
        RepositoryProvider<ProfileRepository>(
          create: ((context) => ProfileRepository(
            apiProvider: RepositoryProvider.of<ApiProvider>(context),
            mediaRepository: RepositoryProvider.of<MediaRepository>(context),
          )),
          lazy: true,
        ),
        RepositoryProvider<SupportRepository>(
          create: ((context) => SupportRepository(
            apiProvider: RepositoryProvider.of<ApiProvider>(context),
            mediaRepository: RepositoryProvider.of<MediaRepository>(context),
          )),
          lazy: true,
        ),
        RepositoryProvider<EngagementRepository>(
          create: ((context) => EngagementRepository(
            apiProvider: RepositoryProvider.of<ApiProvider>(context),
          )),
          lazy: true,
        ),
        RepositoryProvider<SurveyRepository>(
          create: ((context) => SurveyRepository(
            apiProvider: RepositoryProvider.of<ApiProvider>(context),
          )),
          lazy: true,
        ),
        RepositoryProvider<HouseholdSurveyRepository>(
          create: ((context) => HouseholdSurveyRepository(
            apiProvider: RepositoryProvider.of<ApiProvider>(context),
          )),
          lazy: true,
        ),
      ],
      child: child,
    );
  }
}
