import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data_portal_survey/common/cubit/data_state.dart';
import 'package:data_portal_survey/common/http/data_response.dart';
import 'package:data_portal_survey/features/auth/resource/auth_repository.dart';

class VerifyPasswordTokenCubit extends Cubit<CommonState> {
  final AuthRepository authRepository;

  VerifyPasswordTokenCubit({required this.authRepository})
    : super(CommonInitial());

  Future<void> verifyToken({
    required String emailOrPhone,
    required String token,
  }) async {
    emit(CommonLoading());

    final res = await authRepository.verifyPasswordToken(
      emailOrPhone: emailOrPhone,
      token: token,
    );

    if (res.status == Status.success) {
      emit(CommonSuccess());
      return;
    }

    emit(CommonError(message: res.message ?? 'Invalid verification code'));
  }
}
