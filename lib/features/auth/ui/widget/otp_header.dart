import 'package:flutter/material.dart';
import 'package:data_portal_survey/common/theme/app_spacing.dart';
import 'package:data_portal_survey/common/theme/theme.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subTitle;
  const AuthHeader({super.key, required this.title, required this.subTitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.s10),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: ThemeColors.pageBackGroundColor,
          ),
        ),
        const SizedBox(height: AppSpacing.s4),
        Text(
          subTitle,
          textAlign: TextAlign.center,

          style: TextStyle(
            color: ThemeColors.pageBackGroundColor,
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        // const SizedBox(height: 22),
      ],
    );
  }
}
