import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:data_portal_survey/common/theme/app_spacing.dart';
import 'package:data_portal_survey/common/theme/theme_colors.dart';
import 'package:data_portal_survey/common/widgets/page_wrapper.dart';
import 'package:data_portal_survey/common/theme/app_shapes.dart';
import 'package:data_portal_survey/features/survey/constants/survey_theme.dart';

@RoutePage()
class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  static const List<_TermsSection> _sections = [
    _TermsSection(
      title: '1. Acceptance of Terms',
      body:
          'By using the Data Portal Survey mobile app, you agree to these Terms & Conditions. If you do not agree, please discontinue use of the app.',
    ),
    _TermsSection(
      title: '2. Survey Collection',
      body:
          'The app is intended for authorized field workers and survey collectors. You must only collect data you are assigned or permitted to gather, and follow applicable organizational policies.',
    ),
    _TermsSection(
      title: '3. Account Security',
      body:
          'You are responsible for keeping your login credentials secure. Do not share your account with others. Notify your administrator if you suspect unauthorized access.',
    ),
    _TermsSection(
      title: '4. Data Accuracy',
      body:
          'You agree to enter survey responses accurately and honestly. Submitting false or misleading data may violate your organization\'s policies and applicable law.',
    ),
    _TermsSection(
      title: '5. Intellectual Property',
      body:
          'The Data Portal Survey name, logo, app design and related content are protected. Reuse without written permission is not allowed.',
    ),
    _TermsSection(
      title: '6. Changes to These Terms',
      body:
          'We may update these Terms from time to time. Continued use of the app after changes implies acceptance of the revised Terms.',
    ),
    _TermsSection(
      title: '7. Contact',
      body:
          'For questions about these Terms, reach out through the Help & Support section in the app.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      title: 'Terms & Conditions',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: AppInsets.all16,
              decoration: BoxDecoration(
                color: ThemeColors.pageBackGroundColor,
                borderRadius: AppShapes.radiusLg,
              ),
              child: const Text(
                'Please read these Terms & Conditions carefully before using Data Portal Survey.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: ThemeColors.darkGrey,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            Container(
              width: double.infinity,
              padding: AppInsets.all16,
              decoration: BoxDecoration(
                color: ThemeColors.cardBackGroundColor,
                borderRadius: AppShapes.radiusLg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _sections
                    .map(
                      (section) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.s16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              section.title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: SurveyTheme.primary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.s8),
                            Text(
                              section.body,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.5,
                                color: ThemeColors.darkGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TermsSection {
  final String title;
  final String body;

  const _TermsSection({required this.title, required this.body});
}
