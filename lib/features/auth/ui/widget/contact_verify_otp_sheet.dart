import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data_portal_survey/common/constants/app_strings.dart';
import 'package:data_portal_survey/common/cubit/data_state.dart';
import 'package:data_portal_survey/common/theme/app_spacing.dart';
import 'package:data_portal_survey/common/theme/theme_colors.dart';
import 'package:data_portal_survey/common/utils/toast_message_utils.dart';
import 'package:data_portal_survey/common/widgets/primary_button.dart';
import 'package:data_portal_survey/features/auth/bloc/contact_verify_cubit.dart';
import 'package:data_portal_survey/features/auth/ui/widget/otp_code_input.dart';
import 'package:data_portal_survey/features/auth/ui/widget/otp_resend.dart';

class ContactVerifyOtpSheet extends StatefulWidget {
  final ContactVerifyChannel channel;
  final String destination;

  const ContactVerifyOtpSheet({
    super.key,
    required this.channel,
    required this.destination,
  });

  @override
  State<ContactVerifyOtpSheet> createState() => _ContactVerifyOtpSheetState();
}

class _ContactVerifyOtpSheetState extends State<ContactVerifyOtpSheet> {
  String _otp = '';

  void _onVerify() {
    final otp = _otp.trim();
    if (otp.length != 6) {
      ToastMessageUtils.warning('Please enter 6-digit OTP');
      return;
    }
    context.read<ContactVerifyCubit>().verifyOtp(
      channel: widget.channel,
      token: otp,
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final bottomInset = media.viewInsets.bottom;
    // Stay within remaining space above the keyboard to avoid top overflow.
    final maxSheetHeight =
        (media.size.height - bottomInset - media.padding.top).clamp(
          280.0,
          media.size.height,
        );

    final isPhone = widget.channel == ContactVerifyChannel.phone;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxSheetHeight),
          child: Material(
            color: ThemeColors.pageBackGroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            clipBehavior: Clip.antiAlias,
            child: SafeArea(
              top: false,
              child: BlocConsumer<ContactVerifyCubit, CommonState>(
                listener: (context, state) {
                  if (state is CommonSuccess) {
                    ToastMessageUtils.success(
                      isPhone
                          ? 'Phone number verified'
                          : 'Email address verified',
                    );
                    Navigator.of(context).pop(true);
                  }
                  if (state is CommonError) {
                    ToastMessageUtils.error(state.message);
                  }
                  if (state is CommonNoData) {
                    ToastMessageUtils.success('OTP resent');
                  }
                },
                builder: (context, state) {
                  final isLoading = state is CommonLoading;
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final sheetWidth = constraints.maxWidth.isFinite
                          ? constraints.maxWidth
                          : MediaQuery.sizeOf(context).width;
                      final contentWidth = sheetWidth - (AppSpacing.s22 * 2);
                      return SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.s22,
                          AppSpacing.s24,
                          AppSpacing.s22,
                          AppSpacing.s18,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.enterVerificationCode,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: ThemeColors.black,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.s8),
                            Text(
                              'OTP sent to ${widget.destination}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: ThemeColors.lightTextColor,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.s22),
                            OtpCodeInput(
                              length: 6,
                              availableWidth: contentWidth,
                              onChanged: (value) =>
                                  setState(() => _otp = value),
                            ),
                            const SizedBox(height: AppSpacing.s16),
                            OtpResend(
                              onResend: isLoading
                                  ? null
                                  : () => context
                                        .read<ContactVerifyCubit>()
                                        .resendOtp(channel: widget.channel),
                            ),
                            const SizedBox(height: AppSpacing.s22),
                            SizedBox(
                              width: double.infinity,
                              child: PrimaryButton(
                                text: AppStrings.verify,
                                isLoading: isLoading,
                                onPressed: isLoading ? null : _onVerify,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
