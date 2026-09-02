import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:data_portal_survey/common/theme/theme.dart';
import 'package:data_portal_survey/common/theme/app_spacing.dart';

class PhoneNumberField extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onDialCodeChanged;
  final String initialDialCode;
  final String hintText;
  final bool enabled;
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  const PhoneNumberField({
    super.key,
    required this.controller,
    this.onDialCodeChanged,
    this.initialDialCode = '+977',
    this.hintText = '970-45**********',
    this.enabled = true,
    this.validator,
    this.autovalidateMode,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  @override
  State<PhoneNumberField> createState() => _PhoneNumberFieldState();
}

class _PhoneNumberFieldState extends State<PhoneNumberField> {
  late final FocusNode _focusNode;
  late _PhoneCountry _selectedCountry;

  static const List<_PhoneCountry> _countries = [
    _PhoneCountry(name: 'Nepal', dialCode: '+977', flagEmoji: '🇳🇵'),
    _PhoneCountry(name: 'India', dialCode: '+91', flagEmoji: '🇮🇳'),
  ];

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_onFocusChanged);
    _selectedCountry = _countries.firstWhere(
      (c) => c.dialCode == widget.initialDialCode,
      orElse: () => _countries.first,
    );
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    super.dispose();
  }

  void _onFocusChanged() => setState(() {});

  void _onCountryChanged(_PhoneCountry country) {
    if (_selectedCountry == country) return;
    setState(() {
      _selectedCountry = country;
    });
    widget.onDialCodeChanged?.call(country.dialCode);
  }

  Widget _buildCountryDropdown() {
    final textStyle = TextStyle(
      color: ThemeColors.grey.withValues(alpha: 210),
      fontWeight: FontWeight.w600,
      fontSize: 15,
    );

    Future<void> showCountryPicker() async {
      await showCupertinoModalPopup<void>(
        context: context,
        builder: (context) {
          return CupertinoActionSheet(
            title: const Text('Select Country'),
            actions: _countries
                .map(
                  (c) => CupertinoActionSheetAction(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _onCountryChanged(c);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(c.flagEmoji, style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: AppSpacing.s10),
                        Text(
                          c.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: ThemeColors.black,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s10),
                        Text(c.dialCode, style: textStyle),
                      ],
                    ),
                  ),
                )
                .toList(),
            cancelButton: CupertinoActionSheetAction(
              onPressed: () => Navigator.of(context).pop(),
              isDefaultAction: true,
              child: const Text('Cancel'),
            ),
          );
        },
      );
    }

    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.s14,
        right: AppSpacing.s6,
      ),
      child: GestureDetector(
        onTap: widget.enabled ? showCountryPicker : null,
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _selectedCountry.flagEmoji,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: AppSpacing.s6),
            Text(_selectedCountry.dialCode, style: textStyle),
            const SizedBox(width: AppSpacing.s4),
            Icon(
              CupertinoIcons.chevron_down,
              size: 14,
              color: ThemeColors.grey.withValues(alpha: 210),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      keyboardType: TextInputType.phone,
      enabled: widget.enabled,
      validator: widget.validator,
      autovalidateMode: widget.autovalidateMode,
      textInputAction: widget.textInputAction ?? TextInputAction.done,
      onFieldSubmitted: widget.onFieldSubmitted,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: ThemeColors.black,
      ),
      decoration: InputDecoration(
        prefixIcon: _buildCountryDropdown(),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        errorStyle: const TextStyle(
          color: ThemeColors.primaryColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s18,
          vertical: AppSpacing.s14,
        ),
        filled: true,
        fillColor: ThemeColors.pageBackGroundColor,
        enabledBorder: OutlineInputBorder(
          borderRadius: AppShapes.radiusPill,
          borderSide: const BorderSide(color: ThemeColors.lightGrey, width: 1),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: AppShapes.radiusPill,
          borderSide: const BorderSide(color: ThemeColors.lightGrey, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppShapes.radiusPill,
          borderSide: const BorderSide(
            color: ThemeColors.primaryColor,
            width: 1.4,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppShapes.radiusPill,
          borderSide: const BorderSide(
            color: ThemeColors.primaryColor,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppShapes.radiusPill,
          borderSide: const BorderSide(
            color: ThemeColors.primaryColor,
            width: 1.4,
          ),
        ),
        hintText: widget.hintText,
        alignLabelWithHint: true,
        hintStyle: TextStyle(
          color: ThemeColors.lightTextColor,
          fontWeight: FontWeight.w300,
          fontSize: 15,
        ),
      ),
    );
  }
}

class _PhoneCountry {
  final String name;
  final String dialCode;
  final String flagEmoji;

  const _PhoneCountry({
    required this.name,
    required this.dialCode,
    required this.flagEmoji,
  });
}
