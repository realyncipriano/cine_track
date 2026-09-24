import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';

class IdleTimerWrapper extends StatefulWidget {
  final Widget child;
  final Duration timeout;

  const IdleTimerWrapper({
    super.key,
    required this.child,
    this.timeout = const Duration(minutes: 30),
  });

  @override
  State<IdleTimerWrapper> createState() => _IdleTimerWrapperState();
}

class _IdleTimerWrapperState extends State<IdleTimerWrapper> {
  Timer? _timer;
  Timer? _warningTimer;

  @override
  void initState() {
    super.initState();
    _resetTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _warningTimer?.cancel();
    super.dispose();
  }

  void _resetTimer() {
    _timer?.cancel();
    _warningTimer?.cancel();
    _timer = Timer(widget.timeout, _showWarningDialog);
  }

  void _showWarningDialog() {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;

    _warningTimer = Timer(const Duration(minutes: 2), _logout);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.sessionExpiring, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        content: Text(
          l10n.sessionExpiringDesc,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _warningTimer?.cancel();
              _resetTimer();
              Navigator.of(ctx).pop();
            },
            child: Text(l10n.stayLoggedIn),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    _timer?.cancel();
    _warningTimer?.cancel();
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    await auth.logout();
    if (!mounted) return;
    context.go('/landing');
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _resetTimer(),
      onPointerMove: (_) => _resetTimer(),
      child: widget.child,
    );
  }
}
