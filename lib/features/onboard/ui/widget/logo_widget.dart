import 'package:flutter/material.dart';
import 'package:data_portal_survey/common/constants/constant_assets.dart';

class LogoWidget extends StatelessWidget {
  const LogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      Assets.dataPortalLogo,
      height: 56,
      fit: BoxFit.contain,
    );
  }
}
