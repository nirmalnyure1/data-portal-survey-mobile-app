class LocalizedString {
  final String en;
  final String? ne;
  const LocalizedString(this.en, [this.ne]);

  factory LocalizedString.from(dynamic v) {
    if (v == null) return const LocalizedString('');
    if (v is String) return LocalizedString(v.trim());
    final map = v as Map<String, dynamic>;
    return LocalizedString(
      (map['en'] as String? ?? '').trim(),
      (map['ne'] as String?)?.trim(),
    );
  }

  String resolve(String locale) =>
      (locale == 'ne' && (ne?.isNotEmpty ?? false)) ? ne! : en;
}

class VisibilityCondition {
  final String fieldId;
  final String operator;
  final String? value;
  const VisibilityCondition(this.fieldId, this.operator, this.value);

  factory VisibilityCondition.fromJson(Map<String, dynamic> j) =>
      VisibilityCondition(
        j['fieldId'] as String,
        j['operator'] as String,
        j['value'] as String?,
      );
}

class VisibilityRules {
  final String logic;
  final List<VisibilityCondition> conditions;
  const VisibilityRules(this.logic, this.conditions);

  factory VisibilityRules.fromJson(Map<String, dynamic> j) => VisibilityRules(
        j['logic'] as String? ?? 'and',
        ((j['conditions'] as List?) ?? [])
            .map((c) => VisibilityCondition.fromJson(c as Map<String, dynamic>))
            .toList(),
      );
}

class SurveyFieldOption {
  final String id;
  final LocalizedString optionLabel;
  final String optionValue;
  final int displayOrder;
  const SurveyFieldOption(
    this.id,
    this.optionLabel,
    this.optionValue,
    this.displayOrder,
  );

  factory SurveyFieldOption.fromJson(Map<String, dynamic> j) => SurveyFieldOption(
        j['id'] as String,
        LocalizedString.from(j['optionLabel']),
        j['optionValue'] as String,
        (j['displayOrder'] as num?)?.toInt() ?? 0,
      );

  String label(String locale) {
    final l = optionLabel.resolve(locale);
    return l.isNotEmpty ? l : optionValue;
  }
}

class SurveyField {
  final String id;
  final String? sectionId;
  final LocalizedString label;
  final String fieldType;
  final LocalizedString? placeholder;
  final LocalizedString? helperText;
  final bool isRequired;
  final bool isReadonly;
  final String? defaultValue;
  final int displayOrder;
  final List<SurveyFieldOption> options;
  final String? numberType;
  final String? calendarType;
  final num? minValue;
  final num? maxValue;
  final int? minLength;
  final int? maxLength;
  final String? pattern;
  final LocalizedString? validationMessage;
  final VisibilityRules? visibilityRules;
  final int? maxFileSize;
  final String? allowedExtensions;
  final bool allowMultiple;
  final int? maxFiles;
  final num? stepValue;
  final bool isRangeSelection;
  final String? repeatGroupId;

  const SurveyField({
    required this.id,
    this.sectionId,
    required this.label,
    required this.fieldType,
    this.placeholder,
    this.helperText,
    required this.isRequired,
    required this.isReadonly,
    this.defaultValue,
    required this.displayOrder,
    required this.options,
    this.numberType,
    this.calendarType,
    this.minValue,
    this.maxValue,
    this.minLength,
    this.maxLength,
    this.pattern,
    this.validationMessage,
    this.visibilityRules,
    this.maxFileSize,
    this.allowedExtensions,
    required this.allowMultiple,
    this.maxFiles,
    this.stepValue,
    required this.isRangeSelection,
    this.repeatGroupId,
  });

