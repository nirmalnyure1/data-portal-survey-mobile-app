import 'package:flutter/material.dart';
import 'package:data_portal_survey/common/theme/app_spacing.dart';
import 'package:data_portal_survey/common/theme/theme_colors.dart';
import 'package:data_portal_survey/common/widgets/svg_widget.dart';
import 'package:data_portal_survey/common/constants/constant_assets.dart';

class MenuItemWidget extends StatelessWidget {
  final String? iconPath;
  final IconData? materialIcon;
  final String label;
  final VoidCallback onTap;
  final Color? labelColor;
  final Color? iconColor;

  const MenuItemWidget({
    super.key,
    this.iconPath,
    this.materialIcon,
    required this.label,
    required this.onTap,
    this.labelColor,
    this.iconColor,
  }) : assert(
         iconPath != null || materialIcon != null,
         'Either iconPath or materialIcon must be provided',
       );

  @override
  Widget build(BuildContext context) {
    final resolvedLabelColor = labelColor ?? ThemeColors.lightTextColor;
    final resolvedIconColor = iconColor ?? resolvedLabelColor;

    return GestureDetector(
      onTap: onTap,
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: [
            Container(
              color: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
              child: Row(
                children: [
                  if (materialIcon != null)
                    Icon(materialIcon, size: 20, color: resolvedIconColor)
                  else
                    SvgWidget(
                      assetName: iconPath!,
                      width: 20,
                      height: 20,
                      color: resolvedIconColor,
                    ),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: resolvedLabelColor,
                      ),
                    ),
                  ),
                  SvgWidget(
                    assetName: Assets.arrowRight,
                    width: AppSpacing.s20,
                    height: AppSpacing.s20,
                    color: resolvedLabelColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
