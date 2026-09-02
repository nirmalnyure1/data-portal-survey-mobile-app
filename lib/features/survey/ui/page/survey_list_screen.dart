import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data_portal_survey/common/constants/app_strings.dart';
import 'package:data_portal_survey/common/theme/app_spacing.dart';
import 'package:data_portal_survey/common/theme/theme_colors.dart';
import 'package:data_portal_survey/features/auth/resource/auth_repository.dart';
import 'package:data_portal_survey/features/survey/bloc/survey_list_cubit.dart';
import 'package:data_portal_survey/features/survey/bloc/survey_list_state.dart';
import 'package:data_portal_survey/features/survey/constants/survey_theme.dart';
import 'package:data_portal_survey/features/survey/model/household_survey_models.dart';
import 'package:data_portal_survey/features/survey/resource/household_survey_repository.dart';
import 'package:data_portal_survey/features/survey/resource/survey_repository.dart';
import 'package:data_portal_survey/navigation/app_navigator.dart';
import 'package:data_portal_survey/navigation/app_router.dart';

@RoutePage()
class SurveyListScreen extends StatelessWidget {
  const SurveyListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SurveyListCubit(
        surveyRepository: context.read<SurveyRepository>(),
      )..load(),
      child: const _SurveyListView(),
    );
  }
}

class _SurveyListView extends StatefulWidget {
  const _SurveyListView();

  @override
  State<_SurveyListView> createState() => _SurveyListViewState();
}

class _SurveyListViewState extends State<_SurveyListView> {
  bool _householdDraft = false;
  List<HouseholdSurveySubmission> _householdSubmissions = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadHousehold());
  }

  Future<void> _loadHousehold() async {
    final repo = context.read<HouseholdSurveyRepository>();
    final hasDraft = await repo.hasActiveDraft();
    final submissions = await repo.getSubmissions();
    if (!mounted) return;
    setState(() {
      _householdDraft = hasDraft;
      _householdSubmissions = submissions;
    });
  }

  Future<void> _openForm(BuildContext context, String formId) async {
    final auth = context.read<AuthRepository>();
    if (!auth.isAuthenticated) {
      await AppNavigator.toLogin();
      return;
    }
    await AppNavigator.push(SurveyCollectRoute(formId: formId));
    if (context.mounted) {
      context.read<SurveyListCubit>().load();
    }
  }

  Future<void> _openHouseholdSurvey() async {
    final auth = context.read<AuthRepository>();
    if (!auth.isAuthenticated) {
      await AppNavigator.toLogin();
      return;
    }
    await AppNavigator.push(const HouseholdSurveyRoute());
    await _loadHousehold();
    if (mounted) context.read<SurveyListCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.pageBackGroundColor,
      body: SafeArea(
        child: BlocBuilder<SurveyListCubit, SurveyListState>(
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () async {
                await context.read<SurveyListCubit>().load();
                await _loadHousehold();
              },
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.s24),
                children: [
                  const Text(
                    AppStrings.surveysTitle,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: ThemeColors.black,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  const Text(
                    AppStrings.surveysListSubtitle,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.4,
                      color: ThemeColors.lightTextColor,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s24),
                  _SurveyCard(
                    title: AppStrings.householdSurveyTitle,
                    subtitle: AppStrings.householdSurveySubtitle,
                    icon: Icons.home_work_outlined,
                    hasDraft: _householdDraft,
                    onTap: _openHouseholdSurvey,
                  ),
                  if (_householdSubmissions.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.s24),
                    Text(
                      AppStrings.recentSubmissions,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: ThemeColors.black,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    ..._householdSubmissions.take(5).map(
                          (s) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.s8),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: ThemeColors.midGrayColor),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          s.responseId,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          s.draft.answers.headName.isNotEmpty
                                              ? s.draft.answers.headName
                                              : AppStrings.householdSurveyTitle,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: ThemeColors.lightTextColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.check_circle_outline,
                                    color: SurveyTheme.primary,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                  ],
                  const SizedBox(height: AppSpacing.s24),
                  if (state.isLoading)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (state.error != null)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            state.error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: ThemeColors.lightTextColor),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: () => context.read<SurveyListCubit>().load(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  else if (state.forms.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Column(
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: 48,
                            color: ThemeColors.grey,
                          ),
                          const SizedBox(height: AppSpacing.s12),
                          Text(
                            AppStrings.surveysEmptyTitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: ThemeColors.black,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...state.forms.map(
                      (form) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.s12),
                        child: _SurveyCard(
                          title: form.title.en,
                          subtitle: form.description?.en.isNotEmpty == true
                              ? form.description!.en
                              : AppStrings.surveyCardDefaultSubtitle,
                          hasDraft: state.draftFormIds.contains(form.id),
                          onTap: () => _openForm(context, form.id),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SurveyCard extends StatelessWidget {
  const _SurveyCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.hasDraft = false,
    this.icon = Icons.assignment_outlined,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool hasDraft;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: ThemeColors.midGrayColor),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: SurveyTheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: SurveyTheme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: ThemeColors.lightTextColor,
                      ),
                    ),
                    if (hasDraft) ...[
                      const SizedBox(height: 6),
                      Text(
                        AppStrings.resumeDraft,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: SurveyTheme.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: ThemeColors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
