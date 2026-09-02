// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:data_portal_survey/common/constants/colors.dart';
// import 'package:data_portal_survey/features/auth/ui/widget/signup_header.dart';
// import 'package:data_portal_survey/features/auth/ui/widget/signup_sheet.dart';

// class SignupPage extends StatelessWidget {
//   const SignupPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       backgroundColor: ThemeColors.primaryColor,
//       body: AnnotatedRegion<SystemUiOverlayStyle>(
//         value: SystemUiOverlayStyle.light.copyWith(
//           statusBarColor: Colors.transparent,
//           statusBarIconBrightness: Brightness.light,
//           statusBarBrightness: Brightness.dark,
//         ),
//         child: SafeArea(
//           bottom: false,
//           child: Stack(
//             children: const [
//               // Positioned.fill(child: ColoredBox(color: ThemeColors.primaryColor)),
//               Positioned(left: 0, right: 0, top: 0, child: SignupHeader()),
//               Align(alignment: Alignment.bottomCenter, child: SignupSheet()),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
