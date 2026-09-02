import 'package:data_portal_survey/features/auth/resource/auth_repository.dart';

class NotificationSessionSync {
  NotificationSessionSync._();

  static AuthRepository? _authRepository;

  static void configure({required AuthRepository authRepository}) {
    _authRepository = authRepository;
  }

  static bool get isAuthenticated =>
      _authRepository?.isAuthenticated ?? false;
}
