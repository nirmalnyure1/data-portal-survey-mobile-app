import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data_portal_survey/common/cubit/data_state.dart';
import 'package:data_portal_survey/common/http/data_response.dart';
import 'package:data_portal_survey/features/auth/resource/auth_repository.dart';

enum ContactVerifyChannel { phone, email }

class ContactVerifyCubit extends Cubit<CommonState> {
  final AuthRepository authRepository;

  ContactVerifyCubit({required this.authRepository}) : super(CommonInitial());

  Future<void> startPhoneVerification({required String phone}) async {
    emit(CommonLoading());
    final res = await authRepository.addPhone(phone: phone);
    if (res.status == Status.success) {
      emit(const CommonStateSuccess<ContactVerifyChannel>(
        data: ContactVerifyChannel.phone,
      ));
      return;
    }
    emit(CommonError(
      message: res.message ?? 'Unable to start phone verification',
      statusCode: res.statusCode,
      code: res.code,
    ));
  }

  Future<void> startEmailVerification({required String email}) async {
    emit(CommonLoading());
    final res = await authRepository.addEmail(email: email);
    if (res.status == Status.success) {
      emit(const CommonStateSuccess<ContactVerifyChannel>(
        data: ContactVerifyChannel.email,
      ));
      return;
    }
    emit(CommonError(
      message: res.message ?? 'Unable to start email verification',
      statusCode: res.statusCode,
      code: res.code,
    ));
  }

  Future<void> verifyOtp({
    required ContactVerifyChannel channel,
    required String token,
  }) async {
    emit(CommonLoading());
    final res = channel == ContactVerifyChannel.phone
        ? await authRepository.verifyPhone(token: token)
        : await authRepository.verifyEmail(token: token);

    if (res.status == Status.success) {
      emit(CommonSuccess());
      return;
    }
    emit(CommonError(
      message: res.message ?? 'Unable to verify code',
      statusCode: res.statusCode,
      code: res.code,
    ));
  }

  Future<void> resendOtp({required ContactVerifyChannel channel}) async {
    emit(CommonDummyLoading());
    final res = channel == ContactVerifyChannel.phone
        ? await authRepository.sendVerifyPhoneOtp()
        : await authRepository.sendVerifyEmailOtp();

    if (res.status == Status.success) {
      emit(CommonNoData());
      return;
    }
    emit(CommonError(
      message: res.message ?? 'Unable to resend code',
      statusCode: res.statusCode,
      code: res.code,
    ));
  }
}
