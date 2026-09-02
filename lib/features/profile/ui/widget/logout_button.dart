import 'package:flutter/material.dart';
import 'package:data_portal_survey/common/theme/app_spacing.dart';
import 'package:data_portal_survey/common/theme/theme_colors.dart';
import 'package:data_portal_survey/common/widgets/svg_widget.dart';
import 'package:data_portal_survey/common/constants/constant_assets.dart';

class LogoutButton extends StatelessWidget {
  final VoidCallback onTap;

  const LogoutButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(
          left: AppSpacing.s16,
          right: AppSpacing.s16,
          top: AppSpacing.s20,
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
        height: 56,
        decoration: BoxDecoration(
          color: ThemeColors.red,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgWidget(
              assetName: Assets.profileLogout,
              width: AppSpacing.s24,
              height: AppSpacing.s24,
              color: ThemeColors.pageBackGroundColor,
            ),
            const SizedBox(width: AppSpacing.s12),
            const Text(
              'Log Out',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ThemeColors.pageBackGroundColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
