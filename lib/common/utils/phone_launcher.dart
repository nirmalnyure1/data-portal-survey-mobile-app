import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:data_portal_survey/navigation/app_navigator.dart';

class PhoneLauncher {
  const PhoneLauncher._();

  static Future<bool> call(String phoneNumber) async {
    await Clipboard.setData(ClipboardData(text: phoneNumber));

    final opened = await launchUrl(Uri(scheme: 'tel', path: phoneNumber));
    if (!opened) {
      AppNavigator.showSnackBar(message: 'Number copied: $phoneNumber');
    }
    return opened;
  }
}
