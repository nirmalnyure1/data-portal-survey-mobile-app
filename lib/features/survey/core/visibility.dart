import 'package:data_portal_survey/features/survey/model/survey_form_models.dart';

bool _evalCondition(VisibilityCondition c, String answer) {
  final v = answer;
  final target = c.value ?? '';
  switch (c.operator) {
    case 'equals':
      return v == target;
    case 'not_equals':
      return v != target;
    case 'contains':
      return v.contains(target);
    case 'not_contains':
      return !v.contains(target);
    case 'gt':
      return (num.tryParse(v) ?? double.nan) > (num.tryParse(target) ?? double.nan);
    case 'gte':
      return (num.tryParse(v) ?? double.nan) >= (num.tryParse(target) ?? double.nan);
    case 'lt':
      return (num.tryParse(v) ?? double.nan) < (num.tryParse(target) ?? double.nan);
    case 'lte':
      return (num.tryParse(v) ?? double.nan) <= (num.tryParse(target) ?? double.nan);
    case 'is_empty':
      return v.trim().isEmpty;
    case 'is_not_empty':
      return v.trim().isNotEmpty;
    default:
      return true;
  }
}

bool evaluateVisibility(VisibilityRules? rules, Map<String, String> answers) {
  if (rules == null || rules.conditions.isEmpty) return true;
  final results =
      rules.conditions.map((c) => _evalCondition(c, answers[c.fieldId] ?? '')).toList();
  return rules.logic == 'and' ? results.every((r) => r) : results.any((r) => r);
}
