import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data_portal_survey/common/constants/constant_assets.dart';
import 'package:data_portal_survey/common/storage/secure_storage.dart';
import 'package:data_portal_survey/common/widgets/status_bar_wrapper.dart';
import 'package:data_portal_survey/common/wrapper/update_wrapper.dart';
import 'package:data_portal_survey/features/engagement/bloc/track_engagement_cubit.dart';
import 'package:data_portal_survey/features/engagement/resource/engagement_repository.dart';
import 'package:data_portal_survey/features/onboard/bloc/startup_cubit.dart';
import 'package:data_portal_survey/features/onboard/bloc/startup_state.dart';
import 'package:data_portal_survey/features/survey/constants/survey_theme.dart';
import 'package:data_portal_survey/navigation/navigation.dart';
import 'package:data_portal_survey/features/auth/resource/auth_repository.dart';

@RoutePage()
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void _trackEngagementIfLoggedIn(BuildContext context) {
    if (!context.read<StartupCubit>().hasSession) return;
    context.read<TrackEngagementCubit>().trackAppOpenIfNeeded(
      isAuthenticated: true,
    );
  }

  Future<void> _delayBeforeNavigation() async {
    await Future<void>.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    return IosUpdateWrapper(
      child: StatusBarWrapper(
        isDark: false,
        statusBarColor: SurveyTheme.surfaceLowest,
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => StartupCubit(
                authRepository: RepositoryProvider.of<AuthRepository>(context),
                secureStorage: RepositoryProvider.of<SecureStorage>(context),
              )..checkStartupSession(),
            ),
            BlocProvider(
              create: (context) => TrackEngagementCubit(
                engagementRepository:
                    RepositoryProvider.of<EngagementRepository>(context),
                authRepository: RepositoryProvider.of<AuthRepository>(context),
              ),
            ),
          ],
          child: BlocListener<StartupCubit, StartupState>(
            listener: (context, state) async {
              if (state is OnboardingRequired) {
                if (!mounted) return;
                _trackEngagementIfLoggedIn(context);
                await _delayBeforeNavigation();
                if (!mounted) return;
                await AppNavigator.toOnboard();
                return;
              }

              if (state is StartupStateSuccess<bool>) {
                if (!mounted) return;

                final isLoggedIn = state.data;
                if (isLoggedIn) {
                  _trackEngagementIfLoggedIn(context);
                }
                await _delayBeforeNavigation();
                if (!mounted) return;
                await AppNavigator.completeStartup(isAuthenticated: isLoggedIn);
                return;
              }

              if (state is StartupError) {
                if (!mounted) return;
                await _delayBeforeNavigation();
                if (!mounted) return;
                await AppNavigator.completeStartup(isAuthenticated: false);
              }
            },
            child: Scaffold(
              backgroundColor: SurveyTheme.surfaceLowest,
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      Assets.dataPortalLogo,
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 32),
                    const _SplashDotsLoader(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SplashDotsLoader extends StatefulWidget {
  const _SplashDotsLoader();

  @override
  State<_SplashDotsLoader> createState() => _SplashDotsLoaderState();
}

class _SplashDotsLoaderState extends State<_SplashDotsLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final phase = (_controller.value + index * 0.2) % 1.0;
            final opacity = phase < 0.5
                ? (phase * 2).clamp(0.35, 1.0)
                : ((1.0 - phase) * 2).clamp(0.35, 1.0);
            final scale = 0.7 + (opacity * 0.3);

            return Padding(
              padding: EdgeInsets.only(right: index == 2 ? 0 : 8),
              child: Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: SurveyTheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
