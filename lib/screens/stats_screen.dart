import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/stats_provider.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatsProvider>().fetchStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<StatsProvider>(
      builder: (_, sp, _) {
        if (sp.isLoading) {
          return _buildLoading(theme);
        }
        if (sp.error != null) {
          return _buildError(theme, sp);
        }
        final stats = sp.stats;
        if (stats == null) {
          return _buildEmpty(theme);
        }
        return _buildContent(theme, stats);
      },
    );
  }

  Widget _buildLoading(ThemeData theme) {
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        title: Text('Your Stats', style: GoogleFonts.inter(fontSize: 16)),
      ),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildError(ThemeData theme, StatsProvider sp) {
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        title: Text('Your Stats', style: GoogleFonts.inter(fontSize: 16)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bar_chart, size: 48, color: theme.colorScheme.onSurface.withValues(alpha: 0.24)),
              const SizedBox(height: 16),
              Text('Could not load stats', style: GoogleFonts.inter(color: theme.colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 14)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => sp.fetchStats(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(ThemeData theme) {
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        title: Text('Your Stats', style: GoogleFonts.inter(fontSize: 16)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bar_chart, size: 48, color: theme.colorScheme.onSurface.withValues(alpha: 0.24)),
              const SizedBox(height: 16),
              Text('No stats yet. Start watching movies!', style: GoogleFonts.inter(color: theme.colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme, dynamic stats) {
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        title: Text('Your Stats', style: GoogleFonts.inter(fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatCards(theme, stats),
            const SizedBox(height: 24),
            if (stats.genreBreakdown.isNotEmpty) ...[
              _buildSectionTitle(theme, 'Top Genres'),
              const SizedBox(height: 8),
              _buildGenrePieChart(theme, stats.genreBreakdown),
              const SizedBox(height: 24),
            ],
            if (stats.monthlyActivity.isNotEmpty) ...[
              _buildSectionTitle(theme, 'Monthly Activity'),
              const SizedBox(height: 8),
              _buildMonthlyBarChart(theme, stats.monthlyActivity),
              const SizedBox(height: 24),
            ],
            if (stats.ratingDistribution.isNotEmpty) ...[
              _buildSectionTitle(theme, 'Rating Distribution'),
              const SizedBox(height: 8),
              _buildRatingBarChart(theme, stats.ratingDistribution),
              const SizedBox(height: 24),
            ],
            _buildStreakSection(theme, stats),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface));
  }

  Widget _buildStatCards(ThemeData theme, dynamic stats) {
    return Column(
      children: [
        Row(
          children: [
            _statCard(theme, 'Movies', '${stats.moviesWatched}', const Color(0xFF3FB950)),
            const SizedBox(width: 8),
            _statCard(theme, 'Hours', '${stats.hoursWatched}', const Color(0xFF58A6FF)),
            const SizedBox(width: 8),
            _statCard(theme, 'Reviews', '${stats.reviewsWritten}', const Color(0xFFDA7BEF)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _statCard(theme, 'Lists', '${stats.listsCreated}', const Color(0xFFF0883E)),
            const SizedBox(width: 8),
            _statCard(theme, 'Streak', '${stats.currentStreak}d', const Color(0xFFFF6B6B)),
            const SizedBox(width: 8),
            _statCard(theme, 'Best', '${stats.longestStreak}d', const Color(0xFF58A6FF)),
          ],
        ),
      ],
    );
  }

  Widget _statCard(ThemeData theme, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(value, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: color)),
            const SizedBox(height: 4),
            Text(label, style: GoogleFonts.inter(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.54))),
          ],
        ),
      ),
    );
  }

  Widget _buildGenrePieChart(ThemeData theme, List<dynamic> genres) {
    final colors = [
      const Color(0xFF3FB950), const Color(0xFF58A6FF), const Color(0xFFDA7BEF),
      const Color(0xFFF0883E), const Color(0xFFFF6B6B), const Color(0xFF79C0FF),
      const Color(0xFF56D4DD), const Color(0xFFE3B341), const Color(0xFFD2A8FF),
      const Color(0xFFFF7B72),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SizedBox(
        height: 200,
        child: Row(
          children: [
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: genres.asMap().entries.map((entry) {
                    final i = entry.key;
                    final g = entry.value;
                    return PieChartSectionData(
                      value: g.count.toDouble(),
                      color: colors[i % colors.length],
                      radius: 50,
                      title: '',
                    );
                  }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 30,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: genres.take(6).toList().asMap().entries.map((entry) {
                  final i = entry.key;
                  final g = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Container(
                          width: 10, height: 10,
                          decoration: BoxDecoration(
                            color: colors[i % colors.length],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(g.genre, style: GoogleFonts.inter(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.7)), overflow: TextOverflow.ellipsis),
                        ),
                        Text('${g.count}', style: GoogleFonts.inter(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.54))),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyBarChart(ThemeData theme, List<dynamic> months) {
    final maxCount = months.fold<int>(1, (max, m) => m.count > max ? m.count : max);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SizedBox(
        height: 180,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxCount.toDouble(),
            barTouchData: BarTouchData(enabled: false),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (value, meta) {
                    final idx = value.toInt();
                    if (idx >= 0 && idx < months.length) {
                      final label = months[idx].month as String;
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          label.length >= 7 ? label.substring(5) : label,
                          style: GoogleFonts.inter(fontSize: 9, color: theme.colorScheme.onSurface.withValues(alpha: 0.54)),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: (maxCount / 3).ceilToDouble().clamp(1, double.infinity),
            ),
            borderData: FlBorderData(show: false),
            barGroups: months.asMap().entries.map((entry) {
              final i = entry.key;
              final m = entry.value;
              return BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: m.count.toDouble(),
                    color: const Color(0xFF58A6FF),
                    width: 12,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildRatingBarChart(ThemeData theme, List<dynamic> ratings) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: List.generate(ratings.length, (i) {
          final r = ratings[i];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  child: Text('${r.rating}', style: GoogleFonts.inter(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.54))),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: r.count / (ratings.first.count > 0 ? ratings.first.count : 1),
                      backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                      color: const Color(0xFFDA7BEF),
                      minHeight: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 24,
                  child: Text('${r.count}', style: GoogleFonts.inter(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.54)), textAlign: TextAlign.right),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStreakSection(ThemeData theme, dynamic stats) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFF6B6B).withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text('🔥 Streak', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text('${stats.currentStreak}', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: const Color(0xFFFF6B6B))),
                  Text('current', style: GoogleFonts.inter(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.54))),
                ],
              ),
              Column(
                children: [
                  Text('${stats.longestStreak}', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: const Color(0xFF58A6FF))),
                  Text('longest', style: GoogleFonts.inter(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.54))),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
