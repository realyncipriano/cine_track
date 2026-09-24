import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../helpers/responsive.dart';
import '../helpers/time_ago.dart';
import '../helpers/share_helper.dart';
import '../providers/user_lists_provider.dart';
import '../providers/auth_provider.dart';

class ListDetailScreen extends StatefulWidget {
  final int listId;

  const ListDetailScreen({super.key, required this.listId});

  @override
  State<ListDetailScreen> createState() => _ListDetailScreenState();
}

class _ListDetailScreenState extends State<ListDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserListsProvider>().fetchListDetail(widget.listId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<UserListsProvider>();
    final auth = context.watch<AuthProvider>();
    final list = prov.currentList;
    final movies = prov.currentMovies;
    final isOwner = list?.userId != null && list!.userId == auth.user?.id;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            prov.clearDetail();
            Navigator.pop(context);
          },
        ),
        title: Text(list?.name ?? 'List', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
        actions: [
          if (list != null)
            IconButton(
              icon: const Icon(Icons.share),
              tooltip: 'Share list',
              onPressed: () {
                ShareHelper.shareList(
                  listId: widget.listId,
                  listName: list.name,
                  ownerName: list.owner?['name'] as String?,
                );
              },
            ),
          if (isOwner)
            PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'delete') _confirmDelete(context, prov, list);
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'delete', child: Text('Delete List')),
              ],
            ),
        ],
      ),
      body: prov.isLoading
          ? _buildSkeleton(theme)
          : prov.error != null && list == null
              ? _buildError(theme)
              : list == null
                  ? _buildError(theme)
                  : RefreshIndicator(
                      onRefresh: () => prov.fetchListDetail(widget.listId),
                      child: CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(child: _buildInfo(list, movies.length, isOwner, theme)),
                          if (movies.isEmpty)
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: _buildEmptyMovies(theme),
                            )
                          else if (list.isRanked)
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => _buildRankedMovie(movies[index], isOwner, index, prov, theme),
                                childCount: movies.length,
                              ),
                            )
                          else
                            SliverPadding(
                              padding: const EdgeInsets.all(16),
                              sliver: SliverGrid(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: Responsive.movieGridColumns(context),
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 0.65,
                                ),
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) => _buildGridMovie(movies[index], isOwner, prov, theme),
                                  childCount: movies.length,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildInfo(dynamic list, int movieCount, bool isOwner, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (list.owner != null) ...[
            Row(
              children: [
                GestureDetector(
                  onTap: () => context.go('/profile/${list.owner['id']}'),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
                        child: Text(
                          (list.owner['name'] as String? ?? '?')[0].toUpperCase(),
                          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: theme.colorScheme.primary),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        list.owner['name'] as String? ?? '',
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text('·', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.24))),
                const SizedBox(width: 8),
                Text(timeAgo(list.createdAt), style: GoogleFonts.inter(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.38))),
              ],
            ),
            const SizedBox(height: 12),
          ],
          if (list.description != null && list.description!.isNotEmpty) ...[
            Text(
              list.description!,
              style: GoogleFonts.inter(fontSize: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.7), height: 1.4),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Text(
                '$movieCount movies',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface.withValues(alpha: 0.54)),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: list.isPublic
                      ? const Color(0xFF3FB950).withValues(alpha: 0.12)
                      : theme.colorScheme.onSurface.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  list.isPublic ? 'Public' : 'Private',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: list.isPublic ? const Color(0xFF3FB950) : theme.colorScheme.onSurface.withValues(alpha: 0.54),
                  ),
                ),
              ),
              if (list.isRanked) ...[
                const SizedBox(width: 8),
                Icon(Icons.sort, size: 14, color: theme.colorScheme.primary.withValues(alpha: 0.7)),
                const SizedBox(width: 4),
                Text('Ranked', style: GoogleFonts.inter(fontSize: 11, color: theme.colorScheme.primary.withValues(alpha: 0.7))),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRankedMovie(dynamic movie, bool isOwner, int rank, UserListsProvider prov, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: Text(
                '${rank + 1}',
                style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w700, color: theme.colorScheme.primary),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: movie.posterUrl != null
                  ? CachedNetworkImage(
                      imageUrl: movie.posterUrl!,
                      width: 40,
                      height: 60,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => Container(width: 40, height: 60, color: theme.scaffoldBackgroundColor),
                    )
                  : Container(width: 40, height: 60, color: theme.scaffoldBackgroundColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
                  ),
                  if (movie.releaseDate != null && movie.releaseDate!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      movie.releaseDate!.length >= 4 ? movie.releaseDate!.substring(0, 4) : movie.releaseDate!,
                      style: GoogleFonts.inter(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.54)),
                    ),
                  ],
                ],
              ),
            ),
            if (movie.voteAverage > 0) ...[
              Row(
                children: [
                  Icon(Icons.star, size: 14, color: theme.colorScheme.primary),
                  const SizedBox(width: 2),
                  Text(movie.voteAverage.toStringAsFixed(1), style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
                ],
              ),
              const SizedBox(width: 8),
            ],
            if (isOwner)
              IconButton(
                icon: Icon(Icons.close, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.38)),
                onPressed: () => prov.removeMovieFromList(widget.listId, movie.movieId),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridMovie(dynamic movie, bool isOwner, UserListsProvider prov, ThemeData theme) {
    return GestureDetector(
      onTap: () => context.go('/movie/${movie.movieId}'),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            if (movie.posterUrl != null)
              CachedNetworkImage(
                imageUrl: movie.posterUrl!,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(color: theme.cardColor),
                errorWidget: (_, _, _) => Container(color: theme.cardColor),
              )
            else
              Container(color: theme.cardColor),
            if (isOwner)
              Positioned(
                top: 4, right: 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, size: 14, color: Colors.white),
                    onPressed: () => prov.removeMovieFromList(widget.listId, movie.movieId),
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            if (movie.voteAverage > 0)
              Positioned(
                bottom: 4, left: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, size: 10, color: theme.colorScheme.primary),
                      const SizedBox(width: 2),
                      Text(movie.voteAverage.toStringAsFixed(1), style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, UserListsProvider prov, dynamic list) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text('Delete list?'),
        content: Text('Are you sure you want to delete "${list.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              prov.deleteList(widget.listId).then((_) {
                if (context.mounted) context.go('/my-lists');
              });
            },
            child: Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMovies(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.movie_outlined, size: 48, color: theme.colorScheme.onSurface.withValues(alpha: 0.24)),
          const SizedBox(height: 12),
          Text('No movies in this list', style: GoogleFonts.inter(fontSize: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.54))),
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
          Text('Failed to load list', style: GoogleFonts.inter(fontSize: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.54))),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<UserListsProvider>().fetchListDetail(widget.listId),
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
      itemCount: 5,
      itemBuilder: (_, _) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Container(height: 72, decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(12))),
      ),
    );
  }
}
