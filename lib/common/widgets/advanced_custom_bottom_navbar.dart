import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:data_portal_survey/common/theme/app_spacing.dart';
import 'package:data_portal_survey/common/theme/theme_colors.dart';
import '../constants/constant_assets.dart';

class AdvancedCustomBottomNavbar extends StatefulWidget {
  final Function(int)? onNavigate;
  final int currentIndex;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? backgroundColor;

  const AdvancedCustomBottomNavbar({
    super.key,
    this.onNavigate,
    this.currentIndex = 0,
    this.activeColor,
    this.inactiveColor,
    this.backgroundColor,
  });

  @override
  State<AdvancedCustomBottomNavbar> createState() =>
      _AdvancedCustomBottomNavbarState();
}

class _AdvancedCustomBottomNavbarState extends State<AdvancedCustomBottomNavbar>
    with SingleTickerProviderStateMixin {
  late int _selectedIndex;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  final List<NavItem> _navItems = [
    NavItem(icon: Assets.home, label: 'Home', index: 0),
    NavItem(icon: Assets.shoppingBag, label: 'Cart', index: 1),
    NavItem(icon: Assets.star, label: 'Wishlist', index: 2),
    NavItem(icon: Assets.user, label: 'Profile', index: 3),
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      _animationController.forward(from: 0.0);
      setState(() {
        _selectedIndex = index;
      });
      widget.onNavigate?.call(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? ThemeColors.pageBackGroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: AppInsets.v8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _navItems.map((item) => _buildNavItem(item)).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(NavItem item) {
    final isSelected = _selectedIndex == item.index;

    return GestureDetector(
      onTap: () => _onItemTapped(item.index),
      child: AnimatedScale(
        scale: isSelected ? 1.1 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: isSelected
                  ? Tween<double>(
                      begin: 1.0,
                      end: 1.2,
                    ).animate(_animationController)
                  : const AlwaysStoppedAnimation(1.0),
              child: Container(
                padding: AppInsets.all8,
                decoration: isSelected
                    ? BoxDecoration(
                        color: (widget.activeColor ?? Colors.red).withOpacity(
                          0.1,
                        ),
                        shape: BoxShape.circle,
                      )
                    : null,
                child: SvgPicture.asset(
                  item.icon,
                  width: AppSpacing.s24,
                  height: AppSpacing.s24,
                  colorFilter: ColorFilter.mode(
                    isSelected
                        ? (widget.activeColor ?? Colors.red)
                        : (widget.inactiveColor ?? Colors.grey),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s4),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? (widget.activeColor ?? Colors.red)
                    : (widget.inactiveColor ?? Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NavItem {
  final String icon;
  final String label;
  final int index;

  NavItem({required this.icon, required this.label, required this.index});
}
