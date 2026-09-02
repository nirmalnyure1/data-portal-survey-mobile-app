import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data_portal_survey/common/cubit/data_state.dart';
import 'package:data_portal_survey/common/http/data_response.dart';
import 'package:data_portal_survey/features/auth/resource/auth_repository.dart';

class ForgotPasswordCubit extends Cubit<CommonState> {
  final AuthRepository authRepository;

  ForgotPasswordCubit({required this.authRepository}) : super(CommonInitial());

  Future<void> requestForgotPassword({required String emailOrPhone}) async {
    emit(CommonLoading());

    final res = await authRepository.forgotPassword(emailOrPhone: emailOrPhone);

    if (res.status == Status.success) {
      emit(CommonSuccess());
      return;
    }

    emit(CommonError(message: res.message ?? 'Unable to send reset code'));
  }
}
