import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data_portal_survey/common/storage/secure_storage.dart';
import 'package:data_portal_survey/common/utils/permission_handler.dart';
import 'package:data_portal_survey/features/auth/resource/auth_repository.dart';
import 'package:data_portal_survey/features/notification/service/push_notification_service.dart';
import 'package:data_portal_survey/features/onboard/bloc/startup_state.dart';

class StartupCubit extends Cubit<StartupState> {
  StartupCubit({
    required AuthRepository authRepository,
    required SecureStorage secureStorage,
  }) : _authRepository = authRepository,
       _secureStorage = secureStorage,
       super(StartupInitial());

  final AuthRepository _authRepository;
  final SecureStorage _secureStorage;
  bool _hasSession = false;

  bool get hasSession => _hasSession;

  Future<void> checkStartupSession({
    Duration splashDelay = const Duration(seconds: 0),
  }) async {
    emit(StartupLoading());
    try {
      if (splashDelay > Duration.zero) {
        await Future.delayed(splashDelay);
      }

      await _authRepository.initial();

      _hasSession =
          (_authRepository.accessToken.isNotEmpty) &&
          _authRepository.user.value != null;

      final onboardingDone = await _secureStorage.getOnboardingCompleted();
      if (!onboardingDone) {
        emit(const OnboardingRequired());
        return;
      }

      emit(StartupStateSuccess<bool>(data: _hasSession));
    } catch (e) {
      emit(StartupError(message: e.toString()));
    }
  }

  Future<void> requestNotificationPermission() async {
    emit(StartupLoading());
    try {
      final allowed = await PermissionHandler.requestNotificationPermission();

      await _secureStorage.saveNotificationPermissionGranted(allowed);
      await _secureStorage.saveNotificationPermissionPrompted(true);

      if (allowed) {
        await _secureStorage.saveNotificationPermissionSkipped(false);
        await PushNotificationService.instance.saveTokenToServer();
        emit(const NotificationAllowed());
      } else {
        emit(const NotificationPermissionDenied());
      }
    } catch (e) {
      emit(StartupError(message: e.toString()));
    }
  }

  Future<void> skipNotificationPermission() async {
    await _secureStorage.saveNotificationPermissionSkipped(true);
    await _secureStorage.saveNotificationPermissionGranted(false);
    await _secureStorage.saveNotificationPermissionPrompted(true);
  }
}
