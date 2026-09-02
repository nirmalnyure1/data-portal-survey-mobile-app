import 'package:data_portal_survey/features/survey/core/encoding.dart';
import 'package:data_portal_survey/features/survey/core/repeat.dart';
import 'package:data_portal_survey/features/survey/core/visibility.dart';
import 'package:data_portal_survey/features/survey/model/survey_form_models.dart';

const _textLike = {'text', 'textarea', 'phone', 'email', 'url'};

bool isAnswerEmpty(SurveyField f, String? v) {
  if (f.fieldType == 'location') return LocationValue.parse(v) == null;
  return (v ?? '').trim().isEmpty;
}

String? validateAnswer(SurveyField field, String? value) {
  final label = field.label.en.isEmpty ? 'This field' : field.label.en;
  final v = value ?? '';

  if (field.isRequired && isAnswerEmpty(field, v)) return '"$label" is required';
  if (isAnswerEmpty(field, v)) return null;

  final custom = field.validationMessage?.en.trim();
  String msg(String fallback) =>
      (custom != null && custom.isNotEmpty) ? custom : fallback;

  switch (field.fieldType) {
    case 'number':
    case 'rating':
    case 'range':
      if (field.fieldType == 'range' && field.isRangeSelection) {
        final sel = RangeSelection.parse(v);
        if (sel == null) {
          return msg(
            '"$label" — drag both sliders to pick a lower and an upper limit',
          );
        }
        if (field.minValue != null && sel.min < field.minValue!) {
          return msg(
            '"$label" lower limit is too low — the minimum allowed is ${field.minValue}',
          );
        }
        if (field.maxValue != null && sel.max > field.maxValue!) {
          return msg(
            '"$label" upper limit is too high — the maximum allowed is ${field.maxValue}',
          );
        }
        return null;
      }
      final n = num.tryParse(v);
      if (n == null) return msg('"$label" must be a number');
      if (field.minValue != null && n < field.minValue!) {
        return msg('"$label" is too low — the minimum allowed is ${field.minValue}');
      }
      if (field.maxValue != null && n > field.maxValue!) {
        return msg('"$label" is too high — the maximum allowed is ${field.maxValue}');
      }
      if (field.fieldType == 'number') {
        final nt = field.numberType ?? 'int';
        final isDecimal = nt == 'float' ||
            nt == 'positive_float' ||
            nt == 'negative_float';
        if (!isDecimal && n != n.roundToDouble()) {
          return msg('"$label" must be a whole number (e.g. 5, not 5.5)');
        }
        if ((nt == 'positive_int' || nt == 'positive_float') && n < 0) {
          return msg('"$label" cannot be negative — enter 0 or a positive number');
        }
        if ((nt == 'negative_int' || nt == 'negative_float') && n > 0) {
          return msg('"$label" cannot be positive — enter 0 or a negative number');
        }
      }
      return null;

    default:
      if (_textLike.contains(field.fieldType)) {
        if (field.minLength != null && v.length < field.minLength!) {
          return msg('"$label" must be at least ${field.minLength} characters');
        }
        if (field.maxLength != null && v.length > field.maxLength!) {
          return msg('"$label" must be at most ${field.maxLength} characters');
        }
        if (field.pattern != null && field.pattern!.isNotEmpty) {
          try {
            if (!RegExp(field.pattern!).hasMatch(v)) {
              return msg('"$label" does not match the required format');
            }
          } catch (_) {}
        }
      }
      return null;
  }
}

class SurveyValidationError {
  final String message;
  final String fieldId;
  final int? instanceIndex;
  final String? groupId;
  const SurveyValidationError(
    this.message,
    this.fieldId, {
    this.instanceIndex,
    this.groupId,
  });

  String get errorKey =>
      instanceIndex == null ? fieldId : '$fieldId::$instanceIndex';
}

List<SurveyValidationError> validateSection(
  SurveySection section,
  Map<String, String> answers,
  Map<String, int> repeatCounts,
  Map<String, int> groupRepeatCounts,
) {
  final errors = <SurveyValidationError>[];
  final title = section.title.en.isEmpty ? 'Section' : section.title.en;

  if (section.isRepeatable) {
    final count = repeatCounts[section.id] ?? section.defaultInstanceCount;
    final ids = section.fields.map((f) => f.id).toList();
    for (var i = 0; i < count; i++) {
      final scoped = instanceScopedAnswers(answers, ids, i);
      for (final f in section.fields) {
        if (!evaluateVisibility(f.visibilityRules, scoped)) continue;
        final err = validateAnswer(f, answers[repeatKey(f.id, i)]);
        if (err != null) {
          errors.add(
            SurveyValidationError(
              '$err in $title.${i + 1}',
              f.id,
              instanceIndex: i,
            ),
          );
        }
      }
    }
    return errors;
  }

  final split = groupRepeatFields(section.fields);

  for (final f in split.normal) {
    if (!evaluateVisibility(f.visibilityRules, answers)) continue;
    final err = validateAnswer(f, answers[f.id]);
    if (err != null) errors.add(SurveyValidationError(err, f.id));
  }

  split.groups.forEach((groupId, groupFields) {
    final count = groupRepeatCounts[groupId] ?? 1;
    final ids = groupFields.map((f) => f.id).toList();
    for (var i = 0; i < count; i++) {
      final scoped = instanceScopedAnswers(answers, ids, i);
      for (final f in groupFields) {
        if (!evaluateVisibility(f.visibilityRules, scoped)) continue;
        final err = validateAnswer(f, answers[repeatKey(f.id, i)]);
        if (err != null) {
          errors.add(
            SurveyValidationError(
              '$err in $title.${i + 1}',
              f.id,
              instanceIndex: i,
              groupId: groupId,
            ),
          );
        }
      }
    }
  });

  return errors;
}
