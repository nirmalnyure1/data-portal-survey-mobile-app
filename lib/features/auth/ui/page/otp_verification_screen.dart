import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data_portal_survey/common/storage/secure_storage.dart';
import 'package:data_portal_survey/common/theme/theme_colors.dart';
import 'package:data_portal_survey/common/widgets/auth_app_logo.dart';
import 'package:data_portal_survey/common/widgets/back_button.dart';
import 'package:data_portal_survey/features/auth/bloc/resend_otp_cubit.dart';
import 'package:data_portal_survey/features/auth/bloc/verify_otp_cubit.dart';
import 'package:data_portal_survey/features/auth/resource/auth_repository.dart';
import 'package:data_portal_survey/features/auth/ui/widget/otp_verification_sheet.dart';
import 'package:data_portal_survey/features/onboard/bloc/startup_cubit.dart';

@RoutePage()
class OtpVerificationScreen extends StatelessWidget {
  final String phoneNumber;
  const OtpVerificationScreen({super.key, required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => StartupCubit(
            authRepository: RepositoryProvider.of<AuthRepository>(context),
            secureStorage: RepositoryProvider.of<SecureStorage>(context),
          ),
        ),
        BlocProvider<VerifyOtpCubit>(
          create: (context) => VerifyOtpCubit(
            authRepository: RepositoryProvider.of<AuthRepository>(context),
          ),
        ),
        BlocProvider(
          create: (context) => ResendOtpCubit(
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
                    child: OtpVerificationSheet(phoneNumber: phoneNumber),
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
