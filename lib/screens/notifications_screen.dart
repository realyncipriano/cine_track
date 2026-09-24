import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../helpers/time_ago.dart';
import '../models/notification_type.dart';
import '../providers/notification_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<NotificationProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Notifications', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
        actions: [
          if (prov.notifications.any((n) => !n.isRead))
            TextButton(
              onPressed: () => prov.markAllRead(),
              child: Text(
                'Mark all read',
                style: GoogleFonts.inter(fontSize: 13, color: theme.colorScheme.primary),
              ),
            ),
        ],
      ),
      body: prov.isLoading
          ? _buildSkeleton(theme)
          : prov.notifications.isEmpty
              ? _buildEmpty(theme)
              : RefreshIndicator(
                  onRefresh: () => prov.fetchNotifications(),
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (scroll) {
                      if (scroll is ScrollEndNotification &&
                          scroll.metrics.pixels >= scroll.metrics.maxScrollExtent - 200 &&
                          prov.hasMore && !prov.isLoadingMore) {
                        prov.loadMore();
                      }
                      return false;
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: prov.notifications.length + (prov.hasMore ? 1 : 0),
                      separatorBuilder: (_, _) => const SizedBox(height: 6),
                      itemBuilder: (context, index) {
                        if (index >= prov.notifications.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          );
                        }
                        return _buildNotificationItem(prov, index, theme);
                      },
                    ),
                  ),
                ),
    );
  }

  Widget _buildNotificationItem(NotificationProvider prov, int index, ThemeData theme) {
    final notif = prov.notifications[index];
    final isUnread = !notif.isRead;

    IconData icon;
    Color iconColor;
    String? navigatePath;

    switch (notif.type) {
      case NotificationType.follow:
        icon = Icons.person_add;
        iconColor = const Color(0xFFF0883E);
        navigatePath = '/profile/${notif.actorId}';
        break;
      case NotificationType.reviewLike:
        icon = Icons.favorite;
        iconColor = theme.colorScheme.primary;
        navigatePath = '/movies/${notif.targetId}';
        break;
      case NotificationType.reply:
        icon = Icons.reply;
        iconColor = const Color(0xFF58A6FF);
        navigatePath = '/movies/${notif.targetId}';
        break;
      default:
        icon = Icons.notifications_outlined;
        iconColor = theme.colorScheme.onSurface.withValues(alpha: 0.38);
        navigatePath = null;
    }

    final actorName = notif.actorName ?? 'Someone';
    final message = _notificationMessage(notif.type, actorName);

    return InkWell(
      onTap: () {
        if (isUnread) prov.markAsRead(notif.id);
        if (navigatePath != null) context.go(navigatePath);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUnread
              ? theme.colorScheme.primary.withValues(alpha: 0.06)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: isUnread
              ? Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.12))
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: iconColor.withValues(alpha: 0.12),
                  child: Icon(icon, size: 18, color: iconColor),
                ),
                if (isUnread)
                  Positioned(
                    top: 0, right: 0,
                    child: Container(
                      width: 10, height: 10,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF0883E),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: isUnread ? FontWeight.w600 : FontWeight.w400,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeAgo(notif.createdAt),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _notificationMessage(NotificationType type, String actorName) {
    switch (type) {
      case NotificationType.follow:
        return '$actorName followed you';
      case NotificationType.reviewLike:
        return '$actorName liked your review';
      case NotificationType.reply:
        return '$actorName replied to your review';
      default:
        return 'New notification from $actorName';
    }
  }

  Widget _buildEmpty(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_off_outlined, size: 64, color: theme.colorScheme.onSurface.withValues(alpha: 0.24)),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: GoogleFonts.inter(fontSize: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.54)),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll notify you when someone follows you or interacts with your reviews',
            style: GoogleFonts.inter(fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.38)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSkeleton(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (_, _) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Container(
          height: 64,
          decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
