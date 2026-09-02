import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:data_portal_survey/common/cubit/data_state.dart';
import 'package:data_portal_survey/common/http/data_response.dart';
import 'package:data_portal_survey/features/auth/resource/auth_repository.dart';

class SignupCubit extends Cubit<CommonState> {
  final AuthRepository authRepository;
  SignupCubit({required this.authRepository}) : super(CommonInitial());

  void userRegister({
    required String phone,
    required String fullName,
    String? email,
    String? password,
    String? address,
    String? referralCode,
  }) async {
    emit(CommonLoading());

    final res = await authRepository.userRegister(
      phone: phone,
      fullName: fullName,
      email: email,
      password: password,
      address: address,
      referralCode: referralCode,
    );
    if (res.status == Status.success) {
      emit(CommonSuccess());
    } else {
      emit(CommonError(message: res.message ?? ""));
    }
  }
}
