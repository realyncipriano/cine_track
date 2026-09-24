import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../helpers/time_ago.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final List<Map<String, dynamic>> _activities = <Map<String, dynamic>>[];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _page = 1;
  bool _hasMore = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<AuthProvider>().isAuthenticated) {
        _fetch();
      } else {
        setState(() => _isLoading = false);
      }
    });
  }

  Future<void> _fetch({bool loadMore = false}) async {
    if (loadMore && (!_hasMore || _isLoadingMore)) return;
    if (loadMore) {
      _isLoadingMore = true;
    } else {
      _isLoading = true;
      _page = 1;
    }
    setState(() {});
    try {
      final api = context.read<ApiService>();
      final data = await api.get('/feed/timeline.php?page=$_page&per_page=20');
      final items = (data['activities'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ?? [];
      final total = data['total'] as int? ?? 0;
      setState(() {
        if (loadMore) {
          _activities.addAll(items);
        } else {
          _activities
            ..clear()
            ..addAll(items);
        }
        _hasMore = _activities.length < total;
        _page++;
        _error = null;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);

    if (!auth.isAuthenticated) {
      return _buildGuestPrompt(theme);
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        title: Row(
          children: [
            Icon(Icons.explore_rounded, size: 24, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text('Feed', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
            onPressed: () => context.go('/notifications'),
          ),
        ],
      ),
      body: _isLoading
          ? _buildSkeleton(theme)
          : _error != null && _activities.isEmpty
              ? _buildError(theme)
              : _activities.isEmpty
                  ? _buildEmpty(theme)
                  : RefreshIndicator(
                      onRefresh: () => _fetch(),
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (scroll) {
                          if (scroll is ScrollEndNotification &&
                              scroll.metrics.pixels >= scroll.metrics.maxScrollExtent - 200 &&
                              _hasMore && !_isLoadingMore) {
                            _fetch(loadMore: true);
                          }
                          return false;
                        },
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _activities.length + (_hasMore ? 1 : 0),
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            if (index >= _activities.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                              );
                            }
                            return _buildActivityCard(_activities[index], theme);
                          },
                        ),
                      ),
                    ),
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity, ThemeData theme) {
    final actionType = activity['action_type'] as String? ?? '';
    final meta = activity['metadata'] as Map<String, dynamic>?;
    final createdAt = activity['created_at'] as String? ?? '';
    final userData = activity['user'] as Map<String, dynamic>?;
    final userName = userData?['name'] as String? ?? 'Someone';
    final userId = userData?['id'] as int? ?? 0;

    String actionText;
    String? posterPath;
    VoidCallback? onTap;

    switch (actionType) {
      case 'watched':
        actionText = 'Watched ${meta?['movie_title'] ?? 'a movie'}';
        posterPath = meta?['poster_path'] as String?;
        onTap = meta?['movie_id'] != null
            ? () => context.go('/movie/${meta!['movie_id']}')
            : null;
        break;
      case 'reviewed':
        actionText = 'Reviewed ${meta?['movie_title'] ?? 'a movie'}';
        onTap = meta?['movie_id'] != null
            ? () => context.go('/movie/${meta!['movie_id']}')
            : null;
        break;
      case 'favorited':
        actionText = 'Added ${meta?['movie_title'] ?? 'a movie'} to favorites';
        onTap = meta?['movie_id'] != null
            ? () => context.go('/movie/${meta!['movie_id']}')
            : null;
        break;
      case 'watchlisted':
        actionText = 'Added ${meta?['movie_title'] ?? 'a movie'} to watchlist';
        onTap = meta?['movie_id'] != null
            ? () => context.go('/movie/${meta!['movie_id']}')
            : null;
        break;
      case 'followed':
        actionText = 'Followed ${meta?['user_name'] ?? 'someone'}';
        onTap = meta?['user_id'] != null
            ? () => context.go('/profile/${meta!['user_id']}')
            : null;
        break;
      default:
        actionText = actionType;
        onTap = null;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: userId > 0 ? () => context.go('/profile/$userId') : null,
              child: CircleAvatar(
                radius: 20,
                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: theme.colorScheme.primary),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.inter(fontSize: 13, color: theme.colorScheme.onSurface),
                      children: [
                        TextSpan(
                          text: userName,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        TextSpan(
                          text: ' $actionText',
                          style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeAgo(createdAt),
                    style: GoogleFonts.inter(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.38)),
                  ),
                ],
              ),
            ),
            if (posterPath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  'https://image.tmdb.org/t/p/w92$posterPath',
                  width: 48,
                  height: 72,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestPrompt(ThemeData theme) {
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        title: Row(
          children: [
            Icon(Icons.explore_rounded, size: 24, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text('Feed', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.group_outlined, size: 64, color: theme.colorScheme.onSurface.withValues(alpha: 0.24)),
            const SizedBox(height: 16),
            Text(
              'Sign in to see your feed',
              style: GoogleFonts.inter(fontSize: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.54)),
            ),
            const SizedBox(height: 8),
            Text(
              'Follow users and see their activity here',
              style: GoogleFonts.inter(fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.38)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(ThemeData theme) {
    return RefreshIndicator(
      onRefresh: () => _fetch(),
      child: ListView(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.rss_feed_outlined, size: 64, color: theme.colorScheme.onSurface.withValues(alpha: 0.24)),
                const SizedBox(height: 16),
                Text(
                  'No activity yet',
                  style: GoogleFonts.inter(fontSize: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.54)),
                ),
                const SizedBox(height: 8),
                Text(
                  'Follow some users to see their activity here',
                  style: GoogleFonts.inter(fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.38)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: theme.colorScheme.onSurface.withValues(alpha: 0.24)),
          const SizedBox(height: 16),
          Text(
            'Failed to load feed',
            style: GoogleFonts.inter(fontSize: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.54)),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _fetch(),
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

  Widget _buildSkeleton(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (_, _) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Container(
          height: 80,
          decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
