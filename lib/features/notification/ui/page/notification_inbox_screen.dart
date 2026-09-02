import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data_portal_survey/common/theme/app_shapes.dart';
import 'package:data_portal_survey/common/theme/app_spacing.dart';
import 'package:data_portal_survey/common/theme/theme_colors.dart';
import 'package:data_portal_survey/common/utils/card_boxshadow_utils.dart';
import 'package:data_portal_survey/common/utils/toast_message_utils.dart';
import 'package:data_portal_survey/common/widgets/common_loader.dart';
import 'package:data_portal_survey/common/widgets/page_wrapper.dart';
import 'package:data_portal_survey/features/notification/model/inbox_notification_model.dart';
import 'package:data_portal_survey/features/notification/resource/notification_repository.dart';
import 'package:data_portal_survey/features/notification/service/notification_badge_service.dart';
import 'package:data_portal_survey/features/notification/service/notification_badge_sync.dart';
import 'package:data_portal_survey/features/notification/service/notification_navigation_handler.dart';

@RoutePage()
class NotificationInboxScreen extends StatefulWidget {
  const NotificationInboxScreen({super.key});

  @override
  State<NotificationInboxScreen> createState() =>
      _NotificationInboxScreenState();
}

class _NotificationInboxScreenState extends State<NotificationInboxScreen> {
  final List<InboxNotificationModel> _items = [];
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _isMarkingAll = false;
  String? _handlingNotificationId;
  int _currentPage = 1;
  int _totalPages = 1;

  NotificationRepository get _repository =>
      RepositoryProvider.of<NotificationRepository>(context);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadNotifications();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isLoadingMore || _currentPage >= _totalPages) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);

    final response = await _repository.getMyNotifications(page: 1);
    if (!mounted) return;

    if (response.data != null) {
      setState(() {
        _items
          ..clear()
          ..addAll(response.data!.items);
        _currentPage = response.data!.currentPage;
        _totalPages = response.data!.totalPages;
        _isLoading = false;
      });
      await NotificationBadgeSync.instance.syncFromServer();
      return;
    }

    setState(() => _isLoading = false);
    if ((response.message ?? '').isNotEmpty) {
      ToastMessageUtils.error(response.message!);
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || _currentPage >= _totalPages) return;

    setState(() => _isLoadingMore = true);
    final nextPage = _currentPage + 1;
    final response = await _repository.getMyNotifications(page: nextPage);
    if (!mounted) return;

    if (response.data != null) {
      setState(() {
        _items.addAll(response.data!.items);
        _currentPage = response.data!.currentPage;
        _totalPages = response.data!.totalPages;
        _isLoadingMore = false;
      });
      return;
    }

    setState(() => _isLoadingMore = false);
  }

  Future<void> _markAllRead() async {
    if (_isMarkingAll) return;
    setState(() => _isMarkingAll = true);

    final response = await _repository.markAllNotificationsRead();
    if (!mounted) return;

    if (response.data != null) {
      final readAt = DateTime.now().toUtc().toIso8601String();
      setState(() {
        for (var i = 0; i < _items.length; i++) {
          if (_items[i].isUnread) {
            _items[i] = _items[i].copyWith(readAt: readAt);
          }
        }
      });
      await NotificationBadgeService.instance.resetBadgeCount();
      await NotificationBadgeSync.instance.syncFromServer();
    } else if ((response.message ?? '').isNotEmpty) {
      ToastMessageUtils.error(response.message!);
    }

    if (mounted) {
      setState(() => _isMarkingAll = false);
    }
  }

  Future<void> _onNotificationTap(InboxNotificationModel notification) async {
    if (_handlingNotificationId != null) return;

    setState(() => _handlingNotificationId = notification.id);

    if (notification.isUnread) {
      setState(() {
        final index = _items.indexWhere((item) => item.id == notification.id);
        if (index != -1) {
          _items[index] = notification.copyWith(
            readAt: DateTime.now().toUtc().toIso8601String(),
          );
        }
      });
    }

    try {
      await NotificationNavigationHandler.instance.handleInboxNotification(
        notification,
      );
    } finally {
      if (mounted) {
        setState(() => _handlingNotificationId = null);
      }
    }
  }

  String _formatDate(String raw) {
    if (raw.isEmpty) return '';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;

    final local = parsed.toLocal();
    final now = DateTime.now();
    final diff = now.difference(local);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return '${local.day}/${local.month}/${local.year}';
  }

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      title: 'Notifications',
      padding: EdgeInsets.zero,
      body: CommonLoaderOverlay(
        isLoading: _handlingNotificationId != null,
        child: Column(
          children: [
            if (_items.any((item) => item.isUnread))
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s16,
                  vertical: AppSpacing.s8,
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _isMarkingAll ? null : _markAllRead,
                    child: _isMarkingAll
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Mark all read'),
                  ),
                ),
              ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _loadNotifications,
                      child: _items.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: const [
                                SizedBox(height: 120),
                                Center(
                                  child: Text(
                                    'No notifications yet',
                                    style: TextStyle(
                                      color: ThemeColors.lightTextColor,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : ListView.separated(
                              controller: _scrollController,
                              clipBehavior: Clip.none,
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.s16,
                                AppSpacing.s8,
                                AppSpacing.s16,
                                AppSpacing.s16,
                              ),
                              itemCount:
                                  _items.length + (_isLoadingMore ? 1 : 0),
                              separatorBuilder: (_, index) =>
                                  const SizedBox(height: AppSpacing.s12),
                              itemBuilder: (context, index) {
                                if (index >= _items.length) {
                                  return const Padding(
                                    padding: AppInsets.v12,
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }

                                final notification = _items[index];
                                return _NotificationInboxCard(
                                  notification: notification,
                                  formattedDate: _formatDate(
                                    notification.createdAt,
                                  ),
                                  onTap: () => _onNotificationTap(notification),
                                );
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationInboxCard extends StatelessWidget {
  final InboxNotificationModel notification;
  final String formattedDate;
  final VoidCallback onTap;

  const _NotificationInboxCard({
    required this.notification,
    required this.formattedDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeColors.cardBackGroundColor,
        borderRadius: AppShapes.radiusLg,
        boxShadow: [CardBoxShadowUtils.cardBoxShadow],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppShapes.radiusLg,
          child: Padding(
            padding: AppInsets.all16,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (notification.isUnread)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 6, right: 10),
                    decoration: const BoxDecoration(
                      color: ThemeColors.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  )
                else
                  const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: notification.isUnread
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: ThemeColors.black,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s4),
                      Text(
                        notification.body,
                        style: const TextStyle(
                          fontSize: 13,
                          color: ThemeColors.darkGrey,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          fontSize: 12,
                          color: ThemeColors.lightTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
