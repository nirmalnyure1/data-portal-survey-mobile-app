import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:data_portal_survey/common/theme/app_spacing.dart';
import 'package:data_portal_survey/common/theme/theme_colors.dart';
import 'package:data_portal_survey/common/widgets/page_wrapper.dart';
import 'package:data_portal_survey/common/theme/app_shapes.dart';
import 'package:data_portal_survey/features/survey/constants/survey_theme.dart';

@RoutePage()
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const List<_PolicySection> _sections = [
    _PolicySection(
      title: '1. Information We Collect',
      body:
          'We collect information you provide when you create an account, complete surveys, or contact support. This may include your name, phone number, email, survey responses, and device information.',
    ),
    _PolicySection(
      title: '2. How We Use Your Information',
      body:
          'Your information is used to authenticate you, store and submit survey data, send operational notifications, improve the app, and provide customer support.',
    ),
    _PolicySection(
      title: '3. Notifications',
      body:
          'We may send assignment updates, sync status, and other operational messages via push notifications. You can manage notification preferences from the Settings screen.',
    ),
    _PolicySection(
      title: '4. Survey Data',
      body:
          'Survey responses you collect are stored locally on your device until submitted, and may be transmitted to your organization\'s Data Portal backend when you submit or sync.',
    ),
    _PolicySection(
      title: '5. Location Data',
      body:
          'With your permission, location data may be used when a survey form requests GPS coordinates for a response field.',
    ),
    _PolicySection(
      title: '6. Data Security',
      body:
          'We use reasonable technical and organizational measures to protect your information. However, no system is completely secure.',
    ),
    _PolicySection(
      title: '7. Your Choices',
      body:
          'You can update your profile, manage notification preferences, and request account deletion through the app or your administrator.',
    ),
    _PolicySection(
      title: '8. Children\'s Privacy',
      body:
          'The app is not intended for children under 13. We do not knowingly collect personal information from children.',
    ),
    _PolicySection(
      title: '9. Changes to This Policy',
      body:
          'We may update this Privacy Policy from time to time. Significant changes will be communicated through the app.',
    ),
    _PolicySection(
      title: '10. Contact Us',
      body:
          'For privacy-related questions, reach out via the Help & Support section in the app.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      title: 'Privacy Policy',
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
                'Your privacy is important to us. This policy explains what we collect, how we use it, and the choices you have when using Data Portal Survey.',
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

class _PolicySection {
  final String title;
  final String body;

  const _PolicySection({required this.title, required this.body});
}
