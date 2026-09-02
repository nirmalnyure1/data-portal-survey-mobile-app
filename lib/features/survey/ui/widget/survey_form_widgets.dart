import 'package:flutter/material.dart';
import 'package:data_portal_survey/features/survey/constants/survey_theme.dart';

class SurveyFormField extends StatelessWidget {
  const SurveyFormField({
    super.key,
    required this.label,
    this.required = false,
    required this.child,
    this.errorText,
    this.hint,
  });

  final String label;
  final bool required;
  final Widget child;
  final String? errorText;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: SurveyTheme.onSurface,
              ),
              children: required
                  ? [
                      const TextSpan(
                        text: ' *',
                        style: TextStyle(color: SurveyTheme.secondary),
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(height: 7),
          child,
          if (hint != null) ...[
            const SizedBox(height: 6),
            Text(
              hint!,
              style: const TextStyle(
                fontSize: 12,
                color: SurveyTheme.onSurfaceVariant,
              ),
            ),
          ],
          if (errorText != null) ...[
            const SizedBox(height: 6),
            Text(
              errorText!,
              style: const TextStyle(fontSize: 12.5, color: SurveyTheme.secondary),
            ),
          ],
        ],
      ),
    );
  }
}

class SurveyTextField extends StatelessWidget {
  const SurveyTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.placeholder,
    this.keyboardType,
    this.maxLines = 1,
    this.hasError = false,
    this.readOnly = false,
  });

  final TextEditingController? controller;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final String? placeholder;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool hasError;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      onChanged: onChanged,
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly,
      style: const TextStyle(fontSize: 16, color: SurveyTheme.onSurface),
      decoration: InputDecoration(
        hintText: placeholder,
        filled: true,
        fillColor: SurveyTheme.surfaceLowest,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 14,
          vertical: maxLines > 1 ? 12 : 0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SurveyTheme.radiusSm),
          borderSide: BorderSide(
            color: hasError ? SurveyTheme.errorBorder : SurveyTheme.defaultBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SurveyTheme.radiusSm),
          borderSide: BorderSide(
            color: hasError ? SurveyTheme.errorBorder : SurveyTheme.defaultBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SurveyTheme.radiusSm),
          borderSide: BorderSide(
            color: hasError ? SurveyTheme.errorBorder : SurveyTheme.primary,
          ),
        ),
      ),
    );
  }
}

class SurveyChoiceButton extends StatelessWidget {
  const SurveyChoiceButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? SurveyTheme.primarySoft : SurveyTheme.surfaceLowest,
            borderRadius: BorderRadius.circular(SurveyTheme.radiusSm),
            border: Border.all(
              color: selected ? SurveyTheme.primary : SurveyTheme.defaultBorder,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: selected ? SurveyTheme.primary : SurveyTheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class SurveyLangPill extends StatelessWidget {
  const SurveyLangPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.small = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool small;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: small ? 10 : 11,
          vertical: small ? 5 : 6,
        ),
        decoration: BoxDecoration(
          color: selected ? SurveyTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: small ? 11.5 : 12,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : SurveyTheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class SurveyCard extends StatelessWidget {
  const SurveyCard({
    super.key,
    required this.child,
    this.tinted = false,
    this.title,
    this.trailing,
  });

  final Widget child;
  final bool tinted;
  final String? title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tinted ? SurveyTheme.surfaceContainer : SurveyTheme.surfaceLowest,
        borderRadius: BorderRadius.circular(SurveyTheme.radius),
        border: tinted
            ? null
            : Border.all(color: SurveyTheme.outlineVariant),
        boxShadow: tinted
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Row(
              children: [
                Expanded(
                  child: Text(
                    title!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.04,
                      color: SurveyTheme.onSurfaceVariant,
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          if (title != null) const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