  factory SurveyField.fromJson(Map<String, dynamic> j) {
    final options = (((j['options'] as List?) ?? [])
          .map((o) => SurveyFieldOption.fromJson(o as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder)));
    return SurveyField(
      id: j['id'] as String,
      sectionId: j['sectionId'] as String?,
      label: LocalizedString.from(j['label']),
      fieldType: j['fieldType'] as String,
      placeholder:
          j['placeholder'] == null ? null : LocalizedString.from(j['placeholder']),
      helperText:
          j['helperText'] == null ? null : LocalizedString.from(j['helperText']),
      isRequired: j['isRequired'] == true,
      isReadonly: j['isReadonly'] == true,
      defaultValue: j['defaultValue'] as String?,
      displayOrder: (j['displayOrder'] as num?)?.toInt() ?? 0,
      options: options,
      numberType: j['numberType'] as String?,
      calendarType: j['calendarType'] as String?,
      minValue: j['minValue'] as num?,
      maxValue: j['maxValue'] as num?,
      minLength: (j['minLength'] as num?)?.toInt(),
      maxLength: (j['maxLength'] as num?)?.toInt(),
      pattern: j['pattern'] as String?,
      validationMessage: j['validationMessage'] == null
          ? null
          : LocalizedString.from(j['validationMessage']),
      visibilityRules: j['visibilityRules'] == null
          ? null
          : VisibilityRules.fromJson(j['visibilityRules'] as Map<String, dynamic>),
      maxFileSize: (j['maxFileSize'] as num?)?.toInt(),
      allowedExtensions: j['allowedExtensions'] as String?,
      allowMultiple: j['allowMultiple'] == true,
      maxFiles: (j['maxFiles'] as num?)?.toInt(),
      stepValue: j['stepValue'] as num?,
      isRangeSelection: j['isRangeSelection'] == true,
      repeatGroupId: j['repeatGroupId'] as String?,
    );
  }
}

class SurveySection {
  final String id;
  final LocalizedString title;
  final LocalizedString? description;
  final int displayOrder;
  final List<SurveyField> fields;
  final bool isRepeatable;
  final String? triggerFieldId;
  final int? minInstances;
  final int? maxInstances;

  const SurveySection({
    required this.id,
    required this.title,
    this.description,
    required this.displayOrder,
    required this.fields,
    required this.isRepeatable,
    this.triggerFieldId,
    this.minInstances,
    this.maxInstances,
  });

  factory SurveySection.fromJson(Map<String, dynamic> j) {
    final fields = (((j['fields'] as List?) ?? [])
          .map((f) => SurveyField.fromJson(f as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder)));
    return SurveySection(
      id: j['id'] as String,
      title: LocalizedString.from(j['title']),
      description:
          j['description'] == null ? null : LocalizedString.from(j['description']),
      displayOrder: (j['displayOrder'] as num?)?.toInt() ?? 0,
      fields: fields,
      isRepeatable: j['isRepeatable'] == true,
      triggerFieldId: j['triggerFieldId'] as String?,
      minInstances: (j['minInstances'] as num?)?.toInt(),
      maxInstances: (j['maxInstances'] as num?)?.toInt(),
    );
  }

  int get defaultInstanceCount => isRepeatable
      ? (minInstances != null && minInstances! > 1 ? minInstances! : 1)
      : 0;
}

class SurveyForm {
  final String id;
  final LocalizedString title;
  final LocalizedString? description;
  final List<SurveySection> sections;

  const SurveyForm({
    required this.id,
    required this.title,
    this.description,
    required this.sections,
  });

  factory SurveyForm.fromJson(Map<String, dynamic> j) {
    final rawSections = (j['sections'] as List?) ?? [];
    List<SurveySection> sections;
    if (rawSections.isNotEmpty) {
      sections = rawSections
          .map((s) => SurveySection.fromJson(s as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    } else {
      final fields = (((j['fields'] as List?) ?? [])
            .map((f) => SurveyField.fromJson(f as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder)));
      sections = fields.isEmpty
          ? []
          : [
              SurveySection(
                id: '__legacy',
                title: const LocalizedString('Questions'),
                displayOrder: 0,
                fields: fields,
                isRepeatable: false,
              ),
            ];
    }
    return SurveyForm(
      id: j['id'] as String,
      title: LocalizedString.from(j['title']),
      description:
          j['description'] == null ? null : LocalizedString.from(j['description']),
      sections: sections,
    );
  }

  List<SurveyField> get allFields => sections.expand((s) => s.fields).toList();
}

class SurveyFormSummary {
  final String id;
  final LocalizedString title;
  final LocalizedString? description;

  const SurveyFormSummary({
    required this.id,
    required this.title,
    this.description,
  });

  factory SurveyFormSummary.fromJson(Map<String, dynamic> j) => SurveyFormSummary(
        id: j['id'] as String,
        title: LocalizedString.from(j['title']),
        description:
            j['description'] == null ? null : LocalizedString.from(j['description']),
      );
}
