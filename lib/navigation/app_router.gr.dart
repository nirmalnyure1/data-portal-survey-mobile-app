// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [AboutScreen]
class AboutRoute extends PageRouteInfo<void> {
  const AboutRoute({List<PageRouteInfo>? children})
    : super(AboutRoute.name, initialChildren: children);

  static const String name = 'AboutRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AboutScreen();
    },
  );
}

/// generated route for
/// [ChangePasswordScreen]
class ChangePasswordRoute extends PageRouteInfo<void> {
  const ChangePasswordRoute({List<PageRouteInfo>? children})
    : super(ChangePasswordRoute.name, initialChildren: children);

  static const String name = 'ChangePasswordRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ChangePasswordScreen();
    },
  );
}

/// generated route for
/// [DashboardScreen]
class DashboardRoute extends PageRouteInfo<void> {
  const DashboardRoute({List<PageRouteInfo>? children})
    : super(DashboardRoute.name, initialChildren: children);

  static const String name = 'DashboardRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const DashboardScreen();
    },
  );
}

/// generated route for
/// [EditProfileScreen]
class EditProfileRoute extends PageRouteInfo<void> {
  const EditProfileRoute({List<PageRouteInfo>? children})
    : super(EditProfileRoute.name, initialChildren: children);

  static const String name = 'EditProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const EditProfileScreen();
    },
  );
}

/// generated route for
/// [ForgotPasswordOtpScreen]
class ForgotPasswordOtpRoute extends PageRouteInfo<ForgotPasswordOtpRouteArgs> {
  ForgotPasswordOtpRoute({
    Key? key,
    required String emailOrPhone,
    List<PageRouteInfo>? children,
  }) : super(
         ForgotPasswordOtpRoute.name,
         args: ForgotPasswordOtpRouteArgs(key: key, emailOrPhone: emailOrPhone),
         initialChildren: children,
       );

  static const String name = 'ForgotPasswordOtpRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ForgotPasswordOtpRouteArgs>();
      return ForgotPasswordOtpScreen(
        key: args.key,
        emailOrPhone: args.emailOrPhone,
      );
    },
  );
}

class ForgotPasswordOtpRouteArgs {
  const ForgotPasswordOtpRouteArgs({this.key, required this.emailOrPhone});

  final Key? key;

  final String emailOrPhone;

  @override
  String toString() {
    return 'ForgotPasswordOtpRouteArgs{key: $key, emailOrPhone: $emailOrPhone}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ForgotPasswordOtpRouteArgs) return false;
    return key == other.key && emailOrPhone == other.emailOrPhone;
  }

  @override
  int get hashCode => key.hashCode ^ emailOrPhone.hashCode;
}

/// generated route for
/// [ForgotPasswordScreen]
class ForgotPasswordRoute extends PageRouteInfo<void> {
  const ForgotPasswordRoute({List<PageRouteInfo>? children})
    : super(ForgotPasswordRoute.name, initialChildren: children);

  static const String name = 'ForgotPasswordRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ForgotPasswordScreen();
    },
  );
}

/// generated route for
/// [HelpSupportScreen]
class HelpSupportRoute extends PageRouteInfo<void> {
  const HelpSupportRoute({List<PageRouteInfo>? children})
    : super(HelpSupportRoute.name, initialChildren: children);

  static const String name = 'HelpSupportRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HelpSupportScreen();
    },
  );
}

/// generated route for
/// [LanguageSelectionScreen]
class LanguageSelectionRoute extends PageRouteInfo<void> {
  const LanguageSelectionRoute({List<PageRouteInfo>? children})
    : super(LanguageSelectionRoute.name, initialChildren: children);

  static const String name = 'LanguageSelectionRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LanguageSelectionScreen();
    },
  );
}

/// generated route for
/// [LoginScreen]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LoginScreen();
    },
  );
}

/// generated route for
/// [NotificationInboxScreen]
class NotificationInboxRoute extends PageRouteInfo<void> {
  const NotificationInboxRoute({List<PageRouteInfo>? children})
    : super(NotificationInboxRoute.name, initialChildren: children);

  static const String name = 'NotificationInboxRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const NotificationInboxScreen();
    },
  );
}

/// generated route for
/// [NotificationPermissionScreen]
class NotificationPermissionRoute
    extends PageRouteInfo<NotificationPermissionRouteArgs> {
  NotificationPermissionRoute({
    Key? key,
    required bool hasSession,
    List<PageRouteInfo>? children,
  }) : super(
         NotificationPermissionRoute.name,
         args: NotificationPermissionRouteArgs(
           key: key,
           hasSession: hasSession,
         ),
         initialChildren: children,
       );

  static const String name = 'NotificationPermissionRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<NotificationPermissionRouteArgs>();
      return NotificationPermissionScreen(
        key: args.key,
        hasSession: args.hasSession,
      );
    },
  );
}

class NotificationPermissionRouteArgs {
  const NotificationPermissionRouteArgs({this.key, required this.hasSession});

  final Key? key;

  final bool hasSession;

  @override
  String toString() {
    return 'NotificationPermissionRouteArgs{key: $key, hasSession: $hasSession}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! NotificationPermissionRouteArgs) return false;
    return key == other.key && hasSession == other.hasSession;
  }

  @override
  int get hashCode => key.hashCode ^ hasSession.hashCode;
}

/// generated route for
/// [OnboardScreen]
class OnboardRoute extends PageRouteInfo<void> {
  const OnboardRoute({List<PageRouteInfo>? children})
    : super(OnboardRoute.name, initialChildren: children);

