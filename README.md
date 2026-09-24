# CineTrack

CineTrack is a Flutter movie discovery and tracking application with social
features, backed by a PHP REST API. Users browse and search movies, track
favorites, watchlists, viewing history and custom lists, write reviews, follow
other users, and receive push notifications — on Android and Web.

- **Clients:** Flutter (Android + Web)
- **Backend:** PHP REST API + MySQL-compatible database
- **Metadata:** TMDB (The Movie Database) integration
- **Social:** profiles, follows, blocks, feed, reviews, notifications
- **Production:** <https://cine-track-delta.vercel.app> (web app and API are
  deployed to the same Vercel project; the API lives under `/api`)

> **Streaming status note:** movie playback is served through third-party
> streaming providers (see [Streaming](#streaming)). Actual provider playback
> verification is separate and pending — this README makes no claim that every
> listed provider is confirmed playable.

---

# Overview

CineTrack exists so movie fans can discover films, keep track of what they
watch, and discuss movies with a community — in one app instead of scattered
notes, lists, and chat threads. A typical workflow is: browse or search for a
movie, open its details page (cast, trailers, reviews), save it to a watchlist
or custom list, log it as watched, rate and review it, and see what followed
users are watching in the social feed.

The system is split into two deployables. The Flutter client owns all UI and
state and talks to the backend exclusively over HTTP/JSON
(`ApiService` + endpoint constants in `lib/services/`, base URL from
`AppConfig.apiBaseUrl`). The PHP backend owns authentication, persistence,
authorization, notifications, and streaming-proxy endpoints, and reads movie
metadata from TMDB (server search endpoints and the client's
`tmdb_service.dart`).

CineTrack supports two usage modes. **Guests** can explore content immediately
without an account, but saving, social, and notification features are gated
behind a sign-in prompt. **Authenticated users** get the full experience:
tracking, reviews, follows, lists, notifications, and multi-session
management.

Movie metadata (titles, posters, credits, videos, genres) comes from TMDB.
User-generated data — accounts, favorites, watchlists, history, lists,
reviews, likes, replies, reports, follows, blocks, feed entries, and
notifications — is stored in CineTrack's own database and synchronized with
the client per request.

---

# Features

## Discovery

- Movie browsing with curated sections and see-all views
- Movie search (client + `api/search/`, `api/movies/`)
- Rich movie details: metadata, cast and crew, trailers, user reviews
- Person details pages (filmography via TMDB credits)
- Trailer playback (YouTube embeds)
- Stream player with **source switching** across ordered providers
  (see [Streaming](#streaming))

## Tracking

- Favorites (`api/favorites/`)
- Watchlist (`api/watchlist/`)
- Viewing history with runtime capture and watch counts
  (`api/history/`, `migrations/011_*`)
- Custom user lists with movie add/remove and manual reordering
  (`api/lists/`: `create`, `list`, `detail`, `update`, `delete`,
  `add_movie`, `remove_movie`, `reorder`)
- Personal statistics dashboards (charts via `fl_chart`)

## Social

- Own and public user profiles (`api/users/profile.php`)
- Follows with follower/following lists (`follow`, `followers`, `following`)
- Blocks with content filtering (`block`, `blocked` — blocked users' reviews
  are filtered from lists)
- Social timeline feed (`api/feed/timeline.php`)
- Reviews with ratings and moderation statuses (`api/reviews/`)
- Review likes, replies, and user reports
  (`like`, `replies`, `reply`, `report`, `delete`)
- Push + in-app notifications for follows, likes, and replies

## Administration

- Admin dashboard with review charts and pending-review previews
- Analytics: overview, trends, and CSV export (`api/admin/analytics/`)
- User management: roles (`user`/`moderator`/`admin`), bans, deletion
  (`api/admin/users/`)
- Movie management: add/update/delete plus TMDB search import
  (`api/admin/movies/`)
- Review moderation including bulk actions (`api/admin/reviews/`)
- Banner management (`api/admin/banners/`, `api/banners.php`)
- Application settings (`api/admin/settings/`)
- Activity logging and login-attempt audit (`api/admin/activity/` plus the
  login-audit admin screen)

## Platform

- Android app (APK) and responsive Web app from one Flutter codebase
- Localization in English, Spanish, French, and German (see
  [Localization](#localization))
- Firebase Cloud Messaging on Android with deep links to profiles and movies;
  web skips FCM (see [Notifications & Firebase](#notifications--firebase))
- Guest mode with upgrade prompts for restricted tabs
- Responsive shell: navigation rail on desktop, bottom bar on mobile
- Email verification (6-digit code), password reset, avatar upload, account
  deletion, Google/Apple OAuth entry points

---

# Architecture

```text
Flutter Client (Android / Web)
    |
    |  HTTP/JSON (Bearer api_tokens)
    v
PHP REST API  (api/index.php front controller)
    |
    +--> MySQL database (PDO, utf8mb4)
    |
    +--> TMDB (movie/person metadata)
    |
    +--> Firebase / FCM (push notifications)
    |
    +--> Streaming providers (via api/proxy/)
```

- **Flutter client** — all screens, state (Provider), routing (go_router),
  localization, players, and notification handling.
- **PHP REST API** — authentication, authorization, domain CRUD, feed and
  notification fan-out, streaming proxy, admin operations. File path under
  `api/` maps directly to the endpoint URL.
- **Database** — system of record for accounts, tokens, tracking, social
  graph, reviews, notifications, and admin data.
- **TMDB** — third-party source of movie/person metadata, credits, videos,
  and poster artwork.
- **Firebase / FCM** — push delivery to Android devices; tokens registered
  per login.
- **Streaming providers** — third-party embeds reached through
  `api/proxy/embed.php`; see [Streaming](#streaming).

---

# Repository Layout

| Path | Contents |
|---|---|
| `lib/screens/` | User screens (`browse`, `search`, `movie_details`, `feed`, `favorites`, `watchlist`, `history`, `my_lists`, `profile`, …), `auth/` (login, register, password reset, email verification), `admin/` (dashboard, users, movies, reviews, reports, banners, settings, activity, login audit) |
| `lib/widgets/` | Reusable UI: cards, rating/like buttons, pagination, error/empty states, player widgets |
| `lib/providers/` | App state (Provider): `auth`, `movie`, `people`, `home_content`, `history`, `watchlist`, `favorites`, `reviews` + `review_reply`, `user_profile`, `user_lists`, `follow`, `block`, `stats`, `notification`, `theme`, `locale`, plus `admin/` (dashboard, analytics, users, movies, reviews, banners, settings, activity, login audit) |
| `lib/services/` | `api_service` (authenticated HTTP wrapper), `api_endpoints` (path constants), `auth_service` (token/session persistence), `tmdb_service` (TMDB metadata), `fcm_service` (push registration and tap routing) |
| `lib/models/` | JSON models: user, movie, review, person, lists, notifications, stats |
| `lib/router/` | `app_router.dart` — `createAppRouter` with splash/onboarding/landing guards, auth shell, and deep routes |
| `lib/config.dart` | `AppConfig`: TMDB settings, API base-URL resolution, streaming-source list |
| `lib/l10n/` | `app_{en,es,fr,de}.arb` sources + generated `app_localizations_*.dart` |
| `lib/main.dart`, `lib/app.dart`, `lib/theme.dart` | Entry point, root widget with providers/router, theme |
| `api/index.php` | Front controller routing all `/api/*` requests to PHP files |
| `api/config/` | `database.php` (PDO + auth helpers), `env.php`, `mail.php`, `fcm.php`, `streaming.php` |
| `api/auth/` | 14 endpoints: login, register, verify, codes, password reset, sessions, logout, profile, avatar, account, OAuth |
| `api/admin/` | Admin endpoints + subdirs (`users/`, `reviews/`, `movies/`, `banners/`, `analytics/`, `activity/`) |
| `api/reviews/` | `add`, `list`, `my`, `like`, `replies`, `reply`, `report`, `delete` |
| `api/proxy/` | `embed.php` (stream player proxy), `vidsrc.php` (extraction proxy) |
| `api/` (other) | `movies/`, `search/`, `watchlist/`, `favorites/`, `history/`, `lists/`, `users/`, `feed/timeline.php`, `notifications/` (6 files), `banners.php`, `health.php`, `health-db.php` |
| `migrations/` | Numbered SQL migrations `000`–`014` (see [Data & Database](#data--database)) |
| `database_schema.sql` | Base MySQL 8.0+ schema snapshot |
| `web/`, `android/` | Flutter platform shells; Android holds manifest, icons, and FCM wiring |
| `assets/images/` | Bundled app imagery (logo, icons) |
| `vidsrc-api/` | Standalone Node/TypeScript stream-extraction micro-service (own `package.json`/`vercel.json`), deployed separately |
| `test/` | Unit + widget tests (`unit/`, `widgets/`, `widget_test.dart`, `error_message_test.dart`) |
| `vercel.json` | Vercel routing: `/api/*` → PHP, everything else → Flutter web |
| `build.sh` | Vercel build script (Flutter web output to `build/web`) |
| `l10n.yaml` | Localization generation config |
| `pubspec.yaml` | Flutter dependencies |
| `AGENTS.md` | Machine-specific build guide (Windows quirks, JDK, flags) |

---

# Flutter Application

- **Screens** (`lib/screens/`): one widget tree per feature area; `auth/`
  covers the signed-out flow, `admin/` the moderation console. Web/mobile
  player variants use conditional exports (`*_mobile.dart` vs `*_web.dart`).
- **State management**: `provider`/`ChangeNotifier` providers per domain
  (see table above); `AuthProvider` additionally owns guest mode and session
  bootstrapping.
- **Services**: `ApiService` attaches the `auth_token` Bearer header to every
  authenticated call; `api_endpoints.dart` keeps path constants in one place;
  `AuthService` persists token, guest flag, and device info; `TmdbService`
  fetches metadata, credits, and videos; `FcmService` registers the push token
  and routes notification taps.
- **Routing**: `go_router` via `createAppRouter(auth)` — `/splash` while auth
  loads, `/onboarding` for first run, `/landing` for signed-out users, an
  authenticated shell (`/browse`, `/feed`, `/search`, `/favorites`,
  `/watchlist`, `/profile`, …) plus deep routes (`/movies/:id`,
  `/profile/:userId`, `/lists/:listId`, `/person/:id`, `/admin/…`).
  Detail screens (movie, stream, see-all) additionally use `Navigator.push` to
  keep parameter passing simple on mobile.
- **Localization**: `AppLocalizations` generated from ARB files
  (`flutter gen-l10n` via [l10n.yaml](l10n.yaml)); runtime locale switching
  through `LocaleProvider`.
- **Configuration**: `AppConfig` resolves the API URL with precedence
  compile-time `--dart-define=API_BASE_URL` → saved override → emulator
  auto-detect (see [Configuration](#configuration)).
- **Notifications**: foreground messages render through
  `flutter_local_notifications` (`cine_track_channel`); taps deep-link into
  the router (see [Notifications & Firebase](#notifications--firebase)).
- **Web specifics**: trailer/stream playback uses `HtmlElementView` iframes;
  the stream iframe intentionally omits `sandbox` so VidLink can play; FCM is
  skipped on web.

---

# Backend API

`api/index.php` is the single front controller (used by Vercel; Apache/XAMPP
serves files directly via `.htaccess` locally). For each request it:

1. Strips the `/api/` prefix and rejects `..`/null-byte path traversal.
2. Appends `.php` and verifies with `realpath` that the target stays inside
   `api/` (otherwise JSON `404 {"error": "Endpoint not found"}`).
3. Answers CORS preflights (`OPTIONS` → `Access-Control-Allow-Origin: *`,
   methods `GET, POST, DELETE, OPTIONS`, headers
   `Content-Type, Authorization`) and then `require`s the endpoint file.

Conventions: JSON in/out via `jsonResponse`/`jsonError` helpers in
`api/config/database.php`; database access through `getDb(): PDO`
(MySQL, `utf8mb4`, exceptions); caller identity via `getAuthUserId()` against
`api_tokens` Bearer tokens; admin areas guarded by
`requireRole($userId, 'admin'[, 'moderator'])` with 403 on mismatch; notable
side effects (admin actions, logins, notifications) recorded with
`logAdminAction`/`logActivity`/`logLoginAttempt`/`createNotification`.

| Group | Purpose | Location |
|---|---|---|
| Auth | Login, registration, email verification, password reset, sessions, profile, avatar, account deletion, OAuth | `api/auth/` |
| Movies / Search | Movie metadata and search | `api/movies/`, `api/search/` |
| Favorites | Favorite add/remove/list | `api/favorites/` |
| Watchlist | Watchlist add/remove/list | `api/watchlist/` |
| History | Viewing-history log and retrieval | `api/history/` |
| Reviews | Add/list/my-reviews, likes, replies, reports, delete | `api/reviews/` |
| Lists | List CRUD, movie membership, reorder | `api/lists/` |
| Social | Profiles, stats, activity, follow/followers/following, block/blocked | `api/users/` |
| Feed | Social timeline | `api/feed/timeline.php` |
| Notifications | List/read/unread-count/preferences, FCM token register/unregister | `api/notifications/` |
| Banners | Promotional banners | `api/banners.php` |
| Admin | Dashboard, analytics, users, movies, reviews, banners, settings, activity, login audit | `api/admin/` |
| Proxy | Stream embed proxy and extraction proxy | `api/proxy/` |
| Health | Liveness and database checks | `api/health.php`, `api/health-db.php` |

---

# Authentication & Authorization

- **Registration/login**: email + password; login accepts `remember_me` and
  `device_info` (`android`/`web`) and stores a row in `api_tokens`
  (`token`, `expires_at`, `last_used_at`).
- **Requests**: the client sends `Authorization: Bearer <token>`;
  `getAuthUserId()` validates it (including expiry) and refreshes
  `last_used_at`.
- **Email verification**: 6-digit code flow (`verify_code.php`,
  `resend_verification.php`); unverified accounts are flagged client-side.
- **Password reset**: `forgot_password.php` + `reset_password.php` with
  `password_reset_tokens`.
- **Sessions**: `api/auth/sessions.php` lists device sessions with
  per-session revoke and revoke-all.
- **Guest mode**: unsigned users get `guest_mode` in local preferences;
  restricted tabs show an upgrade prompt; any authenticated change clears it.
- **Authorization**: `users.role` is `user`, `moderator`, or `admin`
  (`User.isAdmin` / `User.isModerator` client-side). Admin endpoints call
  `requireRole`; user/movies/banners/settings/activity areas are admin-only,
  while dashboard, reviews, and analytics admit moderators too.
- **Storage note**: tokens live in `SharedPreferences` (not secure storage) —
  see [Security Considerations](#security-considerations).

---

# Data & Database

- **Technology**: MySQL 8.0+ (PlanetScale-compatible per
  [database_schema.sql](database_schema.sql) header); PDO with
  `charset=utf8mb4` and exceptions enabled.
- **Base schema** ([database_schema.sql](database_schema.sql)): `users`,
  `api_tokens`, `cache`, `password_reset_tokens`, `login_audit`,
  `watchlist`, `watch_history`, `reviews`, `favorites`.
- **Migrations** ([migrations/](migrations/), applied in numeric order):
  watch-history fixes and counts (`000`–`002`), avatar storage (`003`),
  admin features (`004`), `movies` cache table (`005`), app settings
  (`006`), banners (`007`), review replies (`008`), social core — follows,
  lists, feed, notifications, FCM tokens (`009`), user bios (`010`),
  history runtime (`011`), token session fields (`012`), user blocks
  (`013`), notification preferences (`014`).
- **Domain overview**:

| Domain | Entities |
|---|---|
| Identity | `users`, `api_tokens`, `password_reset_tokens`, `login_audit` |
| Tracking | `watchlist`, `watch_history`, `favorites`, `movies`, `user_lists`, `list_movies` |
| Social | `follows`, `user_blocks`, `activity_feed` |
| Reviews | `reviews`, `review_likes`, `review_replies`, `review_reports` |
| Notifications | `notifications`, `notification_preferences`, `fcm_tokens` |
| Admin/Content | `banners`, `app_settings`, `admin_logs`, `cache` |

- **Convention**: each migration is one numbered, self-describing `.sql`
  file; the session-fields move (`api/migrations/002_*` →
  `migrations/012_*`) shows migrations live under `migrations/`, not
  `api/`.

---

# Streaming

Source order in `AppConfig.streamingSources` (index matters — it is passed as
`?source=` to the proxy):

1. VidLink (`vidlink.pro`)
2. vidsrcme.su
3. vidsrcme.ru
4. API Player (`apiplayer.ru`)

The client builds playback URLs with
`AppConfig.streamUrl(movieId, sourceIndex)` →
`$apiBaseUrl/proxy/embed.php?source=<i>&tmdb=<id>&platform=<web|mobile>`,
so embeds are proxied through our backend (which can special-case sources and
fall back automatically). The stream screen offers a **Try different source**
action that cycles the index; on web, later indexes open in a new tab.

Platform differences (verified in source): mobile plays inside `InAppWebView`
with JavaScript enabled; web embeds an `HtmlElementView` iframe that
deliberately omits `sandbox` so VidLink playback is not blocked. Trailers are
separate YouTube embeds and are unrelated to these providers.

> **Validation status:** provider ordering and proxy plumbing are implemented
> and the app compiles cleanly, but end-to-end playback against each live
> provider is **pending verification**. Do not treat this section as a
> playability guarantee.

The `vidsrc-api/` directory is a standalone Node/TypeScript extraction
micro-service (own `package.json`/`vercel.json`) deployed separately and used
when direct embeds need extraction help.

---

# Social System

Profiles are the hub: each user has a bio, avatar, stats (counts computed
server-side in `api/users/stats.php`), and an activity trail
(`api/users/activity.php`). **Follows** create directed edges powering the
follower/following lists and the **feed** (`api/feed/timeline.php`), which
aggregates followed users' activity. **Blocks** are directional filters —
blocked users' reviews disappear from the blocker's lists. **Reviews** carry a
moderation `status`; **likes** are lightweight counters with per-user state;
**replies** thread under reviews; **reports** queue content for moderators.
**Notifications** close the loop: follows, likes, and replies generate
notifications (and pushes) to the content owner. Admins/moderators supervise
via the review-moderation console and user-management tools.

---

# Notifications & Firebase

- Android push uses `firebase_messaging`; the FCM token is registered with
  the backend on login (`register_token`, refreshed on token rotation) and
  removed on logout (`unregister_token`).
- Foreground messages render via `flutter_local_notifications` on channel
  `cine_track_channel`.
- Taps carry `{type, target_type, target_id}`: follows open `/profile/:id`,
  review likes/replies open `/movies/:id`.
- Server-side, `createNotification()` fans out only for `follow`,
  `review_like`, and `reply` events; users tune delivery in
  notification preferences (`api/notifications/preferences.php`).
- Web skips FCM entirely (`FcmService` returns early on `kIsWeb`).

> **Secrets:** `android/app/google-services.json` and the Firebase
> service-account JSON under `api/config/` are **local-only** and git-ignored.
> Never commit them. Request them from a project maintainer for local setup.

---

# Localization

Supported locales: **English, Spanish, French, German** — sources
`lib/l10n/app_{en,es,fr,de}.arb` with `app_en.arb` as template.
`flutter gen-l10n` (configured in [l10n.yaml](l10n.yaml)) generates
`lib/l10n/app_localizations*.dart` (`AppLocalizations` class); widgets read
strings from it and the runtime locale switches via `LocaleProvider`.
Generated files are committed so builds work without a generation step.

---

# Configuration

| Mechanism | Safe to commit? | Notes |
|---|---|---|
| `--dart-define=API_BASE_URL=…` | Yes (value is public) | Compile-time override; production `https://cine-track-delta.vercel.app/api` |
| Emulator auto-detect | Yes (code) | Non-physical Android → `http://10.0.2.2/cine_track/api` |
| Saved override (`api_base_url` pref) | Local only | Set via login-screen long-press (see below) |
| `lib/config.dart` TMDB settings | Partially | Endpoint URLs safe; the **API key is a live secret** — tracked historically, should move server-side (see Security) |
| `api/.env` / `api/config/*.php` | No | DB/mail/FCM credentials; only `.env.example` is committed |
| `google-services.json`, service-account JSON | No | Git-ignored; local-only |

**Resolution precedence** (`AppConfig.initialize`): dart-define wins outright;
otherwise emulator default applies, then any saved override replaces it. The
current URL is printed below the login title; **long-pressing the “Welcome
Back” title (or the URL text)** opens a dialog to set a custom URL, persisted
in `SharedPreferences` across restarts. `flutter logs` shows the resolved
value as `AppConfig: …` at startup.

---

# Development Setup

Prerequisites:

- Flutter SDK with Dart `^3.9.2` (see [pubspec.yaml](pubspec.yaml))
- PHP 8+ with PDO-MySQL, and MySQL 8+ (XAMPP works) for the local API
- Android SDK + JDK 21 for APK builds (see [AGENTS.md](AGENTS.md) for the
  exact JDK and required flags on Windows)
- Node.js only if you work on `vidsrc-api/`

```bash
flutter pub get
flutter test
flutter analyze
```

Local API: serve this repository (or at least `api/`) from XAMPP so the
Android emulator reaches it at `http://10.0.2.2/cine_track/api`, create the
database from [database_schema.sql](database_schema.sql), then apply
[migrations/](migrations/) `000`–`014` in order. Copy `api/.env.example`
where required and fill in local credentials (never commit the result).

---

# Builds & Deploy

Release builds need machine-specific flags — the summary below is accurate,
but **[AGENTS.md](AGENTS.md) is authoritative** for the full quirk list
(JBR JDK 21, `ANDROID_AAPT2_EXE`, desugaring, CMake/NDK pins,
`path_provider_android` override, `objective_c` hook workaround).

```powershell
$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
$env:ANDROID_AAPT2_EXE = "C:\Android\build-tools\36.1.0\aapt2.exe"
flutter build apk --release --no-tree-shake-icons --android-skip-build-dependency-validation --split-debug-info=build/debug-info --dart-define=API_BASE_URL=https://cine-track-delta.vercel.app/api
```

Web:

```powershell
flutter build web --release --no-tree-shake-icons --dart-define=API_BASE_URL=https://cine-track-delta.vercel.app/api
```

Deployment: web output (`build/web`) and the PHP API deploy together to the
`cine-track-delta` Vercel project per [vercel.json](vercel.json)
(`build.sh` builds the web app; `/api/*` routes to `api/index.php`,
everything else to `index.html`). Release with:

```bash
vercel --prod --confirm
```

from the project root. If the Vercel project is still linked to a previous
GitHub repository, re-link its Git integration to
`realyncipriano/cine_track` so pushes auto-deploy.

---

# Testing

Tests live in `test/` (7 files): model unit tests
(`user`, `review`, `notification_item`), widget tests (`like_button`,
`auth_error_banner`), `error_message_test`, and the default `widget_test`
landing-page smoke test.

```bash
flutter test                                    # full suite
flutter test test/unit/models/review_test.dart  # single file
flutter analyze                                 # static analysis
```

---

# Security Considerations

- **Hardcoded TMDB key:** `lib/config.dart` currently embeds a live TMDB API
  key, also used as a fallback default in `api/admin/movies/` endpoints. It
  is tracked in git history. Recommended: move it server-side behind
  `TMDB_API_KEY` (which the code already reads via `getenv`) and rotate
  the key.
- **Token storage:** auth Bearer tokens persist in `SharedPreferences`
  (`auth_token`, plus `guest_mode` and `api_base_url`), which is not secure
  storage — treat tokens as revocable (sessions support revoke/revoke-all)
  and consider migrating to platform secure storage.
- **CORS:** the API answers `Access-Control-Allow-Origin: *`; acceptable for
  a public read API + token auth, but review before adding cookie-based auth.
- **Secrets hygiene:** `google-services.json`, Firebase service-account JSON,
  `api/.env`, and any PATs/tokens must never be committed. This repository's
  `.gitignore` covers the known paths — extend it before adding new secret
  files.
- **Server-side guards worth keeping:** `requireRole` on every admin route,
  path-traversal containment in the front controller, login-attempt
  rate-limiting/lockout helpers, and password validation.

---

# Further Reading

- [AGENTS.md](AGENTS.md) — build commands and Windows environment quirks
- [database_schema.sql](database_schema.sql) — base database schema
- [migrations/](migrations/) — incremental schema changes `000`–`014`
- [api/](api/) — backend endpoints (`index.php` front controller)
- [lib/](lib/) — Flutter application source
- [vidsrc-api/](vidsrc-api/) — stream-extraction micro-service
- [pubspec.yaml](pubspec.yaml) — Flutter dependencies
- [l10n.yaml](l10n.yaml) — localization generation config
- [vercel.json](vercel.json) — production routing and build wiring
