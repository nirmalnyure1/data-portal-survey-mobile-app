import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:data_portal_survey/features/survey/constants/survey_theme.dart';
import 'package:data_portal_survey/features/survey/core/encoding.dart';
import 'package:data_portal_survey/features/survey/model/survey_form_models.dart';

const double kSurveyControlHeight = AppMetrics.controlHeight;
const double kSurveyControlRadius = AppMetrics.controlRadius;

InputDecoration surveyDecoration(
  BuildContext context, {
  String? hint,
  String? error,
}) {
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(kSurveyControlRadius),
    borderSide: const BorderSide(color: SurveyTheme.outline, width: 1.5),
  );
  return InputDecoration(
    hintText: hint,
    errorText: error,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: border,
    enabledBorder: border,
    focusedBorder: border.copyWith(
      borderSide: const BorderSide(color: SurveyTheme.primary, width: 2),
    ),
    errorBorder: border.copyWith(
      borderSide: const BorderSide(color: AppColors.destructive, width: 1.5),
    ),
  );
}

class SurveyFieldInput extends StatelessWidget {
  const SurveyFieldInput({
    super.key,
    required this.field,
    required this.value,
    required this.onChanged,
    required this.locale,
    this.error,
    this.onUploadFile,
  });

  final SurveyField field;
  final String? value;
  final ValueChanged<String> onChanged;
  final String locale;
  final String? error;
  final Future<String> Function(String path, String filename)? onUploadFile;

  String get v => value ?? '';
  bool get readOnly => field.isReadonly;

  @override
  Widget build(BuildContext context) {
    switch (field.fieldType) {
      case 'textarea':
        return TextFormField(
          key: ValueKey('${field.id}-$v'),
          initialValue: v,
          onChanged: onChanged,
          readOnly: readOnly,
          minLines: 3,
          maxLines: 8,
          maxLength: field.maxLength,
          decoration: surveyDecoration(
            context,
            hint: field.placeholder?.resolve(locale),
            error: error,
          ),
        );
      case 'number':
        final isDecimal = (field.numberType ?? 'int').contains('float');
        return TextFormField(
          key: ValueKey('${field.id}-$v'),
          initialValue: v,
          onChanged: onChanged,
          readOnly: readOnly,
          keyboardType: TextInputType.numberWithOptions(
            decimal: isDecimal,
            signed: true,
          ),
          decoration: surveyDecoration(context, error: error),
        );
      case 'select':
        return _SelectBox(
          field: field,
          value: v,
          onChanged: onChanged,
          locale: locale,
          readOnly: readOnly,
          error: error,
        );
      case 'multiselect':
        return _MultiSelectBox(
          field: field,
          value: v,
          onChanged: onChanged,
          locale: locale,
          readOnly: readOnly,
          error: error,
        );
      case 'yes_no':
        return _YesNo(
          value: v,
          onChanged: onChanged,
          readOnly: readOnly,
          error: error,
        );
      case 'date':
        return _AdDateInput(
          value: v,
          onChanged: onChanged,
          readOnly: readOnly,
          error: error,
        );
      case 'time':
        return _TimeInput(
          value: v,
          onChanged: onChanged,
          readOnly: readOnly,
          error: error,
        );
      case 'datetime':
        return _DateTimeInput(
          value: v,
          onChanged: onChanged,
          readOnly: readOnly,
          error: error,
        );
      case 'email':
      case 'phone':
      case 'url':
        return TextFormField(
          key: ValueKey('${field.id}-$v'),
          initialValue: v,
          onChanged: onChanged,
          readOnly: readOnly,
          maxLength: field.maxLength,
          keyboardType: switch (field.fieldType) {
            'email' => TextInputType.emailAddress,
            'phone' => TextInputType.phone,
            _ => TextInputType.url,
          },
          decoration: surveyDecoration(
            context,
            hint: field.placeholder?.resolve(locale),
            error: error,
          ),
        );
      case 'rating':
        return _RatingField(
          value: v,
          onChanged: onChanged,
          readOnly: readOnly,
          error: error,
          min: (field.minValue ?? 1).toInt(),
          max: (field.maxValue ?? 5).toInt(),
        );
      case 'range':
        if (field.isRangeSelection) {
          return _DoubleRangeField(
            value: v,
            onChanged: onChanged,
            readOnly: readOnly,
            error: error,
            min: (field.minValue ?? 0).toDouble(),
            max: (field.maxValue ?? 100).toDouble(),
            step: (field.stepValue ?? 1).toDouble(),
          );
        }
        return _RangeField(
          value: v,
          onChanged: onChanged,
          readOnly: readOnly,
          error: error,
          min: (field.minValue ?? 0).toDouble(),
          max: (field.maxValue ?? 100).toDouble(),
          step: (field.stepValue ?? 1).toDouble(),
        );
      case 'location':
        return _LocationField(
          value: v,
          onChanged: onChanged,
          readOnly: readOnly,
          error: error,
        );
      case 'file':
        return _FileField(
          field: field,
          value: v,
          onChanged: onChanged,
          onUpload: onUploadFile,
          error: error,
          readOnly: readOnly,
        );
      default:
        return TextFormField(
          key: ValueKey('${field.id}-$v'),
          initialValue: v,
          onChanged: onChanged,
          readOnly: readOnly,
          maxLength: field.maxLength,
          decoration: surveyDecoration(
            context,
            hint: field.placeholder?.resolve(locale),
            error: error,
          ),
        );
    }
  }
}

