import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data_portal_survey/features/survey/bloc/survey_list_state.dart';
import 'package:data_portal_survey/features/survey/resource/survey_repository.dart';
import 'package:data_portal_survey/features/survey/service/survey_draft_store.dart';

class SurveyListCubit extends Cubit<SurveyListState> {
  SurveyListCubit({required SurveyRepository surveyRepository})
      : _surveyRepository = surveyRepository,
        super(const SurveyListState());

  final SurveyRepository _surveyRepository;

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      await _surveyRepository.flushPendingSubmissions();
      final forms = await _surveyRepository.listForms();
      final draftIds = <String>{};
      for (final form in forms) {
        if (await SurveyDraftStore.hasDraft(form.id)) {
          draftIds.add(form.id);
        }
      }
      emit(
        state.copyWith(
          isLoading: false,
          forms: forms,
          draftFormIds: draftIds,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
