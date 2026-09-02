import 'package:flutter/material.dart';
import 'package:data_portal_survey/common/constants/app_strings.dart';
import 'package:data_portal_survey/common/theme/app_shapes.dart';
import 'package:data_portal_survey/common/theme/app_spacing.dart';
import 'package:data_portal_survey/common/theme/theme_colors.dart';
import 'package:data_portal_survey/common/utils/card_boxshadow_utils.dart';
import 'package:data_portal_survey/navigation/navigation.dart';

class GuestSignInPrompt extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<String> benefits;

  const GuestSignInPrompt({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.lock_outline_rounded,
    this.benefits = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s16,
          vertical: AppSpacing.s20,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s20,
            vertical: AppSpacing.s28,
          ),
          decoration: BoxDecoration(
            color: ThemeColors.cardBackGroundColor,
            borderRadius: AppShapes.radiusLg,
            boxShadow: [CardBoxShadowUtils.cardBoxShadow],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: ThemeColors.highlightBackGroundColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 34,
                  color: ThemeColors.primaryColor,
                ),
              ),
              const SizedBox(height: AppSpacing.s20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: ThemeColors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: ThemeColors.lightTextColor,
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
              if (benefits.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.s20),
                ...benefits.map(
                  (benefit) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.s10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 18,
                          color: ThemeColors.primaryColor,
                        ),
                        const SizedBox(width: AppSpacing.s10),
                        Expanded(
                          child: Text(
                            benefit,
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.35,
                              fontWeight: FontWeight.w500,
                              color: ThemeColors.darkGrey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.s24),
              SizedBox(
                width: double.infinity,
                child: Material(
                  color: ThemeColors.primaryColor,
                  borderRadius: AppShapes.radiusBar,
                  child: InkWell(
                    borderRadius: AppShapes.radiusBar,
                    onTap: () => AppNavigator.push(const LoginRoute()),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.s14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_outline,
                            color: ThemeColors.pageBackGroundColor,
                            size: 20,
                          ),
                          SizedBox(width: AppSpacing.s8),
                          Text(
                            AppStrings.logInSignUp,
                            style: TextStyle(
                              color: ThemeColors.pageBackGroundColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
