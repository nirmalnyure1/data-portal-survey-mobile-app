import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data_portal_survey/common/cubit/data_state.dart';
import 'package:data_portal_survey/common/http/data_response.dart';
import 'package:data_portal_survey/features/support/model/support_ticket_result.dart';
import 'package:data_portal_survey/features/support/resource/support_repository.dart';

class SupportCubit extends Cubit<CommonState> {
  final SupportRepository supportRepository;

  SupportCubit({required this.supportRepository}) : super(CommonInitial());

  Future<void> submit({
    required String issueType,
    required String description,
    File? imageFile,
  }) async {
    // emit(CommonLoading());

    // final res = await supportRepository.applyHelp(
    //   issueType: issueType,
    //   description: description,
    //   imageFile: imageFile,
    // );

    // if (res.status == Status.success && res.data != null) {
    //   emit(CommonStateSuccess<SupportTicketResult>(data: res.data!));
    //   return;
    // }

    // emit(
    //   CommonError(
    //     message: res.message ?? 'Unable to submit your request',
    //     statusCode: res.statusCode,
    //   ),
    // );
    emit(CommonLoading());

    emit(
      CommonStateSuccess<SupportTicketResult>(
        data: SupportTicketResult(ticketDisplay: 'TKT-123456'),
      ),
    );
  }
}
