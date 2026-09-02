import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data_portal_survey/common/cubit/data_state.dart';
import 'package:data_portal_survey/common/http/data_response.dart';
import 'package:data_portal_survey/features/auth/resource/auth_repository.dart';

class ChangePasswordCubit extends Cubit<CommonState> {
  final AuthRepository authRepository;

  ChangePasswordCubit({required this.authRepository}) : super(CommonInitial());

  Future<void> changePassword({
    String? currentPassword,
    required String newPassword,
  }) async {
    emit(CommonLoading());

    final res = await authRepository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    if (res.status == Status.success) {
      emit(CommonSuccess());
      return;
    }

    emit(CommonError(
      message: res.message ?? 'Unable to change password',
      statusCode: res.statusCode,
      code: res.code,
    ));
  }
}
