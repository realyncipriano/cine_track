import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../helpers/responsive.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDesk = Responsive.isDesktop(context);
    final padding = Responsive.horizontalPadding(context);
    final theme = context.watch<ThemeProvider>();
    final isDark = theme.isDark;

    final features = [
      _FeatureData(Icons.search_rounded, l10n.smartSearch, l10n.smartSearchDesc),
      _FeatureData(Icons.cloud_sync_rounded, l10n.apiDiscovery, l10n.apiDiscoveryDesc),
      _FeatureData(Icons.favorite_rounded, l10n.favoritesWatchlist, l10n.favoritesWatchlistDesc),
    ];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF0D1117), const Color(0xFF1a0a2e), const Color(0xFF0D1117)]
                : [const Color(0xFFF5F3F0), const Color(0xFFE8E0F0), const Color(0xFFF5F3F0)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                child: ResponsiveContainer(
                  maxWidth: 1200,
                  padding: EdgeInsets.symmetric(horizontal: padding, vertical: 32),
                  child: Column(
                      children: [
                        const SizedBox(height: 40),
                        _Logo(isDesk: isDesk),
                        const SizedBox(height: 16),
                        Text(
                          l10n.landingTitle,
                          style: GoogleFonts.montserrat(
                            fontSize: Responsive.font(context, 40),
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.landingTagline,
                          style: GoogleFonts.inter(
                            fontSize: isDesk ? 22 : 18,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.landingSubtitle,
                          style: GoogleFonts.inter(
                            fontSize: isDesk ? 16 : 14,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 60),
                        if (isDesk)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: features
                                .map((f) => Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                        child: _FeatureCard(
                                          icon: f.icon,
                                          title: f.title,
                                          description: f.description,
                                        ),
                                      ),
                                    ))
                                .toList(),
                          )
                        else
                          Column(
                            children: features
                                .map((f) => Padding(
                                      padding: const EdgeInsets.only(bottom: 16),
                                      child: _FeatureCard(
                                        icon: f.icon,
                                        title: f.title,
                                        description: f.description,
                                      ),
                                    ))
                                .toList(),
                          ),
                        const SizedBox(height: 48),
                        if (isDesk)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _SignInButton(),
                              const SizedBox(width: 16),
                              _CreateAccountButton(),
                            ],
                          )
                        else ...[
                          _SignInButton(),
                          const SizedBox(height: 16),
                          _CreateAccountButton(),
                        ],
                        const SizedBox(height: 24),
                        _GuestButton(),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            l10n.guestExplanation,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54),
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          l10n.landingFooter,
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              Positioned(
                top: 8,
                right: padding,
                child: IconButton(
                  icon: Icon(
                    isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  onPressed: () => theme.toggle(),
                  tooltip: isDark ? l10n.switchToLightMode : l10n.switchToDarkMode,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Logo widget ──────────────────────────────────────────────────

class _Logo extends StatelessWidget {
  final bool isDesk;
  const _Logo({required this.isDesk});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      width: isDesk ? 120 : 100,
      height: isDesk ? 120 : 100,
      errorBuilder: (_, _, _) => CircleAvatar(
        radius: isDesk ? 60 : 50,
        backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
        child: Text(
          'CT',
          style: GoogleFonts.montserrat(
            fontSize: isDesk ? 40 : 32,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

// ── Feature card ─────────────────────────────────────────────────

class _FeatureData {
  final IconData icon;
  final String title;
  final String description;
  const _FeatureData(this.icon, this.title, this.description);
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black12,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Buttons ──────────────────────────────────────────────────────

class _SignInButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      width: 260,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          context.go('/login');
        },
        child: Text(
          l10n.signIn,
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _CreateAccountButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: 260,
      height: 56,
      child: OutlinedButton(
        onPressed: () {
          context.go('/login/register');
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark ? Colors.white70 : const Color(0xFF2C2C2C),
          side: BorderSide(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
        ),
        child: Text(
          l10n.createAccount,
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _GuestButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      width: 260,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: () async {
          await context.read<AuthProvider>().enterGuestMode();
        },
        icon: const Icon(Icons.explore_outlined, size: 20),
        label: Text(
          l10n.continueAsGuest,
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.primary,
          side: BorderSide(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }
}
