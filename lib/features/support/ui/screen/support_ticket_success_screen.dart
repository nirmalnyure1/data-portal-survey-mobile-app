import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:data_portal_survey/common/constants/constant_assets.dart';
import 'package:data_portal_survey/common/theme/app_shapes.dart';
import 'package:data_portal_survey/common/theme/app_spacing.dart';
import 'package:data_portal_survey/common/theme/theme_colors.dart';
import 'package:data_portal_survey/common/utils/card_boxshadow_utils.dart';
import 'package:data_portal_survey/common/widgets/page_wrapper.dart';
import 'package:data_portal_survey/common/widgets/primary_button.dart';
import 'package:data_portal_survey/features/home/ui/widget/dashboard_widget.dart';

@RoutePage()
class SupportTicketSuccessScreen extends StatelessWidget {
  const SupportTicketSuccessScreen({super.key, required this.ticketDisplay});

  final String ticketDisplay;

  String get _ticketSuffix {
    final t = ticketDisplay.trim();
    if (t.isEmpty) return '';
    return t.startsWith('#') ? t : '#$t';
  }

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      title: '',
      body: SafeArea(
        child: Padding(
          padding: AppInsets.h24,
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.s80),
              Expanded(
                child: Center(
                  child: Container(
                    width: double.infinity,
                    padding: AppInsets.all24,
                    decoration: BoxDecoration(
                      color: ThemeColors.cardBackGroundColor,
                      borderRadius: AppShapes.radiusLg,
                      boxShadow: [CardBoxShadowUtils.cardBoxShadow],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: AppSpacing.s100,
                          height: AppSpacing.s100,
                          decoration: BoxDecoration(
                            color: ThemeColors.pageBackGroundColor,
                            shape: BoxShape.circle,
                            boxShadow: [CardBoxShadowUtils.cardBoxShadow],
                          ),
                          padding: const EdgeInsets.all(AppSpacing.s18),
                          child: Image.asset(
                            Assets.support,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s24),
                        if (_ticketSuffix.isEmpty)
                          const Text(
                            'Request submitted',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                              color: ThemeColors.black,
                            ),
                          )
                        else
                          Text.rich(
                            TextSpan(
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                                color: ThemeColors.black,
                              ),
                              children: [
                                const TextSpan(text: 'Ticket '),
                                TextSpan(
                                  text: _ticketSuffix,
                                  style: const TextStyle(
                                    color: ThemeColors.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        const SizedBox(height: AppSpacing.s10),
                        const Text(
                          "Supporting ticket created. We'll get back to you soon",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: ThemeColors.lightTextColor,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s32),
                        PrimaryButton(
                          hPadding: AppSpacing.s28,
                          text: 'Browse Menu',
                          onPressed: () {
                            DashboardTabController.jumpTo(0);
                            context.router.pop();
                          },
                          suffixIcon: Icons.arrow_forward,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s80),
            ],
          ),
        ),
      ),
    );
  }
}
