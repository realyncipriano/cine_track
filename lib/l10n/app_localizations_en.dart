// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get createAccount => 'Create Account';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get invalidEmail => 'Enter a valid email';

  @override
  String get minPasswordChars => 'Min 8 characters';

  @override
  String get verifyCode => 'Verify Code';

  @override
  String get resendVerification => 'Resend verification email';

  @override
  String get verificationEmailSent => 'Verification email sent';

  @override
  String get emailVerifiedSigningIn => 'Email verified! Signing in...';

  @override
  String get enter6DigitCode => 'Enter the 6-digit code from the email';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get apiUrl => 'API URL';

  @override
  String get apiUrlDescription =>
      'Enter a custom API base URL.\nThis is saved across app restarts.';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get apiUrlUpdated => 'API URL updated';

  @override
  String get newVerificationLinkSent =>
      'A new verification link has been sent to your email.';

  @override
  String get nameLabel => 'Name';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get usernameLabel => 'Username';

  @override
  String get usernameMinChars => 'Min 3 characters';

  @override
  String get usernameMaxChars => 'Max 50 characters';

  @override
  String get usernameInvalidChars => 'Letters, numbers, _ and - only';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get phoneOptionalLabel => 'Phone (optional)';

  @override
  String get invalidPhone => 'Invalid phone number';

  @override
  String get dateOfBirthLabel => 'Date of Birth';

  @override
  String get dateOfBirthOptionalLabel => 'Date of Birth (optional)';

  @override
  String get countryLabel => 'Country';

  @override
  String get countryOptionalLabel => 'Country (optional)';

  @override
  String get selectCountry => 'Select your country';

  @override
  String get passwordStrengthWeak => 'Weak';

  @override
  String get passwordStrengthFair => 'Fair';

  @override
  String get passwordStrengthGood => 'Good';

  @override
  String get passwordStrengthStrong => 'Strong';

  @override
  String get passwordStrengthVeryStrong => 'Very strong';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get maxPasswordChars => 'Max 72 characters';

  @override
  String get needsUppercase => 'Needs an uppercase letter';

  @override
  String get needsLowercase => 'Needs a lowercase letter';

  @override
  String get needsDigit => 'Needs a digit';

  @override
  String get acceptTerms =>
      'I agree to the Terms of Service and Privacy Policy';

  @override
  String get marketingOptIn =>
      'Send me movie recommendations and updates via email';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get accountCreated => 'Account created!';

  @override
  String get mustAcceptTerms =>
      'You must agree to the Terms of Service and Privacy Policy';

  @override
  String get resetPasswordTitle => 'Reset Password';

  @override
  String get resetPasswordDescription =>
      'Enter your email address and we\'ll send you a link to reset your password.';

  @override
  String get pasteResetLink => 'Paste the reset link from your email below:';

  @override
  String get resetLinkHint => 'Paste full reset link here';

  @override
  String get continueAction => 'Continue';

  @override
  String get sendResetLink => 'Send Reset Link';

  @override
  String get backTo => 'Back to ';

  @override
  String get ifEmailRegistered =>
      'If that email is registered, you will receive a password reset link shortly.';

  @override
  String get invalidLinkFormat => 'Invalid link format';

  @override
  String get noResetToken => 'Could not find reset token in the link';

  @override
  String get invalidEmailInLink => 'Invalid email address in the reset link';

  @override
  String get invalidResetToken => 'Invalid reset token in the link';

  @override
  String get setNewPassword => 'Set New Password';

  @override
  String get setNewPasswordDescription => 'Enter your new password below.';

  @override
  String get newPasswordLabel => 'New Password';

  @override
  String get confirmNewPasswordLabel => 'Confirm New Password';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get passwordResetSuccess => 'Password Reset!';

  @override
  String get passwordResetDescription =>
      'Your password has been reset successfully. All existing sessions have been logged out.';

  @override
  String get goToHome => 'Go to Home';

  @override
  String get emailNotVerified => 'Email Not Verified';

  @override
  String get verifyEmailDescription =>
      'Please verify your email address to access all features.';

  @override
  String get newCodeSent => 'A new verification code has been sent.';

  @override
  String get emailVerifiedSuccess => 'Email verified successfully!';

  @override
  String get resendVerificationEmail => 'Resend Verification Email';

  @override
  String get iVerifiedSignIn => 'I\'ve Verified — Sign In';

  @override
  String get signOut => 'Sign Out';

  @override
  String get checkYourEmail => 'Check Your Email';

  @override
  String get emailVerified => 'Email Verified!';

  @override
  String get verificationSentTo => 'We sent a verification code to';

  @override
  String get codeExpires10Min =>
      'Enter the 6-digit code from the email. The code expires in 10 minutes.';

  @override
  String get youCanNowLogIn => 'You can now log in to your account.';

  @override
  String get goToSignIn => 'Go to Sign In';

  @override
  String get resendCode => 'Resend Code';

  @override
  String resendCodeCountdown(Object count) {
    return 'Resend Code ($count)';
  }

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get bioLabel => 'Bio';

  @override
  String get bioHint => 'Tell us about yourself...';

  @override
  String get marketingEmails => 'Marketing emails';

  @override
  String get marketingEmailsSubtitle => 'Receive recommendations and updates';

  @override
  String get emailNotVerifiedWarning => 'Email not verified';

  @override
  String get profileUpdated => 'Profile updated!';

  @override
  String get changeEmailWarning =>
      'Changing email will require re-verification';

  @override
  String get signOutTitle => 'Sign Out';

  @override
  String get signOutConfirm => 'Are you sure you want to sign out?';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountWarning =>
      'This action cannot be undone. All your data will be permanently deleted.';

  @override
  String get enterPasswordConfirm => 'Enter your password to confirm';

  @override
  String get delete => 'Delete';

  @override
  String get clearCache => 'Clear Cache';

  @override
  String get clearCacheConfirm => 'Clear cached images and data?';

  @override
  String get cacheCleared => 'Cache cleared';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get spanish => 'Spanish';

  @override
  String get french => 'French';

  @override
  String get german => 'German';

  @override
  String get close => 'Close';

  @override
  String get about => 'About';

  @override
  String get appTagline =>
      'Track your movies, build watchlists, and discover new favorites.';

  @override
  String get avatarUpdated => 'Avatar updated';

  @override
  String get passwordChanged => 'Password changed successfully';

  @override
  String get changePassword => 'Change Password';

  @override
  String get currentPasswordLabel => 'Current Password';

  @override
  String get update => 'Update';

  @override
  String get fillAllPasswordFields => 'Fill in all password fields';

  @override
  String get newPasswordMinChars =>
      'New password must be at least 8 characters';

  @override
  String get guestBrowsing => 'You\'re browsing as a guest';

  @override
  String get saveFavorites => 'Save Favorites';

  @override
  String get saveFavoritesDesc => 'Bookmark movies you love for quick access';

  @override
  String get buildWatchlist => 'Build Watchlist';

  @override
  String get buildWatchlistDesc => 'Plan what to watch next';

  @override
  String get trackHistory => 'Track History';

  @override
  String get trackHistoryDesc => 'Keep a record of every movie you watch';

  @override
  String get signInCreateAccount => 'Sign In / Create Account';

  @override
  String get settings => 'Settings';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get myReviews => 'My Reviews';

  @override
  String get myLists => 'My Lists';

  @override
  String get stats => 'Stats';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationComingSoon => 'Notification settings coming soon';

  @override
  String get manageSessions => 'Manage Sessions';

  @override
  String get blockedUsers => 'Blocked Users';

  @override
  String get movies => 'Movies';

  @override
  String get reviews => 'Reviews';

  @override
  String get lists => 'Lists';

  @override
  String get followers => 'Followers';

  @override
  String get following => 'Following';

  @override
  String get favorites => 'Favorites';

  @override
  String get watchHistory => 'Watch History';

  @override
  String get seeAll => 'See All';

  @override
  String get noWatchHistory => 'No watch history yet';

  @override
  String get marketingEmailsEnabled => 'Marketing emails enabled';

  @override
  String get resend => 'Resend';

  @override
  String get showCurrentPassword => 'Show current password';

  @override
  String get hideCurrentPassword => 'Hide current password';

  @override
  String get showNewPassword => 'Show new password';

  @override
  String get hideNewPassword => 'Hide new password';

  @override
  String get showConfirmPassword => 'Show confirm password';

  @override
  String get hideConfirmPassword => 'Hide confirm password';

  @override
  String get browseMovies => 'Browse Movies';

  @override
  String get recentlyWatched => 'Recently Watched';

  @override
  String get trendingNow => 'Trending Now';

  @override
  String get nowPlaying => 'Now Playing';

  @override
  String get popular => 'Popular';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String get topRated => 'Top Rated';

  @override
  String get noMoviesFound => 'No movies found';

  @override
  String get noMoviesAvailable => 'No movies available';

  @override
  String get featuredMovies => 'Featured Movies';

  @override
  String get searchMoviesHint => 'Search movies...';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get filterByYear => 'Filter by year';

  @override
  String get sortBy => 'Sort by';

  @override
  String get rating => 'Rating';

  @override
  String get newest => 'Newest';

  @override
  String get searchMillions => 'Search millions of movies';

  @override
  String noResultsFor(Object query) {
    return 'No results for \"$query\"';
  }

  @override
  String get movie => 'Movie';

  @override
  String get movieNotFound => 'Movie not found';

  @override
  String get failedToLoadMovie => 'Failed to load movie details';

  @override
  String get failedToLoadCast => 'Failed to load cast';

  @override
  String get failedToLoadSimilar => 'Failed to load similar movies';

  @override
  String get failedToLoadRecommendations => 'Failed to load recommendations';

  @override
  String get failedToLoadTrailer => 'Failed to load trailer';

  @override
  String get retry => 'Retry';

  @override
  String get reportReview => 'Report Review';

  @override
  String get reportReasonHint => 'Why are you reporting this review?';

  @override
  String get submit => 'Submit';

  @override
  String get reviewReported => 'Review reported';

  @override
  String get failedToReportReview => 'Failed to report review';

  @override
  String get notAvailable => 'N/A';

  @override
  String get hoursAbbr => 'h';

  @override
  String get minutesAbbr => 'm';

  @override
  String get minutesSuffix => ' min';

  @override
  String get overview => 'Overview';

  @override
  String get noOverview => 'No overview available.';

  @override
  String get cast => 'Cast';

  @override
  String get similarMovies => 'Similar Movies';

  @override
  String get recommendationSection => 'Recommendations';

  @override
  String get ratingsReviews => 'Ratings & Reviews';

  @override
  String get yourReview => 'Your review';

  @override
  String get watchTeaser => 'Watch Teaser';

  @override
  String get watchTrailer => 'Watch Trailer';

  @override
  String get favorited => 'Favorited';

  @override
  String get favoriteAction => 'Favorite';

  @override
  String get saved => 'Saved';

  @override
  String get watchlistAction => 'Watchlist';

  @override
  String get listAction => 'List';

  @override
  String get share => 'Share';

  @override
  String get watchNow => 'Watch Now';

  @override
  String get editAction => 'Edit';

  @override
  String get deleteAction => 'Delete';

  @override
  String get writeReviewHint => 'Write your review (optional)';

  @override
  String get updateReview => 'Update Review';

  @override
  String get submitReview => 'Submit Review';

  @override
  String get shareReview => 'Share review';

  @override
  String get reportAction => 'Report';

  @override
  String get landingTitle => 'CineTrack';

  @override
  String get landingTagline => 'Your personal cinema command center';

  @override
  String get landingSubtitle =>
      'Track every film. Discover your next obsession.';

  @override
  String get smartSearch => 'Smart Search';

  @override
  String get smartSearchDesc => 'Find any movie instantly with powerful search';

  @override
  String get apiDiscovery => 'API-Powered Discovery';

  @override
  String get apiDiscoveryDesc =>
      'Browse trending and top-rated movies live from TMDB';

  @override
  String get favoritesWatchlist => 'Favorites & Watchlist';

  @override
  String get favoritesWatchlistDesc =>
      'Save movies to your favorites or build a watchlist';

  @override
  String get guestExplanation =>
      'Guest mode: browse and search only. Sign in to save favorites, build watchlists, and track history.';

  @override
  String get landingFooter => '© 2026 CineTrack. Powered by TMDB.';

  @override
  String get continueAsGuest => 'Continue as Guest';

  @override
  String get switchToLightMode => 'Switch to light mode';

  @override
  String get switchToDarkMode => 'Switch to dark mode';

  @override
  String get discoverMovies => 'Discover Movies';

  @override
  String get discoverMoviesDesc =>
      'Browse thousands of movies from TMDB. Search by genre, year, or popularity to find your next favorite film.';

  @override
  String get trackFavorites => 'Track Favorites';

  @override
  String get trackFavoritesDesc =>
      'Save movies to your favorites, build a watchlist, and keep track of everything you\'ve watched.';

  @override
  String get startWatching => 'Start Watching';

  @override
  String get startWatchingDesc =>
      'Stream movies built-in, read reviews, rate films, and explore recommendations tailored just for you.';

  @override
  String get signInOrExplore => 'Sign In or Explore';

  @override
  String get signInOrExploreDesc =>
      'Create an account to sync across devices, or browse as a guest and start watching right away.';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get Started';

  @override
  String get changeProfilePicture => 'Change Profile Picture';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get removeCurrentPhoto => 'Remove Current Photo';

  @override
  String failedToPickImage(Object error) {
    return 'Failed to pick image: $error';
  }

  @override
  String get sessionExpiring => 'Session Expiring';

  @override
  String get sessionExpiringDesc =>
      'Your session will expire in 2 minutes due to inactivity.\n\nTap \"Stay Logged In\" to continue.';

  @override
  String get stayLoggedIn => 'Stay Logged In';

  @override
  String hideReplies(Object count) {
    return 'Hide replies ($count)';
  }

  @override
  String repliesCount(Object count) {
    return 'Replies ($count)';
  }

  @override
  String get anonymous => 'Anonymous';

  @override
  String get writeReplyHint => 'Write a reply...';

  @override
  String movieCount(Object count) {
    return '$count movies';
  }

  @override
  String get publicBadge => 'Public';

  @override
  String get privateBadge => 'Private';

  @override
  String pageIndicator(Object current, Object total) {
    return 'Page $current of $total';
  }

  @override
  String ratingOutOf10(Object rating) {
    return 'Rating: $rating out of 10';
  }

  @override
  String get ratingSelector => 'Rating selector';

  @override
  String get selectRatingHint => 'Select a rating from 1 to 10';

  @override
  String rateOutOf10(Object starValue) {
    return 'Rate $starValue out of 10';
  }

  @override
  String get tapToRate => 'Tap to rate';

  @override
  String ratingDisplay(Object rating) {
    return '$rating / 10';
  }

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get notifFollowLabel => 'New Followers';

  @override
  String get notifFollowSubtitle => 'When someone follows you';

  @override
  String get notifReviewLikeLabel => 'Review Likes';

  @override
  String get notifReviewLikeSubtitle => 'When someone likes your review';

  @override
  String get notifReplyLabel => 'Replies';

  @override
  String get notifReplySubtitle => 'When someone replies to your review';

  @override
  String get notifModerationLabel => 'Moderation';

  @override
  String get notifModerationSubtitle => 'When your content is moderated';

  @override
  String get notifListAddLabel => 'List Additions';

  @override
  String get notifListAddSubtitle => 'When someone adds you to a list';

  @override
  String get notificationSettingsHint =>
      'You\'ll also receive essential notifications about your account security.';

  @override
  String get person => 'Person';

  @override
  String get personNotFound => 'Person not found';

  @override
  String get failedToLoadPerson => 'Failed to load person details';

  @override
  String get biography => 'Biography';

  @override
  String get readMore => 'Read more';

  @override
  String get showLess => 'Show less';

  @override
  String get personalInfo => 'Personal Info';

  @override
  String get birthdayLabel => 'Birthday';

  @override
  String get ageLabel => 'Age';

  @override
  String yearsOld(Object age) {
    return '$age years old';
  }

  @override
  String get placeOfBirth => 'Place of Birth';

  @override
  String get status => 'Status';

  @override
  String get alive => 'Alive';

  @override
  String get deceased => 'Deceased';

  @override
  String get alsoKnownAs => 'Also Known As';

  @override
  String get knownFor => 'Known For';

  @override
  String get filmography => 'Filmography';
}
