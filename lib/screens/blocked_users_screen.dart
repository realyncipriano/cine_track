import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config.dart';
import '../models/user.dart';
import '../providers/block_provider.dart';

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  final List<User> _users = [];
  int _page = 1;
  bool _hasMore = true;
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch({bool loadMore = false}) async {
    if (loadMore && (!_hasMore || _loadingMore)) return;
    setState(() => _loadingMore = true);

    try {
      final prov = context.read<BlockProvider>();
      final users = await prov.fetchBlockedUsers(page: _page);
      setState(() {
        if (loadMore) {
          _users.addAll(users);
        } else {
          _users.clear();
          _users.addAll(users);
        }
        _hasMore = users.length >= 20;
        _page++;
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load blocked users'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  Future<void> _unblock(User user) async {
    try {
      final prov = context.read<BlockProvider>();
      await prov.toggleBlock(user.id);
      setState(() => _users.removeWhere((u) => u.id == user.id));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unblocked ${user.name}'), backgroundColor: Colors.greenAccent),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to unblock user'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Blocked Users', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
      ),
      body: _users.isEmpty && !_loadingMore
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.block, size: 48, color: theme.colorScheme.onSurface.withValues(alpha: 0.24)),
                  const SizedBox(height: 12),
                  Text(
                    'No blocked users',
                    style: GoogleFonts.inter(fontSize: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.54)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'You haven\'t blocked anyone yet',
                    style: GoogleFonts.inter(fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.38)),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () {
                _page = 1;
                _hasMore = true;
                return _fetch();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _users.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _users.length) {
                    if (_loadingMore) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      );
                    }
                    return Center(
                      child: TextButton(
                        onPressed: () => _fetch(loadMore: true),
                        child: const Text('Load more'),
                      ),
                    );
                  }

                  final user = _users[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => context.go('/profile/${user.id}'),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
                                  backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                                      ? CachedNetworkImageProvider('${AppConfig.imageBaseUrl}${user.avatarUrl}')
                                      : null,
                                  child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                                      ? Text(
                                          (user.name)[0].toUpperCase(),
                                          style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: theme.colorScheme.primary,
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.name,
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    Text(
                                      '@${user.username}',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () => _unblock(user),
                            style: TextButton.styleFrom(
                              foregroundColor: theme.colorScheme.primary,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                            ),
                            child: Text('Unblock', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
