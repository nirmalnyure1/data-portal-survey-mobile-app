import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data_portal_survey/common/cubit/data_state.dart';
import 'package:data_portal_survey/common/http/data_response.dart';
import 'package:data_portal_survey/features/auth/resource/auth_repository.dart';

/// Password-based login. Reuses the existing verify-login endpoint but sends a
/// `password` payload instead of an OTP, so no OTP verification step is needed.
class LoginCubit extends Cubit<CommonState> {
  final AuthRepository authRepository;

  LoginCubit({required this.authRepository}) : super(CommonInitial());

  Future<void> login({
    required String emailOrPhone,
    required String password,
  }) async {
    emit(CommonLoading());

    final res = await authRepository.verifyLogin(
      emailOrPhone: emailOrPhone,
      password: password,
    );

    if (res.status == Status.success) {
      emit(CommonSuccess());
    } else {
      emit(CommonError(
        message: res.message ?? '',
        statusCode: res.statusCode,
        code: res.code,
      ));
    }
  }
}
