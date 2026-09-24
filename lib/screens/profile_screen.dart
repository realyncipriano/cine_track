import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../helpers/responsive.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/history_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/watchlist_provider.dart';
import '../providers/user_profile_provider.dart';
import '../widgets/avatar_picker.dart';
import 'movie_details_screen.dart';
import 'public_profile_screen.dart';
import '../l10n/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  final bool isGuest;
  final VoidCallback? onSignIn;

  const ProfileScreen({super.key, this.isGuest = false, this.onSignIn});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _appVersion;

  bool _cpExpanded = false;
  final _cpController = TextEditingController();
  final _npController = TextEditingController();
  final _cnpController = TextEditingController();
  int _newPasswordStrength = 0;
  String? _pwError;
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  void initState() {
    super.initState();
    _loadVersion();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        context.read<UserProfileProvider>().fetchProfile(user.id);
      }
    });
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) setState(() => _appVersion = '${info.version}+${info.buildNumber}');
    } catch (_) {}
  }

  @override
  void dispose() {
    _cpController.dispose();
    _npController.dispose();
    _cnpController.dispose();
    super.dispose();
  }

  void _pickAvatar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AvatarPicker(
        onPicked: (base64, mime) async {
          if (base64.isEmpty) return;
          final error = await context.read<AuthProvider>().uploadAvatar(base64, mime);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error ?? l10n.avatarUpdated),
                backgroundColor: error != null ? Theme.of(context).colorScheme.error : Colors.green,
              ),
            );
          }
        },
      ),
    );
  }

  void _showLogoutDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.signOutTitle, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        content: Text(l10n.signOutConfirm, style: GoogleFonts.inter(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                context.go('/landing');
              }
            },
            child: Text(l10n.signOut, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    final l10n = AppLocalizations.of(context)!;
    final pwController = TextEditingController();
    String? deleteError;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(l10n.deleteAccount, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.deleteAccountWarning,
                style: GoogleFonts.inter(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: pwController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: l10n.enterPasswordConfirm,
                  filled: true,
                  fillColor: Theme.of(context).scaffoldBackgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              if (deleteError != null) ...[
                const SizedBox(height: 8),
                Text(deleteError!, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () async {
                final pw = pwController.text;
                if (pw.isEmpty) return;
                final error = await context.read<AuthProvider>().deleteAccount(pw);
                if (error != null) {
                  setDialogState(() => deleteError = error);
                } else if (context.mounted) {
                  context.go('/landing');
                }
              },
              child: Text(l10n.delete, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          ],
        ),
      ),
    );
  }

  void _showCacheCleared() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.clearCache, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        content: Text(l10n.clearCacheConfirm, style: GoogleFonts.inter(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await CachedNetworkImage.evictFromCache('*');
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.cacheCleared), backgroundColor: Colors.green),
                );
              }
            },
            child: Text(l10n.delete, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = context.read<LocaleProvider>().locale.languageCode;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.language, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _langOption(ctx, 'English', 'en', currentLocale == 'en'),
            _langOption(ctx, 'Spanish', 'es', currentLocale == 'es'),
            _langOption(ctx, 'French', 'fr', currentLocale == 'fr'),
            _langOption(ctx, 'German', 'de', currentLocale == 'de'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  Widget _langOption(BuildContext ctx, String name, String code, bool selected) {
    return ListTile(
      leading: Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38)),
      title: Text(name, style: GoogleFonts.inter(color: selected ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54))),
      onTap: () {
        Navigator.pop(ctx);
        context.read<LocaleProvider>().setLocale(Locale(code));
      },
    );
  }

  void _showAboutDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.about, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset('assets/images/logo.png', height: 64),
            ),
            const SizedBox(height: 16),
            Text('CineTrack', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 4),
            Text('v$_appVersion', style: GoogleFonts.inter(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54))),
            const SizedBox(height: 16),
            Text(
              l10n.appTagline,
              style: GoogleFonts.inter(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54), fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  Future<void> _changePassword() async {
    final l10n = AppLocalizations.of(context)!;
    final cp = _cpController.text;
    final np = _npController.text;
    final cnp = _cnpController.text;

    if (cp.isEmpty || np.isEmpty) {
      setState(() => _pwError = l10n.fillAllPasswordFields);
      return;
    }
    if (np.length < 8) {
      setState(() => _pwError = l10n.newPasswordMinChars);
      return;
    }
    if (np != cnp) {
      setState(() => _pwError = l10n.passwordsDoNotMatch);
      return;
    }

    final error = await context.read<AuthProvider>().changePassword(cp, np, cnp);
    if (mounted) {
      if (error != null) {
        setState(() => _pwError = error);
      } else {
        _cpController.clear();
        _npController.clear();
        _cnpController.clear();
        setState(() {
          _cpExpanded = false;
          _pwError = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.passwordChanged),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Color _strengthColor() {
    return switch (_newPasswordStrength) {
      0 => Colors.red, 1 => Colors.orange, 2 => Colors.amber, 3 => Colors.lightGreen,
      _ => Colors.green,
    };
  }

  String _strengthLabel(AppLocalizations l10n) {
    return switch (_newPasswordStrength) {
      0 => l10n.passwordStrengthWeak, 1 => l10n.passwordStrengthFair, 2 => l10n.passwordStrengthGood, 3 => l10n.passwordStrengthStrong,
      _ => l10n.passwordStrengthVeryStrong,
    };
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (widget.isGuest && !auth.isAuthenticated) {
      return _buildGuestView();
    }

    return _buildAuthView(context, auth);
  }

  Widget _buildGuestView() {
    final l10n = AppLocalizations.of(context)!;
    final theme = context.watch<ThemeProvider>();
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ResponsiveContainer(
          child: Column(
            children: [
            const SizedBox(height: 40),
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(Icons.person_outline_rounded, size: 48, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.guestBrowsing,
              style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(height: 20),
            _guestFeatureCard(Icons.favorite, l10n.saveFavorites, l10n.saveFavoritesDesc, Theme.of(context).colorScheme.primary),
            const SizedBox(height: 10),
            _guestFeatureCard(Icons.bookmark, l10n.buildWatchlist, l10n.buildWatchlistDesc, const Color(0xFF58A6FF)),
            const SizedBox(height: 10),
            _guestFeatureCard(Icons.history, l10n.trackHistory, l10n.trackHistoryDesc, const Color(0xFF3FB950)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                onPressed: widget.onSignIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                ),
                child: Text(l10n.signInCreateAccount, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 40),
            _sectionHeader(l10n.settings),
            _settingsItem(
              icon: theme.isDark ? Icons.light_mode : Icons.dark_mode,
              label: theme.isDark ? l10n.lightMode : l10n.darkMode,
              trailing: Switch(
                value: !theme.isDark,
                activeTrackColor: Theme.of(context).colorScheme.primary,
                activeThumbColor: Theme.of(context).colorScheme.onPrimary,
                inactiveTrackColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24),
                inactiveThumbColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54),
                onChanged: (_) => theme.toggle(),
              ),
              onTap: () => theme.toggle(),
            ),
            _settingsItem(
              icon: Icons.language,
              label: l10n.language,
              trailing: Icon(Icons.chevron_right, size: 18, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24)),
              onTap: _showLanguageDialog,
            ),
            _settingsItem(
              icon: Icons.info_outline,
              label: l10n.about,
              trailing: _appVersion != null
                  ? Text('v$_appVersion', style: GoogleFonts.inter(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38)))
                  : null,
              onTap: _showAboutDialog,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      ),
    );
  }

  Widget _guestFeatureCard(IconData icon, String title, String description, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 2),
                Text(description, style: GoogleFonts.inter(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthView(BuildContext context, AuthProvider auth) {
    final l10n = AppLocalizations.of(context)!;
    final user = auth.user;
    final theme = context.watch<ThemeProvider>();
    final hp = context.watch<HistoryProvider>();
    final fp = context.watch<FavoritesProvider>();
    final wp = context.watch<WatchlistProvider>();
    final profileProv = context.watch<UserProfileProvider>();
    final recentHistory = hp.recentlyWatched;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async => await hp.fetchHistory(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          physics: const AlwaysScrollableScrollPhysics(),
          child: ResponsiveContainer(
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(user, auth),
              const SizedBox(height: 24),
              _buildStatsRow(fp, wp, hp, profileProv),
              const SizedBox(height: 24),
              _buildHistorySection(recentHistory, hp),
              const SizedBox(height: 24),
              _sectionHeader(l10n.settings),
              _settingsItem(
                icon: theme.isDark ? Icons.light_mode : Icons.dark_mode,
                label: theme.isDark ? l10n.lightMode : l10n.darkMode,
                trailing: Switch(
                  value: !theme.isDark,
                  activeTrackColor: Theme.of(context).colorScheme.primary,
                  activeThumbColor: Theme.of(context).colorScheme.onPrimary,
                  inactiveTrackColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24),
                  inactiveThumbColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54),
                  onChanged: (_) => theme.toggle(),
                ),
                onTap: () => theme.toggle(),
              ),
              _buildChangePasswordSection(auth),
              _settingsItem(
                icon: Icons.rate_review_outlined,
                label: l10n.myReviews,
                trailing: Icon(Icons.chevron_right, size: 18, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24)),
                onTap: () => context.go('/my-reviews'),
              ),
              _settingsItem(
                icon: Icons.list_alt_outlined,
                label: l10n.myLists,
                trailing: Icon(Icons.chevron_right, size: 18, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24)),
                onTap: () => context.go('/my-lists'),
              ),
              _settingsItem(
                icon: Icons.bar_chart_outlined,
                label: l10n.stats,
                trailing: Icon(Icons.chevron_right, size: 18, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24)),
                onTap: () => context.go('/stats'),
              ),
              _settingsItem(
                icon: Icons.language,
                label: l10n.language,
                trailing: Icon(Icons.chevron_right, size: 18, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24)),
                onTap: _showLanguageDialog,
              ),
              _settingsItem(
                icon: Icons.notifications_outlined,
                label: l10n.notifications,
                trailing: Icon(Icons.chevron_right, size: 18, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24)),
                onTap: () => context.go('/notification-settings'),
              ),
              _settingsItem(
                icon: Icons.devices,
                label: l10n.manageSessions,
                trailing: Icon(Icons.chevron_right, size: 18, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24)),
                onTap: () => context.go('/sessions'),
              ),
              _settingsItem(
                icon: Icons.block,
                label: l10n.blockedUsers,
                trailing: Icon(Icons.chevron_right, size: 18, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24)),
                onTap: () => context.go('/blocked'),
              ),
              _settingsItem(
                icon: Icons.delete_sweep_outlined,
                label: l10n.clearCache,
                onTap: _showCacheCleared,
              ),
              _settingsItem(
                icon: Icons.info_outline,
                label: l10n.about,
                trailing: _appVersion != null
                    ? Text('v$_appVersion', style: GoogleFonts.inter(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38)))
                    : null,
                onTap: _showAboutDialog,
              ),
              const SizedBox(height: 24),
              Divider(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity, height: 48,
                child: OutlinedButton.icon(
                  onPressed: _showLogoutDialog,
                  icon: const Icon(Icons.logout, size: 18),
                  label: Text(l10n.signOut),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54),
                    side: BorderSide(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity, height: 48,
                child: OutlinedButton.icon(
                  onPressed: _showDeleteDialog,
                  icon: const Icon(Icons.delete_forever, size: 18),
                  label: Text(l10n.deleteAccount),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                    side: BorderSide(color: Theme.of(context).colorScheme.error),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildProfileHeader(user, AuthProvider auth) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PublicProfileScreen(userId: user?.id ?? 0),
            ),
          ),
          onLongPress: () => _pickAvatar(context),
          child: Stack(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                backgroundImage: _buildAvatarImage(user),
                child: _buildAvatarFallback(user),
              ),
              Positioned(
                bottom: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
                  ),
                  child: Icon(Icons.camera_alt, size: 16, color: Theme.of(context).colorScheme.onPrimary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          user?.name ?? 'User',
          style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface),
        ),
        const SizedBox(height: 4),
        Text('@${user?.username ?? ''}', style: GoogleFonts.inter(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38))),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _infoRow(Icons.email_outlined, user?.email ?? ''),
              if (user?.phone != null && user!.phone!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: _infoRow(Icons.phone_outlined, user.phone!),
                ),
              if (user?.dateOfBirth != null && user!.dateOfBirth!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: _infoRow(Icons.cake_outlined, user.dateOfBirth!),
                ),
              if (user?.country != null && user!.country!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: _infoRow(Icons.public_outlined, user.country!),
                ),
              if (user?.marketingOptIn == true)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: _infoRow(Icons.email_outlined, l10n.marketingEmailsEnabled, iconColor: const Color(0xFF3FB950)),
                ),
            ],
          ),
        ),
        if (user?.emailVerified == false) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.emailNotVerifiedWarning, style: GoogleFonts.inter(fontSize: 12, color: Colors.orangeAccent)),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _resendVerification(auth, user?.email ?? ''),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    l10n.resend,
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.orangeAccent),
                  ),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity, height: 48,
          child: OutlinedButton.icon(
            onPressed: () => context.go('/edit-profile'),
            icon: const Icon(Icons.edit, size: 18),
            label: Text(l10n.editProfile),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              side: BorderSide(color: Theme.of(context).colorScheme.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String text, {Color? iconColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 14, color: iconColor ?? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38)),
        const SizedBox(width: 6),
        Text(text, style: GoogleFonts.inter(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
      ],
    );
  }

  Future<void> _resendVerification(AuthProvider auth, String email) async {
    final l10n = AppLocalizations.of(context)!;
    final error = await auth.resendVerification(email);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? l10n.verificationEmailSent),
          backgroundColor: error != null ? Theme.of(context).colorScheme.error : Colors.green,
        ),
      );
    }
  }

  Widget _buildStatsRow(FavoritesProvider fp, WatchlistProvider wp, HistoryProvider hp, UserProfileProvider pp) {
    final l10n = AppLocalizations.of(context)!;
    final counts = pp.counts;
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _statCard(Icons.movie_outlined, '${counts['movies_watched'] ?? hp.totalCount}', l10n.movies, const Color(0xFF3FB950))),
            const SizedBox(width: 12),
            Expanded(child: _statCard(Icons.rate_review_outlined, '${counts['reviews'] ?? 0}', l10n.reviews, const Color(0xFF58A6FF))),
            const SizedBox(width: 12),
            Expanded(child: _statCard(Icons.list_alt, '${counts['lists'] ?? 0}', l10n.lists, Theme.of(context).colorScheme.primary)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _statCard(Icons.people_outline, '${counts['followers'] ?? 0}', l10n.followers, const Color(0xFFF0883E))),
            const SizedBox(width: 12),
            Expanded(child: _statCard(Icons.person_outline, '${counts['following'] ?? 0}', l10n.following, const Color(0xFFDA7BEF))),
            const SizedBox(width: 12),
            Expanded(child: _statCard(Icons.favorite, '${fp.totalCount}', l10n.favorites, Theme.of(context).colorScheme.primary)),
          ],
        ),
      ],
    );
  }

  Widget _statCard(IconData icon, String count, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 8),
          Text(
            count,
            style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54)),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(List recentHistory, HistoryProvider hp) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.history, size: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54)),
            const SizedBox(width: 6),
            Text(
              l10n.watchHistory,
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
            ),
            if (!hp.isEmpty) ...[
              const SizedBox(width: 6),
              Text(
                '(${hp.history.length})',
                style: GoogleFonts.inter(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38)),
              ),
            ],
            const Spacer(),
            if (!hp.isEmpty)
              GestureDetector(
                onTap: () => context.go('/history'),
                child: Text(
                  l10n.seeAll,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (recentHistory.isNotEmpty)
          SizedBox(
            height: 230,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: recentHistory.length > 5 ? 5 : recentHistory.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final movie = recentHistory[index];
                return SizedBox(
                  width: 140,
                  child: _historyCard(movie),
                );
              },
            ),
          )
        else if (hp.isLoading)
          SizedBox(
            height: 230,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) => _historyCardSkeleton(),
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(Icons.history, size: 32, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24)),
                const SizedBox(height: 8),
                Text(l10n.noWatchHistory, style: GoogleFonts.inter(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38))),
              ],
            ),
          ),
      ],
    );
  }

  Widget _historyCard(movie) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MovieDetailsScreen(movie: movie),
            ),
          );
        },
        child: Hero(
          tag: 'movie_poster_${movie.id}',
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
                placeholder: (_, _) => Container(color: Theme.of(context).cardColor),
                errorWidget: (_, _, _) => Icon(Icons.movie, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38)),
              )
            else
              Container(color: Theme.of(context).cardColor, child: Icon(Icons.movie, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38))),
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black87, Colors.transparent],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(movie.watchedAt),
                      style: GoogleFonts.inter(fontSize: 10, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
            if (movie.watchCount > 1)
              Positioned(
                top: 8, left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.replay, size: 12, color: Theme.of(context).colorScheme.onPrimary),
                      const SizedBox(width: 4),
                      Text(
                        '${movie.watchCount}',
                        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onPrimary),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      ),
      ),
    );
  }

  Widget _historyCardSkeleton() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 140,
        decoration: BoxDecoration(color: Theme.of(context).cardColor),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.04),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 10, width: 100,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 8, width: 70,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChangePasswordSection(AuthProvider auth) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        _settingsItem(
          icon: Icons.lock_outline,
          label: l10n.changePassword,
          trailing: Icon(_cpExpanded ? Icons.expand_less : Icons.expand_more, size: 18, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24)),
          onTap: () => setState(() => _cpExpanded = !_cpExpanded),
        ),
        if (_cpExpanded) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Column(
              children: [
                const SizedBox(height: 12),
                TextFormField(
                  controller: _cpController,
                  obscureText: !_showCurrentPassword,
                  decoration: InputDecoration(
                    labelText: l10n.currentPasswordLabel,
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    suffixIcon: IconButton(
                      icon: Icon(_showCurrentPassword ? Icons.visibility_off : Icons.visibility),
                      tooltip: _showCurrentPassword ? l10n.hideCurrentPassword : l10n.showCurrentPassword,
                      onPressed: () => setState(() => _showCurrentPassword = !_showCurrentPassword),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _npController,
                  obscureText: !_showNewPassword,
                  onChanged: (v) {
                    int s = 0;
                    if (v.length >= 8) s++;
                    if (v.contains(RegExp(r'[A-Z]'))) s++;
                    if (v.contains(RegExp(r'[a-z]'))) s++;
                    if (v.contains(RegExp(r'[0-9]'))) s++;
                    setState(() => _newPasswordStrength = s);
                  },
                  decoration: InputDecoration(
                    labelText: l10n.newPasswordLabel,
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    suffixIcon: IconButton(
                      icon: Icon(_showNewPassword ? Icons.visibility_off : Icons.visibility),
                      tooltip: _showNewPassword ? l10n.hideNewPassword : l10n.showNewPassword,
                      onPressed: () => setState(() => _showNewPassword = !_showNewPassword),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _newPasswordStrength / 4,
                    minHeight: 4,
                    backgroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.10),
                    valueColor: AlwaysStoppedAnimation(_strengthColor()),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(_strengthLabel(l10n), style: TextStyle(fontSize: 12, color: _strengthColor())),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _cnpController,
                  obscureText: !_showConfirmPassword,
                  decoration: InputDecoration(
                    labelText: l10n.confirmNewPasswordLabel,
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    suffixIcon: IconButton(
                      icon: Icon(_showConfirmPassword ? Icons.visibility_off : Icons.visibility),
                      tooltip: _showConfirmPassword ? l10n.hideConfirmPassword : l10n.showConfirmPassword,
                      onPressed: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed: auth.isLoading ? null : _changePassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: auth.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(l10n.update),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton(
                          onPressed: () => setState(() { _cpExpanded = false; _pwError = null; }),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54),
                            side: BorderSide(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(l10n.cancel),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_pwError != null) ...[
                  const SizedBox(height: 8),
                  Text(_pwError!, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 13)),
                ],

              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 11, fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38), letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _settingsItem({
    required IconData icon,
    required String label,
    Widget? trailing,
    Color? color,
    VoidCallback? onTap,
  }) {
    return ListTile(
      dense: true,
      leading: Icon(icon, size: 20, color: color ?? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54)),
      title: Text(label, style: GoogleFonts.inter(fontSize: 14, color: color ?? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
      trailing: trailing ?? Icon(Icons.chevron_right, size: 18, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24)),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  ImageProvider? _buildAvatarImage(user) {
    final url = user?.avatarUrl;
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('data:')) {
      final parts = url.split(',');
      if (parts.length >= 2 && parts[1].isNotEmpty) {
        return MemoryImage(base64Decode(parts[1]));
      }
    }
    return CachedNetworkImageProvider(url);
  }

  Widget? _buildAvatarFallback(user) {
    if (user?.avatarUrl == null || user!.avatarUrl!.isEmpty) {
      return Icon(Icons.person, size: 48, color: Theme.of(context).colorScheme.primary);
    }
    return null;
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return dateStr;
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}
