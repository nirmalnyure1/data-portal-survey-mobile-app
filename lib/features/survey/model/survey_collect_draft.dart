import 'dart:convert';

class SurveyCollectDraft {
  final String formId;
  final String locale;
  final int step;
  final bool submitted;
  final String? responseId;
  final Map<String, String> answers;
  final Map<String, int> repeatCounts;
  final Map<String, int> repeatActive;
  final Map<String, int> groupRepeatCounts;
  final Map<String, int> groupRepeatActive;
  final int? draftSavedAt;

  const SurveyCollectDraft({
    required this.formId,
    this.locale = 'en',
    this.step = 0,
    this.submitted = false,
    this.responseId,
    this.answers = const {},
    this.repeatCounts = const {},
    this.repeatActive = const {},
    this.groupRepeatCounts = const {},
    this.groupRepeatActive = const {},
    this.draftSavedAt,
  });

  SurveyCollectDraft copyWith({
    String? locale,
    int? step,
    bool? submitted,
    String? responseId,
    Map<String, String>? answers,
    Map<String, int>? repeatCounts,
    Map<String, int>? repeatActive,
    Map<String, int>? groupRepeatCounts,
    Map<String, int>? groupRepeatActive,
    int? draftSavedAt,
    bool clearResponseId = false,
  }) {
    return SurveyCollectDraft(
      formId: formId,
      locale: locale ?? this.locale,
      step: step ?? this.step,
      submitted: submitted ?? this.submitted,
      responseId: clearResponseId ? null : responseId ?? this.responseId,
      answers: answers ?? this.answers,
      repeatCounts: repeatCounts ?? this.repeatCounts,
      repeatActive: repeatActive ?? this.repeatActive,
      groupRepeatCounts: groupRepeatCounts ?? this.groupRepeatCounts,
      groupRepeatActive: groupRepeatActive ?? this.groupRepeatActive,
      draftSavedAt: draftSavedAt ?? this.draftSavedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'formId': formId,
        'locale': locale,
        'step': step,
        'submitted': submitted,
        'responseId': responseId,
        'answers': answers,
        'repeatCounts': repeatCounts.map((k, v) => MapEntry(k, v)),
        'repeatActive': repeatActive.map((k, v) => MapEntry(k, v)),
        'groupRepeatCounts': groupRepeatCounts.map((k, v) => MapEntry(k, v)),
        'groupRepeatActive': groupRepeatActive.map((k, v) => MapEntry(k, v)),
        'draftSavedAt': draftSavedAt,
      };

  factory SurveyCollectDraft.fromJson(Map<String, dynamic> json) {
    Map<String, int> intMap(dynamic raw) {
      if (raw is! Map) return {};
      return raw.map(
        (k, v) => MapEntry(k.toString(), (v as num?)?.toInt() ?? 0),
      );
    }

    final answersRaw = json['answers'];
    final answers = <String, String>{};
    if (answersRaw is Map) {
      answersRaw.forEach((k, v) => answers[k.toString()] = v?.toString() ?? '');
    }

    return SurveyCollectDraft(
      formId: json['formId'] as String,
      locale: json['locale'] as String? ?? 'en',
      step: json['step'] as int? ?? 0,
      submitted: json['submitted'] as bool? ?? false,
      responseId: json['responseId'] as String?,
      answers: answers,
      repeatCounts: intMap(json['repeatCounts']),
      repeatActive: intMap(json['repeatActive']),
      groupRepeatCounts: intMap(json['groupRepeatCounts']),
      groupRepeatActive: intMap(json['groupRepeatActive']),
      draftSavedAt: json['draftSavedAt'] as int?,
    );
  }

  String encode() => jsonEncode(toJson());

  factory SurveyCollectDraft.decode(String raw) =>
      SurveyCollectDraft.fromJson(jsonDecode(raw) as Map<String, dynamic>);
}
