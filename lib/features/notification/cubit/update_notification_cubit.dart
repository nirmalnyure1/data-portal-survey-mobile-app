import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:data_portal_survey/common/cubit/data_state.dart';
import 'package:data_portal_survey/common/http/data_response.dart';
import 'package:data_portal_survey/features/notification/resource/notification_repository.dart';

class UpdateNotificationCubit extends Cubit<CommonState> {
  final NotificationRepository notificationRepository;

  UpdateNotificationCubit({required this.notificationRepository})
    : super(CommonInitial());

  updateNotification({required String id}) async {
    final res = await notificationRepository.updateNotification(id: id);

    if (res.status == Status.success) {
      emit(CommonSuccess());
    } else {
      emit(CommonError(message: res.message ?? "something went wrong"));
    }
  }
}
