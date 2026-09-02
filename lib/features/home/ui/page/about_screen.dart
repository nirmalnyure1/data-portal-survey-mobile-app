import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:data_portal_survey/common/constants/app_strings.dart';
import 'package:data_portal_survey/common/theme/app_spacing.dart';
import 'package:data_portal_survey/common/theme/theme_colors.dart';
import 'package:data_portal_survey/common/widgets/page_wrapper.dart';
import 'package:data_portal_survey/common/theme/app_shapes.dart';

@RoutePage()
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      title: AppStrings.aboutApp,
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: AppInsets.all16,
          decoration: BoxDecoration(
            color: ThemeColors.cardBackGroundColor,
            borderRadius: AppShapes.radiusLg,
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.appDisplayName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: ThemeColors.primaryColor,
                ),
              ),
              SizedBox(height: AppSpacing.s8),
              Text(
                AppStrings.aboutAppBody,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: ThemeColors.darkGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
