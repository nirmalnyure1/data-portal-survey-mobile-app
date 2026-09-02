import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data_portal_survey/common/cubit/data_state.dart';
import 'package:data_portal_survey/common/http/data_response.dart';
import 'package:data_portal_survey/features/auth/resource/auth_repository.dart';

class ResetPasswordCubit extends Cubit<CommonState> {
  final AuthRepository authRepository;

  ResetPasswordCubit({required this.authRepository}) : super(CommonInitial());

  Future<void> resetPassword({
    required String emailOrPhone,
    required String token,
    required String password,
  }) async {
    emit(CommonLoading());

    final res = await authRepository.resetPassword(
      emailOrPhone: emailOrPhone,
      token: token,
      password: password,
    );

    if (res.status == Status.success) {
      emit(CommonSuccess());
      return;
    }

    emit(CommonError(message: res.message ?? 'Unable to reset password'));
  }
}
