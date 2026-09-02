import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data_portal_survey/common/cubit/data_state.dart';
import 'package:data_portal_survey/common/http/data_response.dart';
import 'package:data_portal_survey/features/auth/resource/auth_repository.dart';

class VerifyOtpCubit extends Cubit<CommonState> {
  final AuthRepository authRepository;

  VerifyOtpCubit({required this.authRepository}) : super(CommonInitial());

  Future<void> verifyLogin({
    required String emailOrPhone,
    required String otp,
  }) async {
    emit(CommonLoading());

    final res = await authRepository.verifyLogin(
      emailOrPhone: emailOrPhone,
      otp: otp,
    );
    if (res.status == Status.success) {
      emit(CommonSuccess());
    } else {
      emit(CommonError(message: res.message ?? ""));
    }
  }
}
