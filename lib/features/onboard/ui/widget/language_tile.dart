import 'package:flutter/material.dart';
import 'package:data_portal_survey/common/constants/text_styles.dart';
import 'package:data_portal_survey/common/theme/theme.dart';
import 'package:data_portal_survey/common/theme/app_spacing.dart';

class LanguageTile extends StatelessWidget {
  final String language;
  final String flag;
  final bool isSelected;
  final VoidCallback onTap;

  const LanguageTile({
    super.key,
    required this.language,
    required this.flag,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppInsets.all16,
        decoration: BoxDecoration(
          color: isSelected
              ? ThemeColors.primaryColor.withOpacity(0.1)
              : ThemeColors.lightGrey.withOpacity(0.5),
          borderRadius: AppShapes.radiusMd,
          border: Border.all(
            color: isSelected ? ThemeColors.primaryColor : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Image.asset(flag, width: 24, height: 24),
            const SizedBox(width: AppSpacing.s16),
            Text(language, style: AppTextStyles.body),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check_circle_outline,
                color: ThemeColors.primaryColor,
              ),
          ],
        ),
      ),
    );
  }
}
