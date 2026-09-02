import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:data_portal_survey/common/constants/app_strings.dart';
import 'package:data_portal_survey/common/theme/theme_colors.dart';
import 'package:data_portal_survey/common/widgets/auth_app_logo.dart';
import 'package:data_portal_survey/common/widgets/back_button.dart';
import 'package:data_portal_survey/features/auth/bloc/forget_password_cubit.dart';
import 'package:data_portal_survey/features/auth/bloc/verify_password_token_cubit.dart';
import 'package:data_portal_survey/features/auth/resource/auth_repository.dart';
import 'package:data_portal_survey/features/auth/ui/widget/forgot_password_otp_sheet.dart';
import 'package:data_portal_survey/features/auth/ui/widget/otp_header.dart';

@RoutePage()
class ForgotPasswordOtpScreen extends StatelessWidget {
  final String emailOrPhone;

  const ForgotPasswordOtpScreen({super.key, required this.emailOrPhone});

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => VerifyPasswordTokenCubit(
            authRepository: RepositoryProvider.of<AuthRepository>(context),
          ),
        ),
        BlocProvider(
          create: (context) => ForgotPasswordCubit(
            authRepository: RepositoryProvider.of<AuthRepository>(context),
          ),
        ),
      ],
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
          child: SafeArea(
            bottom: false,
            top: false,
            child: Stack(
              children: [
                // 1. Properly constrained SVG logo at the top using AnimatedContainer
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: AuthAppLogo(
                    expandedHeight: 190,
                    isKeyboardOpen: isKeyboardOpen,
                  ),
                ),

                // 2. Back Button
                const Positioned(
                  top: 15,
                  left: 15,
                  child: SafeArea(child: AuthBackButton()),
                ),

                // 3. The OTP Sheet
                Positioned(
                  top: 100,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: ForgotPasswordOtpSheet(emailOrPhone: emailOrPhone),
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
