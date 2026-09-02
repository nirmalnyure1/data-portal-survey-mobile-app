import 'dart:io';
import 'package:data_portal_survey/common/http/http.dart';
import 'package:data_portal_survey/features/auth/model/user_model.dart';
import 'package:data_portal_survey/features/media/resource/media_repository.dart';
import 'package:data_portal_survey/features/profile/resource/profile_api_provider.dart';

class ProfileRepository {
  final ApiProvider apiProvider;
  final MediaRepository mediaRepository;

  late ProfileApiProvider profileApiProvider;

  ProfileRepository({
    required this.apiProvider,
    required this.mediaRepository,
  }) {
    profileApiProvider = ProfileApiProvider(apiProvider: apiProvider);
  }

  Future<DataResponse<UserModel>> updateProfile({
    required String userId,
    required Map<String, dynamic> payload,
    File? imageFile,
  }) async {
    try {
      final body = Map<String, dynamic>.from(payload);

      if (imageFile != null) {
        final mediaRes = await mediaRepository.uploadMedia(file: imageFile);
        if (mediaRes.status != Status.success || mediaRes.data == null) {
          return DataResponse.error(
            mediaRes.message ?? 'Unable to upload profile image',
            mediaRes.statusCode,
          );
        }
        body['profilePicture'] = mediaRes.data;
      }

      final res = await profileApiProvider.updateProfile(
        userId: userId,
        body: body,
      );

      final rawUser =
          res['data']?['data'] ?? res['data'] ?? <String, dynamic>{};

      if (rawUser is! Map) {
        return DataResponse.error(
          'Invalid user payload in profile update response',
        );
      }

      final user = UserModel.fromMap(Map<String, dynamic>.from(rawUser));
      return DataResponse.success(user);
    } on CustomException catch (e) {
      return DataResponse.error(
        e.message?.toString() ?? e.toString(),
        e.statusCode,
      );
    } catch (e) {
      return DataResponse.error(e.toString());
    }
  }

  Future<DataResponse<void>> updateBusinessProfile({
    required Map<String, dynamic> payload,
  }) async {
    try {
      await profileApiProvider.updateBusinessProfile(body: payload);
      return DataResponse.success(null);
    } on CustomException catch (e) {
      return DataResponse.error(
        e.message?.toString() ?? e.toString(),
        e.statusCode,
      );
    } catch (e) {
      return DataResponse.error(e.toString());
    }
  }
}
