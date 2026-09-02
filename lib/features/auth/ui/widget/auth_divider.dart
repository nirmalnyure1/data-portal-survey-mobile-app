import 'package:flutter/material.dart';
import 'package:data_portal_survey/common/theme/app_spacing.dart';
import 'package:data_portal_survey/common/theme/theme.dart';

class AuthDivider extends StatelessWidget {
  final String text;

  const AuthDivider({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: ThemeColors.lightGrey)),
        const SizedBox(width: AppSpacing.s20),
        Text(
          text,
          style: TextStyle(
            color: ThemeColors.lightTextColor,
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: AppSpacing.s20),
        Expanded(child: Container(height: 1, color: ThemeColors.lightGrey)),
      ],
    );
  }
}
