import 'package:flutter/material.dart';
import 'package:data_portal_survey/common/theme/app_spacing.dart';
import 'package:data_portal_survey/common/theme/theme_colors.dart';
import 'package:data_portal_survey/common/widgets/dashed_rounded_border.dart';

class IssueItemWidget extends StatelessWidget {
  const IssueItemWidget({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fill = selected
        ? ThemeColors.primaryMaterialColor
        : ThemeColors.pageBackGroundColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s10),
      child: Material(
        color: fill,
        borderRadius: AppBorderRadius.all8,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppBorderRadius.all8,
          child: Container(
            // borderColor: borderColor,
            // borderRadius: AppRadius.r8,
            child: SizedBox(
              height: AppSpacing.s48,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.only(left: AppSpacing.s12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: selected
                          ? ThemeColors.pageBackGroundColor
                          : ThemeColors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
