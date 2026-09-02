import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:data_portal_survey/common/constants/app_strings.dart';
import 'package:data_portal_survey/common/theme/app_shapes.dart';
import 'package:data_portal_survey/common/theme/app_spacing.dart';
import 'package:data_portal_survey/common/theme/theme_colors.dart';
import 'package:data_portal_survey/common/utils/user_listener.dart';
import 'package:data_portal_survey/features/auth/model/user_model.dart';
import 'package:data_portal_survey/navigation/navigation.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return UserListener(
      builder: (context, userListenerModel) {
        if (!userListenerModel.isLoggedIn ||
            userListenerModel.userModel == null) {
          return _buildGuestHeader(context);
        }

        return _buildMemberHeader(context, userListenerModel.userModel!);
      },
    );
  }

  Widget _buildGuestHeader(BuildContext context) {
    final topInset = MediaQuery.viewPaddingOf(context).top;

    return Container(
      width: double.infinity,
      color: ThemeColors.primaryColor,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.s20,
        topInset + AppSpacing.s20,
        AppSpacing.s20,
        AppSpacing.s20,
      ),
      child: Column(
        children: [
          const _AvatarBadge(label: 'G'),
          const SizedBox(height: AppSpacing.s14),
          const Text(
            'Guest User',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ThemeColors.pageBackGroundColor,
              fontSize: AppSpacing.s18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          SizedBox(
            width: double.infinity,
            child: Material(
              color: ThemeColors.pageBackGroundColor,
              borderRadius: AppShapes.radiusPill,
              child: InkWell(
                borderRadius: AppShapes.radiusPill,
                onTap: () => AppNavigator.push(const LoginRoute()),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.s14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.account_circle_outlined,
                        color: ThemeColors.primaryColor,
                        size: 22,
                      ),
                      SizedBox(width: AppSpacing.s8),
                      Text(
                        AppStrings.logInSignUp,
                        style: TextStyle(
                          color: ThemeColors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          Text(
            AppStrings.guestProfileSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ThemeColors.pageBackGroundColor.withValues(alpha: 0.9),
              fontSize: AppSpacing.s13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberHeader(BuildContext context, UserModel user) {
    final topInset = MediaQuery.viewPaddingOf(context).top;
    final fullName = '${user.firstName} ${user.lastName}'.trim();
    final initial = fullName.isNotEmpty
        ? fullName.characters.first.toUpperCase()
        : 'U';
    final phoneVerified = user.hasVerifiedPhone;

    return Container(
      width: double.infinity,
      color: ThemeColors.primaryColor,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.s20,
        topInset + AppSpacing.s20,
        AppSpacing.s20,
        AppSpacing.s20,
      ),
      child: Column(
        children: [
          _AvatarBadge(label: initial, imageUrl: user.profilePicture),
          const SizedBox(height: AppSpacing.s14),
          Text(
            fullName.isEmpty ? 'Member' : fullName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: ThemeColors.pageBackGroundColor,
              fontSize: AppSpacing.s18,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (user.phone.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s6),
            Text(
              user.phone,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ThemeColors.pageBackGroundColor.withValues(alpha: 0.9),
                fontSize: AppSpacing.s14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
          if (!phoneVerified) ...[
            const SizedBox(height: AppSpacing.s10),
            _PhoneNotVerifiedIndicator(
              hasPhone: user.phone.trim().isNotEmpty,
              onTap: () => context.router.push(const EditProfileRoute()),
            ),
          ],
        ],
      ),
    );
  }
}

class _PhoneNotVerifiedIndicator extends StatelessWidget {
  final bool hasPhone;
  final VoidCallback onTap;

  const _PhoneNotVerifiedIndicator({
    required this.hasPhone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ThemeColors.pageBackGroundColor.withValues(alpha: 0.16),
      borderRadius: AppShapes.radiusPill,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppShapes.radiusPill,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s12,
            vertical: AppSpacing.s8,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: ThemeColors.pageBackGroundColor.withValues(alpha: 0.95),
              ),
              const SizedBox(width: AppSpacing.s6),
              Text(
                hasPhone ? 'Phone not verified' : 'Add & verify phone',
                style: TextStyle(
                  color: ThemeColors.pageBackGroundColor.withValues(
                    alpha: 0.95,
                  ),
                  fontSize: AppSpacing.s12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: AppSpacing.s4),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: ThemeColors.pageBackGroundColor.withValues(alpha: 0.95),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarBadge extends StatelessWidget {
  final String label;
  final String? imageUrl;

  const _AvatarBadge({required this.label, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return Container(
      width: 65,
      height: 65,
      decoration: BoxDecoration(
        color: ThemeColors.pageBackGroundColor,
        borderRadius: AppShapes.radiusXl,
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? CachedNetworkImage(
              imageUrl: imageUrl!,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => _InitialText(label: label),
            )
          : _InitialText(label: label),
    );
  }
}

class _InitialText extends StatelessWidget {
  final String label;

  const _InitialText({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        label,
        style: const TextStyle(
          color: ThemeColors.primaryColor,
          fontSize: 28,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
