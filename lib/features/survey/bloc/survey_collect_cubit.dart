import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data_portal_survey/features/survey/bloc/survey_collect_state.dart';
import 'package:data_portal_survey/features/survey/constants/survey_strings.dart';
import 'package:data_portal_survey/features/survey/core/payload.dart';
import 'package:data_portal_survey/features/survey/core/repeat.dart';
import 'package:data_portal_survey/features/survey/core/validation.dart';
import 'package:data_portal_survey/features/survey/model/survey_collect_draft.dart';
import 'package:data_portal_survey/features/survey/model/survey_form_models.dart';
import 'package:data_portal_survey/features/survey/resource/survey_repository.dart';
import 'package:data_portal_survey/features/survey/service/survey_draft_store.dart';

class SurveyCollectCubit extends Cubit<SurveyCollectState> {
  SurveyCollectCubit({
    required this.formId,
    required SurveyRepository surveyRepository,
  })  : _surveyRepository = surveyRepository,
        super(const SurveyCollectState());

  final String formId;
  final SurveyRepository _surveyRepository;
  Timer? _saveTimer;

  SurveyLang get lang =>
      state.locale == 'ne' ? SurveyLang.ne : SurveyLang.en;

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, clearLoadError: true));
    try {
      final form = await _surveyRepository.getForm(formId);
      final saved = await SurveyDraftStore.loadDraft(formId);

      var answers = Map<String, String>.from(saved?.answers ?? {});
      var repeatCounts = Map<String, int>.from(saved?.repeatCounts ?? {});
      var repeatActive = Map<String, int>.from(saved?.repeatActive ?? {});
      var groupRepeatCounts =
          Map<String, int>.from(saved?.groupRepeatCounts ?? {});
      var groupRepeatActive =
          Map<String, int>.from(saved?.groupRepeatActive ?? {});

      _initRepeatState(form, repeatCounts, repeatActive, groupRepeatCounts, groupRepeatActive);
      answers = _ensureRepeatAnswerKeys(form, answers, repeatCounts, groupRepeatCounts);

      for (final section in form.sections) {
        for (final field in section.fields) {
          if (field.defaultValue != null &&
              field.defaultValue!.isNotEmpty &&
              !answers.containsKey(field.id)) {
            answers[field.id] = field.defaultValue!;
          }
        }
      }

      if (saved != null && !saved.submitted) {
        emit(
          state.copyWith(
            form: form,
            isLoading: false,
            locale: saved.locale,
            answers: answers,
            repeatCounts: repeatCounts,
            repeatActive: repeatActive,
            groupRepeatCounts: groupRepeatCounts,
            groupRepeatActive: groupRepeatActive,
            step: saved.step.clamp(0, form.sections.isEmpty ? 0 : form.sections.length - 1),
            draftSavedAt: saved.draftSavedAt,
            clearFieldErrors: true,
          ),
        );
        _applyTriggers();
        return;
      }

      emit(
        state.copyWith(
          form: form,
          isLoading: false,
          answers: answers,
          repeatCounts: repeatCounts,
          repeatActive: repeatActive,
          groupRepeatCounts: groupRepeatCounts,
          groupRepeatActive: groupRepeatActive,
          clearFieldErrors: true,
        ),
      );
      _applyTriggers();
    } catch (e) {
      emit(state.copyWith(isLoading: false, loadError: e.toString()));
    }
  }

  void _initRepeatState(
    SurveyForm form,
    Map<String, int> repeatCounts,
    Map<String, int> repeatActive,
    Map<String, int> groupRepeatCounts,
    Map<String, int> groupRepeatActive,
  ) {
    for (final section in form.sections) {
      if (section.isRepeatable) {
        repeatCounts.putIfAbsent(section.id, () => section.defaultInstanceCount);
        repeatActive.putIfAbsent(section.id, () => 0);
      }
      for (final field in section.fields) {
        if (field.repeatGroupId != null) {
          groupRepeatCounts.putIfAbsent(field.repeatGroupId!, () => 1);
          groupRepeatActive.putIfAbsent(field.repeatGroupId!, () => 0);
        }
      }
    }
  }

  Map<String, String> _ensureRepeatAnswerKeys(
    SurveyForm form,
    Map<String, String> answers,
    Map<String, int> repeatCounts,
    Map<String, int> groupRepeatCounts,
  ) {
    final next = Map<String, String>.from(answers);
    for (final section in form.sections) {
      if (section.isRepeatable) {
        final count = repeatCounts[section.id] ?? section.defaultInstanceCount;
        for (var i = 0; i < count; i++) {
          for (final field in section.fields) {
            next.putIfAbsent(repeatKey(field.id, i), () => '');
          }
        }
      }
      final split = groupRepeatFields(section.fields);
      for (final entry in split.groups.entries) {
        final count = groupRepeatCounts[entry.key] ?? 1;
        for (var i = 0; i < count; i++) {
          for (final field in entry.value) {
            next.putIfAbsent(repeatKey(field.id, i), () => '');
          }
        }
      }
    }
    return next;
  }

  void setLang(SurveyLang lang) {
    emit(state.copyWith(locale: SurveyStrings.localeCode(lang)));
    _scheduleAutosave();
  }

  void setAnswer(String key, String value) {
    final answers = Map<String, String>.from(state.answers)..[key] = value;
    final fieldErrors = Map<String, String>.from(state.fieldErrors)..remove(key);
    emit(state.copyWith(answers: answers, fieldErrors: fieldErrors));
    _applyTriggers();
    _scheduleAutosave();
  }

  void _applyTriggers() {
    final form = state.form;
    if (form == null) return;

    var repeatCounts = Map<String, int>.from(state.repeatCounts);
    var repeatActive = Map<String, int>.from(state.repeatActive);
    var changed = false;

    for (final section in form.sections.where((s) => s.isRepeatable && s.triggerFieldId != null)) {
      final n = int.tryParse(state.answers[section.triggerFieldId!] ?? '');
      if (n != null && n > 0 && n != repeatCounts[section.id]) {
        repeatCounts[section.id] = n;
        repeatActive[section.id] = 0;
        changed = true;
      }
    }

    if (changed) {
      var answers = Map<String, String>.from(state.answers);
      for (final section in form.sections.where((s) => s.isRepeatable)) {
        final count = repeatCounts[section.id] ?? section.defaultInstanceCount;
        for (var i = 0; i < count; i++) {
          for (final field in section.fields) {
            answers.putIfAbsent(repeatKey(field.id, i), () => '');
          }
        }
      }
      emit(
        state.copyWith(
          repeatCounts: repeatCounts,
          repeatActive: repeatActive,
          answers: answers,
        ),
      );
    }
  }

  void setRepeatActive(String sectionId, int index) {
    final repeatActive = Map<String, int>.from(state.repeatActive)
      ..[sectionId] = index;
    emit(state.copyWith(repeatActive: repeatActive));
  }

  void setGroupRepeatActive(String groupId, int index) {
    final groupRepeatActive = Map<String, int>.from(state.groupRepeatActive)
      ..[groupId] = index;
    emit(state.copyWith(groupRepeatActive: groupRepeatActive));
  }

  void addSectionInstance(SurveySection section) {
    final max = section.maxInstances ?? 99;
    final count = state.repeatCounts[section.id] ?? section.defaultInstanceCount;
    if (count >= max) return;
    final repeatCounts = Map<String, int>.from(state.repeatCounts)
      ..[section.id] = count + 1;
    final answers = Map<String, String>.from(state.answers);
    for (final field in section.fields) {
      answers.putIfAbsent(repeatKey(field.id, count), () => '');
    }
    emit(state.copyWith(repeatCounts: repeatCounts, answers: answers));
    _scheduleAutosave();
  }

  void removeSectionInstance(SurveySection section, int index) {
    final min = section.minInstances ?? 1;
    final count = state.repeatCounts[section.id] ?? section.defaultInstanceCount;
    if (count <= min) return;
    final ids = section.fields.map((f) => f.id).toList();
    final answers = removeInstanceAnswers(state.answers, ids, index, count);
    final repeatCounts = Map<String, int>.from(state.repeatCounts)
      ..[section.id] = count - 1;
    final repeatActive = Map<String, int>.from(state.repeatActive);
    repeatActive[section.id] = nextActiveInstance(
      repeatActive[section.id] ?? 0,
      index,
      count - 1,
    );
    emit(
      state.copyWith(
        answers: answers,
        repeatCounts: repeatCounts,
        repeatActive: repeatActive,
      ),
    );
    _scheduleAutosave();
  }

  void addGroupInstance(String groupId, List<SurveyField> fields) {
    final count = state.groupRepeatCounts[groupId] ?? 1;
    final groupRepeatCounts = Map<String, int>.from(state.groupRepeatCounts)
      ..[groupId] = count + 1;
    final answers = Map<String, String>.from(state.answers);
    for (final field in fields) {
      answers.putIfAbsent(repeatKey(field.id, count), () => '');
    }
    emit(state.copyWith(groupRepeatCounts: groupRepeatCounts, answers: answers));
    _scheduleAutosave();
  }

  void removeGroupInstance(String groupId, List<SurveyField> fields, int index) {
    final count = state.groupRepeatCounts[groupId] ?? 1;
    if (count <= 1) return;
    final ids = fields.map((f) => f.id).toList();
    final answers = removeInstanceAnswers(state.answers, ids, index, count);
    final groupRepeatCounts = Map<String, int>.from(state.groupRepeatCounts)
      ..[groupId] = count - 1;
    final groupRepeatActive = Map<String, int>.from(state.groupRepeatActive);
    groupRepeatActive[groupId] = nextActiveInstance(
      groupRepeatActive[groupId] ?? 0,
      index,
      count - 1,
    );
    emit(
      state.copyWith(
        answers: answers,
        groupRepeatCounts: groupRepeatCounts,
        groupRepeatActive: groupRepeatActive,
      ),
    );
    _scheduleAutosave();
  }

  String? validateCurrentSection() {
    final section = state.currentSection;
    if (section == null) return null;

    final errors = validateSection(
      section,
      state.answers,
      state.repeatCounts,
      state.groupRepeatCounts,
    );
    final fieldErrors = {for (final e in errors) e.errorKey: e.message};

    if (errors.isEmpty) {
      emit(state.copyWith(clearFieldErrors: true));
      return null;
    }

    final first = errors.first;
    var repeatActive = Map<String, int>.from(state.repeatActive);
    var groupRepeatActive = Map<String, int>.from(state.groupRepeatActive);

    if (first.instanceIndex != null) {
      if (first.groupId != null) {
        groupRepeatActive[first.groupId!] = first.instanceIndex!;
      } else if (section.isRepeatable) {
        repeatActive[section.id] = first.instanceIndex!;
      }
    }

    emit(
      state.copyWith(
        fieldErrors: fieldErrors,
        repeatActive: repeatActive,
        groupRepeatActive: groupRepeatActive,
      ),
    );
    return first.message;
  }

  bool next() {
    if (validateCurrentSection() != null) return false;
    if (!state.isLast) {
      emit(state.copyWith(step: state.step + 1, clearFieldErrors: true));
      _scheduleAutosave();
    }
    return true;
  }

  void previous() {
    if (state.step > 0) {
      emit(state.copyWith(step: state.step - 1, clearFieldErrors: true));
      _scheduleAutosave();
    }
  }

  Future<void> submit() async {
    if (validateCurrentSection() != null) return;
    final form = state.form;
    if (form == null) return;

    emit(state.copyWith(isSubmitting: true, clearSubmitError: true));
    try {
      final result = await _surveyRepository.submit(
        form: form,
        answers: state.answers,
      );
      await SurveyDraftStore.clearDraft(formId);
      final responseId = result['id']?.toString() ??
          result['responseId']?.toString() ??
          '';
      emit(
        state.copyWith(
          isSubmitting: false,
          submitted: true,
          responseId: responseId,
        ),
      );
    } catch (e) {
      try {
        final payload = buildSubmitPayload(form.sections, state.answers);
        await _surveyRepository.queueOfflineSubmission(
          formId: form.id,
          answers: payload,
        );
        await SurveyDraftStore.clearDraft(formId);
        emit(
          state.copyWith(
            isSubmitting: false,
            submitted: true,
            responseId: 'offline',
            submitError: null,
          ),
        );
      } catch (_) {
        emit(
          state.copyWith(
            isSubmitting: false,
            submitError: e.toString(),
          ),
        );
      }
    }
  }

  void restart() {
    _saveTimer?.cancel();
    SurveyDraftStore.clearDraft(formId);
    emit(const SurveyCollectState());
    load();
  }

  void _scheduleAutosave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 700), () async {
      final form = state.form;
      if (form == null || state.submitted) return;
      final savedAt = DateTime.now().millisecondsSinceEpoch;
      emit(state.copyWith(draftSavedAt: savedAt));
      await SurveyDraftStore.saveDraft(
        SurveyCollectDraft(
          formId: formId,
          locale: state.locale,
          step: state.step,
          answers: state.answers,
          repeatCounts: state.repeatCounts,
          repeatActive: state.repeatActive,
          groupRepeatCounts: state.groupRepeatCounts,
          groupRepeatActive: state.groupRepeatActive,
          draftSavedAt: savedAt,
        ),
      );
    });
  }

  Future<String> uploadFile(String path, String filename) async {
    final form = state.form;
    if (form == null) throw StateError('Form not loaded');
    return _surveyRepository.uploadFile(
      formId: form.id,
      path: path,
      filename: filename,
    );
  }

  @override
  Future<void> close() {
    _saveTimer?.cancel();
    return super.close();
  }
}
