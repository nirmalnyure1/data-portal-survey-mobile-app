import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:data_portal_survey/common/logger/log.dart';
import 'package:data_portal_survey/common/utils/toast_message_utils.dart';
import 'package:data_portal_survey/navigation/app_navigator.dart';

// import 'package:servicebus/common/navigation/navigation_service.dart';
// import 'package:servicebus/common/utils/custom_toast.dart';
// import 'package:servicebus/common/utils/log.dart';
import 'package:upgrader/upgrader.dart';

class UpdateWrapper extends StatefulWidget {
  final Widget child;

  const UpdateWrapper({super.key, required this.child});

  @override
  State<UpdateWrapper> createState() => _UpdateWrapperState();
}

class _UpdateWrapperState extends State<UpdateWrapper> {
  Future<void> _checkInApp(BuildContext context) async {
    try {
      if (Platform.isAndroid) {
        InAppUpdate.checkForUpdate().then((value) async {
          if (value.immediateUpdateAllowed) {
            final AppUpdateResult result =
                await InAppUpdate.performImmediateUpdate();
            if (context.mounted) {
              if (result == AppUpdateResult.inAppUpdateFailed) {
                ToastMessageUtils.error("Update Failed");
              } else if (result == AppUpdateResult.success) {
                ToastMessageUtils.success("Update Success");
              }
            }
          }
        });
      } else {}
    } catch (e) {
      Log.e(e);
    }
  }

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 500)).whenComplete(() {
      if (Platform.isAndroid && !kDebugMode) {
        _checkInApp(context);
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class IosUpdateWrapper extends StatefulWidget {
  final Widget child;
  const IosUpdateWrapper({super.key, required this.child});

  @override
  State<IosUpdateWrapper> createState() => _IosUpdateWrapperState();
}

class _IosUpdateWrapperState extends State<IosUpdateWrapper> {
  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? UpgradeAlert(
            dialogStyle: UpgradeDialogStyle.cupertino,
            upgrader: Upgrader(),
            navigatorKey: AppNavigator.navigationKey,
            onUpdate: () {
              return true;
            },
            child: widget.child,
          )
        : widget.child;
  }
}
