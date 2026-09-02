import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data_portal_survey/common/constants/app_strings.dart';
import 'package:data_portal_survey/common/cubit/data_state.dart';
import 'package:data_portal_survey/common/utils/toast_message_utils.dart';
import 'package:data_portal_survey/common/storage/secure_storage.dart';
import 'package:data_portal_survey/features/auth/bloc/login_cubit.dart';
import 'package:data_portal_survey/features/auth/bloc/resend_otp_cubit.dart';
import 'package:data_portal_survey/features/auth/constants/auth_error_codes.dart';
import 'package:data_portal_survey/features/auth/resource/auth_repository.dart';
import 'package:data_portal_survey/features/engagement/resource/engagement_repository.dart';
import 'package:data_portal_survey/features/auth/ui/widget/auth_text_field.dart';
import 'package:data_portal_survey/features/auth/ui/widget/phone_number_field.dart';
import 'package:data_portal_survey/common/widgets/primary_button.dart';
import 'package:data_portal_survey/navigation/navigation.dart';
import 'package:data_portal_survey/common/theme/theme.dart';
import 'package:data_portal_survey/common/theme/app_spacing.dart';

/// Identifies which sign-in action the user initiated, so that while the
/// follow-up navigation is running we only show the spinner on the button
/// that was tapped (and disable the others) instead of all of them.
enum _LoginAction { none, signIn }

class LoginSheet extends StatefulWidget {
  final ValueChanged<bool>? onBusyChanged;

  const LoginSheet({super.key, this.onBusyChanged});

  @override
  State<LoginSheet> createState() => _LoginSheetState();
}

