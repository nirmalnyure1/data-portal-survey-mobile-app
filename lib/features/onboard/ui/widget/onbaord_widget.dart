import 'package:flutter/material.dart';
import 'package:data_portal_survey/common/constants/constant_assets.dart';
import 'package:data_portal_survey/common/constants/app_strings.dart';
import 'package:data_portal_survey/common/constants/text_styles.dart';
import 'package:data_portal_survey/features/onboard/ui/widget/page_indicator.dart';
import 'package:data_portal_survey/common/theme/app_spacing.dart';
import 'package:data_portal_survey/features/survey/constants/survey_theme.dart';

class OnboardWidget extends StatelessWidget {
  final Widget page;
  final int currentIndex;

  final String subTitle;
  final String assets;

  const OnboardWidget({
    super.key,
    required this.page,
    required this.subTitle,
    required this.assets,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.s24),
        Align(
          alignment: Alignment.center,
          child: Image.asset(Assets.dataPortalLogo, height: 48, fit: BoxFit.contain),
        ),
        Align(
          alignment: Alignment.center,
          child: Image.asset(assets, height: 300, width: 300),
        ),
        const SizedBox(height: AppSpacing.s10),
        Align(
          alignment: Alignment.center,
          child: PageIndicator(count: 3, currentIndex: currentIndex),
        ),
        const SizedBox(height: AppSpacing.s40),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [page]),
        const SizedBox(height: AppSpacing.s16),
        Text(
          subTitle,
          textAlign: TextAlign.start,
          style: AppTextStyles.subtitle,
        ),
      ],
    );
  }
}

class FirstPageText extends StatelessWidget {
  const FirstPageText({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.start,
      text: TextSpan(
        style: AppTextStyles.heading1,
        children: [
          const TextSpan(text: '${AppStrings.onboardTitle1} '),
          TextSpan(
            text: '\n${AppStrings.onboardHighlight1}',
            style: AppTextStyles.heading2.copyWith(
              color: SurveyTheme.primary,
            ),
          ),
          TextSpan(
            text: AppStrings.onboardTitle1Suffix,
            style: AppTextStyles.heading2.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class SecondPageText extends StatelessWidget {
  const SecondPageText({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.start,
      text: TextSpan(
        style: AppTextStyles.heading1,
        children: [
          TextSpan(
            text: '${AppStrings.onboardTitle2} ',
            style: AppTextStyles.heading2.copyWith(
              color: SurveyTheme.primary,
            ),
          ),
          TextSpan(
            text: AppStrings.onboardTitle2Suffix,
            style: AppTextStyles.heading2.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class ThirdPageText extends StatelessWidget {
  const ThirdPageText({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.start,
      text: TextSpan(
        style: AppTextStyles.heading1,
        children: [
          TextSpan(
            text: '${AppStrings.onboardTitle3} ',
            style: AppTextStyles.heading2.copyWith(
              color: SurveyTheme.primary,
            ),
          ),
          TextSpan(
            text: AppStrings.onboardTitle3Suffix,
            style: AppTextStyles.heading2.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
