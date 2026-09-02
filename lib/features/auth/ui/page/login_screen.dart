import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auto_route/auto_route.dart';
import 'package:data_portal_survey/common/theme/theme_colors.dart';
import 'package:data_portal_survey/common/widgets/auth_app_logo.dart';
import 'package:data_portal_survey/common/widgets/back_button.dart';
import 'package:data_portal_survey/features/auth/ui/widget/login_sheet.dart';

@RoutePage()
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoginBusy = false;

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
        child: AbsorbPointer(
          absorbing: _isLoginBusy,
          child: SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: _isLoginBusy
                  ? const NeverScrollableScrollPhysics()
                  : const ClampingScrollPhysics(),
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
                    decoration: const BoxDecoration(
                      color: ThemeColors.pageBackGroundColor,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(34),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(),
                      child: LoginSheet(
                        onBusyChanged: (isBusy) {
                          if (_isLoginBusy == isBusy) return;
                          setState(() => _isLoginBusy = isBusy);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
