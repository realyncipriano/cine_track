import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/notification_preferences.dart';
import '../providers/notification_provider.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final np = context.watch<NotificationProvider>();
    final prefs = np.preferences;
    final loading = np.preferencesLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationSettings),
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _buildToggle(
                  context,
                  icon: Icons.person_add_outlined,
                  label: l10n.notifFollowLabel,
                  subtitle: l10n.notifFollowSubtitle,
                  value: prefs.follow,
                  onChanged: (v) => _toggle(context, np, prefs.copyWith(follow: v)),
                ),
                _buildToggle(
                  context,
                  icon: Icons.thumb_up_outlined,
                  label: l10n.notifReviewLikeLabel,
                  subtitle: l10n.notifReviewLikeSubtitle,
                  value: prefs.reviewLike,
                  onChanged: (v) => _toggle(context, np, prefs.copyWith(reviewLike: v)),
                ),
                _buildToggle(
                  context,
                  icon: Icons.reply_outlined,
                  label: l10n.notifReplyLabel,
                  subtitle: l10n.notifReplySubtitle,
                  value: prefs.reply,
                  onChanged: (v) => _toggle(context, np, prefs.copyWith(reply: v)),
                ),
                _buildToggle(
                  context,
                  icon: Icons.shield_outlined,
                  label: l10n.notifModerationLabel,
                  subtitle: l10n.notifModerationSubtitle,
                  value: prefs.moderation,
                  onChanged: (v) => _toggle(context, np, prefs.copyWith(moderation: v)),
                ),
                _buildToggle(
                  context,
                  icon: Icons.playlist_add_outlined,
                  label: l10n.notifListAddLabel,
                  subtitle: l10n.notifListAddSubtitle,
                  value: prefs.listAdd,
                  onChanged: (v) => _toggle(context, np, prefs.copyWith(listAdd: v)),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.notificationSettingsHint,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
    );
  }

  Widget _buildToggle(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        secondary: Icon(icon, color: value
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38)),
        title: Text(label, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: GoogleFonts.inter(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54))),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  void _toggle(BuildContext context, NotificationProvider np, NotificationPreferences newPrefs) {
    np.updatePreferences(newPrefs);
  }
}
