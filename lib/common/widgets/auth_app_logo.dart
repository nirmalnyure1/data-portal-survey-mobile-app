import 'package:flutter/material.dart';
import 'package:data_portal_survey/common/constants/constant_assets.dart';
import 'package:data_portal_survey/common/theme/theme_colors.dart';

class AuthAppLogo extends StatelessWidget {
  final double expandedHeight;
  final double collapsedHeight;
  final bool? isKeyboardOpen;

  const AuthAppLogo({
    super.key,
    this.expandedHeight = 180,
    this.collapsedHeight = 120,
    this.isKeyboardOpen,
  });

  @override
  Widget build(BuildContext context) {
    // Detect if the keyboard is open by checking viewInsets, unless explicitly passed in
    final keyboardOpen =
        isKeyboardOpen ?? MediaQuery.viewInsetsOf(context).bottom > 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      // This makes the red top section shrink when the keyboard opens!
      height: keyboardOpen ? collapsedHeight : expandedHeight,
      decoration: const BoxDecoration(color: ThemeColors.primaryColor),
      // Use Center to guarantee the logo stays perfectly in the middle
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Image.asset(
            Assets.appIcon,
            height: 72,
            width: 72,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
