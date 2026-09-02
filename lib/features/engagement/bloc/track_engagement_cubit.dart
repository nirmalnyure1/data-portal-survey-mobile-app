import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data_portal_survey/common/logger/log.dart';
import 'package:data_portal_survey/features/auth/resource/auth_repository.dart';
import 'package:data_portal_survey/features/engagement/resource/engagement_repository.dart';

class TrackEngagementCubit extends Cubit<void> {
  TrackEngagementCubit({
    required EngagementRepository engagementRepository,
    required AuthRepository authRepository,
  })
    : _engagementRepository = engagementRepository,
      _authRepository = authRepository,
      super(null);

  final EngagementRepository _engagementRepository;
  final AuthRepository _authRepository;

  Future<void> trackAppOpenIfNeeded({required bool isAuthenticated}) async {
    if (!isAuthenticated) return;

    final userId = _authRepository.user.value?.id ?? '';
    final accessToken = _authRepository.accessToken;
    if (userId.isEmpty || accessToken.isEmpty) return;

    try {
      await _engagementRepository.trackAppOpenIfNeeded(
        sessionKey: '$userId:$accessToken',
      );
    } catch (e, stack) {
      Log.e('Failed to track app_open engagement\n$e\n$stack');
    }
  }

  void resetTrackedSession() {
    _engagementRepository.resetTrackedSession();
  }
}
