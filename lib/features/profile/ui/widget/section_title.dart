import 'package:flutter/material.dart';
import 'package:data_portal_survey/common/theme/theme_colors.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: ThemeColors.black,
      ),
    );
  }
}
