import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:data_portal_survey/common/utils/permission_handler.dart';
import 'package:data_portal_survey/common/utils/toast_message_utils.dart';
import 'package:data_portal_survey/common/widgets/primary_button.dart';
import 'package:data_portal_survey/common/widgets/secondary_button.dart';
import 'package:data_portal_survey/common/theme/theme_colors.dart';
import 'package:data_portal_survey/features/auth/resource/auth_repository.dart';
import 'package:data_portal_survey/features/onboard/bloc/startup_cubit.dart';
import 'package:data_portal_survey/features/onboard/bloc/startup_state.dart';
import 'package:data_portal_survey/navigation/navigation.dart';
import 'package:data_portal_survey/common/theme/app_spacing.dart';
import 'package:data_portal_survey/common/theme/app_shapes.dart';

@RoutePage()
class NotificationPermissionScreen extends StatefulWidget {
  final bool hasSession;

  const NotificationPermissionScreen({super.key, required this.hasSession});

  @override
  State<NotificationPermissionScreen> createState() =>
      _NotificationPermissionScreenState();
}

class _NotificationPermissionScreenState
    extends State<NotificationPermissionScreen> {
  late final StartupCubit _startupCubit;
  bool _isCubitInitialized = false;
  bool _showNotNow = false;

  Future<void> _skipNotificationsAndContinue() async {
    await _startupCubit.skipNotificationPermission();
    if (!mounted) return;
    await AppNavigator.completeStartup(isAuthenticated: widget.hasSession);
  }

  Future<void> _showPermissionDeniedSnackBar() async {
    final isPermanentlyDenied =
        await PermissionHandler.isNotificationPermanentlyDenied();
    if (!mounted) return;

    ToastMessageUtils.show(
      isPermanentlyDenied
          ? 'Notification permission is disabled. Open settings to enable it.'
          : 'Notification permission was not granted.',
      action: isPermanentlyDenied
          ? SnackBarAction(
              label: 'Open Settings',
              onPressed: openAppSettings,
            )
          : null,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isCubitInitialized) {
      return;
    }

    _startupCubit = StartupCubit(
      authRepository: RepositoryProvider.of<AuthRepository>(context),
      secureStorage: RepositoryProvider.of(context),
    );
    _isCubitInitialized = true;
  }

  @override
  void dispose() {
    _startupCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _startupCubit,
      child: BlocListener<StartupCubit, StartupState>(
        listener: (context, state) async {
          if (state is NotificationAllowed) {
            await AppNavigator.completeStartup(isAuthenticated: widget.hasSession);
          }
          if (state is NotificationPermissionDenied) {
            setState(() => _showNotNow = true);
            await _showPermissionDeniedSnackBar();
          }
          if (state is StartupError) {
            if (!context.mounted) return;
            ToastMessageUtils.error(state.message);
          }
        },
        child: BlocBuilder<StartupCubit, StartupState>(
          builder: (context, state) {
            return Scaffold(
              backgroundColor: const Color(0xFFF7F7F7),
              body: SafeArea(
                child: Padding(
                  padding: AppInsets.all20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.s20),
                      // Container(
                      //   width: 68,
                      //   height: 68,
                      //   decoration: BoxDecoration(
                      //     color: const Color(0xFFFFE4E6),
                      //     borderRadius: AppShapes.radiusPill,
                      //   ),
                      //   child: const Icon(
                      //     Icons.notifications_active_rounded,
                      //     size: 34,
                      //     color: Color(0xFFE13A3E),
                      //   ),
                      // ),
                      const SizedBox(height: AppSpacing.s24),
                      const Text(
                        'Stay in the loop',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s10),
                      const Text(
                        'Enable notifications for survey updates and important account alerts.',
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.4,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                      const Spacer(),

                      // SizedBox(
                      //   width: double.infinity,
                      //   height: 52,
                      //   child: ElevatedButton(
                      //     onPressed: () =>
                      //         _startupCubit.requestNotificationPermission(),
                      //     style: ElevatedButton.styleFrom(
                      //       backgroundColor: const Color(0xFFE13A3E),
                      //       foregroundColor: Colors.white,
                      //       shape: RoundedRectangleBorder(
                      //         borderRadius: AppShapes.radiusLg,
                      //       ),
                      //     ),
                      //     child: const Text(
                      //       'Allow Notifications',
                      //       style: TextStyle(
                      //         fontSize: 16,
                      //         fontWeight: FontWeight.w700,
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      SizedBox(
                        width: double.infinity,
                        child: PrimaryButton(
                          isLoading: state is StartupLoading,
                          onPressed: () {
                            _startupCubit.requestNotificationPermission();
                          },
                          text: 'Continue',
                        ),
                      ),
                      if (_showNotNow) ...[
                        const SizedBox(height: AppSpacing.s12),
                        SizedBox(
                          width: double.infinity,
                          child: SecondaryButton(
                            buttonColor: ThemeColors.grey,
                            text: 'Not now',
                            onPressed: _skipNotificationsAndContinue,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
