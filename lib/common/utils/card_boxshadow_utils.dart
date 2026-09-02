import 'package:flutter/widgets.dart';
import 'package:data_portal_survey/common/theme/theme_colors.dart';

class CardBoxShadowUtils {
  static BoxShadow cardBoxShadow = BoxShadow(
    color: ThemeColors.shadowColor,
    blurRadius: 6,
    offset: const Offset(0, 4),
    // spreadRadius: -20,
  );
}
