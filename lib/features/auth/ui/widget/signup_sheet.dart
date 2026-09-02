import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data_portal_survey/common/constants/app_strings.dart';
import 'package:data_portal_survey/common/cubit/data_state.dart';
import 'package:data_portal_survey/common/utils/toast_message_utils.dart';
import 'package:data_portal_survey/common/utils/form_validator.dart';
import 'package:data_portal_survey/features/auth/bloc/signup_cubit.dart';
import 'package:data_portal_survey/features/auth/resource/auth_repository.dart';
import 'package:data_portal_survey/features/auth/ui/widget/auth_labeled_field.dart';
import 'package:data_portal_survey/features/auth/ui/widget/auth_text_field.dart';
import 'package:data_portal_survey/features/auth/ui/widget/password_requirements_hint.dart';
import 'package:data_portal_survey/features/auth/ui/widget/phone_number_field.dart';
import 'package:data_portal_survey/common/widgets/primary_button.dart';
import 'package:data_portal_survey/navigation/app_navigator.dart';
import 'package:data_portal_survey/common/theme/theme.dart';
import 'package:data_portal_survey/common/theme/app_spacing.dart';
import 'package:data_portal_survey/navigation/app_router.dart';

class SignupSheet extends StatefulWidget {
  const SignupSheet({super.key});

  @override
  State<SignupSheet> createState() => _SignupSheetState();
}

