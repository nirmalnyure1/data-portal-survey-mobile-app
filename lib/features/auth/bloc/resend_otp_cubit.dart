import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data_portal_survey/common/cubit/data_state.dart';
import 'package:data_portal_survey/common/http/data_response.dart';
import 'package:data_portal_survey/features/auth/resource/auth_repository.dart';

class ResendOtpCubit extends Cubit<CommonState> {
  final AuthRepository authRepository;

  ResendOtpCubit({required this.authRepository}) : super(CommonInitial());

  Future<void> sendLoginOtp({required String emailOrPhone}) async {
    emit(CommonLoading());

    final res = await authRepository.sendLoginOtp(emailOrPhone: emailOrPhone);

    if (res.status == Status.success) {
      emit(CommonSuccess());
    } else {
      emit(CommonError(message: res.message ?? ""));
    }
  }
}
