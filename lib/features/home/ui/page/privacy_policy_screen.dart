import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:data_portal_survey/common/theme/app_spacing.dart';
import 'package:data_portal_survey/common/theme/theme_colors.dart';
import 'package:data_portal_survey/common/widgets/page_wrapper.dart';
import 'package:data_portal_survey/common/theme/app_shapes.dart';

@RoutePage()
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const List<_PolicySection> _sections = [
    _PolicySection(
      title: '1. Information We Collect',
      body:
          'We collect information you provide when you create an account, place an order, contact support or apply for a franchise. This includes your name, phone number, email, delivery address and order history.',
    ),
    _PolicySection(
      title: '2. How We Use Your Information',
      body:
          'Your information is used to process and deliver orders, send payment and delivery updates, share offers, improve our menu and app experience, and provide customer support.',
    ),
    _PolicySection(
      title: '3. Notifications & SMS Updates',
      body:
          'We may send payment, delivery and order-status updates via push notifications and SMS. You can manage notification preferences from the Settings screen.',
    ),
    _PolicySection(
      title: '4. Sharing With Delivery Partners',
      body:
          'When you place an order routed through Pathao, Foodmandu or Bhoj, we share only the information required for delivery (name, contact and address). These partners handle that data per their own privacy policies.',
    ),
    _PolicySection(
      title: '5. Payment Information',
      body:
          'Payment details are processed by trusted payment gateways. Syanko Rolls does not store full card or wallet credentials on its servers.',
    ),
    _PolicySection(
      title: '6. Location Data',
      body:
          'With your permission, we use location data to suggest the nearest outlet, calculate delivery options and improve your ordering experience.',
    ),
    _PolicySection(
      title: '7. Data Security',
      body:
          'We use reasonable technical and organizational measures to protect your information. However, no system is completely secure, and we cannot guarantee absolute security.',
    ),
    _PolicySection(
      title: '8. Cookies & App Analytics',
      body:
          'Our website and app may use cookies and analytics tools to understand usage patterns so we can improve performance, content and features.',
    ),
    _PolicySection(
      title: '9. Your Choices',
      body:
          'You can update your profile, manage saved addresses, control notification preferences and request deletion of your account at any time through the app.',
    ),
    _PolicySection(
      title: '10. Children\'s Privacy',
      body:
          'Our services are not intended for children under 13. We do not knowingly collect personal information from children.',
    ),
    _PolicySection(
      title: '11. Changes to This Policy',
      body:
          'We may update this Privacy Policy from time to time. Significant changes will be communicated through the app or website.',
    ),
    _PolicySection(
      title: '12. Contact Us',
      body:
          'For privacy-related questions or requests, reach out via the Help & Support section in the app or our website contact page.',
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
                'Your privacy is important to us. This policy explains what we collect, how we use it and the choices you have when using the Syanko Rolls app and website.',
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
                color: ThemeColors.pageBackGroundColor,
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
                                color: ThemeColors.black,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.s6),
                            Text(
                              section.body,
                              style: const TextStyle(
                                fontSize: 13,
                                height: 1.55,
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
            const SizedBox(height: AppSpacing.s20),
            const Center(
              child: Text(
                'Last updated: 2026',
                style: TextStyle(
                  fontSize: 11,
                  color: ThemeColors.lightTextColor,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s20),
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