class _SignupSheetState extends State<SignupSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _referralController = TextEditingController();
  bool _agreedToTerms = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _dialCode = '+977';

  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _referralController.dispose();
    super.dispose();
  }

  void _onContinuePressed(BuildContext context) {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      setState(() {
        _autovalidateMode = AutovalidateMode.onUserInteraction;
      });
      return;
    }

    final rawDigits = FormValidator.digitsOnly(_phoneController.text);
    final fullName = _nameController.text.trim();
    final email = _emailController.text.trim();
    final referralCode = _referralController.text.trim();

    FocusScope.of(context).unfocus();

    context.read<SignupCubit>().userRegister(
      phone: "$_dialCode$rawDigits",
      fullName: fullName,
      email: email,
      password: _passwordController.text,
      referralCode: referralCode.isEmpty ? null : referralCode,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return SignupCubit(
          authRepository: RepositoryProvider.of<AuthRepository>(context),
        );
      },
      child: BlocListener<SignupCubit, CommonState>(
        listener: (context, state) {
          if (state is CommonSuccess) {
            final rawDigits = _phoneController.text
                .replaceAll(RegExp(r'[^0-9]'), '')
                .trim();
            if (rawDigits.isEmpty) return;

            AppNavigator.toOtpVerification('($_dialCode) $rawDigits');
          }

          if (state is CommonError) {
            final message = state.message.trim();
            if (message.isEmpty) return;
            ToastMessageUtils.error(message);
          }
        },
        child: Form(
          key: _formKey,
          autovalidateMode: _autovalidateMode,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.s10),
              AuthLabeledField(
                required: true,
                label: AppStrings.fullName,
                field: AuthTextField(
                  controller: _nameController,
                  hintText: AppStrings.fullNameHint,
                  validator: FormValidator.fullName,
                ),
              ),
              const SizedBox(height: AppSpacing.s18),
              AuthLabeledField(
                required: true,
                label: AppStrings.phoneNumber,
                field: PhoneNumberField(
                  controller: _phoneController,
                  initialDialCode: '+977',
                  hintText: '970-45***********',
                  validator: FormValidator.phoneNumber,
                  autovalidateMode: _autovalidateMode,
                  onDialCodeChanged: (dialCode) {
                    _dialCode = dialCode;
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.s18),
              AuthLabeledField(
                label: AppStrings.emailAddress,
                field: AuthTextField(
                  controller: _emailController,
                  hintText: AppStrings.emailHint,
                  keyboardType: TextInputType.emailAddress,
                  validator: FormValidator.emailRequired,
                ),
              ),
              const SizedBox(height: AppSpacing.s18),
              AuthLabeledField(
                required: true,
                label: AppStrings.password,
                helper: const PasswordRequirementsHint(),
                field: AuthTextField(
                  controller: _passwordController,
                  hintText: AppStrings.passwordHint,
                  obscureText: _obscurePassword,
                  validator: FormValidator.password,
                  onChanged: (_) {
                    if (_autovalidateMode ==
                        AutovalidateMode.onUserInteraction) {
                      _formKey.currentState?.validate();
                    }
                  },
                  suffix: GestureDetector(
                    onTap: () {
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
              ),
              const SizedBox(height: AppSpacing.s18),
              AuthLabeledField(
                required: true,
                label: AppStrings.confirmPassword,
                field: AuthTextField(
                  controller: _confirmPasswordController,
                  hintText: AppStrings.confirmPasswordHint,
                  obscureText: _obscureConfirmPassword,
                  validator: (value) => FormValidator.confirmPassword(
                    value,
                    _passwordController.text,
                  ),
                  suffix: GestureDetector(
                    onTap: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                    child: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: ThemeColors.grey.withValues(alpha: 200),
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s18),
              AuthLabeledField(
                label: AppStrings.referralCodeOptional,
                field: AuthTextField(
                  controller: _referralController,
                  hintText: AppStrings.referralHint,
                ),
              ),
              const SizedBox(height: AppSpacing.s18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: AppSpacing.s20,
                    height: AppSpacing.s20,
                    child: Checkbox(
                      value: _agreedToTerms,
                      onChanged: (value) {
                        setState(() {
                          _agreedToTerms = value ?? false;
                        });
                      },
                      activeColor: ThemeColors.primaryColor,
                      checkColor: ThemeColors.pageBackGroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      side: BorderSide(
                        color: ThemeColors.lightTextColor,
                        width: 1.2,
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s10),
                  Expanded(
                    child: Wrap(
                      children: [
                        Text(
                          "I Agree to the ",
                          style: TextStyle(
                            color: ThemeColors.lightTextColor,
                            fontSize: 13.2,
                            fontWeight: FontWeight.w500,
                            height: 1.35,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            context.pushRoute(const TermsConditionsRoute());
                          },
                          child: Text(
                            "Terms and Conditions",
                            style: TextStyle(
                              color: ThemeColors.primaryColor,
                              fontSize: 13.2,
                              fontWeight: FontWeight.w500,
                              height: 1.35,
                            ),
                          ),
                        ),
                        Text(
                          " and ",
                          style: TextStyle(
                            color: ThemeColors.lightTextColor,
                            fontSize: 13.2,
                            fontWeight: FontWeight.w500,
                            height: 1.35,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            context.pushRoute(const PrivacyPolicyRoute());
                          },
                          child: Text(
                            "Privacy Policy.",
                            style: TextStyle(
                              color: ThemeColors.primaryColor,
                              fontSize: 13.2,
                              fontWeight: FontWeight.w500,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s22),
              SizedBox(
                width: double.infinity,
                child: BlocBuilder<SignupCubit, CommonState>(
                  builder: (context, state) {
                    final isLoading = state is CommonLoading;
                    return AbsorbPointer(
                      absorbing: isLoading,
                      child: Opacity(
                        opacity: isLoading ? 0.85 : 1,
                        child: PrimaryButton(
                          isDisabled: !_agreedToTerms,
                          text: AppStrings.continueText,
                          onPressed: () => _onContinuePressed(context),
                          isLoading: isLoading,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.s14),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${AppStrings.alreadyHaveAccount} ',
                      style: TextStyle(
                        color: ThemeColors.grey.withValues(alpha: 210),
                        fontSize: 12.8,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        context.pop();
                      },
                      child: const Text(
                        AppStrings.signIn,
                        style: TextStyle(
                          color: ThemeColors.primaryColor,
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
  }
}
