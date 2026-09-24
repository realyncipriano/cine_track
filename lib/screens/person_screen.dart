import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../l10n/app_localizations.dart';
import '../models/movie.dart';
import '../models/person.dart';
import '../providers/people_provider.dart';
import '../widgets/movie_card.dart';
import '../helpers/responsive.dart';

class PersonScreen extends StatefulWidget {
  final int personId;

  const PersonScreen({super.key, required this.personId});

  @override
  State<PersonScreen> createState() => _PersonScreenState();
}

class _PersonScreenState extends State<PersonScreen> {
  @override
  void initState() {
    super.initState();
    final pp = context.read<PeopleProvider>();
    pp.clear();
    pp.fetchPerson(widget.personId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pp = context.watch<PeopleProvider>();

    if (pp.isLoading) {
      return Scaffold(
        appBar: AppBar(centerTitle: true, title: Text(l10n.person)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (pp.error != null || pp.person == null) {
      return Scaffold(
        appBar: AppBar(centerTitle: true, title: Text(l10n.personNotFound)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_off, size: 64,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24)),
                const SizedBox(height: 16),
                Text(l10n.failedToLoadPerson,
                    style: GoogleFonts.inter(fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54))),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => context.read<PeopleProvider>().fetchPerson(widget.personId),
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return _PersonContent(person: pp.person!);
  }
}

class _PersonContent extends StatelessWidget {
  final Person person;

  const _PersonContent({required this.person});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, l10n),
          SliverToBoxAdapter(child: _buildHeader(context, l10n)),
          if (person.biography != null && person.biography!.isNotEmpty)
            SliverToBoxAdapter(child: _buildBiography(context, l10n)),
          SliverToBoxAdapter(child: _buildPersonalInfo(context, l10n)),
          if (person.knownFor.isNotEmpty) ...[
            SliverToBoxAdapter(child: _buildSectionHeader(context, l10n.knownFor)),
            SliverToBoxAdapter(child: _buildKnownForList(context)),
          ],
          SliverToBoxAdapter(child: _buildSectionHeader(context, l10n.filmography)),
          _buildFilmographyGrid(context),
          const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, AppLocalizations l10n) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      centerTitle: true,
      title: Text(person.name, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (person.profileUrl != null)
              CachedNetworkImage(
                imageUrl: person.profileUrl!,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(color: Theme.of(context).cardColor),
                errorWidget: (_, _, _) => Container(color: Theme.of(context).cardColor),
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.7),
                    Theme.of(context).scaffoldBackgroundColor,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: Theme.of(context).cardColor,
            backgroundImage: person.profileUrl != null
                ? CachedNetworkImageProvider(person.profileUrl!)
                : null,
            child: person.profileUrl == null
                ? Icon(Icons.person, size: 48,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38))
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            person.name,
            style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface),
            textAlign: TextAlign.center,
          ),
          if (person.knownForDepartment != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                person.knownForDepartment!,
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBiography(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: _ExpandableText(
        title: l10n.biography,
        text: person.biography!,
      ),
    );
  }

  Widget _buildPersonalInfo(BuildContext context, AppLocalizations l10n) {
    final items = <_InfoRow>[];

    if (person.birthday != null) {
      items.add(_InfoRow(
        icon: Icons.cake_outlined,
        label: l10n.birthdayLabel,
        value: person.birthday!,
      ));
      if (person.age != null) {
        items.add(_InfoRow(
          icon: Icons.auto_awesome,
          label: l10n.ageLabel,
          value: l10n.yearsOld(person.age.toString()),
        ));
      }
    }

    if (person.placeOfBirth != null && person.placeOfBirth!.isNotEmpty) {
      items.add(_InfoRow(
        icon: Icons.location_on_outlined,
        label: l10n.placeOfBirth,
        value: person.placeOfBirth!,
      ));
    }

    items.add(_InfoRow(
      icon: Icons.info_outline,
      label: l10n.status,
      value: person.isDeceased ? l10n.deceased : l10n.alive,
    ));

    if (person.alsoKnownAs.isNotEmpty) {
      items.add(_InfoRow(
        icon: Icons.alternate_email,
        label: l10n.alsoKnownAs,
        value: person.alsoKnownAs.take(3).join(', '),
      ));
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Card(
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.personalInfo,
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface)),
              const SizedBox(height: 12),
              ...items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(item.icon, size: 18,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54)),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 90,
                      child: Text(item.label,
                          style: GoogleFonts.inter(fontSize: 13,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54))),
                    ),
                    Expanded(
                      child: Text(item.value,
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface)),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Text(title,
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface)),
    );
  }

  Widget _buildKnownForList(BuildContext context) {
    final movies = person.knownFor.take(10).toList();
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: movies.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final credit = movies[index];
          return SizedBox(
            width: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: credit.posterUrl != null
                      ? CachedNetworkImage(
                          imageUrl: credit.posterUrl!,
                          height: 160,
                          width: 120,
                          fit: BoxFit.cover,
                          placeholder: (_, _) => Container(
                            height: 160,
                            color: Theme.of(context).cardColor,
                            child: Icon(Icons.movie, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24)),
                          ),
                          errorWidget: (_, _, _) => Container(
                            height: 160,
                            color: Theme.of(context).cardColor,
                            child: Icon(Icons.movie, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24)),
                          ),
                        )
                      : Container(
                          height: 160,
                          color: Theme.of(context).cardColor,
                          child: Icon(Icons.movie, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24)),
                        ),
                ),
                const SizedBox(height: 6),
                Text(credit.title,
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilmographyGrid(BuildContext context) {
    final filmography = person.knownFor;
    if (filmography.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Text('No filmography available',
            style: GoogleFonts.inter(fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54))),
      );
    }

    final movies = filmography
        .map((c) => Movie(
              id: c.id,
              title: c.title,
              overview: '',
              posterPath: c.posterPath,
              releaseDate: c.releaseDate,
              voteAverage: c.voteAverage,
            ))
        .toList();

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: Responsive.movieGridColumns(context),
          childAspectRatio: 0.6,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => MovieCard(movie: movies[index]),
          childCount: movies.length,
        ),
      ),
    );
  }
}

class _ExpandableText extends StatefulWidget {
  final String title;
  final String text;

  const _ExpandableText({required this.title, required this.text});

  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isLong = widget.text.length > 250;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title,
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface)),
        const SizedBox(height: 10),
        AnimatedCrossFade(
          firstChild: Text(
            widget.text,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(fontSize: 14, height: 1.5,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8)),
          ),
          secondChild: Text(
            widget.text,
            style: GoogleFonts.inter(fontSize: 14, height: 1.5,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8)),
          ),
          crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
        if (isLong)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Text(
                _expanded ? l10n.showLess : l10n.readMore,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _InfoRow {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});
}
