import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:data_portal_survey/features/survey/bloc/household_survey_state.dart';
import 'package:data_portal_survey/features/survey/constants/household_survey_strings.dart';
import 'package:data_portal_survey/features/survey/model/household_survey_models.dart';
import 'package:data_portal_survey/features/survey/resource/survey_repository.dart';
import 'package:data_portal_survey/features/survey/service/survey_draft_store.dart';
import 'package:data_portal_survey/features/survey/utils/household_survey_validation.dart';

class HouseholdSurveyCubit extends Cubit<HouseholdSurveyState> {
  HouseholdSurveyCubit({required SurveyRepository surveyRepository})
      : _surveyRepository = surveyRepository,
        super(HouseholdSurveyState(draft: HouseholdSurveyDraft.empty()));

  final SurveyRepository _surveyRepository;
  Timer? _saveTimer;

  SurveyLang get lang =>
      state.draft.lang == 'ne' ? SurveyLang.ne : SurveyLang.en;

  Future<void> load() async {
    final saved = await SurveyDraftStore.loadDraft();
    if (saved != null && !saved.submitted) {
      emit(state.copyWith(draft: saved, clearErrors: true));
    }
  }

  void _scheduleAutosave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 700), () async {
      final updated = state.draft.copyWith(draftSavedAt: DateTime.now().millisecondsSinceEpoch);
      emit(state.copyWith(draft: updated));
      await SurveyDraftStore.saveDraft(updated);
    });
  }

  void setLang(SurveyLang lang) {
    final updated = state.draft.copyWith(lang: lang == SurveyLang.ne ? 'ne' : 'en');
    emit(state.copyWith(draft: updated));
    _scheduleAutosave();
  }

  void updateAnswers(HouseholdSurveyAnswers answers) {
    emit(state.copyWith(draft: state.draft.copyWith(answers: answers), clearErrors: true));
    _scheduleAutosave();
  }

  void updateAnswerField({
    String? headName,
    String? phone,
    String? email,
    String? wardNumber,
    String? address,
    String? toleLocation,
    String? dob,
    String? calendarType,
    String? gender,
    String? ownsLand,
    String? landArea,
    int? incomeRange,
    int? supportRating,
    String? lastVisitDateTime,
    String? preferredVisitTime,
    String? notesUrl,
  }) {
    final answers = state.draft.answers.copyWith(
      headName: headName,
      phone: phone,
      email: email,
      wardNumber: wardNumber,
      address: address,
      toleLocation: toleLocation,
      dob: dob,
      calendarType: calendarType,
      gender: gender,
      ownsLand: ownsLand,
      landArea: landArea,
      incomeRange: incomeRange,
      supportRating: supportRating,
      lastVisitDateTime: lastVisitDateTime,
      preferredVisitTime: preferredVisitTime,
      notesUrl: notesUrl,
    );
    updateAnswers(answers);
  }

  void addMember() {
    if (state.draft.members.length >= HouseholdSurveyDraft.maxMembers) return;
    final members = [
      ...state.draft.members,
      HouseholdMember(id: DateTime.now().millisecondsSinceEpoch),
    ];
    emit(state.copyWith(draft: state.draft.copyWith(members: members), clearErrors: true));
    _scheduleAutosave();
  }

  void removeMember(int id) {
    if (state.draft.members.length <= 1) return;
    final members = state.draft.members.where((m) => m.id != id).toList();
    emit(state.copyWith(draft: state.draft.copyWith(members: members), clearErrors: true));
    _scheduleAutosave();
  }

  void updateMember(int id, HouseholdMember member) {
    final members = state.draft.members
        .map((m) => m.id == id ? member : m)
        .toList();
    emit(state.copyWith(draft: state.draft.copyWith(members: members), clearErrors: true));
    _scheduleAutosave();
  }

  void toggleMemberSkill(int memberId, String skill) {
    final member = state.draft.members.firstWhere((m) => m.id == memberId);
    final skills = List<String>.from(member.skills);
    if (skills.contains(skill)) {
      skills.remove(skill);
    } else {
      skills.add(skill);
    }
    updateMember(memberId, member.copyWith(skills: skills));
  }

  void setCropCount(int n) {
    final clamped = max(0, min(HouseholdSurveyDraft.maxCrops, n));
    var crops = state.draft.crops.toList();
    if (crops.length > clamped) {
      crops = crops.sublist(0, clamped);
    }
    while (crops.length < clamped) {
      crops.add(const HouseholdCrop());
    }
    emit(
      state.copyWith(
        draft: state.draft.copyWith(cropCount: clamped, crops: crops),
        clearErrors: true,
      ),
    );
    _scheduleAutosave();
  }

  void updateCrop(int index, HouseholdCrop crop) {
    final crops = state.draft.crops.toList();
    if (index < 0 || index >= crops.length) return;
    crops[index] = crop;
    emit(state.copyWith(draft: state.draft.copyWith(crops: crops), clearErrors: true));
    _scheduleAutosave();
  }

  void setHousePhoto(SurveyFileRef? file) {
    emit(
      state.copyWith(
        draft: file == null
            ? state.draft.copyWith(clearHousePhoto: true)
            : state.draft.copyWith(housePhoto: file),
        clearErrors: true,
      ),
    );
    _scheduleAutosave();
  }

  void setLandCertificate(SurveyFileRef? file) {
    emit(
      state.copyWith(
        draft: file == null
            ? state.draft.copyWith(clearLandCertificate: true)
            : state.draft.copyWith(landCertificate: file),
        clearErrors: true,
      ),
    );
    _scheduleAutosave();
  }

  Future<void> captureGpsLocation() async {
    try {
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
      final label = HouseholdSurveyStrings.tr(
        lang,
        '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}',
        '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}',
      );
      updateAnswerField(toleLocation: label);
    } catch (_) {}
  }

  void goNext() {
    final step = state.draft.step;
    final errors = HouseholdSurveyValidation.validateStep(state.draft, step);
    if (HouseholdSurveyValidation.hasErrors(errors)) {
      final touched = Map<int, bool>.from(state.draft.stepTouched);
      touched[step] = true;
      emit(
        state.copyWith(
          draft: state.draft.copyWith(stepTouched: touched),
          errors: errors,
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        draft: state.draft.copyWith(step: min(step + 1, HouseholdSurveyDraft.totalSteps - 1)),
        clearErrors: true,
      ),
    );
    _scheduleAutosave();
  }

  void goBack() {
    final step = max(0, state.draft.step - 1);
    emit(state.copyWith(draft: state.draft.copyWith(step: step), clearErrors: true));
    _scheduleAutosave();
  }

  void editStep(int step) {
    emit(state.copyWith(draft: state.draft.copyWith(step: step), clearErrors: true));
    _scheduleAutosave();
  }

  Future<void> submit() async {
    final docErrors = HouseholdSurveyValidation.validateStep(state.draft, 5);
    if (HouseholdSurveyValidation.hasErrors(docErrors)) {
      final touched = Map<int, bool>.from(state.draft.stepTouched);
      touched[5] = true;
      emit(
        state.copyWith(
          draft: state.draft.copyWith(stepTouched: touched),
          errors: docErrors,
        ),
      );
      return;
    }

    emit(state.copyWith(isSubmitting: true));
    final responseId = await _surveyRepository.submit(state.draft);
    final submitted = state.draft.copyWith(
      submitted: true,
      responseId: responseId,
    );
    await SurveyDraftStore.clearDraft();
    emit(
      HouseholdSurveyState(
        draft: submitted,
        isSubmitting: false,
      ),
    );
  }

  void restart() {
    _saveTimer?.cancel();
    SurveyDraftStore.clearDraft();
    emit(HouseholdSurveyState(draft: HouseholdSurveyDraft.empty()));
  }

  Map<String, String> errorsForCurrentStep() {
    if (!showErrorsForStep(state.draft.step)) return {};
    return HouseholdSurveyValidation.validateStep(state.draft, state.draft.step);
  }

  bool showErrorsForStep(int step) => state.draft.stepTouched[step] == true;

  @override
  Future<void> close() {
    _saveTimer?.cancel();
    return super.close();
  }
}
