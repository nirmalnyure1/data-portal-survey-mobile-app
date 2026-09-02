import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data_portal_survey/common/theme/app_spacing.dart';
import 'package:data_portal_survey/common/constants/constant_assets.dart';
import 'package:data_portal_survey/common/utils/auth_gate.dart';
import 'package:data_portal_survey/common/widgets/app_dialog.dart';
import 'package:data_portal_survey/features/auth/resource/auth_repository.dart';
import 'package:data_portal_survey/features/profile/ui/widget/section_title.dart';
import 'package:data_portal_survey/navigation/app_router.dart';
import 'menu_item_widget.dart';

class AccountSection extends StatelessWidget {
  final VoidCallback onDeleteAccount;

  const AccountSection({super.key, required this.onDeleteAccount});

  Future<void> _onChangePasswordTap(BuildContext context) async {
    final user = context.read<AuthRepository>().user.value;
    final hasVerifiedPhone = user?.hasVerifiedPhone == true;

    if (!hasVerifiedPhone) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AppDialog(
            type: AppDialogType.warning,
            icon: Icons.phone_android_rounded,
            title: 'Verify phone number',
            message:
                'Please add and verify your phone number before changing your password.',
            primaryButtonText: 'Verify phone',
            secondaryButtonText: 'Cancel',
            onPrimaryPressed: () {
              Navigator.of(dialogContext).pop();
              context.router.push(const EditProfileRoute());
            },
            onSecondaryPressed: () => Navigator.of(dialogContext).pop(),
          );
        },
      );
      return;
    }

    context.router.push(const ChangePasswordRoute());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'ACCOUNT'),
        const SizedBox(height: AppSpacing.s12),
        MenuItemWidget(
          iconPath: Assets.profileUser,
          label: 'Edit Profile',
          onTap: () {
            AuthGate.requireAuth(
              context,
              onAuthenticated: () {
                context.router.push(const EditProfileRoute());
              },
            );
          },
        ),
        MenuItemWidget(
          materialIcon: Icons.lock_reset_rounded,
          label: 'Change Password',
          onTap: () {
            AuthGate.requireAuth(
              context,
              onAuthenticated: () => _onChangePasswordTap(context),
            );
          },
        ),
        MenuItemWidget(
          iconPath: Assets.user,
          label: 'Delete Account',
          onTap: () {
            AuthGate.requireAuth(
              context,
              message: 'Sign in to manage your account',
              onAuthenticated: onDeleteAccount,
            );
          },
        ),
      ],
    );
  }
}