class _SelectBox extends StatelessWidget {
  const _SelectBox({
    required this.field,
    required this.value,
    required this.onChanged,
    required this.locale,
    required this.readOnly,
    this.error,
  });

  final SurveyField field;
  final String value;
  final ValueChanged<String> onChanged;
  final String locale;
  final bool readOnly;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final items = field.options
        .map(
          (o) => DropdownMenuItem(
            value: o.optionValue,
            child: Text(o.label(locale)),
          ),
        )
        .toList();
    final current =
        field.options.any((o) => o.optionValue == value) ? value : null;
    return DropdownButtonFormField<String>(
      value: current,
      items: items,
      onChanged: readOnly ? null : (v) => onChanged(v ?? ''),
      isExpanded: true,
      hint: const Text('Select…'),
      decoration: surveyDecoration(context, error: error),
    );
  }
}

class _MultiSelectBox extends StatefulWidget {
  const _MultiSelectBox({
    required this.field,
    required this.value,
    required this.onChanged,
    required this.locale,
    required this.readOnly,
    this.error,
  });

  final SurveyField field;
  final String value;
  final ValueChanged<String> onChanged;
  final String locale;
  final bool readOnly;
  final String? error;

  @override
  State<_MultiSelectBox> createState() => _MultiSelectBoxState();
}

class _MultiSelectBoxState extends State<_MultiSelectBox> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final selected = parseMulti(widget.value);
    final opts = widget.field.options.where(
      (o) =>
          _query.isEmpty ||
          o.label(widget.locale).toLowerCase().contains(_query.toLowerCase()),
    );

    void toggle(String v) {
      final next = List<String>.from(selected);
      if (next.contains(v)) {
        next.remove(v);
      } else {
        next.add(v);
      }
      widget.onChanged(next.join(','));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.field.options.length > 8)
          TextField(
            onChanged: (q) => setState(() => _query = q),
            decoration: surveyDecoration(context, hint: 'Search…').copyWith(
              prefixIcon: const Icon(Icons.search, size: 20),
            ),
          ),
        if (widget.field.options.length > 8) const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final o in opts)
              FilterChip(
                label: Text(o.label(widget.locale)),
                selected: selected.contains(o.optionValue),
                onSelected: widget.readOnly ? null : (_) => toggle(o.optionValue),
              ),
          ],
        ),
        if (selected.isNotEmpty && !widget.readOnly)
          TextButton(
            onPressed: () => widget.onChanged(''),
            child: const Text('Clear all'),
          ),
        if (widget.error != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              widget.error!,
              style: const TextStyle(color: AppColors.destructive, fontSize: 12),
            ),
          ),
      ],
    );
  }
}

