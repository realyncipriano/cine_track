import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/responsive.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../screens/onboarding_screen.dart';
import '../screens/landing_page.dart';
import '../screens/browse_screen.dart';
import '../screens/feed_screen.dart';
import '../screens/search_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/watchlist_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/public_profile_screen.dart';
import '../screens/history_screen.dart';
import '../screens/my_lists_screen.dart';
import '../screens/list_detail_screen.dart';
import '../screens/movie_details_loader_screen.dart';
import '../screens/person_screen.dart';
import '../screens/my_reviews_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/notification_settings_screen.dart';
import '../screens/stats_screen.dart';
import '../screens/sessions_screen.dart';
import '../screens/blocked_users_screen.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/reset_password_screen.dart';
import '../screens/auth/verify_email_screen.dart';
import '../screens/auth/verification_sent_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/admin_users_screen.dart';
import '../screens/admin/admin_reviews_screen.dart';
import '../screens/admin/admin_settings_screen.dart';
import '../screens/admin/admin_activity_screen.dart';
import '../screens/admin/admin_movies_screen.dart';
import '../screens/admin/admin_banners_screen.dart';
import '../screens/admin/admin_reports_screen.dart';
import '../screens/admin/admin_login_audit_screen.dart';
import '../widgets/idle_timer_wrapper.dart';

