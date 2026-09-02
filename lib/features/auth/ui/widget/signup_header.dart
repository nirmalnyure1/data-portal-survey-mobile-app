import 'package:flutter/material.dart';
import 'package:data_portal_survey/common/constants/app_strings.dart';
import 'package:data_portal_survey/common/theme/app_spacing.dart';
import 'package:data_portal_survey/common/theme/theme.dart';

class SignupHeader extends StatelessWidget {
  const SignupHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.s10),
        Text(
          AppStrings.createAccount,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: ThemeColors.black,
          ),
        ),
        const SizedBox(height: AppSpacing.s4),
        Text(
          AppStrings.createAccountSubtitle,
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
