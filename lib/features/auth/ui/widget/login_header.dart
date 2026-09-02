// import 'package:flutter/material.dart';
// import 'package:data_portal_survey/common/constants/app_strings.dart';
// import 'package:data_portal_survey/common/constants/colors.dart';
// import 'package:data_portal_survey/common/constants/constant_assets.dart';

// // class LoginHeader extends StatelessWidget {
// //   const LoginHeader({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Column(
// //       children: [
// //         const SizedBox(height: 50),
// //         const _MascotCircle(),
// //         const SizedBox(height: 12),
// //         const Text(
// //           AppStrings.welcomeToSyanko,
// //           textAlign: TextAlign.center,
// //           style: TextStyle(
// //             color: ThemeColors.white,
// //             fontSize: 26,
// //             fontWeight: FontWeight.w800,
// //             letterSpacing: -0.2,
// //           ),
// //         ),
// //         const SizedBox(height: 4),
// //         Text(
// //           AppStrings.welcomeSubtitle,
// //           style: TextStyle(
// //             color: ThemeColors.white.withValues(alpha: 204),
// //             fontSize: 14,
// //             fontWeight: FontWeight.w500,
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// // }

// class _MascotCircle extends StatelessWidget {
//   const _MascotCircle();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 86,
//       height: 86,
//       decoration: const BoxDecoration(
//         shape: BoxShape.circle,
//         color: Color(0xFFFFB300),
//       ),
//       alignment: Alignment.center,
//       child: ClipOval(
//         child: Image.asset(
//           Assets.chef,
//           width: 86,
//           height: 86,
//           fit: BoxFit.cover,
//           errorBuilder: (context, error, stackTrace) {
//             return const Icon(
//               Icons.restaurant_rounded,
//               size: 44,
//               color: ThemeColors.white,
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
