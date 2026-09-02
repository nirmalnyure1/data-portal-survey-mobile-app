import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data_portal_survey/common/constants/app_strings.dart';
import 'package:data_portal_survey/common/cubit/data_state.dart';
import 'package:data_portal_survey/common/utils/form_validator.dart';
import 'package:data_portal_survey/common/utils/toast_message_utils.dart';
import 'package:data_portal_survey/features/auth/bloc/forget_password_cubit.dart';
import 'package:data_portal_survey/features/auth/resource/auth_repository.dart';
import 'package:data_portal_survey/features/auth/ui/widget/auth_divider.dart';
import 'package:data_portal_survey/features/auth/ui/widget/auth_text_field.dart';
import 'package:data_portal_survey/features/auth/ui/widget/phone_number_field.dart';
import 'package:data_portal_survey/features/auth/utils/auth_contact_utils.dart';
import 'package:data_portal_survey/common/widgets/primary_button.dart';
import 'package:data_portal_survey/navigation/navigation.dart';
import 'package:data_portal_survey/common/theme/theme.dart';
import 'package:data_portal_survey/common/theme/app_spacing.dart';

class ForgotPasswordRequestSheet extends StatefulWidget {
  const ForgotPasswordRequestSheet({super.key});

  @override
  State<ForgotPasswordRequestSheet> createState() =>
      _ForgotPasswordRequestSheetState();
}

class _ForgotPasswordRequestSheetState
    extends State<ForgotPasswordRequestSheet> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String _dialCode = '+977';
  String? _submittedEmailOrPhone;

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String? _resolveEmailOrPhone() {
    final email = _emailController.text.trim();
    if (email.isNotEmpty) {
      final emailError = FormValidator.emailRequired(email);
      if (emailError != null) {
        ToastMessageUtils.warning(emailError);
        return null;
      }
      return email;
    }

    final rawDigits = FormValidator.digitsOnly(_phoneController.text);
    if (rawDigits.isEmpty) {
      ToastMessageUtils.warning(AppStrings.enterEmailOrPhone);
      return null;
    }

    return AuthContactUtils.normalizeEmailOrPhone(
      value: rawDigits,
      dialCode: _dialCode,
    );
  }

  void _onContinuePressed(BuildContext context) {
    final emailOrPhone = _resolveEmailOrPhone();
    if (emailOrPhone == null) return;

    FocusScope.of(context).unfocus();
    _submittedEmailOrPhone = emailOrPhone;
    context.read<ForgotPasswordCubit>().requestForgotPassword(
      emailOrPhone: emailOrPhone,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final maxSheetHeight = screenHeight * 0.78;

    return BlocProvider(
      create: (context) => ForgotPasswordCubit(
        authRepository: RepositoryProvider.of<AuthRepository>(context),
      ),
      child: BlocListener<ForgotPasswordCubit, CommonState>(
        listener: (context, state) {
          if (state is CommonSuccess) {
            final emailOrPhone = _submittedEmailOrPhone;
            if (emailOrPhone == null) return;
            AppNavigator.push(
              ForgotPasswordOtpRoute(emailOrPhone: emailOrPhone),
            );
          }
          if (state is CommonError) {
            ToastMessageUtils.error(state.message);
          }
        },
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
                top: false,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.s22,
                    AppSpacing.s26,
                    AppSpacing.s22,
                    AppSpacing.s18,
                  ),
                  child: Column(
                    // mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Text(
                              AppStrings.forgotPasswordTitle,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: ThemeColors.black,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.s8),
                            Text(
                              AppStrings.forgotPasswordSubtitle,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: ThemeColors.lightTextColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s22),
                      PhoneNumberField(
                        controller: _phoneController,
                        initialDialCode: '+977',
                        onDialCodeChanged: (dialCode) {
                          _dialCode = dialCode;
                        },
                      ),
                      const SizedBox(height: AppSpacing.s18),
                      // const AuthDivider(text: AppStrings.orEnterEmail),
                      // const SizedBox(height: AppSpacing.s18),
                      // AuthTextField(
                      //   controller: _emailController,
                      //   hintText: AppStrings.emailHint,
                      //   keyboardType: TextInputType.emailAddress,
                      //   textInputAction: TextInputAction.done,
                      // ),
                      const SizedBox(height: AppSpacing.s22),
                      SizedBox(
                        width: double.infinity,
                        child: BlocBuilder<ForgotPasswordCubit, CommonState>(
                          builder: (context, state) {
                            final isLoading = state is CommonLoading;
                            return AbsorbPointer(
                              absorbing: isLoading,
                              child: Opacity(
                                opacity: isLoading ? 0.85 : 1,
                                child: PrimaryButton(
                                  text: AppStrings.continueText,
                                  isLoading: isLoading,
                                  onPressed: () => _onContinuePressed(context),
                                ),
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
      ),
    );
  }
}
