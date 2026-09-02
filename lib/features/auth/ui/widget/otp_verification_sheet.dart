import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data_portal_survey/common/constants/app_strings.dart';
import 'package:data_portal_survey/common/cubit/data_state.dart';
import 'package:data_portal_survey/common/utils/toast_message_utils.dart';
import 'package:data_portal_survey/common/utils/form_validator.dart';
import 'package:data_portal_survey/features/auth/resource/auth_repository.dart';
import 'package:data_portal_survey/features/auth/bloc/resend_otp_cubit.dart';
import 'package:data_portal_survey/features/auth/bloc/verify_otp_cubit.dart';
import 'package:data_portal_survey/features/engagement/resource/engagement_repository.dart';
import 'package:data_portal_survey/features/auth/ui/widget/otp_code_input.dart';
import 'package:data_portal_survey/features/auth/ui/widget/otp_resend.dart';
import 'package:data_portal_survey/common/widgets/primary_button.dart';
import 'package:data_portal_survey/features/onboard/bloc/startup_cubit.dart';
import 'package:data_portal_survey/features/onboard/bloc/startup_state.dart';
import 'package:data_portal_survey/navigation/navigation.dart';
import 'package:data_portal_survey/common/theme/theme.dart';
import 'package:data_portal_survey/common/theme/app_spacing.dart';

class OtpVerificationSheet extends StatefulWidget {
  final String phoneNumber;

  const OtpVerificationSheet({super.key, required this.phoneNumber});

  @override
  State<OtpVerificationSheet> createState() => _OtpVerificationSheetState();
}

class _OtpVerificationSheetState extends State<OtpVerificationSheet> {
  String _otp = '';

  String _normalizeEmailOrPhone(String value) {
    final trimmed = value.trim();
    if (trimmed.contains('@')) return trimmed;
    final digits = FormValidator.digitsOnly(trimmed);
    if (digits.isEmpty) return trimmed;
    return '+$digits';
  }

  Future<void> _trackAppOpenForSession(BuildContext context) async {
    final authRepository = RepositoryProvider.of<AuthRepository>(context);
    final engagementRepository = RepositoryProvider.of<EngagementRepository>(
      context,
    );
    final userId = authRepository.user.value?.id ?? '';
    final accessToken = authRepository.accessToken;
    if (userId.isEmpty || accessToken.isEmpty) return;
    await engagementRepository.trackAppOpenIfNeeded(
      sessionKey: '$userId:$accessToken',
    );
  }

  void _onVerifyPressed(BuildContext context) {
    final otp = _otp.trim();
    if (otp.length != 6) {
      ToastMessageUtils.warning('Please enter 6-digit OTP');
      return;
    }

    context.read<VerifyOtpCubit>().verifyLogin(
      emailOrPhone: _normalizeEmailOrPhone(widget.phoneNumber),
      otp: otp,
    );
  }

  void _onResendPressed() {
    context.read<ResendOtpCubit>().sendLoginOtp(
      emailOrPhone: _normalizeEmailOrPhone(widget.phoneNumber),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final maxSheetHeight = screenHeight * 0.78;

    return MultiBlocListener(
      listeners: [
        BlocListener<StartupCubit, StartupState>(
          listener: (context, state) async {
            if (state is StartupStateSuccess<bool>) {
              if (!mounted) return;

              final isLoggedIn = state.data;
              if (isLoggedIn) {
                await _trackAppOpenForSession(context);
                await AppNavigator.completeStartup(isAuthenticated: true);
              } else {
                ToastMessageUtils.error('Unable to sign in. Please try again.');
              }
              return;
            }

            if (state is StartupError) {
              if (!mounted) return;
              ToastMessageUtils.error(state.message);
            }
          },
        ),
        BlocListener<VerifyOtpCubit, CommonState>(
          listener: (context, state) {
            if (state is CommonSuccess) {
              context.read<StartupCubit>().checkStartupSession();
            }
            if (state is CommonError) {
              ToastMessageUtils.error(state.message);
            }
          },
        ),
      ],
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: bottomInset),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxSheetHeight),
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: ThemeColors.pageBackGroundColor,
              // borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s20,
                  AppSpacing.s16,
                  AppSpacing.s20,
                  AppSpacing.s18,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.s10),
                    Text(
                      AppStrings.weJustSendSMS,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: ThemeColors.black,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    Text(
                      '${AppStrings.otpSentToPrefix}${widget.phoneNumber}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s24),
                    Center(
                      child: OtpCodeInput(
                        length: 6,
                        onChanged: (value) {
                          setState(() {
                            _otp = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s22),
                    SizedBox(
                      width: double.infinity,
                      child: BlocBuilder<StartupCubit, StartupState>(
                        builder: (context, startupState) {
                          return BlocBuilder<VerifyOtpCubit, CommonState>(
                            builder: (context, state) {
                              final isLoading =
                                  state is CommonLoading ||
                                  startupState is StartupLoading;
                              return AbsorbPointer(
                                absorbing: isLoading,
                                child: Opacity(
                                  opacity: isLoading ? 0.85 : 1,
                                  child: PrimaryButton(
                                    text: AppStrings.verifyAndSignIn,
                                    onPressed: () => _onVerifyPressed(context),
                                    isLoading: isLoading,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s22),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OtpResend(
                        initialSeconds: 60,
                        onResend: _onResendPressed,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
