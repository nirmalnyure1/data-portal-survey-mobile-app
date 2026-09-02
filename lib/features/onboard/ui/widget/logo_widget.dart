import 'package:flutter/material.dart';
import 'package:data_portal_survey/common/constants/constant_assets.dart';

class LogoWidget extends StatelessWidget {
  final bool isWhite;
  const LogoWidget({super.key, this.isWhite = false});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      Assets.appIcon,
      height: 50,
    );
  }
}
