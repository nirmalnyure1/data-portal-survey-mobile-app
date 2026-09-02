import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:data_portal_survey/common/theme/app_spacing.dart';
import 'package:data_portal_survey/common/constants/constant_assets.dart';
import 'package:data_portal_survey/navigation/app_router.dart';
import 'package:data_portal_survey/features/profile/ui/widget/section_title.dart';
import 'menu_item_widget.dart';

class PreferencesSection extends StatelessWidget {
  const PreferencesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'PREFERENCES'),
        const SizedBox(height: AppSpacing.s12),
        MenuItemWidget(
          iconPath: Assets.profileSetting,
          label: 'Settings',
          onTap: () {
            context.router.push(const SettingsRoute());
          },
        ),
        MenuItemWidget(
          iconPath: Assets.profileHelp,
          label: 'Help & Support',
          onTap: () {
            context.router.push(const HelpSupportRoute());
          },
        ),
      ],
    );
  }
}
