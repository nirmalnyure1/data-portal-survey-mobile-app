import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:data_portal_survey/features/survey/model/household_survey_models.dart';

class SurveyDraftStore {
  SurveyDraftStore._();

  static const String _activeDraftKey = 'household_survey_active_draft';
  static const String _submissionsKey = 'household_survey_submissions';

  static Future<void> saveDraft(HouseholdSurveyDraft draft) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeDraftKey, draft.encode());
  }

  static Future<HouseholdSurveyDraft?> loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_activeDraftKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return HouseholdSurveyDraft.decode(raw);
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activeDraftKey);
  }

  static Future<bool> hasDraft() async {
    final draft = await loadDraft();
    return draft != null && !draft.submitted;
  }

  static Future<List<HouseholdSurveySubmission>> loadSubmissions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_submissionsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map(
            (e) => HouseholdSurveySubmission.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> addSubmission(
    HouseholdSurveySubmission submission,
  ) async {
    final existing = await loadSubmissions();
    final updated = [submission, ...existing];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _submissionsKey,
      jsonEncode(updated.map((s) => s.toJson()).toList()),
    );
  }
}
