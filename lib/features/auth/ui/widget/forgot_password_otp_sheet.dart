import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data_portal_survey/common/constants/app_strings.dart';
import 'package:data_portal_survey/common/cubit/data_state.dart';
import 'package:data_portal_survey/common/utils/toast_message_utils.dart';
import 'package:data_portal_survey/features/auth/bloc/forget_password_cubit.dart';
import 'package:data_portal_survey/features/auth/bloc/verify_password_token_cubit.dart';
import 'package:data_portal_survey/features/auth/ui/widget/otp_code_input.dart';
import 'package:data_portal_survey/features/auth/ui/widget/otp_resend.dart';
import 'package:data_portal_survey/common/widgets/primary_button.dart';
import 'package:data_portal_survey/navigation/navigation.dart';
import 'package:data_portal_survey/common/theme/theme.dart';
import 'package:data_portal_survey/common/theme/app_spacing.dart';

class ForgotPasswordOtpSheet extends StatefulWidget {
  final String emailOrPhone;

  const ForgotPasswordOtpSheet({super.key, required this.emailOrPhone});

  @override
  State<ForgotPasswordOtpSheet> createState() => _ForgotPasswordOtpSheetState();
}

class _ForgotPasswordOtpSheetState extends State<ForgotPasswordOtpSheet> {
  String _otp = '';

  void _onVerifyPressed(BuildContext context) {
    final token = _otp.trim();
    if (token.length != 6) {
      ToastMessageUtils.warning('Please enter 6-digit OTP');
      return;
    }

    context.read<VerifyPasswordTokenCubit>().verifyToken(
      emailOrPhone: widget.emailOrPhone,
      token: token,
    );
  }

  void _onResendPressed() {
    context.read<ForgotPasswordCubit>().requestForgotPassword(
      emailOrPhone: widget.emailOrPhone,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final maxSheetHeight = screenHeight * 0.78;

    return MultiBlocListener(
      listeners: [
        BlocListener<VerifyPasswordTokenCubit, CommonState>(
          listener: (context, state) {
            if (state is CommonSuccess) {
              AppNavigator.push(
                ResetPasswordRoute(
                  emailOrPhone: widget.emailOrPhone,
                  token: _otp.trim(),
                ),
              );
            }
            if (state is CommonError) {
              ToastMessageUtils.error(state.message);
            }
          },
        ),
        BlocListener<ForgotPasswordCubit, CommonState>(
          listener: (context, state) {
            if (state is CommonSuccess) {
              ToastMessageUtils.show('Reset code sent again');
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
                      '${AppStrings.otpSentToPrefix}${widget.emailOrPhone}',
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
                      child: BlocBuilder<VerifyPasswordTokenCubit, CommonState>(
                        builder: (context, state) {
                          final isLoading = state is CommonLoading;
                          return AbsorbPointer(
                            absorbing: isLoading,
                            child: Opacity(
                              opacity: isLoading ? 0.85 : 1,
                              child: PrimaryButton(
                                text: AppStrings.verify,
                                onPressed: () => _onVerifyPressed(context),
                                isLoading: isLoading,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s22),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: BlocBuilder<ForgotPasswordCubit, CommonState>(
                        builder: (context, state) {
                          final isResending = state is CommonLoading;
                          return AbsorbPointer(
                            absorbing: isResending,
                            child: OtpResend(
                              initialSeconds: 60,
                              onResend: _onResendPressed,
                            ),
                          );
                        },
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
