import 'package:data_portal_survey/features/survey/model/survey_form_models.dart';

const keySep = '::';

String repeatKey(String fieldId, int instanceIndex) => '$fieldId$keySep$instanceIndex';

bool isRepeatKey(String key) => key.contains(keySep);

({String fieldId, int instanceIndex})? parseRepeatKey(String key) {
  final i = key.lastIndexOf(keySep);
  if (i < 0) return null;
  return (
    fieldId: key.substring(0, i),
    instanceIndex: int.tryParse(key.substring(i + keySep.length)) ?? 0,
  );
}

({List<SurveyField> normal, Map<String, List<SurveyField>> groups}) groupRepeatFields(
  List<SurveyField> fields,
) {
  final normal = <SurveyField>[];
  final groups = <String, List<SurveyField>>{};
  for (final f in fields) {
    if (f.repeatGroupId != null) {
      groups.putIfAbsent(f.repeatGroupId!, () => []).add(f);
    } else {
      normal.add(f);
    }
  }
  return (normal: normal, groups: groups);
}

Map<String, String> instanceScopedAnswers(
  Map<String, String> answers,
  List<String> fieldIds,
  int instanceIndex,
) {
  final scoped = Map<String, String>.from(answers);
  for (final id in fieldIds) {
    scoped[id] = answers[repeatKey(id, instanceIndex)] ?? '';
  }
  return scoped;
}

Map<String, String> removeInstanceAnswers(
  Map<String, String> answers,
  List<String> fieldIds,
  int removedIndex,
  int previousCount,
) {
  final next = Map<String, String>.from(answers);
  for (final id in fieldIds) {
    for (var i = removedIndex; i < previousCount - 1; i++) {
      final from = repeatKey(id, i + 1);
      final to = repeatKey(id, i);
      if (next.containsKey(from)) {
        next[to] = next[from]!;
      } else {
        next.remove(to);
      }
    }
    next.remove(repeatKey(id, previousCount - 1));
  }
  return next;
}

int nextActiveInstance(int active, int removedIndex, int nextCount) {
  if (nextCount <= 0) return 0;
  final shifted = active > removedIndex ? active - 1 : active;
  return shifted.clamp(0, nextCount - 1);
}
