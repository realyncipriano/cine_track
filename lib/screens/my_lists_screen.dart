import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../helpers/responsive.dart';
import '../providers/user_lists_provider.dart';
import '../widgets/list_card.dart';
import 'create_list_sheet.dart';

class MyListsScreen extends StatefulWidget {
  const MyListsScreen({super.key});

  @override
  State<MyListsScreen> createState() => _MyListsScreenState();
}

class _MyListsScreenState extends State<MyListsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserListsProvider>().fetchMyLists();
    });
  }

  int _columnCount(BuildContext context) {
    if (Responsive.isLarge(context)) return 4;
    if (Responsive.isDesktop(context)) return 3;
    if (Responsive.isTablet(context)) return 2;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<UserListsProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        title: Text('My Lists', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateSheet(context),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
      body: prov.isLoading
          ? _buildSkeletonGrid(theme)
          : prov.error != null && prov.myLists.isEmpty
              ? _buildError(theme)
              : prov.myLists.isEmpty
                  ? _buildEmpty(theme)
                  : RefreshIndicator(
                      onRefresh: () => prov.fetchMyLists(),
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (scroll) {
                          if (scroll is ScrollEndNotification &&
                              scroll.metrics.pixels >= scroll.metrics.maxScrollExtent - 200 &&
                              prov.hasMore && !prov.isLoadingMore) {
                            prov.fetchMyLists(loadMore: true);
                          }
                          return false;
                        },
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final cols = _columnCount(context);
                            final crossAxisSpacing = 12.0;
                            final totalSpacing = crossAxisSpacing * (cols - 1);
                            final childWidth = (constraints.maxWidth - 32 - totalSpacing) / cols;
                            final childAspectRatio = childWidth / (childWidth * 1.4);

                            return GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: cols,
                                crossAxisSpacing: crossAxisSpacing,
                                mainAxisSpacing: 12,
                                childAspectRatio: childAspectRatio,
                              ),
                              itemCount: prov.myLists.length + (prov.hasMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index >= prov.myLists.length) {
                                  return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                                }
                                final list = prov.myLists[index];
                                return ListCard(
                                  list: list,
                                  onTap: () => context.go('/lists/${list.id}'),
                                  onLongPress: () => _showListOptions(context, list),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
    );
  }

  void _showCreateSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const CreateListSheet(),
    );
  }

  void _showListOptions(BuildContext context, dynamic list) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showCreateSheet(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                title: Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDelete(context, list.id);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, int listId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text('Delete list?'),
        content: const Text('This action cannot be undone. All movies in this list will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<UserListsProvider>().deleteList(listId);
            },
            child: Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.list_alt_outlined, size: 64, color: theme.colorScheme.onSurface.withValues(alpha: 0.24)),
          const SizedBox(height: 16),
          Text('No lists yet', style: GoogleFonts.inter(fontSize: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.54))),
          const SizedBox(height: 8),
          Text('Create your first list to organize movies', style: GoogleFonts.inter(fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.38))),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showCreateSheet(context),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Create List'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
          Text('Failed to load lists', style: GoogleFonts.inter(fontSize: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.54))),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<UserListsProvider>().fetchMyLists(),
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

  Widget _buildSkeletonGrid(ThemeData theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = _columnCount(context);
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.7,
          ),
          itemCount: 6,
          itemBuilder: (_, _) => const ListCardSkeleton(),
        );
      },
    );
  }
}