class _YesNo extends StatelessWidget {
  const _YesNo({
    required this.value,
    required this.onChanged,
    required this.readOnly,
    this.error,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final bool readOnly;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final v = value.trim();
    final isYes = ['Yes', 'true', 'yes', '1'].contains(v);
    final isNo = ['No', 'false', 'no', '0'].contains(v);

    Widget half(String answer, bool active) => Expanded(
          child: SizedBox(
            height: kSurveyControlHeight,
            child: OutlinedButton(
              onPressed: readOnly ? null : () => onChanged(answer),
              style: OutlinedButton.styleFrom(
                backgroundColor:
                    active ? SurveyTheme.primary.withValues(alpha: 0.10) : null,
                foregroundColor: active ? SurveyTheme.primary : SurveyTheme.onSurface,
                side: BorderSide(
                  color: active ? SurveyTheme.primary : SurveyTheme.outline,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(kSurveyControlRadius),
                ),
              ),
              child: Text(
                answer,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [half('Yes', isYes), const SizedBox(width: 10), half('No', isNo)]),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              error!,
              style: const TextStyle(color: AppColors.destructive, fontSize: 12),
            ),
          ),
      ],
    );
  }
}

class _AdDateInput extends StatelessWidget {
  const _AdDateInput({
    required this.value,
    required this.onChanged,
    required this.readOnly,
    this.error,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final bool readOnly;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final parsed = DateTime.tryParse(value);
    return InkWell(
      onTap: readOnly
          ? null
          : () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: parsed ?? DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
              );
              if (picked != null) onChanged(fmtAdDate(picked));
            },
      child: InputDecorator(
        decoration: surveyDecoration(context, error: error).copyWith(
          suffixIcon: const Icon(Icons.calendar_today, size: 18),
        ),
        child: Text(value.isEmpty ? 'Select date' : value),
      ),
    );
  }
}

class _TimeInput extends StatelessWidget {
  const _TimeInput({
    required this.value,
    required this.onChanged,
    required this.readOnly,
    this.error,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final bool readOnly;
  final String? error;

  @override
  Widget build(BuildContext context) {
    TimeOfDay initial = TimeOfDay.now();
    final parts = value.split(':');
    if (parts.length == 2) {
      initial = TimeOfDay(
        hour: int.tryParse(parts[0]) ?? initial.hour,
        minute: int.tryParse(parts[1]) ?? initial.minute,
      );
    }
    return InkWell(
      onTap: readOnly
          ? null
          : () async {
              final picked = await showTimePicker(context: context, initialTime: initial);
              if (picked != null) {
                onChanged(
                  '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
                );
              }
            },
      child: InputDecorator(
        decoration: surveyDecoration(context, error: error).copyWith(
          suffixIcon: const Icon(Icons.schedule, size: 18),
        ),
        child: Text(value.isEmpty ? 'Select time' : value),
      ),
    );
  }
}

class _DateTimeInput extends StatelessWidget {
  const _DateTimeInput({
    required this.value,
    required this.onChanged,
    required this.readOnly,
    this.error,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final bool readOnly;
  final String? error;

  @override
  Widget build(BuildContext context) {
    DateTime initial = DateTime.now();
    if (value.contains('T')) {
      initial = DateTime.tryParse(value) ?? initial;
    }
    return InkWell(
      onTap: readOnly
          ? null
          : () async {
              final date = await showDatePicker(
                context: context,
                initialDate: initial,
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
              );
              if (date == null || !context.mounted) return;
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(initial),
              );
              if (time == null) return;
              onChanged(
                '${fmtAdDate(date)}T${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
              );
            },
      child: InputDecorator(
        decoration: surveyDecoration(context, error: error).copyWith(
          suffixIcon: const Icon(Icons.event, size: 18),
        ),
        child: Text(value.isEmpty ? 'Select date & time' : value),
      ),
    );
  }
}

class _RatingField extends StatelessWidget {
  const _RatingField({
    required this.value,
    required this.onChanged,
    required this.readOnly,
    required this.min,
    required this.max,
    this.error,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final bool readOnly;
  final int min;
  final int max;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final current = int.tryParse(value) ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (var i = min; i <= max; i++)
              IconButton(
                onPressed: readOnly ? null : () => onChanged('$i'),
                icon: Icon(
                  i <= current ? Icons.star : Icons.star_border,
                  color: SurveyTheme.primary,
                ),
              ),
          ],
        ),
        if (error != null)
          Text(error!, style: const TextStyle(color: AppColors.destructive, fontSize: 12)),
      ],
    );
  }
}

