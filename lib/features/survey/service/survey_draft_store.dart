import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:data_portal_survey/features/survey/model/survey_collect_draft.dart';

class SurveyDraftStore {
  SurveyDraftStore._();

  static String _draftKey(String formId) => 'survey_draft_$formId';
  static const String _pendingSubmissionsKey = 'survey_pending_submissions';

  static Future<void> saveDraft(SurveyCollectDraft draft) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_draftKey(draft.formId), draft.encode());
  }

  static Future<SurveyCollectDraft?> loadDraft(String formId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_draftKey(formId));
    if (raw == null || raw.isEmpty) return null;
    try {
      return SurveyCollectDraft.decode(raw);
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearDraft(String formId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_draftKey(formId));
  }

  static Future<bool> hasDraft(String formId) async {
    final draft = await loadDraft(formId);
    return draft != null && !draft.submitted;
  }

  static Future<List<Map<String, dynamic>>> loadPendingSubmissions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_pendingSubmissionsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> addPendingSubmission(Map<String, dynamic> item) async {
    final existing = await loadPendingSubmissions();
    existing.add(item);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pendingSubmissionsKey, jsonEncode(existing));
  }

  static Future<void> setPendingSubmissions(List<Map<String, dynamic>> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pendingSubmissionsKey, jsonEncode(items));
  }
}
