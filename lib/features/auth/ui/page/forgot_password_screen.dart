import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:data_portal_survey/common/theme/theme_colors.dart';
import 'package:data_portal_survey/common/widgets/auth_app_logo.dart';
import 'package:data_portal_survey/common/widgets/back_button.dart';
import 'package:data_portal_survey/features/auth/ui/widget/forgot_password_request_sheet.dart';

@RoutePage()
class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Scaffold(
      backgroundColor: ThemeColors.primaryColor,
      resizeToAvoidBottomInset: true,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    AuthAppLogo(
                      expandedHeight: 180,
                      isKeyboardOpen: isKeyboardOpen,
                    ),
                    const Positioned(
                      top: 15,
                      left: 15,
                      child: AuthBackButton(),
                    ),
                  ],
                ),
              ),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Container(
                  color: ThemeColors.pageBackGroundColor,
                  child: const ForgotPasswordRequestSheet(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
