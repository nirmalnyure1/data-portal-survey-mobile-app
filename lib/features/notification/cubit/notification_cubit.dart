// import 'dart:async';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:krishi_hub/common/cubit/data_state.dart';
// import 'package:krishi_hub/feature/notification/resource/notification_repository.dart';


// class NotificationCubit extends Cubit<CommonState> {
//   final NotificationRepository notificationRepository;

//   NotificationCubit({
//     required this.notificationRepository,
//   }) : super(CommonInitial());

//   getNotification([
//     String? searchSlug,
//   ]) async {
//     emit(CommonLoading());
//     await Future.delayed(const Duration(milliseconds: 200));
//     final res = await notificationRepository.getNotification(
//       searchSlug: searchSlug,
//     );

//     res.fold((failure) {
//       emit(CommonError(message: failure.message));
//     }, (success) {
//       if (success.isNotEmpty) {
//         emit(CommonDataFetchSuccess<String>(data: success));
//       } else {
//         emit(CommonNoData());
//       }
//     });
//   }

//   loadMore([
//     String? searchSlug,
//   ]) async {
//     emit(CommonDummyLoading());
//     await Future.delayed(const Duration(milliseconds: 400));
//     final res = await notificationRepository.getNotification(
//       searchSlug: searchSlug,
//       isLoadMore: true,
//     );

//     res.fold((failure) {
//       emit(CommonDataFetchSuccess<String>(
//           data: notificationRepository.getItems));
//     }, (res) {
//       if (res.isNotEmpty) {
//         emit(CommonDataFetchSuccess<String>(data: res));
//       } else {
//         emit(CommonDataFetchSuccess<String>(
//             data: notificationRepository.getItems));
//       }
//     });
//   }

//   // getTrainingById(String id) async {
//   //   emit(CommonLoading());
//   //   await Future.delayed(const Duration(milliseconds: 200));
//   //   final res = await notificationRepository.getTrainingById(id);

//   //   res.fold((failure) {
//   //     emit(CommonError(message: failure.message));
//   //   }, (success) {
//   //     emit(CommonStateSuccess<Training>(data: success));
//   //   });
//   // }
// }
