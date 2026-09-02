import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import 'package:data_portal_survey/features/auth/ui/page/login_screen.dart';
import 'package:data_portal_survey/features/auth/ui/page/forgot_password_screen.dart';
import 'package:data_portal_survey/features/auth/ui/page/forgot_password_otp_screen.dart';
import 'package:data_portal_survey/features/auth/ui/page/reset_password_screen.dart';
import 'package:data_portal_survey/features/auth/ui/page/change_password_screen.dart';
import 'package:data_portal_survey/features/auth/ui/page/otp_verification_screen.dart';
import 'package:data_portal_survey/features/auth/ui/page/signup_screen.dart';
import 'package:data_portal_survey/features/home/ui/page/about_screen.dart';
import 'package:data_portal_survey/features/home/ui/page/dashboard_screen.dart';
import 'package:data_portal_survey/features/home/ui/page/privacy_policy_screen.dart';
import 'package:data_portal_survey/features/home/ui/page/settings_screen.dart';
import 'package:data_portal_survey/features/home/ui/page/terms_conditions_screen.dart';
import 'package:data_portal_survey/features/notification/ui/page/notification_inbox_screen.dart';
import 'package:data_portal_survey/features/onboard/ui/page/language_selection_screen.dart';
import 'package:data_portal_survey/features/onboard/ui/page/notification_permission_screen.dart';
import 'package:data_portal_survey/features/onboard/ui/page/onboard_screen.dart';
import 'package:data_portal_survey/features/onboard/ui/page/splash_screen.dart';
import 'package:data_portal_survey/features/profile/ui/page/edit_profile_screen.dart';
import 'package:data_portal_survey/features/support/ui/screen/help_support_screen.dart';
import 'package:data_portal_survey/features/support/ui/screen/support_ticket_success_screen.dart';
import 'package:data_portal_survey/features/survey/ui/page/survey_list_screen.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: SplashRoute.page, initial: true),
    AutoRoute(page: LanguageSelectionRoute.page),
    AutoRoute(page: OnboardRoute.page),
    AutoRoute(page: LoginRoute.page),
    AutoRoute(page: ForgotPasswordRoute.page),
    AutoRoute(page: ForgotPasswordOtpRoute.page),
    AutoRoute(page: ResetPasswordRoute.page),
    AutoRoute(page: ChangePasswordRoute.page),
    AutoRoute(page: OtpVerificationRoute.page),
    AutoRoute(page: SignupRoute.page),
    AutoRoute(page: NotificationPermissionRoute.page),
    AutoRoute(page: DashboardRoute.page),
    AutoRoute(page: SurveyListRoute.page),
    AutoRoute(page: SettingsRoute.page),
    AutoRoute(page: NotificationInboxRoute.page),
    AutoRoute(page: AboutRoute.page),
    AutoRoute(page: TermsConditionsRoute.page),
    AutoRoute(page: PrivacyPolicyRoute.page),
    AutoRoute(page: EditProfileRoute.page),
    AutoRoute(page: HelpSupportRoute.page),
    AutoRoute(page: SupportTicketSuccessRoute.page),
  ];
}
