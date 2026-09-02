import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:data_portal_survey/common/theme/app_spacing.dart';
import 'package:data_portal_survey/common/theme/theme_colors.dart';
import 'package:data_portal_survey/common/widgets/page_wrapper.dart';
import 'package:data_portal_survey/common/theme/app_shapes.dart';

@RoutePage()
class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  static const List<_TermsSection> _sections = [
    _TermsSection(
      title: '1. Acceptance of Terms',
      body:
          'By using the Syanko Rolls mobile app or website, you agree to these Terms & Conditions. If you do not agree with any part of these terms, please discontinue use of our services.',
    ),
    _TermsSection(
      title: '2. Ordering & Direct Order Cut-off',
      body:
          'Our last direct order time is 7:30 PM each day. Once direct orders are closed, you can still place orders through our delivery partners: Pathao, Foodmandu and Bhoj.',
    ),
    _TermsSection(
      title: '3. Pricing',
      body:
          'All menu prices are listed in NRS and may change without prior notice. Promotional offers and franchise-exclusive prices may vary by outlet.',
    ),
    _TermsSection(
      title: '4. Order Confirmation',
      body:
          'An order is confirmed only after you receive an in-app or SMS confirmation. We reserve the right to cancel any order due to unavailability of items, payment issues or other operational reasons.',
    ),
    _TermsSection(
      title: '5. Delivery',
      body:
          'Delivery is available through our partner platforms — Pathao, Foodmandu and Bhoj. Delivery times, fees and availability are governed by the chosen partner and your selected outlet.',
    ),
    _TermsSection(
      title: '6. Cancellation & Refunds',
      body:
          'Orders can be cancelled before preparation begins. Once an item is being prepared, cancellations are not possible. Refunds, where applicable, are processed back through your original payment method.',
    ),
    _TermsSection(
      title: '7. Franchise Partnerships',
      body:
          'Franchise applications are reviewed individually. Approval, terms and obligations are governed by a separate franchise agreement entered into with Syanko Rolls.',
    ),
    _TermsSection(
      title: '8. Intellectual Property',
      body:
          'The Syanko Rolls name, logo, menu, recipes and all related content are the property of Syanko Rolls. Reuse without written permission is not allowed.',
    ),
    _TermsSection(
      title: '9. Changes to These Terms',
      body:
          'We may update these Terms from time to time. Continued use of the app after changes implies acceptance of the revised Terms.',
    ),
    _TermsSection(
      title: '10. Contact',
      body:
          'For any questions about these Terms, please reach out through the Help & Support section in the app or visit our website.',
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
                'Please read these Terms & Conditions carefully before using the Syanko Rolls app, website or any of our outlets.',
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

class _TermsSection {
  final String title;
  final String body;

  const _TermsSection({required this.title, required this.body});
}