class _LoginSheetState extends State<LoginSheet> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = true;
  bool _obscurePassword = true;
  String _dialCode = '+977';
  _LoginAction _activeAction = _LoginAction.none;

  @override
  void initState() {
    super.initState();
    _loadRememberedPhone();
  }

  Future<void> _loadRememberedPhone() async {
    final storage = SecureStorage();
    final phone = await storage.getRememberedPhone();
    final dialCode = await storage.getRememberedDialCode();
    if (!mounted) return;

    if (phone != null && phone.isNotEmpty) {
      _phoneController.text = phone;
    }
    if (dialCode != null && dialCode.isNotEmpty && dialCode != _dialCode) {
      setState(() => _dialCode = dialCode);
    } else if (phone != null && phone.isNotEmpty) {
      setState(() {});
    }
  }

  Future<void> _persistRememberMe() async {
    final storage = SecureStorage();
    if (_rememberMe) {
      final digits = _phoneController.text
          .replaceAll(RegExp(r'[^0-9]'), '')
          .trim();
      if (digits.isEmpty) return;
      await storage.saveRememberedPhone(phone: digits, dialCode: _dialCode);
    } else {
      await storage.clearRememberedPhone();
    }
  }

  void _setActiveAction(_LoginAction action) {
    if (!mounted) return;
    setState(() => _activeAction = action);
    widget.onBusyChanged?.call(action != _LoginAction.none);
  }

  void _resetActiveAction() {
    if (!mounted || _activeAction == _LoginAction.none) return;
    setState(() => _activeAction = _LoginAction.none);
    widget.onBusyChanged?.call(false);
  }

  String _normalizedEmailOrPhone() {
    final rawDigits = _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final digits = rawDigits.trim();
    if (digits.isEmpty) return '';
    return '$_dialCode$digits';
  }

  String _displayPhoneNumber() {
    final rawDigits = _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final digits = rawDigits.trim();
    if (digits.isEmpty) return '';
    return '($_dialCode) $digits';
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

  /// After auth succeeds, go straight to the dashboard.
  /// Location / country / notification are already handled on splash.
  Future<void> _onLoginSuccess(BuildContext context) async {
    // Queue before navigation — stack clear dismisses any live SnackBar.
    ToastMessageUtils.success('Login successful');
    unawaited(_trackAppOpenForSession(context));
    await AppNavigator.completeStartup(isAuthenticated: true);
    if (mounted) _resetActiveAction();
    // Flush if dashboard hasn't already (or as a timed fallback).
    Future.delayed(const Duration(milliseconds: 500), () {
      ToastMessageUtils.success('Login successful');
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => LoginCubit(
            authRepository: RepositoryProvider.of<AuthRepository>(context),
          ),
        ),
        BlocProvider(
          create: (context) => ResendOtpCubit(
            authRepository: RepositoryProvider.of<AuthRepository>(context),
          ),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          // Password login success -> dashboard (permissions handled on splash).
          BlocListener<LoginCubit, CommonState>(
            listener: (context, state) async {
              if (state is CommonSuccess) {
                await _persistRememberMe();
                if (!context.mounted) return;
                await _onLoginSuccess(context);
                return;
              }
              if (state is! CommonError) return;

              _resetActiveAction();
              final code = state.code;
              if (code == AuthErrorCodes.phoneNotVerified ||
                  code == AuthErrorCodes.emailNotVerified) {
                final destination = _normalizedEmailOrPhone();
                if (destination.isEmpty) {
                  ToastMessageUtils.error(state.message);
                  return;
                }
                if (state.message.isNotEmpty) {
                  ToastMessageUtils.warning(state.message);
                }
                final resendCubit = context.read<ResendOtpCubit>();
                final display = _displayPhoneNumber().isNotEmpty
                    ? _displayPhoneNumber()
                    : destination;
                resendCubit.sendLoginOtp(emailOrPhone: destination);
                if (!mounted) return;
                await AppNavigator.toOtpVerification(display);
                return;
              }
              if (state.message.isNotEmpty) {
                ToastMessageUtils.error(state.message);
              }
            },
          ),
          // NOTE: OTP login flow is kept for future use but is not used now.
          // BlocListener<ResendOtpCubit, CommonState>(
          //   listener: (context, state) {
          //     if (state is CommonSuccess) {
          //       final display = _displayPhoneNumber();
          //       if (display.isEmpty) return;
          //       AppNavigator.toOtpVerification(display);
          //     }
          //     if (state is CommonError) {
          //       ToastMessageUtils.error(state.message);
          //     }
          //   },
          // ),
        ],
        child: Builder(
          builder: (context) {
            final isBusy = _activeAction != _LoginAction.none;
            final isSignInLoading = _activeAction == _LoginAction.signIn;

            return Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: ThemeColors.pageBackGroundColor,
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  physics: isBusy
                      ? const NeverScrollableScrollPhysics()
                      : const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.s22,
                    AppSpacing.s26,
                    AppSpacing.s22,
                    AppSpacing.s18,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Text(
                              AppStrings.welcomeBack,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: ThemeColors.black,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.s8),
                            Text(
                              AppStrings.pleaseEnterYourPhoneNumber,
                              style: TextStyle(
                                color: ThemeColors.lightTextColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s22),
                      const SizedBox(height: AppSpacing.s10),
                      PhoneNumberField(
                        key: ValueKey(_dialCode),
                        controller: _phoneController,
                        enabled: !isBusy,
                        initialDialCode: _dialCode,
                        onDialCodeChanged: (dialCode) {
                          _dialCode = dialCode;
                        },
                      ),
                      const SizedBox(height: AppSpacing.s18),
                      AuthTextField(
                        controller: _passwordController,
                        enabled: !isBusy,
                        hintText: AppStrings.passwordHint,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        suffix: GestureDetector(
                          onTap: isBusy
                              ? null
                              : () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                          child: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: ThemeColors.grey.withValues(alpha: 200),
                            size: 20,
                          ),
                        ),
                      ),
                      SizedBox(height: AppSpacing.s15),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: isBusy
                              ? null
                              : () {
                                  FocusScope.of(context).unfocus();
                                  AppNavigator.push(
                                    const ForgotPasswordRoute(),
                                  );
                                },
                          child: Text(
                            AppStrings.forgotPassword,
                            style: TextStyle(
                              color: isBusy
                                  ? ThemeColors.lightTextColor
                                  : ThemeColors.primaryColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s20),
                      Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: Checkbox(
                              value: _rememberMe,
                              onChanged: isBusy
                                  ? null
                                  : (bool? value) {
                                      setState(() {
                                        _rememberMe = value ?? false;
                                      });
                                    },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              activeColor: ThemeColors.primaryColor,
                              side: BorderSide(
                                color: ThemeColors.lightTextColor,
                                width: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s10),
                          const Text(
                            'Remember Me',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: ThemeColors.lightTextColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s18),
                      SizedBox(
                        width: double.infinity,
                        child: Opacity(
                          opacity: isSignInLoading ? 0.85 : (isBusy ? 0.5 : 1),
                          child: PrimaryButton(
                            isLoading: isSignInLoading,
                            isDisabled: isBusy && !isSignInLoading,
                            text: 'Sign In',
                            onPressed: isBusy
                                ? null
                                : () {
                                    final emailOrPhone =
                                        _normalizedEmailOrPhone();
                                    if (emailOrPhone.isEmpty) {
                                      ToastMessageUtils.warning(
                                        AppStrings.pleaseEnterYourPhoneNumber,
                                      );
                                      return;
                                    }
                                    final password = _passwordController.text;
                                    if (password.isEmpty) {
                                      ToastMessageUtils.warning(
                                        'Please enter your password',
                                      );
                                      return;
                                    }
                                    FocusScope.of(context).unfocus();
                                    _setActiveAction(_LoginAction.signIn);
                                    context.read<LoginCubit>().login(
                                      emailOrPhone: emailOrPhone,
                                      password: password,
                                    );
                                  },
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s18),
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${AppStrings.dontHaveAccount} ',
                              style: TextStyle(
                                color: ThemeColors.lightTextColor,
                                fontSize: 12.8,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            GestureDetector(
                              onTap: isBusy
                                  ? null
                                  : () {
                                      FocusScope.of(context).unfocus();
                                      AppNavigator.toSignup();
                                    },
                              child: Text(
                                AppStrings.signUp,
                                style: TextStyle(
                                  color: isBusy
                                      ? ThemeColors.lightTextColor
                                      : ThemeColors.primaryColor,
                                  fontSize: 12.8,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s16),
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
