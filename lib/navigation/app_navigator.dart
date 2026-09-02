import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:data_portal_survey/common/storage/secure_storage.dart';
import 'package:data_portal_survey/common/utils/toast_message_utils.dart';
import 'package:data_portal_survey/features/notification/service/notification_badge_sync.dart';
import 'package:data_portal_survey/features/notification/service/notification_navigation_handler.dart';
import 'package:data_portal_survey/features/notification/service/push_notification_service.dart';
import 'package:data_portal_survey/navigation/app_router.dart';

/// Central navigation service.
/// All navigation calls in the app should go through this class.
/// Pages remain independent of auto_route implementation.
class AppNavigator {
  AppNavigator._internal();
  static final AppNavigator _instance = AppNavigator._internal();
  factory AppNavigator() => _instance;

  static GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  static void init(GlobalKey<NavigatorState> navKey) {
    _navigatorKey = navKey;
  }

  static GlobalKey<NavigatorState> get navigationKey => _navigatorKey;

  static BuildContext get context =>
      _navigatorKey.currentState!.overlay!.context;

  static Future<T?> push<T extends Object?>(PageRouteInfo route) {
    return context.router.push<T>(route);
  }

  static Future<T?> replace<T extends Object?>(PageRouteInfo route) {
    return context.router.replace<T>(route);
  }

  static Future<T?> pushAndRemoveUntil<T extends Object?>(
    PageRouteInfo route, {
    bool Function(Route<dynamic>)? predicate,
  }) {
    return context.router.pushAndPopUntil(
      route,
      predicate: predicate ?? (route) => false,
    );
  }

  static Future<T?> pushAndClearStack<T extends Object?>(PageRouteInfo route) {
    return context.router.pushAndPopUntil(route, predicate: (route) => false);
  }

  static Future<bool> pop<T extends Object?>([T? result]) {
    return context.router.maybePop(result);
  }

  static void forcePop<T extends Object?>([T? result]) {
    if (_navigatorKey.currentState?.canPop() ?? false) {
      _navigatorKey.currentState!.pop(result);
    }
  }

  static void popUntil(bool Function(Route<dynamic>) predicate) {
    context.router.popUntil(predicate);
  }

  static void popUntilRoute(String routeName) {
    context.router.popUntil((route) => route.settings.name == routeName);
  }

  static void popUntilRoot() {
    context.router.popUntilRoot();
  }

  static void popUntilFirst() {
    _navigatorKey.currentState?.popUntil((route) => route.isFirst);
  }

  static bool canPop() {
    return context.router.canPop();
  }

  static void removeRoute(PageRouteInfo route) {
    context.router.removeWhere((r) => r.name == route.routeName);
  }

  static void removeAllRoutesBelow() {
    context.router.popUntilRoot();
  }

  static void popUntilCheckRoute({
    required String routeName,
    String? optionalRouteName,
  }) {
    _navigatorKey.currentState?.popUntil((route) {
      if (route.settings.name == routeName) {
        return true;
      } else if (route.settings.name == optionalRouteName) {
        return true;
      }
      return false;
    });
  }

  static Future<void> toOnboard() => replace(const OnboardRoute());

  static Future<void> toLogin() => replace(const LoginRoute());

  /// First-time users see [OnboardScreen] intro; returning users go to login.
  static Future<void> toLoginOrOnboard() async {
    final completed = await SecureStorage().getOnboardingCompleted();
    if (!completed) {
      await replace(const OnboardRoute());
    } else {
      await replace(const LoginRoute());
    }
  }

  static Future<void> toDashboard() =>
      pushAndClearStack(const DashboardRoute());

  /// Completes startup: opens dashboard first, then syncs auth-only services.
  static Future<void> completeStartup({required bool isAuthenticated}) async {
    await toDashboard();
    if (!isAuthenticated) return;

    unawaited(() async {
      try {
        await PushNotificationService.instance.saveTokenToServer();
        await NotificationNavigationHandler.instance.flushPending();
        await NotificationBadgeSync.instance.syncFromServer();
      } catch (_) {}
    }());
  }

  static Future<void> continueStartupFlow({
    required bool isAuthenticated,
  }) async {
    await completeStartup(isAuthenticated: isAuthenticated);
  }

  static Future<void> toNotificationPermissionPage(bool hasSession) =>
      replace(NotificationPermissionRoute(hasSession: hasSession));

  static Future<void> toLanguageSelection() =>
      push(const LanguageSelectionRoute());

  static Future<void> toOnboardPush() => push(const OnboardRoute());
  static Future<void> toSignup() => push(const SignupRoute());
  static Future<void> toOtpVerification(String phoneNumber) =>
      push(OtpVerificationRoute(phoneNumber: phoneNumber));

  static Future<void> toForgotPassword() => push(const ForgotPasswordRoute());

  static String? get currentRouteName {
    return context.router.current.name;
  }

  static String? get currentRoutePath {
    return context.router.current.path;
  }

  static bool isRouteActive(String routeName) {
    return context.router.current.name == routeName;
  }

  static List<AutoRoutePage> get routeStack {
    return context.router.stack;
  }

  static Future<T?> showBottomSheet<T>({
    required Widget Function(BuildContext) builder,
    bool isDismissible = true,
    bool enableDrag = true,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      builder: builder,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape: shape,
    );
  }

  static Future<T?> showDialogBox<T>({
    required Widget Function(BuildContext) builder,
    bool barrierDismissible = true,
    Color? barrierColor,
    String? barrierLabel,
  }) {
    return showDialog<T>(
      context: context,
      builder: builder,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      barrierLabel: barrierLabel,
    );
  }

  static void showSnackBar({
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
    Color? backgroundColor,
  }) => ToastMessageUtils.show(
    message,
    duration: duration,
    action: action,
    backgroundColor: backgroundColor,
  );

  static void hideSnackBar() => ToastMessageUtils.dismiss();
}
