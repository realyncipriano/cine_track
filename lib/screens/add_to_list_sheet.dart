import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/movie.dart';
import '../providers/user_lists_provider.dart';
import 'create_list_sheet.dart';

class AddToListSheet extends StatefulWidget {
  final Movie movie;

  const AddToListSheet({super.key, required this.movie});

  @override
  State<AddToListSheet> createState() => _AddToListSheetState();
}

class _AddToListSheetState extends State<AddToListSheet> {
  final Set<int> _selectedListIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = context.read<UserListsProvider>();
      if (prov.myLists.isEmpty) {
        prov.fetchMyLists();
      }
    });
  }

  Future<void> _toggleList(int listId) async {
    final prov = context.read<UserListsProvider>();
    if (_selectedListIds.contains(listId)) {
      final ok = await prov.removeMovieFromList(listId, widget.movie.id);
      if (ok && mounted) {
        setState(() => _selectedListIds.remove(listId));
      }
    } else {
      final ok = await prov.addMovieToList(
        listId: listId,
        movieId: widget.movie.id,
        title: widget.movie.title,
        posterPath: widget.movie.posterPath,
        releaseDate: widget.movie.releaseDate,
        voteAverage: widget.movie.voteAverage,
      );
      if (ok && mounted) {
        setState(() => _selectedListIds.add(listId));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<UserListsProvider>();
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.24),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Add to List', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
          const SizedBox(height: 4),
          Text(widget.movie.title, style: GoogleFonts.inter(fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.54))),
          const SizedBox(height: 16),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
              child: Icon(Icons.add, color: theme.colorScheme.primary, size: 20),
            ),
            title: Text('Create new list', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
            onTap: () {
              Navigator.pop(context);
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: theme.scaffoldBackgroundColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (_) => const CreateListSheet(),
              );
            },
          ),
          const Divider(),
          if (prov.isLoading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else if (prov.myLists.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text('No lists yet. Create one!', style: GoogleFonts.inter(fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.38))),
              ),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: prov.myLists.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final list = prov.myLists[index];
                  final selected = _selectedListIds.contains(list.id);
                  return ListTile(
                    leading: Icon(
                      list.isRanked ? Icons.sort : Icons.list_alt,
                      size: 20,
                      color: selected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withValues(alpha: 0.54),
                    ),
                    title: Text(list.name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
                    subtitle: Text(
                      '${list.movieCount ?? 0} movies · ${list.isPublic ? "Public" : "Private"}',
                      style: GoogleFonts.inter(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.38)),
                    ),
                    trailing: Icon(
                      selected ? Icons.check_circle : Icons.add_circle_outline,
                      size: 22,
                      color: selected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.38),
                    ),
                    onTap: () => _toggleList(list.id),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
