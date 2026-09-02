import 'package:flutter/material.dart';
import 'package:data_portal_survey/common/theme/app_spacing.dart';
import 'package:data_portal_survey/common/theme/theme_colors.dart';

/// Shows a verified badge or a Verify action below a contact field.
class ContactVerifyAction extends StatelessWidget {
  final bool verified;
  final bool canVerify;
  final bool busy;
  final VoidCallback onVerify;

  const ContactVerifyAction({
    super.key,
    required this.verified,
    required this.canVerify,
    required this.onVerify,
    this.busy = false,
  });

  @override
  Widget build(BuildContext context) {
    if (verified) {
      return const Padding(
        padding: EdgeInsets.only(top: AppSpacing.s8),
        child: Row(
          children: [
            Icon(Icons.verified_rounded, size: 16, color: ThemeColors.green),
            SizedBox(width: 6),
            Text(
              'Verified',
              style: TextStyle(
                color: ThemeColors.green,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (!canVerify) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.s8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextButton(
          onPressed: busy ? null : onVerify,
          style: TextButton.styleFrom(
            foregroundColor: ThemeColors.primaryColor,
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Verify',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
