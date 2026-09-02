import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:data_portal_survey/navigation/navigation.dart';
import 'package:data_portal_survey/common/constants/constant_assets.dart';
import 'package:data_portal_survey/common/constants/app_strings.dart';
import 'package:data_portal_survey/features/onboard/ui/widget/language_tile.dart';
import 'package:data_portal_survey/features/onboard/ui/widget/logo_widget.dart';
import 'package:data_portal_survey/common/widgets/primary_button.dart';
import 'package:data_portal_survey/common/theme/app_spacing.dart';

@RoutePage()
class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  int _selectedIndex = 0;

  final List<Map<String, String>> _languages = [
    {'name': AppStrings.english, 'flag': Assets.usFlag},
    {'name': AppStrings.nepali, 'flag': Assets.nepalFlag},
    {'name': AppStrings.arabic, 'flag': Assets.arabicFlag},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppInsets.all24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(child: LogoWidget()),
              const SizedBox(height: AppSpacing.s40),
              const Text(
                AppStrings.chooseYourLanguage,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.s20),
              ListView.separated(
                shrinkWrap: true,
                itemCount: _languages.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppSpacing.s12),
                itemBuilder: (context, index) {
                  return LanguageTile(
                    language: _languages[index]['name']!,
                    flag: _languages[index]['flag']!,
                    isSelected: _selectedIndex == index,
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                  );
                },
              ),
              const Spacer(),
              const Center(
                child: Text(
                  AppStrings.changeLanguageLater,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
              PrimaryButton(
                text: AppStrings.continueText,
                onPressed: () {
                  AppNavigator.toOnboardPush();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