class _RangeField extends StatelessWidget {
  const _RangeField({
    required this.value,
    required this.onChanged,
    required this.readOnly,
    required this.min,
    required this.max,
    required this.step,
    this.error,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final bool readOnly;
  final double min;
  final double max;
  final double step;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final current = double.tryParse(value) ?? min;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Slider(
          value: current.clamp(min, max),
          min: min,
          max: max,
          divisions: step > 0 ? ((max - min) / step).round() : null,
          onChanged: readOnly
              ? null
              : (v) => onChanged('${snapToStep(v, min, step)}'),
        ),
        Text('${snapToStep(current, min, step)}'),
        if (error != null)
          Text(error!, style: const TextStyle(color: AppColors.destructive, fontSize: 12)),
      ],
    );
  }
}

class _DoubleRangeField extends StatefulWidget {
  const _DoubleRangeField({
    required this.value,
    required this.onChanged,
    required this.readOnly,
    required this.min,
    required this.max,
    required this.step,
    this.error,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final bool readOnly;
  final double min;
  final double max;
  final double step;
  final String? error;

  @override
  State<_DoubleRangeField> createState() => _DoubleRangeFieldState();
}

class _DoubleRangeFieldState extends State<_DoubleRangeField> {
  late RangeValues _range;

  @override
  void initState() {
    super.initState();
    _syncFromValue();
  }

  @override
  void didUpdateWidget(covariant _DoubleRangeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) _syncFromValue();
  }

  void _syncFromValue() {
    final parsed = RangeSelection.parse(widget.value);
    _range = RangeValues(
      (parsed?.min ?? widget.min).toDouble(),
      (parsed?.max ?? widget.max).toDouble(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RangeSlider(
          values: _range,
          min: widget.min,
          max: widget.max,
          divisions: widget.step > 0 ? ((widget.max - widget.min) / widget.step).round() : null,
          onChanged: widget.readOnly
              ? null
              : (v) {
                  setState(() => _range = v);
                  widget.onChanged(
                    RangeSelection(
                      snapToStep(v.start, widget.min, widget.step),
                      snapToStep(v.end, widget.min, widget.step),
                    ).serialize(),
                  );
                },
        ),
        Text('${snapToStep(_range.start, widget.min, widget.step)} – '
            '${snapToStep(_range.end, widget.min, widget.step)}'),
        if (widget.error != null)
          Text(
            widget.error!,
            style: const TextStyle(color: AppColors.destructive, fontSize: 12),
          ),
      ],
    );
  }
}

class _LocationField extends StatelessWidget {
  const _LocationField({
    required this.value,
    required this.onChanged,
    required this.readOnly,
    this.error,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final bool readOnly;
  final String? error;

  Future<void> _captureGps() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }
    final position = await Geolocator.getCurrentPosition();
    onChanged(LocationValue(position.latitude, position.longitude).serialize());
  }

  @override
  Widget build(BuildContext context) {
    final loc = LocationValue.parse(value);
    final label = loc == null
        ? 'No location selected'
        : '${loc.lat.toStringAsFixed(6)}, ${loc.lng.toStringAsFixed(6)}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InputDecorator(
          decoration: surveyDecoration(context, error: error),
          child: Text(label),
        ),
        if (!readOnly) ...[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _captureGps,
            icon: const Icon(Icons.gps_fixed, size: 18),
            label: const Text('Use GPS'),
          ),
        ],
      ],
    );
  }
}

class _FileField extends StatelessWidget {
  const _FileField({
    required this.field,
    required this.value,
    required this.onChanged,
    required this.readOnly,
    this.onUpload,
    this.error,
  });

  final SurveyField field;
  final String value;
  final ValueChanged<String> onChanged;
  final bool readOnly;
  final Future<String> Function(String path, String filename)? onUpload;
  final String? error;

  Future<void> _pick(BuildContext context) async {
    if (onUpload == null) return;
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    final url = await onUpload!(file.path, file.name);
    if (field.allowMultiple) {
      final existing = parseFileUrls(value);
      existing.add(url);
      onChanged(jsonEncode(existing));
    } else {
      onChanged(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final urls = parseFileUrls(value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (urls.isNotEmpty)
          ...urls.map(
            (u) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(u, maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
          ),
        if (!readOnly)
          OutlinedButton.icon(
            onPressed: () => _pick(context),
            icon: const Icon(Icons.upload_file, size: 18),
            label: Text(field.allowMultiple ? 'Add file' : 'Choose file'),
          ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(error!, style: const TextStyle(color: AppColors.destructive, fontSize: 12)),
          ),
      ],
    );
  }
}
