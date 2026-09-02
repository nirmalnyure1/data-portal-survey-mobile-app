import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:data_portal_survey/common/theme/app_spacing.dart';
import 'package:data_portal_survey/common/theme/theme_colors.dart';
import 'package:data_portal_survey/common/theme/theme_text_styles.dart';
import 'package:data_portal_survey/common/widgets/page_wrapper.dart';
import 'package:data_portal_survey/features/auth/ui/widget/signup_sheet.dart';

@RoutePage()
class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The custom RichText Title stays fixed, no animation or hiding logic!
            Text.rich(
              TextSpan(
                text: 'Create your account to',
                style: ThemeTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
                children: const [
                  TextSpan(
                    text: ' collect\n',
                    style: TextStyle(color: ThemeColors.primaryColor),
                  ),
                  TextSpan(text: 'survey data.'),
                ],
              ),
            ),

            // The main Signup Form
            const SignupSheet(),
          ],
        ),
      ),
    );
  }
}
