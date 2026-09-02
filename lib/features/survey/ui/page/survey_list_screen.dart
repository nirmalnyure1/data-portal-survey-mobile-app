import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:data_portal_survey/common/constants/app_strings.dart';
import 'package:data_portal_survey/common/theme/app_spacing.dart';
import 'package:data_portal_survey/common/theme/theme_colors.dart';

@RoutePage()
class SurveyListScreen extends StatelessWidget {
  const SurveyListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.pageBackGroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                AppStrings.surveysTitle,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: ThemeColors.black,
                ),
              ),
              const SizedBox(height: AppSpacing.s8),
              const Text(
                AppStrings.surveysEmptySubtitle,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: ThemeColors.lightTextColor,
                ),
              ),
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.assignment_outlined,
                        size: 56,
                        color: ThemeColors.grey,
                      ),
                      SizedBox(height: AppSpacing.s16),
                      Text(
                        AppStrings.surveysEmptyTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: ThemeColors.black,
                        ),
                      ),
                    ],
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
