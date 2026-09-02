import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data_portal_survey/common/cubit/data_state.dart';
import 'package:data_portal_survey/common/utils/card_boxshadow_utils.dart';
import 'package:data_portal_survey/common/utils/toast_message_utils.dart';
import 'package:data_portal_survey/common/utils/user_listener.dart';
import 'package:data_portal_survey/common/theme/app_spacing.dart';
import 'package:data_portal_survey/common/theme/theme_colors.dart';
import 'package:data_portal_survey/common/widgets/app_dialog.dart';
import 'package:data_portal_survey/common/widgets/status_bar_wrapper.dart';
import 'package:data_portal_survey/common/widgets/tertiary_button.dart';
import 'package:data_portal_survey/features/auth/bloc/get_me_cubit.dart';
import 'package:data_portal_survey/features/auth/bloc/logout_cubit.dart';
import 'package:data_portal_survey/features/auth/resource/auth_repository.dart';
import 'package:data_portal_survey/navigation/navigation.dart';
import '../widget/profile_header.dart';
import '../widget/account_section.dart';
import '../widget/preferences_section.dart';
import 'package:data_portal_survey/common/theme/app_shapes.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final authRepository = RepositoryProvider.of<AuthRepository>(context);
      if (authRepository.isAuthenticated) {
        context.read<GetMeCubit>().fetchMe();
      }
    });
  }

  Future<void> _refreshProfile(BuildContext context) async {
    final authRepository = RepositoryProvider.of<AuthRepository>(context);
    if (!authRepository.isAuthenticated) return;

    final getMeCubit = context.read<GetMeCubit>();
    await getMeCubit.fetchMe();
    if (!context.mounted) return;

    final state = getMeCubit.state;
    if (state is CommonError && state.message.isNotEmpty) {
      ToastMessageUtils.error(state.message);
    }
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return BlocListener<LogoutCubit, CommonState>(
          listener: (context, state) {
            if (state is CommonSuccess) {
              Navigator.of(dialogContext).pop();
            }
          },
          child: BlocBuilder<LogoutCubit, CommonState>(
            builder: (context, state) {
              return AppDialog(
                type: AppDialogType.confirmation,
                icon: Icons.logout_rounded,
                title: 'Are you sure want to logout?',
                primaryButtonText: 'Yes',
                secondaryButtonText: 'No',
                showCloseButton: false,
                isPrimaryLoading: state is CommonLoading,
                onPrimaryPressed: () => context.read<LogoutCubit>().logout(),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _showDeleteAccountDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return BlocListener<LogoutCubit, CommonState>(
          listener: (context, state) {
            if (state is CommonSuccess) {
              Navigator.of(dialogContext).pop();
            }
          },
          child: BlocBuilder<LogoutCubit, CommonState>(
            builder: (context, state) {
              return AppDialog(
                type: AppDialogType.warning,
                icon: Icons.delete_forever_rounded,
                title: 'Delete your account?',
                message:
                    'This will permanently delete your account and associated data. This action cannot be undone.',
                primaryButtonText: 'Delete account',
                secondaryButtonText: 'Cancel',
                showCloseButton: false,
                isPrimaryLoading: state is CommonLoading,
                onPrimaryPressed: () => context.read<LogoutCubit>().logout(),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LogoutCubit, CommonState>(
      listener: (context, state) {
        if (state is CommonSuccess) {
          AppNavigator.replace(const DashboardRoute());
        }
        if (state is CommonError) {
          ToastMessageUtils.error(state.message);
        }
      },
      builder: (context, state) {
        return UserListener(
          builder: (context, userListenerModel) {
            final isLoggedIn =
                userListenerModel.isLoggedIn &&
                userListenerModel.userModel != null;

            return StatusBarWrapper(
              isDark: true,
              statusBarColor: ThemeColors.primaryColor,
              child: Scaffold(
                backgroundColor: ThemeColors.primaryColor,
                body: RefreshIndicator(
                  onRefresh: () => _refreshProfile(context),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    clipBehavior: Clip.none,
                    child: Column(
                      children: [
                        const ProfileHeader(),
                        ColoredBox(
                          color: ThemeColors.pageBackGroundColor,
                          child: Column(
                            children: [
                              const SizedBox(height: AppSpacing.s14),
                              Container(
                                padding: AppInsets.all16,
                                decoration: BoxDecoration(
                                  color: ThemeColors.cardBackGroundColor,
                                  borderRadius: AppShapes.radiusMd,
                                  boxShadow: [CardBoxShadowUtils.cardBoxShadow],
                                ),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.s16,
                                ),
                                child: Column(
                                  children: [
                                    AccountSection(
                                      onDeleteAccount: () =>
                                          _showDeleteAccountDialog(context),
                                    ),
                                    const Divider(
                                      height: 1,
                                      thickness: 1,
                                      color: ThemeColors.lightGrey,
                                    ),
                                    const SizedBox(height: AppSpacing.s20),
                                    const PreferencesSection(),
                                  ],
                                ),
                              ),
                              if (isLoggedIn)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.s16,
                                    vertical: AppSpacing.s24,
                                  ),
                                  child: TertiaryButton(
                                    prefixIcon: Icons.logout,
                                    text: 'Logout',
                                    isLoading: state is CommonLoading,
                                    onPressed: () =>
                                        _showLogoutDialog(context),
                                  ),
                                )
                              else
                                const SizedBox(height: AppSpacing.s24),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
