import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data_portal_survey/common/constants/app_strings.dart';
import 'package:data_portal_survey/common/theme/app_shapes.dart';
import 'package:data_portal_survey/common/theme/app_spacing.dart';
import 'package:data_portal_survey/common/theme/theme_colors.dart';
import 'package:data_portal_survey/common/utils/card_boxshadow_utils.dart';
import 'package:data_portal_survey/common/utils/toast_message_utils.dart';
import 'package:data_portal_survey/common/widgets/page_wrapper.dart';
import 'package:data_portal_survey/features/auth/resource/auth_repository.dart';
import 'package:data_portal_survey/features/home/ui/widget/settings_switch_row.dart';
import 'package:data_portal_survey/features/notification/model/notification_preferences_model.dart';
import 'package:data_portal_survey/features/notification/resource/notification_repository.dart';
import 'package:data_portal_survey/navigation/navigation.dart';

@RoutePage()
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  NotificationPreferencesModel? _preferences;
  bool _isLoading = true;
  bool _isSaving = false;

  NotificationRepository get _notificationRepository =>
      RepositoryProvider.of<NotificationRepository>(context);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _maybeLoadPreferences(),
    );
  }

  Future<void> _maybeLoadPreferences() async {
    if (!mounted) return;
    final isAuthenticated = RepositoryProvider.of<AuthRepository>(
      context,
    ).isAuthenticated;
    if (!isAuthenticated) {
      setState(() => _isLoading = false);
      return;
    }
    await _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final response = await _notificationRepository.getMyPreferences();
    if (!mounted) return;

    if (response.data != null) {
      setState(() {
        _preferences = response.data;
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = false);
    if ((response.message ?? '').isNotEmpty) {
      ToastMessageUtils.error(response.message!);
    }
  }

  Future<void> _updatePreferences(NotificationPreferencesModel next) async {
    final previous = _preferences;
    setState(() {
      _preferences = next;
      _isSaving = true;
    });

    final response = await _notificationRepository.updateMyPreferences(next);
    if (!mounted) return;

    if (response.data != null) {
      setState(() {
        _preferences = response.data;
        _isSaving = false;
      });
      return;
    }

    setState(() {
      _preferences = previous;
      _isSaving = false;
    });
    ToastMessageUtils.error(response.message ?? 'Unable to update preferences');
  }

  Widget _buildMenuRow({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: AppShapes.radiusMd,
          child: Padding(
            padding: AppInsets.v12,
            child: Row(
              children: [
                Icon(icon, size: AppSpacing.s20, color: ThemeColors.darkGrey),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: ThemeColors.black,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  size: AppSpacing.s20,
                  color: ThemeColors.lightTextColor,
                ),
              ],
            ),
          ),
        ),
        if (showDivider) const Divider(height: 1, color: ThemeColors.lightGrey),
      ],
    );
  }

  Widget _buildGuestNotificationPrompt() {
    return Padding(
      padding: AppInsets.v12,
      child: Column(
        children: [
          Icon(
            Icons.notifications_outlined,
            size: 40,
            color: ThemeColors.primaryColor.withValues(alpha: 180),
          ),
          const SizedBox(height: AppSpacing.s12),
          const Text(
            AppStrings.signInToManageNotifications,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: ThemeColors.black,
            ),
          ),
          const SizedBox(height: AppSpacing.s6),
          const Text(
            AppStrings.guestNotificationsSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: ThemeColors.lightTextColor,
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          SizedBox(
            width: double.infinity,
            child: Material(
              color: ThemeColors.primaryColor,
              borderRadius: AppShapes.radiusBar,
              child: InkWell(
                borderRadius: AppShapes.radiusBar,
                onTap: () => AppNavigator.push(const LoginRoute()),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.s12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_outline,
                        color: ThemeColors.pageBackGroundColor,
                        size: 18,
                      ),
                      SizedBox(width: AppSpacing.s8),
                      Text(
                        AppStrings.logInSignUp,
                        style: TextStyle(
                          color: ThemeColors.pageBackGroundColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = RepositoryProvider.of<AuthRepository>(
      context,
    ).isAuthenticated;
    final preferences =
        _preferences ??
        const NotificationPreferencesModel(
          pushEnabled: false,
          marketingEnabled: false,
          orderEnabled: false,
          topics: {},
        );

    return PageWrapper(
      title: 'Settings',
      body: SingleChildScrollView(
        clipBehavior: Clip.none,
        padding: const EdgeInsets.only(bottom: AppSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: AppInsets.all16,
              decoration: BoxDecoration(
                color: ThemeColors.cardBackGroundColor,
                borderRadius: AppShapes.radiusLg,
                boxShadow: [CardBoxShadowUtils.cardBoxShadow],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notification Preferences',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: ThemeColors.black,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  if (!isAuthenticated)
                    _buildGuestNotificationPrompt()
                  else if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: AppInsets.v12,
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else ...[
                    SettingsSwitchRow(
                      title: 'Push Notifications',
                      value: preferences.pushEnabled,
                      onChanged: _isSaving
                          ? (_) {}
                          : (value) => _updatePreferences(
                              preferences.copyWith(pushEnabled: value),
                            ),
                    ),
                    SettingsSwitchRow(
                      title: 'Survey Updates',
                      value: preferences.orderEnabled,
                      onChanged: _isSaving
                          ? (_) {}
                          : (value) => _updatePreferences(
                              preferences.copyWith(
                                orderEnabled: value,
                                topics: {
                                  ...preferences.topics,
                                  'order_updates': value,
                                },
                              ),
                            ),
                    ),
                    SettingsSwitchRow(
                      title: 'Announcements',
                      value:
                          preferences.marketingEnabled ||
                          (preferences.topics['offers'] ?? false),
                      onChanged: _isSaving
                          ? (_) {}
                          : (value) => _updatePreferences(
                              preferences.copyWith(
                                marketingEnabled: value,
                                topics: {
                                  ...preferences.topics,
                                  'offers': value,
                                },
                              ),
                            ),
                      showDivider: false,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            Container(
              padding: AppInsets.all16,
              decoration: BoxDecoration(
                color: ThemeColors.cardBackGroundColor,
                borderRadius: AppShapes.radiusLg,
                boxShadow: [CardBoxShadowUtils.cardBoxShadow],
              ),
              child: Column(
                children: [
                  _buildMenuRow(
                    icon: Icons.info_outline,
                    title: 'About',
                    onTap: () => context.router.push(const AboutRoute()),
                  ),
                  _buildMenuRow(
                    icon: Icons.description_outlined,
                    title: 'Terms & Conditions',
                    onTap: () =>
                        context.router.push(const TermsConditionsRoute()),
                  ),
                  _buildMenuRow(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    onTap: () =>
                        context.router.push(const PrivacyPolicyRoute()),
                    showDivider: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            // Container(
            //   padding: AppInsets.all16,
            //   decoration: BoxDecoration(
            //     color: ThemeColors.cardBackGroundColor,
            //     borderRadius: AppShapes.radiusLg,
            //     boxShadow: [CardBoxShadowUtils.cardBoxShadow],
            //   ),
            //   child: const Row(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Icon(
            //         Icons.info_outline,
            //         color: ThemeColors.yellow,
            //         size: AppSpacing.s20,
            //       ),
            //       SizedBox(width: AppSpacing.s10),
            //       Expanded(
            //         child: Text(
            //           'We’ll send payment and delivery updates via SMS.',
            //           style: TextStyle(
            //             fontSize: 14,
            //             fontWeight: FontWeight.w500,
            //             color: ThemeColors.darkGrey,
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
