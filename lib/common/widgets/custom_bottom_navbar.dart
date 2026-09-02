import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:data_portal_survey/common/theme/theme_colors.dart';
import '../constants/constant_assets.dart';

class CustomBottomNavbar extends StatelessWidget {
  final Function(int)? onNavigate;
  final int currentIndex;

  const CustomBottomNavbar({
    super.key,
    this.onNavigate,
    this.currentIndex = 0,
  });

  static final List<NavbarItem> _navItems = [
    NavbarItem(icon: Assets.home, label: 'Home'),
    NavbarItem(icon: Assets.star, label: 'Surveys'),
    NavbarItem(icon: Assets.user, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeColors.pageBackGroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onNavigate,
        type: BottomNavigationBarType.fixed,
        backgroundColor: ThemeColors.pageBackGroundColor,
        elevation: 0,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedItemColor: ThemeColors.primaryColor,
        unselectedItemColor: ThemeColors.grey,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        items: _navItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isSelected = currentIndex == index;
          return BottomNavigationBarItem(
            icon: SvgPicture.asset(
              item.icon,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                isSelected ? ThemeColors.primaryColor : ThemeColors.grey,
                BlendMode.srcIn,
              ),
            ),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }
}

class NavbarItem {
  final String icon;
  final String label;

  NavbarItem({required this.icon, required this.label});
}
