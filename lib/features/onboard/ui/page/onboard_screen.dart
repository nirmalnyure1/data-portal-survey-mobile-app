import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data_portal_survey/common/storage/secure_storage.dart';
import 'package:data_portal_survey/features/auth/resource/auth_repository.dart';
import 'package:data_portal_survey/navigation/navigation.dart';
import 'package:data_portal_survey/common/constants/constant_assets.dart';
import 'package:data_portal_survey/common/constants/app_strings.dart';
import 'package:data_portal_survey/features/onboard/ui/widget/onbaord_widget.dart';
import 'package:data_portal_survey/common/widgets/primary_button.dart';
import 'package:data_portal_survey/features/onboard/ui/widget/skip_button.dart';
import 'package:data_portal_survey/common/theme/app_spacing.dart';

@RoutePage()
class OnboardScreen extends StatefulWidget {
  const OnboardScreen({super.key});

  @override
  State<OnboardScreen> createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Widget> _pages = [
    const OnboardWidget(
      page: FirstPageText(),
      subTitle: AppStrings.onboardSubtitle1,
      assets: Assets.onboard1,
      currentIndex: 0,
    ),
    const OnboardWidget(
      page: SecondPageText(),
      subTitle: AppStrings.onboardSubtitle2,
      assets: Assets.onboard2,
      currentIndex: 1,
    ),
    const OnboardWidget(
      page: ThirdPageText(),
      subTitle: AppStrings.onboardSubtitle3,
      assets: Assets.onboard3,
      currentIndex: 2,
    ),
  ];

  String _getButtonText() {
    if (_currentPage == 0) {
      return AppStrings.getStarted;
    } else if (_currentPage == 1) {
      return AppStrings.next;
    } else {
      return AppStrings.startCollecting;
    }
  }

  Future<void> _finishOnboarding() async {
    await SecureStorage().saveOnboardingCompleted(true);
    if (!mounted) return;
    final isAuthenticated =
        RepositoryProvider.of<AuthRepository>(context).isAuthenticated;
    await AppNavigator.continueStartupFlow(isAuthenticated: isAuthenticated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppInsets.all24,
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  children: _pages,
                ),
              ),
              const SizedBox(height: AppSpacing.s40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SkipButton(onPressed: _finishOnboarding),
                  SizedBox(
                    width: 180,
                    child: PrimaryButton(
                      text: _getButtonText(),
                      onPressed: () async {
                        if (_currentPage < _pages.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.ease,
                          );
                        } else {
                          await _finishOnboarding();
                        }
                      },
                      suffixIcon: Icons.arrow_forward_ios,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