  static const String name = 'OnboardRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const OnboardScreen();
    },
  );
}

/// generated route for
/// [OtpVerificationScreen]
class OtpVerificationRoute extends PageRouteInfo<OtpVerificationRouteArgs> {
  OtpVerificationRoute({
    Key? key,
    required String phoneNumber,
    List<PageRouteInfo>? children,
  }) : super(
         OtpVerificationRoute.name,
         args: OtpVerificationRouteArgs(key: key, phoneNumber: phoneNumber),
         initialChildren: children,
       );

  static const String name = 'OtpVerificationRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<OtpVerificationRouteArgs>();
      return OtpVerificationScreen(
        key: args.key,
        phoneNumber: args.phoneNumber,
      );
    },
  );
}

class OtpVerificationRouteArgs {
  const OtpVerificationRouteArgs({this.key, required this.phoneNumber});

  final Key? key;

  final String phoneNumber;

  @override
  String toString() {
    return 'OtpVerificationRouteArgs{key: $key, phoneNumber: $phoneNumber}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OtpVerificationRouteArgs) return false;
    return key == other.key && phoneNumber == other.phoneNumber;
  }

  @override
  int get hashCode => key.hashCode ^ phoneNumber.hashCode;
}

/// generated route for
/// [PrivacyPolicyScreen]
class PrivacyPolicyRoute extends PageRouteInfo<void> {
  const PrivacyPolicyRoute({List<PageRouteInfo>? children})
    : super(PrivacyPolicyRoute.name, initialChildren: children);

  static const String name = 'PrivacyPolicyRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PrivacyPolicyScreen();
    },
  );
}

/// generated route for
/// [ResetPasswordScreen]
class ResetPasswordRoute extends PageRouteInfo<ResetPasswordRouteArgs> {
  ResetPasswordRoute({
    Key? key,
    required String emailOrPhone,
    required String token,
    List<PageRouteInfo>? children,
  }) : super(
         ResetPasswordRoute.name,
         args: ResetPasswordRouteArgs(
           key: key,
           emailOrPhone: emailOrPhone,
           token: token,
         ),
         initialChildren: children,
       );

  static const String name = 'ResetPasswordRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ResetPasswordRouteArgs>();
      return ResetPasswordScreen(
        key: args.key,
        emailOrPhone: args.emailOrPhone,
        token: args.token,
      );
    },
  );
}

class ResetPasswordRouteArgs {
  const ResetPasswordRouteArgs({
    this.key,
    required this.emailOrPhone,
    required this.token,
  });

  final Key? key;

  final String emailOrPhone;

  final String token;

  @override
  String toString() {
    return 'ResetPasswordRouteArgs{key: $key, emailOrPhone: $emailOrPhone, token: $token}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ResetPasswordRouteArgs) return false;
    return key == other.key &&
        emailOrPhone == other.emailOrPhone &&
        token == other.token;
  }

  @override
  int get hashCode => key.hashCode ^ emailOrPhone.hashCode ^ token.hashCode;
}

/// generated route for
/// [SettingsScreen]
class SettingsRoute extends PageRouteInfo<void> {
  const SettingsRoute({List<PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SettingsScreen();
    },
  );
}

/// generated route for
/// [SignupScreen]
class SignupRoute extends PageRouteInfo<void> {
  const SignupRoute({List<PageRouteInfo>? children})
    : super(SignupRoute.name, initialChildren: children);

  static const String name = 'SignupRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SignupScreen();
    },
  );
}

/// generated route for
/// [SplashScreen]
class SplashRoute extends PageRouteInfo<void> {
  const SplashRoute({List<PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SplashScreen();
    },
  );
}

/// generated route for
/// [SupportTicketSuccessScreen]
class SupportTicketSuccessRoute
    extends PageRouteInfo<SupportTicketSuccessRouteArgs> {
  SupportTicketSuccessRoute({
    Key? key,
    required String ticketDisplay,
    List<PageRouteInfo>? children,
  }) : super(
         SupportTicketSuccessRoute.name,
         args: SupportTicketSuccessRouteArgs(
           key: key,
           ticketDisplay: ticketDisplay,
         ),
         initialChildren: children,
       );

  static const String name = 'SupportTicketSuccessRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SupportTicketSuccessRouteArgs>();
      return SupportTicketSuccessScreen(
        key: args.key,
        ticketDisplay: args.ticketDisplay,
      );
    },
  );
}

class SupportTicketSuccessRouteArgs {
  const SupportTicketSuccessRouteArgs({this.key, required this.ticketDisplay});

  final Key? key;

  final String ticketDisplay;

  @override
  String toString() {
    return 'SupportTicketSuccessRouteArgs{key: $key, ticketDisplay: $ticketDisplay}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SupportTicketSuccessRouteArgs) return false;
    return key == other.key && ticketDisplay == other.ticketDisplay;
  }

  @override
  int get hashCode => key.hashCode ^ ticketDisplay.hashCode;
}

/// generated route for
/// [SurveyListScreen]
class SurveyListRoute extends PageRouteInfo<void> {
  const SurveyListRoute({List<PageRouteInfo>? children})
    : super(SurveyListRoute.name, initialChildren: children);

  static const String name = 'SurveyListRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SurveyListScreen();
    },
  );
}

/// generated route for
/// [TermsConditionsScreen]
class TermsConditionsRoute extends PageRouteInfo<void> {
  const TermsConditionsRoute({List<PageRouteInfo>? children})
    : super(TermsConditionsRoute.name, initialChildren: children);

  static const String name = 'TermsConditionsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const TermsConditionsScreen();
    },
  );
}
