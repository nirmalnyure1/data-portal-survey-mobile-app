import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:data_portal_survey/features/home/ui/widget/dashboard_widget.dart';

@RoutePage()
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardWidget();
  }
}
