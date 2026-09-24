import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config.dart';
import '../helpers/responsive.dart';
import '../helpers/time_ago.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../providers/block_provider.dart';
import '../providers/user_profile_provider.dart';
import '../providers/follow_provider.dart';
import '../services/api_service.dart';
import '../helpers/share_helper.dart';
import 'follow_list_sheet.dart';

class PublicProfileScreen extends StatefulWidget {
  final int userId;

  const PublicProfileScreen({super.key, required this.userId});

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  final ApiService _api = ApiService();

  List<Map<String, dynamic>> _activities = [];
  List<Map<String, dynamic>> _lists = [];
  bool _loadingActivities = false;
  bool _loadingLists = false;
  int _activityPage = 1;
  bool _hasMoreActivities = true;

  @override
  void initState() {
    super.initState();
    final profileProv = context.read<UserProfileProvider>();
    profileProv.fetchProfile(widget.userId);
    _fetchActivities();
    _fetchLists();
  }

  Future<void> _fetchActivities({bool loadMore = false}) async {
    if (loadMore && (!_hasMoreActivities || _loadingActivities)) return;
    setState(() => _loadingActivities = true);
    try {
      final data = await _api.get('/users/activity.php?user_id=${widget.userId}&page=$_activityPage&per_page=10');
      final items = (data['activities'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [];
      final total = data['total'] as int? ?? 0;
      setState(() {
        if (loadMore) {
          _activities.addAll(items);
        } else {
          _activities = items;
        }
        _hasMoreActivities = _activities.length < total;
        _activityPage++;
      });
    } catch (e) {
      debugPrint('fetchActivities error: $e');
    } finally {
      setState(() => _loadingActivities = false);
    }
  }

  Future<void> _fetchLists() async {
    setState(() => _loadingLists = true);
    try {
      final data = await _api.get('/lists/list.php?user_id=${widget.userId}&per_page=10');
      final items = (data['lists'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [];
      setState(() => _lists = items);
    } catch (e) {
      debugPrint('fetchLists error: $e');
    } finally {
      setState(() => _loadingLists = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileProv = context.watch<UserProfileProvider>();
    final followProv = context.watch<FollowProvider>();
    final authProv = context.watch<AuthProvider>();
    final profile = profileProv.profile;
    final counts = profileProv.counts;
    final isOwnProfile = authProv.user?.id == widget.userId;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          profile?.name ?? 'Profile',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
        ),
        actions: [
          if (profile != null)
            IconButton(
              icon: const Icon(Icons.share),
              tooltip: 'Share profile',
              onPressed: () {
                ShareHelper.shareProfile(
                  userId: widget.userId,
                  name: profile.name,
                );
              },
            ),
        ],
      ),
      body: profileProv.isLoading
          ? _buildSkeleton(theme)
          : profileProv.error != null
              ? _buildError(theme)
              : RefreshIndicator(
                  onRefresh: () async {
                    await profileProv.fetchProfile(widget.userId);
                    await _fetchActivities();
                    await _fetchLists();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ResponsiveContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(profile, counts, theme),
                          if (!isOwnProfile && authProv.isAuthenticated)
                            _buildFollowButton(profileProv, followProv, theme),
                          if (!isOwnProfile && authProv.isAuthenticated)
                            _buildBlockButton(theme),
                          const SizedBox(height: 24),
                          if (_lists.isNotEmpty)
                            _buildListsSection(theme),
                          _buildActivitySection(theme),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildHeader(User? profile, Map<String, int> counts, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
            backgroundImage: profile?.avatarUrl != null
                ? CachedNetworkImageProvider('${AppConfig.imageBaseUrl}${profile!.avatarUrl}')
                : null,
            child: profile?.avatarUrl == null
                ? Text(
                    (profile?.name ?? '?')[0].toUpperCase(),
                    style: GoogleFonts.montserrat(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            profile?.name ?? 'User',
            style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 4),
          Text(
            '@${profile?.username ?? ''}',
            style: GoogleFonts.inter(fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.38)),
          ),
          if (profile?.bio != null && profile!.bio!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              profile.bio!,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.7), height: 1.4),
            ),
          ],
          const SizedBox(height: 20),
          _buildStatsRow(counts, theme),
        ],
      ),
    );
  }

  Widget _buildStatsRow(Map<String, int> counts, ThemeData theme) {
    final stats = [
      {'icon': Icons.movie_outlined, 'count': '${counts['movies_watched'] ?? 0}', 'label': 'Movies', 'color': const Color(0xFF3FB950)},
      {'icon': Icons.rate_review_outlined, 'count': '${counts['reviews'] ?? 0}', 'label': 'Reviews', 'color': const Color(0xFF58A6FF)},
      {'icon': Icons.list_alt, 'count': '${counts['lists'] ?? 0}', 'label': 'Lists', 'color': theme.colorScheme.primary},
      {'icon': Icons.people_outline, 'count': '${counts['followers'] ?? 0}', 'label': 'Followers', 'color': const Color(0xFFF0883E)},
      {'icon': Icons.person_outline, 'count': '${counts['following'] ?? 0}', 'label': 'Following', 'color': const Color(0xFFDA7BEF)},
    ];

    return Row(
      children: stats.map((s) => Expanded(
        child: GestureDetector(
          onTap: (s['label'] == 'Followers' || s['label'] == 'Following')
              ? () => _showFollowList(context, s['label'] as String)
              : null,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Icon(s['icon'] as IconData, size: 18, color: s['color'] as Color),
                const SizedBox(height: 6),
                Text(
                  s['count'] as String,
                  style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface),
                ),
                Text(
                  s['label'] as String,
                  style: GoogleFonts.inter(fontSize: 10, color: theme.colorScheme.onSurface.withValues(alpha: 0.54)),
                ),
              ],
            ),
          ),
        ),
      )).toList(),
    );
  }

  void _showFollowList(BuildContext context, String type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FollowListSheet(
        userId: widget.userId,
        type: type.toLowerCase(),
      ),
    );
  }

  Widget _buildFollowButton(UserProfileProvider profileProv, FollowProvider followProv, ThemeData theme) {
    final isFollowing = profileProv.isFollowing ?? false;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: SizedBox(
        width: double.infinity,
        height: 44,
        child: ElevatedButton.icon(
          onPressed: () async {
            try {
              final newState = await followProv.toggleFollow(widget.userId);
              profileProv.setIsFollowing(newState);
            } catch (_) {}
          },
          icon: Icon(isFollowing ? Icons.person_remove : Icons.person_add, size: 18),
          label: Text(isFollowing ? 'Unfollow' : 'Follow'),
          style: ElevatedButton.styleFrom(
            backgroundColor: isFollowing
                ? theme.colorScheme.onSurface.withValues(alpha: 0.08)
                : theme.colorScheme.primary,
            foregroundColor: isFollowing
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  Widget _buildBlockButton(ThemeData theme) {
    final blockProv = context.watch<BlockProvider>();
    final isBlocked = blockProv.isBlocked(widget.userId);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      child: SizedBox(
        width: double.infinity,
        height: 44,
        child: OutlinedButton.icon(
          onPressed: () async {
            try {
              final newBlocked = await blockProv.toggleBlock(widget.userId);
              if (newBlocked) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User blocked'), backgroundColor: Colors.orangeAccent),
                  );
                }
              }
            } catch (_) {}
          },
          icon: Icon(isBlocked ? Icons.block : Icons.block, size: 18),
          label: Text(isBlocked ? 'Unblock' : 'Block'),
          style: OutlinedButton.styleFrom(
            foregroundColor: isBlocked
                ? theme.colorScheme.onSurface
                : theme.colorScheme.error,
            side: BorderSide(
              color: isBlocked
                  ? theme.colorScheme.onSurface.withValues(alpha: 0.24)
                  : theme.colorScheme.error.withValues(alpha: 0.5),
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  Widget _buildListsSection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.list_alt, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.54)),
              const SizedBox(width: 6),
              Text('Lists', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
              const SizedBox(width: 6),
              Text('(${_lists.length})', style: GoogleFonts.inter(fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.38))),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _lists.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final list = _lists[index];
                return GestureDetector(
                  onTap: () {
                    final listId = list['id'] as int?;
                    if (listId != null) context.go('/lists/$listId');
                  },
                  child: Container(
                    width: 160,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          list['name'] as String? ?? '',
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (list['description'] != null && (list['description'] as String).isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            list['description'] as String,
                            style: GoogleFonts.inter(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.54)),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const Spacer(),
                        Row(
                          children: [
                            if (list['is_ranked'] == true)
                              Icon(Icons.sort, size: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.38)),
                            const Spacer(),
                            Text(
                              list['is_public'] == true ? 'Public' : 'Private',
                              style: GoogleFonts.inter(fontSize: 10, color: theme.colorScheme.onSurface.withValues(alpha: 0.38)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildActivitySection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.54)),
              const SizedBox(width: 6),
              Text('Activity', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
            ],
          ),
          const SizedBox(height: 12),
          if (_activities.isEmpty && !_loadingActivities)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(Icons.history, size: 32, color: theme.colorScheme.onSurface.withValues(alpha: 0.24)),
                  const SizedBox(height: 8),
                  Text('No activity yet', style: GoogleFonts.inter(fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.38))),
                ],
              ),
            )
          else
            ..._activities.map((a) => _buildActivityItem(a, theme)),
          if (_loadingActivities)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.primary)),
            ),
          if (_hasMoreActivities && !_loadingActivities && _activities.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: TextButton(
                  onPressed: () => _fetchActivities(loadMore: true),
                  child: Text('Load more', style: GoogleFonts.inter(fontSize: 13, color: theme.colorScheme.primary)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity, ThemeData theme) {
    final actionType = activity['action_type'] as String? ?? '';
    final meta = activity['metadata'] as Map<String, dynamic>?;
    final createdAt = activity['created_at'] as String? ?? '';

    String actionText;
    IconData icon;
    Color iconColor;
    VoidCallback? onTap;

    switch (actionType) {
      case 'watched':
        actionText = 'Watched ${meta?['movie_title'] ?? 'a movie'}';
        icon = Icons.visibility;
        iconColor = const Color(0xFF3FB950);
        onTap = meta?['movie_id'] != null
            ? () => context.go('/movie/${meta!['movie_id']}')
            : null;
        break;
      case 'reviewed':
        actionText = 'Reviewed ${meta?['movie_title'] ?? 'a movie'}';
        icon = Icons.rate_review;
        iconColor = const Color(0xFF58A6FF);
        onTap = meta?['movie_id'] != null
            ? () => context.go('/movie/${meta!['movie_id']}')
            : null;
        break;
      case 'favorited':
        actionText = 'Added ${meta?['movie_title'] ?? 'a movie'} to favorites';
        icon = Icons.favorite;
        iconColor = theme.colorScheme.primary;
        onTap = meta?['movie_id'] != null
            ? () => context.go('/movie/${meta!['movie_id']}')
            : null;
        break;
      case 'watchlisted':
        actionText = 'Added ${meta?['movie_title'] ?? 'a movie'} to watchlist';
        icon = Icons.bookmark;
        iconColor = const Color(0xFFDA7BEF);
        onTap = meta?['movie_id'] != null
            ? () => context.go('/movie/${meta!['movie_id']}')
            : null;
        break;
      case 'followed':
        actionText = 'Followed ${meta?['user_name'] ?? 'someone'}';
        icon = Icons.person_add;
        iconColor = const Color(0xFFF0883E);
        onTap = meta?['user_id'] != null
            ? () => context.go('/profile/${meta!['user_id']}')
            : null;
        break;
      default:
        actionText = actionType;
        icon = Icons.circle;
        iconColor = theme.colorScheme.onSurface.withValues(alpha: 0.38);
        onTap = null;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  actionText,
                  style: GoogleFonts.inter(fontSize: 13, color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500),
                ),
              ),
              Text(
                timeAgo(createdAt),
                style: GoogleFonts.inter(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.38)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeleton(ThemeData theme) {
    return SingleChildScrollView(
      child: ResponsiveContainer(
        child: Column(
          children: [
            const SizedBox(height: 32),
            CircleAvatar(
              radius: 48,
              backgroundColor: theme.cardColor,
            ),
            const SizedBox(height: 16),
            Container(width: 160, height: 20, decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(6))),
            const SizedBox(height: 8),
            Container(width: 100, height: 14, decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(6))),
            const SizedBox(height: 24),
            Row(
              children: List.generate(5, (_) => Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 70,
                  decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(10)),
                ),
              )),
            ),
            const SizedBox(height: 24),
            ...List.generate(3, (_) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(10)),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildError(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_off, size: 48, color: theme.colorScheme.onSurface.withValues(alpha: 0.24)),
          const SizedBox(height: 16),
          Text('User not found', style: GoogleFonts.inter(fontSize: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.54))),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<UserProfileProvider>().fetchProfile(widget.userId),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
