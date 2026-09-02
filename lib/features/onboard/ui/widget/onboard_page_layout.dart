// import 'package:flutter/material.dart';
// import 'package:data_portal_survey/common/constants/text_styles.dart';

// class OnboardPageLayout extends StatelessWidget {
//   final String image;
//   final String title;
//   final String highlightedText;
//   final String subtitle;

//   const OnboardPageLayout({
//     super.key,
//     required this.image,
//     required this.title,
//     required this.highlightedText,
//     required this.subtitle,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Image.asset(image, height: 200),
//         const SizedBox(height: 40),
//         RichText(
//           textAlign: TextAlign.center,
//           text: TextSpan(
//             style: AppTextStyles.heading1,
//             children: [
//               TextSpan(text: title),
//               TextSpan(text: highlightedText, style: AppTextStyles.heading2),
//             ],
//           ),
//         ),
//         const SizedBox(height: 16),
//         Text(
//           subtitle,
//           textAlign: TextAlign.center,
//           style: AppTextStyles.subtitle,
//         ),
//       ],
//     );
//   }
// }
