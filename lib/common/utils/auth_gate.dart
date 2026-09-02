import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data_portal_survey/common/theme/app_spacing.dart';
import 'package:data_portal_survey/common/theme/theme_colors.dart';
import 'package:data_portal_survey/common/widgets/primary_button.dart';
import 'package:data_portal_survey/common/widgets/secondary_button.dart';
import 'package:data_portal_survey/features/auth/resource/auth_repository.dart';
import 'package:data_portal_survey/navigation/navigation.dart';

class AuthGate {
  AuthGate._();

  static bool isAuthenticated(BuildContext context) {
    return RepositoryProvider.of<AuthRepository>(context).isAuthenticated;
  }

  static void requireAuth(
    BuildContext context, {
    required VoidCallback onAuthenticated,
    String message = 'Sign in to continue',
  }) {
    if (isAuthenticated(context)) {
      onAuthenticated();
      return;
    }
    showLoginPrompt(context, message: message, onAuthenticated: onAuthenticated);
  }

  static Future<void> showLoginPrompt(
    BuildContext context, {
    String message = 'Sign in to continue',
    VoidCallback? onAuthenticated,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: ThemeColors.pageBackGroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(
            AppSpacing.s22,
            AppSpacing.s22,
            AppSpacing.s22,
            AppSpacing.s22 + MediaQuery.of(sheetContext).padding.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: ThemeColors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.s8),
              const Text(
                'Create an account or sign in to access this feature.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ThemeColors.lightTextColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: AppSpacing.s22),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  text: 'Log In',
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    AppNavigator.push(const LoginRoute());
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.s12),
              SizedBox(
                width: double.infinity,
                child: SecondaryButton(
                  text: 'Sign Up',
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    AppNavigator.toSignup();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
