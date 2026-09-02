import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data_portal_survey/common/constants/app_strings.dart';
import 'package:data_portal_survey/common/cubit/data_state.dart';
import 'package:data_portal_survey/common/utils/form_validator.dart';
import 'package:data_portal_survey/common/utils/toast_message_utils.dart';
import 'package:data_portal_survey/features/auth/bloc/reset_password_cubit.dart';
import 'package:data_portal_survey/features/auth/resource/auth_repository.dart';
import 'package:data_portal_survey/features/auth/ui/widget/auth_labeled_field.dart';
import 'package:data_portal_survey/features/auth/ui/widget/auth_text_field.dart';
import 'package:data_portal_survey/features/auth/ui/widget/password_requirements_hint.dart';
import 'package:data_portal_survey/common/widgets/primary_button.dart';
import 'package:data_portal_survey/navigation/navigation.dart';
import 'package:data_portal_survey/common/theme/theme.dart';
import 'package:data_portal_survey/common/theme/app_spacing.dart';

class ResetPasswordSheet extends StatefulWidget {
  final String emailOrPhone;
  final String token;

  const ResetPasswordSheet({
    super.key,
    required this.emailOrPhone,
    required this.token,
  });

  @override
  State<ResetPasswordSheet> createState() => _ResetPasswordSheetState();
}

class _ResetPasswordSheetState extends State<ResetPasswordSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSubmit(BuildContext context) {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      setState(() {
        _autovalidateMode = AutovalidateMode.onUserInteraction;
      });
      return;
    }

    FocusScope.of(context).unfocus();
    context.read<ResetPasswordCubit>().resetPassword(
      emailOrPhone: widget.emailOrPhone,
      token: widget.token,
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final maxSheetHeight = screenHeight * 0.72;

    return BlocProvider(
      create: (context) => ResetPasswordCubit(
        authRepository: RepositoryProvider.of<AuthRepository>(context),
      ),
      child: BlocListener<ResetPasswordCubit, CommonState>(
        listener: (context, state) {
          if (state is CommonSuccess) {
            ToastMessageUtils.show(AppStrings.resetPasswordSuccess);
            AppNavigator.replace(const LoginRoute());
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
                borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
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
                  child: Form(
                    key: _formKey,
                    autovalidateMode: _autovalidateMode,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Column(
                            children: [
                              Text(
                                AppStrings.resetPasswordTitle,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: ThemeColors.black,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.s8),
                              Text(
                                AppStrings.resetPasswordSubtitle,
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
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
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
                        const SizedBox(height: AppSpacing.s22),
                        SizedBox(
                          width: double.infinity,
                          child: BlocBuilder<ResetPasswordCubit, CommonState>(
                            builder: (context, state) {
                              final isLoading = state is CommonLoading;
                              return AbsorbPointer(
                                absorbing: isLoading,
                                child: Opacity(
                                  opacity: isLoading ? 0.85 : 1,
                                  child: PrimaryButton(
                                    text: AppStrings.continueText,
                                    isLoading: isLoading,
                                    onPressed: () => _onSubmit(context),
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
      ),
    );
  }
}
