// import 'package:awesome_notifications/awesome_notifications.dart';
// import 'package:flutter/material.dart';

// ValueNotifier<int> notificationCount = ValueNotifier(0);

// class NotificationUtils {

//   static const String notificationChannelKeyConnectKishan =
//       "notification_notification_channel_connect_kishan";
//   // static const String alert = "alert";

//   // static LocalPushNotification convertToLocalPushNofication(
//   //     Map<String, dynamic> json) {
//   //   return LocalPushNotification(
//   //     id: json["id"] ?? "",
//   //     type: json["model"] ?? "",
//   //     deeplink: json["deeplink"],
//   //   );
//   // }

//   static Future createLocalNotification(
//       {String? title, String? body, int? id}) async {
//     await AwesomeNotifications().createNotification(
//         content: NotificationContent(
//       id: id ?? DateTime.now().millisecondsSinceEpoch.remainder(100000),
//       channelKey: notificationChannelKey,
//       title: title ?? "",
//       body: body ?? "",
//       actionType: ActionType.Default,
//       displayOnBackground: true,
//       displayOnForeground: true,
//       // backgroundColor: Theme.of(NavigationService.context).primaryColor,
//       // largeIcon: "asset://assets/images/app_icon.png",
//       notificationLayout: NotificationLayout.Default,
//     ));
//   }

//   static Future initNotificationCount(BuildContext context) async {
//     try {
//       await AwesomeNotifications().getGlobalBadgeCounter().then(((value) {
//         notificationCount.value = value;
//       }));
//       // debugPrint(notificationCount.value.toString());
//     } catch (e) {
//       debugPrint(e.toString());
//     }
//   }

//   // static Future incrementNotficationCount() async {
//   //   await AwesomeNotifications().incrementGlobalBadgeCounter();

//   //   await AwesomeNotifications().getGlobalBadgeCounter().then(
//   //     ((value) {
//   //       NavigationService.context
//   //           .read<NotificationBadgeCubit>()
//   //           .updateNotificationBadge(value);
//   //       notificationCount.value = value;
//   //       // return value;
//   //     }),
//   //   );

//   //   // await AwesomeNotifications().setGlobalBadgeCounter();
//   //   // notificationCount.value = notificationCount.value + 1;
//   // }

//   // static Future decrementNotificationCount() async {
//   //   final count = await AwesomeNotifications().getGlobalBadgeCounter();

//   //   if (count > 0) {
//   //     await AwesomeNotifications().decrementGlobalBadgeCounter();

//   //     await AwesomeNotifications().getGlobalBadgeCounter().then(
//   //       ((value) {
//   //         NavigationService.context
//   //             .read<NotificationBadgeCubit>()
//   //             .updateNotificationBadge(value);
//   //         notificationCount.value = value;
//   //         // return value;
//   //       }),
//   //     );
//   //     // notificationCount.value = notificationCount.value - 1;
//   //   }
//   // }

//   static Future clearNotificationCount() async {
//     await AwesomeNotifications().resetGlobalBadge();
//     await AwesomeNotifications().getGlobalBadgeCounter().then(
//       ((value) {
//         // NavigationService.context
//         //     .read<NotificationBadgeCubit>()
//         // .updateNotificationBadge(value);
//         notificationCount.value = value;
//         // return value;
//       }),
//     );

//     // notificationCount.value = 0;
//     // notificationCount.notifyListeners();
//     // notificationCount.notifyListeners();
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:krishi_hub/common/utils/log.dart';
// import 'package:krishi_hub/feature/notification/utils/badge_utils.dart';

// ValueNotifier<int> notificationCount = ValueNotifier(0);

// class NotificationUtils {
//   // static const String notificationChannelKey =
//   //     "default_notification_channel";

//   static const String notificationChannelKeyConnectKishan =
//       "notification_notification_channel_connect_kishan";

//   static Future<void> initializedNotificationCount() async {}

//   //   static Future initNotificationCount(BuildContext context) async {
//   //   try {
//   //     await AwesomeNotifications().getGlobalBadgeCounter().then(((value) {
//   //       notificationCount.value = value;
//   //     }));
//   //     // debugPrint(notificationCount.value.toString());
//   //   } catch (e) {
//   //     debugPrint(e.toString());
//   //   }
//   // }

//   static Future<void> updateBadgeCount(int badgeCount) async {
//     notificationCount.value = badgeCount;
//   }

//   static Future<void> clearBadgeCountLocally() async {
//     try {
//       notificationCount.value = 0;
//       BadgeUtils.clearBadge();
//     } catch (e) {
//       Log.e(e.toString());
//     }
//   }
// }
