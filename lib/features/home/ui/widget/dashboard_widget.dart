import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:data_portal_survey/common/theme/theme_colors.dart';
import 'package:data_portal_survey/common/widgets/custom_bottom_navbar.dart';
import 'package:data_portal_survey/common/widgets/status_bar_wrapper.dart';
import 'package:data_portal_survey/features/home/ui/page/home_screen.dart';
import 'package:data_portal_survey/features/profile/ui/page/profile_screen.dart';
import 'package:data_portal_survey/features/survey/ui/page/survey_list_screen.dart';

class DashboardTabController {
  DashboardTabController._();

  static final ValueNotifier<int?> tabIndex = ValueNotifier<int?>(null);

  static void jumpTo(int index) {
    tabIndex.value = index;
  }
}

class DashboardWidget extends StatefulWidget {
  const DashboardWidget({super.key});

  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  late PageController _pageController;
  int _currentIndex = 0;

  List<Widget> _buildScreens() {
    return const [
      HomeScreen(),
      SurveyListScreen(),
      ProfileScreen(),
    ];
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    DashboardTabController.tabIndex.addListener(_onExternalTabChange);
  }

  @override
  void dispose() {
    DashboardTabController.tabIndex.removeListener(_onExternalTabChange);
    _pageController.dispose();
    super.dispose();
  }

  void _onExternalTabChange() {
    final idx = DashboardTabController.tabIndex.value;
    if (idx == null || !mounted) return;
    _onNavbarTapped(idx);
    DashboardTabController.tabIndex.value = null;
  }

  void _onNavbarTapped(int index) {
    _pageController.jumpToPage(index);
    setState(() {
      _currentIndex = index;
    });

    final isPrimaryTab = index == 2;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: isPrimaryTab
            ? ThemeColors.primaryColor
            : ThemeColors.pageBackGroundColor,
        statusBarIconBrightness: isPrimaryTab
            ? Brightness.light
            : Brightness.dark,
        statusBarBrightness: isPrimaryTab ? Brightness.dark : Brightness.light,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StatusBarWrapper(
      statusBarColor: _currentIndex == 2
          ? ThemeColors.primaryColor
          : ThemeColors.pageBackGroundColor,
      isDark: _currentIndex == 2,
      child: Scaffold(
        body: SafeArea(
          top: false,
          bottom: false,
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: _buildScreens(),
          ),
        ),
        bottomNavigationBar: CustomBottomNavbar(
          currentIndex: _currentIndex,
          onNavigate: _onNavbarTapped,
        ),
      ),
    );
  }
}
