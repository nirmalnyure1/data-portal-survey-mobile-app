import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:data_portal_survey/common/widgets/app_dialog.dart';

class LocationPermissionDialog extends StatelessWidget {
  const LocationPermissionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      type: AppDialogType.location,
      title: 'Enable Location',
      message:
          'Please enable location services to find nearby franchises for delivery.',
      primaryButtonText: 'Open Settings',
      secondaryButtonText: 'Cancel',
      onPrimaryPressed: () async {
        await openAppSettings();
        if (!context.mounted) return;
        Navigator.of(context).pop(true);
      },
    );
  }
}

Future<bool> showLocationPermissionDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => const LocationPermissionDialog(),
  );
  return result ?? false;
}
