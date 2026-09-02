import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data_portal_survey/common/constants/app_strings.dart';
import 'package:data_portal_survey/common/theme/app_spacing.dart';
import 'package:data_portal_survey/common/theme/theme_colors.dart';
import 'package:data_portal_survey/features/auth/resource/auth_repository.dart';
import 'package:data_portal_survey/features/survey/constants/survey_theme.dart';
import 'package:data_portal_survey/features/survey/model/household_survey_models.dart';
import 'package:data_portal_survey/features/survey/resource/survey_repository.dart';
import 'package:data_portal_survey/features/survey/service/survey_draft_store.dart';
import 'package:data_portal_survey/navigation/app_navigator.dart';
import 'package:data_portal_survey/navigation/app_router.dart';

@RoutePage()
class SurveyListScreen extends StatefulWidget {
  const SurveyListScreen({super.key});

  @override
  State<SurveyListScreen> createState() => _SurveyListScreenState();
}

class _SurveyListScreenState extends State<SurveyListScreen> {
  bool _hasDraft = false;
  List<HouseholdSurveySubmission> _submissions = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final hasDraft = await SurveyDraftStore.hasDraft();
    final submissions =
        await context.read<SurveyRepository>().getSubmissions();
    if (!mounted) return;
    setState(() {
      _hasDraft = hasDraft;
      _submissions = submissions;
    });
  }

  Future<void> _openSurvey() async {
    final auth = context.read<AuthRepository>();
    if (!auth.isAuthenticated) {
      await AppNavigator.toLogin();
      return;
    }
    await AppNavigator.push(const HouseholdSurveyRoute());
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.pageBackGroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
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
              Text(
                AppStrings.surveysListSubtitle,
                style: const TextStyle(
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
                accent: SurveyTheme.primary,
                badge: _hasDraft ? AppStrings.resumeDraft : null,
                onTap: _openSurvey,
              ),
              if (_submissions.isNotEmpty) ...[
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
                ..._submissions.take(10).map(
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
            ],
          ),
        ),
      ),
    );
  }
}

class _SurveyCard extends StatelessWidget {
  const _SurveyCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.onTap,
    this.badge,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;
  final String? badge;

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
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accent),
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
                      style: TextStyle(
                        fontSize: 13,
                        color: ThemeColors.lightTextColor,
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        badge!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: accent,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: ThemeColors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
