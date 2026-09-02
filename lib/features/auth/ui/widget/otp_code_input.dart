import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:data_portal_survey/common/theme/app_spacing.dart';
import 'package:data_portal_survey/common/theme/theme.dart';

class OtpCodeInput extends StatelessWidget {
  final int length;
  final ValueChanged<String> onChanged;
  final double? availableWidth;

  const OtpCodeInput({
    super.key,
    required this.length,
    required this.onChanged,
    this.availableWidth,
  });

  static const double _spacing = AppSpacing.s12;
  static const double _maxCellSize = 48;
  static const double _horizontalPadding = AppSpacing.s20 * 2;

  @override
  Widget build(BuildContext context) {
    // Avoid LayoutBuilder here — SliverFillRemaining asks for intrinsic sizes
    // and LayoutBuilder cannot provide them.
    final width = availableWidth ??
        (MediaQuery.sizeOf(context).width - _horizontalPadding);
    final rawSize = (width - (_spacing * (length - 1))) / length;
    final cellSize = rawSize.clamp(28.0, _maxCellSize).toDouble();

    return MaterialPinField(
      length: length,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: onChanged,
      mainAxisAlignment: MainAxisAlignment.center,
      theme: MaterialPinTheme(
        shape: MaterialPinShape.outlined,
        cellSize: Size(cellSize, cellSize),
        spacing: _spacing,
        borderRadius: const BorderRadius.all(Radius.circular(14)),
        borderWidth: 1,
        focusedBorderWidth: 1.6,
        fillColor: ThemeColors.pageBackGroundColor,
        focusedFillColor: ThemeColors.pageBackGroundColor,
        filledFillColor: ThemeColors.pageBackGroundColor,
        borderColor: ThemeColors.lightGrey,
        focusedBorderColor: ThemeColors.primaryColor,
        filledBorderColor: ThemeColors.lightGrey,
        entryAnimation: MaterialPinAnimation.none,
        textStyle: const TextStyle(
          color: ThemeColors.black,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
