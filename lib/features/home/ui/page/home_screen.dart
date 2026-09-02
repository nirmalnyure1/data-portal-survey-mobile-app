import 'package:flutter/material.dart';
import 'package:data_portal_survey/common/constants/app_strings.dart';
import 'package:data_portal_survey/common/theme/app_spacing.dart';
import 'package:data_portal_survey/common/theme/theme_colors.dart';
import 'package:data_portal_survey/common/utils/user_listener.dart';
import 'package:data_portal_survey/features/home/ui/widget/dashboard_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return UserListener(
      builder: (context, userListenerModel) {
        final firstName = userListenerModel.userModel?.firstName;
        final greeting = (firstName != null && firstName.isNotEmpty)
            ? 'Hello, $firstName'
            : AppStrings.welcomeToApp;

        return Scaffold(
          backgroundColor: ThemeColors.pageBackGroundColor,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.s24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: ThemeColors.black,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  const Text(
                    AppStrings.homeSubtitle,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.4,
                      color: ThemeColors.lightTextColor,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s32),
                  _HomeActionCard(
                    icon: Icons.assignment_outlined,
                    title: AppStrings.surveysTitle,
                    subtitle: AppStrings.surveysEmptySubtitle,
                    onTap: () => DashboardTabController.jumpTo(1),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HomeActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HomeActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ThemeColors.cardBackGroundColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: ThemeColors.primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: ThemeColors.primaryColor),
              ),
              const SizedBox(width: AppSpacing.s14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: ThemeColors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: ThemeColors.lightTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: ThemeColors.lightTextColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