/// Creates the unified [GoRouter] for all platforms.
/// Detail screens (movie, stream, see-all, etc.) still use Navigator.push
/// to avoid complex parameter passing.
GoRouter createAppRouter(AuthProvider auth, {GlobalKey<NavigatorState>? navigatorKey}) {
  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/browse',
    refreshListenable: auth,
    redirect: (context, state) async {
      if (auth.isLoading) return '/splash';
      if (state.matchedLocation == '/splash') return '/browse';

      final isAuth = auth.isAuthenticated || auth.isGuest;
      final path = state.matchedLocation;

      final prefs = await SharedPreferences.getInstance();
      final onboardingDone = prefs.getBool('onboarding_completed') ?? false;

      final isPublicRoute = path.startsWith('/profile/');
      final isAuthRoute = path.startsWith('/login') ||
          path.startsWith('/register') ||
          path.startsWith('/forgot-password') ||
          path.startsWith('/reset-password') ||
          path == '/landing';

      // Onboarding guard
      if (!onboardingDone && path != '/onboarding') return '/onboarding';
      if (onboardingDone && path == '/onboarding') return '/browse';

      // Auth guard (public profiles are allowed without auth)
      if (!isAuth && !isAuthRoute && !isPublicRoute) return '/landing';
      if (isAuth && isAuthRoute) return '/browse';

      // Email verification guard
      if (isAuth && auth.isAuthenticated && !auth.emailVerified && path != '/verify-email') {
        return '/verify-email';
      }

      // Admin guard
      if (path.startsWith('/admin') && auth.user?.isModerator != true) {
        return '/browse';
      }

      return null;
    },
    routes: [
      // ── Standalone routes ──
      GoRoute(
        path: '/splash',
        builder: (_, _) => const _SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (_, _) => OnboardingScreen(
          onComplete: () {
            SharedPreferences.getInstance().then((prefs) {
              prefs.setBool('onboarding_completed', true);
            });
          },
        ),
      ),
      GoRoute(
        path: '/landing',
        builder: (_, _) => const LandingPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, _) => const LoginScreen(),
        routes: [
          GoRoute(
            path: 'register',
            builder: (_, _) => const RegisterScreen(),
          ),
          GoRoute(
            path: 'forgot-password',
            builder: (_, _) => const ForgotPasswordScreen(),
          ),
          GoRoute(
            path: 'reset-password',
            builder: (_, state) {
              final email = state.uri.queryParameters['email'] ?? '';
              final token = state.uri.queryParameters['token'] ?? '';
              return ResetPasswordScreen(email: email, token: token);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/verify-email',
        builder: (_, _) => const VerifyEmailScreen(),
      ),
      GoRoute(
        path: '/verification-sent',
        builder: (_, state) => VerificationSentScreen(
          email: state.uri.queryParameters['email'] ?? '',
        ),
      ),

      // ── Shell route (auth screens with responsive nav) ──
      ShellRoute(
        builder: (context, state, child) {
          return _AppShell(child: child);
        },
        routes: [
          GoRoute(path: '/browse', builder: (_, _) => const BrowseScreen()),
          GoRoute(path: '/feed', builder: (_, _) => const FeedScreen()),
          GoRoute(path: '/search', builder: (_, _) => const SearchScreen()),
          GoRoute(path: '/favorites', builder: (_, _) => const FavoritesScreen()),
          GoRoute(path: '/watchlist', builder: (_, _) => const WatchlistScreen()),
          GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
          GoRoute(
            path: '/profile/:userId',
            builder: (_, state) {
              final userId = int.tryParse(state.pathParameters['userId'] ?? '') ?? 0;
              return PublicProfileScreen(userId: userId);
            },
          ),
          GoRoute(path: '/history', builder: (_, _) => const HistoryScreen()),
          GoRoute(path: '/my-lists', builder: (_, _) => const MyListsScreen()),
          GoRoute(
            path: '/lists/:listId',
            builder: (_, state) {
              final listId = int.parse(state.pathParameters['listId']!);
              return ListDetailScreen(listId: listId);
            },
          ),
          GoRoute(
            path: '/movies/:movieId',
            builder: (_, state) {
              final movieId = int.tryParse(state.pathParameters['movieId'] ?? '') ?? 0;
              return MovieDetailsLoaderScreen(movieId: movieId);
            },
          ),
          GoRoute(path: '/my-reviews', builder: (_, _) => const MyReviewsScreen()),
          GoRoute(path: '/sessions', builder: (_, _) => const SessionsScreen()),
          GoRoute(path: '/edit-profile', builder: (_, _) => const EditProfileScreen()),
          GoRoute(path: '/notifications', builder: (_, _) => const NotificationsScreen()),
          GoRoute(path: '/notification-settings', builder: (_, _) => const NotificationSettingsScreen()),
          GoRoute(
            path: '/person/:personId',
            builder: (_, state) {
              final personId = int.tryParse(state.pathParameters['personId'] ?? '') ?? 0;
              return PersonScreen(personId: personId);
            },
          ),
          GoRoute(path: '/stats', builder: (_, _) => const StatsScreen()),
          GoRoute(path: '/blocked', builder: (_, _) => const BlockedUsersScreen()),
          // Admin routes (inside shell, keeps nav visible)
          GoRoute(path: '/admin', builder: (_, _) => const AdminDashboardScreen()),
          GoRoute(path: '/admin/users', builder: (_, _) => const AdminUsersScreen()),
          GoRoute(path: '/admin/reviews', builder: (_, _) => const AdminReviewsScreen()),
          GoRoute(path: '/admin/settings', builder: (_, _) => const AdminSettingsScreen()),
          GoRoute(path: '/admin/activity', builder: (_, _) => const AdminActivityScreen()),
          GoRoute(path: '/admin/movies', builder: (_, _) => const AdminMoviesScreen()),
          GoRoute(path: '/admin/banners', builder: (_, _) => const AdminBannersScreen()),
          GoRoute(path: '/admin/reports', builder: (_, _) => const AdminReportsScreen()),
          GoRoute(path: '/admin/login-audit', builder: (_, _) => const AdminLoginAuditScreen()),
        ],
      ),
    ],
  );
}

/// Splash screen shown during initial auth loading.
class _SplashScreen extends StatefulWidget {
  const _SplashScreen();

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen> {
  bool _timedOut = false;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 15), () {
      if (mounted) setState(() => _timedOut = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: _timedOut
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud_off, size: 48,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
                    const SizedBox(height: 16),
                    Text(
                      'Taking longer than expected',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Check your connection and try again.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () {
                        setState(() => _timedOut = false);
                        context.read<AuthProvider>().checkAuth();
                        Timer(const Duration(seconds: 15), () {
                          if (mounted) setState(() => _timedOut = true);
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                )
              : const CircularProgressIndicator(),
        ),
      ),
    );
  }
}

/// Unified shell with responsive NavigationRail / BottomNavigationBar
/// and guest-mode guarding.
class _AppShell extends StatefulWidget {
  final Widget child;
  const _AppShell({required this.child});

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  List<_NavItem> _navItems(bool isMod) => [
    _NavItem('Browse', Icons.explore_outlined, Icons.explore, '/browse'),
    _NavItem('Feed', Icons.rss_feed_outlined, Icons.rss_feed, '/feed'),
    _NavItem('Search', Icons.search_outlined, Icons.search, '/search'),
    _NavItem('Favorites', Icons.favorite_outline, Icons.favorite, '/favorites'),
    _NavItem('Watchlist', Icons.bookmark_outline, Icons.bookmark, '/watchlist'),
    if (isMod)
      _NavItem('Admin', Icons.admin_panel_settings_outlined, Icons.admin_panel_settings, '/admin'),
    _NavItem('Profile', Icons.person_outline, Icons.person, '/profile'),
  ];

  int _currentTabForPath(String path, bool isMod) {
    final items = _navItems(isMod);
    final idx = items.indexWhere((item) => path.startsWith(item.route));
    return idx >= 0 ? idx : 0;
  }

  void _onTabSelected(int index) {
    final auth = context.read<AuthProvider>();
    final isMod = auth.user?.isModerator ?? false;
    final items = _navItems(isMod);
    if (index >= 0 && index < items.length) {
      context.go(items[index].route);
    }
  }

  void _showGuestPrompt(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Icon(Icons.lock_outline, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'Sign in to use this feature',
              style: GoogleFonts.inter(
                fontSize: 18, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create an account or sign in to save favorites, build a watchlist, and track your history.',
              style: GoogleFonts.inter(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.read<AuthProvider>().exitGuestMode();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Sign In / Create Account',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = Responsive.isDesktop(context);
    final auth = context.watch<AuthProvider>();
    final isGuest = auth.isGuest;
    final isMod = auth.user?.isModerator ?? false;
    final isAuthenticated = auth.isAuthenticated;
    final currentPath = GoRouterState.of(context).matchedLocation;
    final items = _navItems(isMod);
    final currentIndex = _currentTabForPath(currentPath, isMod);

    final notifProv = context.watch<NotificationProvider>();
    final unreadCount = notifProv.unreadCount;

    // Guest-mode guard for restricted tabs
    Widget body;
    if (isGuest && (currentPath == '/favorites' || currentPath == '/watchlist' || currentPath == '/feed')) {
      body = const _GuestGuardScreen();
    } else if (isGuest && currentPath == '/profile') {
      body = ProfileScreen(isGuest: true, onSignIn: () {
        context.read<AuthProvider>().exitGuestMode();
      });
    } else {
      body = widget.child;
    }

    final shell = Scaffold(
      body: Row(
        children: [
          if (isWide)
            NavigationRail(
              selectedIndex: currentIndex,
              onDestinationSelected: _onTabSelected,
              labelType: NavigationRailLabelType.all,
              minWidth: 72,
              leading: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  Icon(
                    Icons.movie_rounded,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'CineTrack',
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Divider(height: 1, color: Theme.of(context).dividerColor),
                ],
              ),
              trailing: isAuthenticated
                  ? Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: CircleAvatar(
                  radius: 18,
                  backgroundImage: auth.user?.avatarUrl != null &&
                      auth.user!.avatarUrl!.isNotEmpty
                      ? (auth.user!.avatarUrl!.startsWith('data:')
                      ? MemoryImage(
                    base64Decode(
                      auth.user!.avatarUrl!.split(',').length >= 2
                          ? auth.user!.avatarUrl!.split(',')[1]
                          : '',
                    ),
                  )
                      : NetworkImage(auth.user!.avatarUrl!) as ImageProvider)
                      : null,
                  child: auth.user?.avatarUrl == null ||
                      auth.user!.avatarUrl!.isEmpty
                      ? Icon(Icons.person, size: 20)
                      : null,
                ),
              )
                  : const SizedBox.shrink(),
              destinations: List.generate(items.length, (i) {
                final icon = items[i].route == '/feed' && unreadCount > 0
                    ? Badge(
                        label: Text(unreadCount.toString(), style: const TextStyle(fontSize: 10)),
                        child: Icon(items[i].icon),
                      )
                    : Icon(items[i].icon);
                return NavigationRailDestination(
                  icon: icon,
                  selectedIcon: Icon(items[i].activeIcon),
                  label: Text(items[i].label, style: GoogleFonts.inter(fontSize: 12)),
                );
              }),
            ),
          Expanded(child: body),
        ],
      ),
      bottomNavigationBar: isWide
          ? null
          : BottomNavigationBar(
        currentIndex: currentIndex >= 0 && currentIndex < items.length ? currentIndex : 0,
        onTap: (index) {
          if (isGuest && index >= 2 && index <= 3) {
            _showGuestPrompt(context);
            return;
          }
          _onTabSelected(index);
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context)
            .colorScheme
            .onSurface
            .withValues(alpha: 0.54),
        items: List.generate(items.length, (i) {
          final icon = items[i].route == '/feed' && unreadCount > 0
              ? Badge(
                  label: Text(unreadCount.toString(), style: const TextStyle(fontSize: 10)),
                  child: Icon(items[i].icon),
                )
              : Icon(items[i].icon);
          return BottomNavigationBarItem(
            icon: icon,
            activeIcon: Icon(items[i].activeIcon),
            label: items[i].label,
          );
        }),
      ),
    );

    // Wrap authenticated users in idle timer
    if (isAuthenticated) {
      return IdleTimerWrapper(child: shell);
    }

    return shell;
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;
  const _NavItem(this.label, this.icon, this.activeIcon, this.route);
}

/// Shown when a guest taps a tab that requires authentication.
class _GuestGuardScreen extends StatelessWidget {
  const _GuestGuardScreen();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, size: 64, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24)),
            const SizedBox(height: 16),
            Text(
              'Sign in to access this feature',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54), fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
