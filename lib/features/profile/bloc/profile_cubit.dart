import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data_portal_survey/common/cubit/data_state.dart';
import 'package:data_portal_survey/common/http/data_response.dart';
import 'package:data_portal_survey/common/storage/secure_storage.dart';
import 'package:data_portal_survey/features/auth/model/user_model.dart';
import 'package:data_portal_survey/features/auth/resource/auth_repository.dart';
import 'package:data_portal_survey/features/profile/resource/profile_repository.dart';

class ProfileCubit extends Cubit<CommonState> {
  final ProfileRepository profileRepository;
  final AuthRepository authRepository;

  final SecureStorage secureStorage;

  ProfileCubit({
    required this.profileRepository,
    required this.authRepository,
    required this.secureStorage,
  }) : super(CommonInitial());

  Future<void> updateProfile({
    required Map<String, dynamic> payload,
    File? imageFile,
  }) async {
    emit(CommonLoading());

    final userId = authRepository.user.value?.id ?? '';
    if (userId.isEmpty) {
      emit(const CommonError(message: 'User not found'));
      return;
    }

    final res = await profileRepository.updateProfile(
      userId: userId,
      payload: payload,
      imageFile: imageFile,
    );

    if (res.status == Status.success && res.data != null) {
      // Prefer /auth/me so isPhoneVerified / isEmailVerified stay accurate.
      final me = await authRepository.getMe();
      if (me.status == Status.success && me.data != null) {
        emit(CommonStateSuccess<UserModel>(data: me.data!));
        return;
      }

      final oldUser = authRepository.user.value;
      final updated = res.data!;
      final mergedUser = oldUser == null
          ? updated
          : updated.copyWith(
              accessToken: oldUser.accessToken,
              gender: updated.gender.isEmpty ? oldUser.gender : updated.gender,
              isEmailVerified: oldUser.isEmailVerified,
              isPhoneVerified: oldUser.isPhoneVerified,
              hasGoogleAuth: oldUser.hasGoogleAuth,
              hasAppleAuth: oldUser.hasAppleAuth,
            );

      authRepository.setUser(mergedUser);
      await secureStorage.setUser(user: mergedUser);
      emit(CommonStateSuccess<UserModel>(data: mergedUser));
      return;
    }

    emit(CommonError(message: res.message ?? 'Unable to update profile'));
  }

  Future<void> updateBusinessProfile({
    required Map<String, dynamic> payload,
  }) async {
    emit(CommonLoading());

    final res = await profileRepository.updateBusinessProfile(payload: payload);

    if (res.status == Status.success) {
      emit(CommonSuccess());
      return;
    }

    emit(
      CommonError(message: res.message ?? 'Unable to update business profile'),
    );
  }
}
