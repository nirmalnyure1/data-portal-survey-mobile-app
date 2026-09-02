import 'package:flutter/material.dart';
import 'package:data_portal_survey/common/theme/theme_colors.dart';
import 'package:data_portal_survey/features/notification/service/notification_badge_service.dart';
import 'package:data_portal_survey/common/theme/app_shapes.dart';

class NotificationBadgeButton extends StatelessWidget {
  final VoidCallback? onTap;

  const NotificationBadgeButton({super.key, this.onTap});

  String _formatCount(int count) {
    if (count > 99) return '99+';
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Padding(
      padding: const EdgeInsets.only(top: 4, right: 4),
      child: ValueListenableBuilder<int>(
        valueListenable: NotificationBadgeService.instance.badgeCountNotifier,
        builder: (context, count, _) {
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: AppShapes.radiusPill,
              child: Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  color: ThemeColors.pageBackGroundColor,
                  borderRadius: AppShapes.radiusPill,
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.notifications_outlined,
                      color: primaryColor,
                      size: 22,
                    ),
                    if (count > 0)
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: count > 9 ? 4 : 0,
                            vertical: 2,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          decoration: BoxDecoration(
                            color: ThemeColors.primaryColor,
                            borderRadius: AppShapes.radiusLg,
                            border: Border.all(
                              color: ThemeColors.pageBackGroundColor,
                              width: 1.5,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _formatCount(count),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: ThemeColors.pageBackGroundColor,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
