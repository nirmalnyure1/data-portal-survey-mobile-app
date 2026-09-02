import 'package:data_portal_survey/features/survey/core/repeat.dart';
import 'package:data_portal_survey/features/survey/model/survey_form_models.dart';

List<Map<String, dynamic>> buildSubmitPayload(
  List<SurveySection> sections,
  Map<String, String> answers,
) {
  final items = <Map<String, dynamic>>[];

  for (final section in sections) {
    if (section.isRepeatable) {
      final ids = section.fields.map((f) => f.id).toList();
      final instances = <int>{};
      for (final key in answers.keys) {
        final parsed = parseRepeatKey(key);
        if (parsed != null && ids.contains(parsed.fieldId)) {
          instances.add(parsed.instanceIndex);
        }
      }
      final sorted = (instances.isEmpty ? {0} : instances).toList()..sort();
      for (final idx in sorted) {
        for (final id in ids) {
          items.add({
            'surveyFieldId': id,
            'answerValue': answers[repeatKey(id, idx)] ?? '',
            'repeatGroupId': section.id,
            'repeatInstanceIndex': idx,
          });
        }
      }
      continue;
    }

    final split = groupRepeatFields(section.fields);

    for (final f in split.normal) {
      items.add({'surveyFieldId': f.id, 'answerValue': answers[f.id] ?? ''});
    }

    split.groups.forEach((groupId, groupFields) {
      final ids = groupFields.map((f) => f.id).toList();
      final instances = <int>{};
      for (final key in answers.keys) {
        final parsed = parseRepeatKey(key);
        if (parsed != null && ids.contains(parsed.fieldId)) {
          instances.add(parsed.instanceIndex);
        }
      }
      final sorted = (instances.isEmpty ? {0} : instances).toList()..sort();
      for (final idx in sorted) {
        for (final id in ids) {
          items.add({
            'surveyFieldId': id,
            'answerValue': answers[repeatKey(id, idx)] ?? '',
            'repeatGroupId': groupId,
            'repeatInstanceIndex': idx,
          });
        }
      }
    });
  }

  return items;
}
