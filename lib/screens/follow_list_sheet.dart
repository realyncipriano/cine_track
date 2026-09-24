import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config.dart';
import '../models/user.dart';
import '../providers/follow_provider.dart';
import '../services/api_service.dart';

class FollowListSheet extends StatefulWidget {
  final int userId;
  final String type;

  const FollowListSheet({super.key, required this.userId, required this.type});

  @override
  State<FollowListSheet> createState() => _FollowListSheetState();
}

class _FollowListSheetState extends State<FollowListSheet> {
  final ApiService _api = ApiService();
  final List<User> _users = [];
  bool _isLoading = true;
  int _page = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _isLoading = true);
    try {
      final endpoint = widget.type == 'followers'
          ? '/users/followers.php'
          : '/users/following.php';
      final data = await _api.get('$endpoint?user_id=${widget.userId}&page=$_page&per_page=30');
      final list = (data[widget.type] as List<dynamic>?)
              ?.map((u) => User.fromJson(u as Map<String, dynamic>))
              .toList() ??
          [];
      final total = data['total'] as int? ?? 0;
      setState(() {
        _users.addAll(list);
        _hasMore = _users.length < total;
        _page++;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final followProv = context.watch<FollowProvider>();
    final sheetHeight = MediaQuery.of(context).size.height * 0.75;

    return Container(
      height: sheetHeight,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.24),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Text(
                  widget.type == 'followers' ? 'Followers' : 'Following',
                  style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _isLoading && _users.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _users.isEmpty
                    ? Center(
                        child: Text(
                          'No ${widget.type} yet',
                          style: GoogleFonts.inter(fontSize: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.38)),
                        ),
                      )
                    : NotificationListener<ScrollNotification>(
                        onNotification: (scroll) {
                          if (scroll is ScrollEndNotification && scroll.metrics.pixels >= scroll.metrics.maxScrollExtent - 100 && _hasMore && !_isLoading) {
                            _fetch();
                          }
                          return false;
                        },
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: _users.length + (_hasMore ? 1 : 0),
                          separatorBuilder: (_, _) => const Divider(height: 1, indent: 72),
                          itemBuilder: (context, index) {
                            if (index >= _users.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                              );
                            }
                            final user = _users[index];
                            return ListTile(
                              leading: CircleAvatar(
                                radius: 20,
                                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
                                backgroundImage: user.avatarUrl != null
                                    ? CachedNetworkImageProvider('${AppConfig.imageBaseUrl}${user.avatarUrl}')
                                    : null,
                                child: user.avatarUrl == null
                                    ? Text(
                                        user.name[0].toUpperCase(),
                                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: theme.colorScheme.primary),
                                      )
                                    : null,
                              ),
                              title: Text(user.name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
                              subtitle: Text('@${user.username}', style: GoogleFonts.inter(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.54))),
                              trailing: followProv.isFollowing(user.id)
                                  ? SizedBox(
                                      height: 32,
                                      child: OutlinedButton(
                                        onPressed: () => followProv.toggleFollow(user.id).catchError((_) => false),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                          foregroundColor: theme.colorScheme.onSurface,
                                          side: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.24)),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                        child: Text('Unfollow', style: GoogleFonts.inter(fontSize: 11)),
                                      ),
                                    )
                                  : SizedBox(
                                      height: 32,
                                      child: ElevatedButton(
                                        onPressed: () => followProv.toggleFollow(user.id).catchError((_) => false),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                          backgroundColor: theme.colorScheme.primary,
                                          foregroundColor: theme.colorScheme.onPrimary,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                        child: Text('Follow', style: GoogleFonts.inter(fontSize: 11)),
                                      ),
                                    ),
                              onTap: () {
                                Navigator.pop(context);
                                context.go('/profile/${user.id}');
                              },
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
