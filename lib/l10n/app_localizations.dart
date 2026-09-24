import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
  ];

  /// Login button
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// Register link text
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// Register page title
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// Login page greeting
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// Forgot password link
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// Remember me checkbox
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// Sign up prompt
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// Email validation error
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get invalidEmail;

  /// Password min length error
  ///
  /// In en, this message translates to:
  /// **'Min 8 characters'**
  String get minPasswordChars;

  /// Verify code button
  ///
  /// In en, this message translates to:
  /// **'Verify Code'**
  String get verifyCode;

  /// Resend verification link
  ///
  /// In en, this message translates to:
  /// **'Resend verification email'**
  String get resendVerification;

  /// Verification sent confirmation
  ///
  /// In en, this message translates to:
  /// **'Verification email sent'**
  String get verificationEmailSent;

  /// Verification success message
  ///
  /// In en, this message translates to:
  /// **'Email verified! Signing in...'**
  String get emailVerifiedSigningIn;

  /// Code input hint
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code from the email'**
  String get enter6DigitCode;

  /// Show password tooltip
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// Hide password tooltip
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// API URL dialog title
  ///
  /// In en, this message translates to:
  /// **'API URL'**
  String get apiUrl;

  /// API URL dialog description
  ///
  /// In en, this message translates to:
  /// **'Enter a custom API base URL.\nThis is saved across app restarts.'**
  String get apiUrlDescription;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// API URL update snackbar
  ///
  /// In en, this message translates to:
  /// **'API URL updated'**
  String get apiUrlUpdated;

  /// Verification link sent
  ///
  /// In en, this message translates to:
  /// **'A new verification link has been sent to your email.'**
  String get newVerificationLinkSent;

  /// Name field label
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// Name validation error
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// Username field label
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get usernameLabel;

  /// Username min length error
  ///
  /// In en, this message translates to:
  /// **'Min 3 characters'**
  String get usernameMinChars;

  /// Username max length error
  ///
  /// In en, this message translates to:
  /// **'Max 50 characters'**
  String get usernameMaxChars;

  /// Username invalid chars error
  ///
  /// In en, this message translates to:
  /// **'Letters, numbers, _ and - only'**
  String get usernameInvalidChars;

  /// Phone field label
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// Optional phone field label
  ///
  /// In en, this message translates to:
  /// **'Phone (optional)'**
  String get phoneOptionalLabel;

  /// Phone validation error
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number'**
  String get invalidPhone;

  /// DOB field label
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirthLabel;

  /// Optional DOB field label
  ///
  /// In en, this message translates to:
  /// **'Date of Birth (optional)'**
  String get dateOfBirthOptionalLabel;

  /// Country field label
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get countryLabel;

  /// Optional country field label
  ///
  /// In en, this message translates to:
  /// **'Country (optional)'**
  String get countryOptionalLabel;

  /// Country dropdown hint
  ///
  /// In en, this message translates to:
  /// **'Select your country'**
  String get selectCountry;

  /// Password strength label
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get passwordStrengthWeak;

  /// Password strength label
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get passwordStrengthFair;

  /// Password strength label
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get passwordStrengthGood;

  /// Password strength label
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get passwordStrengthStrong;

  /// Password strength label
  ///
  /// In en, this message translates to:
  /// **'Very strong'**
  String get passwordStrengthVeryStrong;

  /// Confirm password field label
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordLabel;

  /// Password mismatch error
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// Password max length error
  ///
  /// In en, this message translates to:
  /// **'Max 72 characters'**
  String get maxPasswordChars;

  /// Password uppercase requirement
  ///
  /// In en, this message translates to:
  /// **'Needs an uppercase letter'**
  String get needsUppercase;

  /// Password lowercase requirement
  ///
  /// In en, this message translates to:
  /// **'Needs a lowercase letter'**
  String get needsLowercase;

  /// Password digit requirement
  ///
  /// In en, this message translates to:
  /// **'Needs a digit'**
  String get needsDigit;

  /// Terms acceptance label
  ///
  /// In en, this message translates to:
  /// **'I agree to the Terms of Service and Privacy Policy'**
  String get acceptTerms;

  /// Marketing opt-in label
  ///
  /// In en, this message translates to:
  /// **'Send me movie recommendations and updates via email'**
  String get marketingOptIn;

  /// Sign in prompt on register
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// Registration success
  ///
  /// In en, this message translates to:
  /// **'Account created!'**
  String get accountCreated;

  /// Terms acceptance error
  ///
  /// In en, this message translates to:
  /// **'You must agree to the Terms of Service and Privacy Policy'**
  String get mustAcceptTerms;

  /// Forgot password page title
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordTitle;

  /// Forgot password description
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we\'ll send you a link to reset your password.'**
  String get resetPasswordDescription;

  /// Reset link paste prompt
  ///
  /// In en, this message translates to:
  /// **'Paste the reset link from your email below:'**
  String get pasteResetLink;

  /// Reset link field hint
  ///
  /// In en, this message translates to:
  /// **'Paste full reset link here'**
  String get resetLinkHint;

  /// Continue button
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// Send reset link button
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// Back to sign in link prefix
  ///
  /// In en, this message translates to:
  /// **'Back to '**
  String get backTo;

  /// Reset email sent message
  ///
  /// In en, this message translates to:
  /// **'If that email is registered, you will receive a password reset link shortly.'**
  String get ifEmailRegistered;

  /// Invalid reset link error
  ///
  /// In en, this message translates to:
  /// **'Invalid link format'**
  String get invalidLinkFormat;

  /// Missing token error
  ///
  /// In en, this message translates to:
  /// **'Could not find reset token in the link'**
  String get noResetToken;

  /// Invalid email in link error
  ///
  /// In en, this message translates to:
  /// **'Invalid email address in the reset link'**
  String get invalidEmailInLink;

  /// Invalid token error
  ///
  /// In en, this message translates to:
  /// **'Invalid reset token in the link'**
  String get invalidResetToken;

  /// Reset password page title
  ///
  /// In en, this message translates to:
  /// **'Set New Password'**
  String get setNewPassword;

  /// Reset password description
  ///
  /// In en, this message translates to:
  /// **'Enter your new password below.'**
  String get setNewPasswordDescription;

  /// New password field label
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPasswordLabel;

  /// Confirm new password field label
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPasswordLabel;

  /// Reset password button
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// Reset success title
  ///
  /// In en, this message translates to:
  /// **'Password Reset!'**
  String get passwordResetSuccess;

  /// Reset success description
  ///
  /// In en, this message translates to:
  /// **'Your password has been reset successfully. All existing sessions have been logged out.'**
  String get passwordResetDescription;

  /// Home navigation button
  ///
  /// In en, this message translates to:
  /// **'Go to Home'**
  String get goToHome;

  /// Verify email page title
  ///
  /// In en, this message translates to:
  /// **'Email Not Verified'**
  String get emailNotVerified;

  /// Verify email description
  ///
  /// In en, this message translates to:
  /// **'Please verify your email address to access all features.'**
  String get verifyEmailDescription;

  /// New code sent message
  ///
  /// In en, this message translates to:
  /// **'A new verification code has been sent.'**
  String get newCodeSent;

  /// Email verified success
  ///
  /// In en, this message translates to:
  /// **'Email verified successfully!'**
  String get emailVerifiedSuccess;

  /// Resend button
  ///
  /// In en, this message translates to:
  /// **'Resend Verification Email'**
  String get resendVerificationEmail;

  /// Verified sign in button
  ///
  /// In en, this message translates to:
  /// **'I\'ve Verified — Sign In'**
  String get iVerifiedSignIn;

  /// Sign out button
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// Verification sent title
  ///
  /// In en, this message translates to:
  /// **'Check Your Email'**
  String get checkYourEmail;

  /// Email verified title
  ///
  /// In en, this message translates to:
  /// **'Email Verified!'**
  String get emailVerified;

  /// Verification sent message
  ///
  /// In en, this message translates to:
  /// **'We sent a verification code to'**
  String get verificationSentTo;

  /// Code expiry hint
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code from the email. The code expires in 10 minutes.'**
  String get codeExpires10Min;

  /// Post-verification message
  ///
  /// In en, this message translates to:
  /// **'You can now log in to your account.'**
  String get youCanNowLogIn;

  /// Navigate to sign in button
  ///
  /// In en, this message translates to:
  /// **'Go to Sign In'**
  String get goToSignIn;

  /// Resend code button
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get resendCode;

  /// Resend code with cooldown
  ///
  /// In en, this message translates to:
  /// **'Resend Code ({count})'**
  String resendCodeCountdown(Object count);

  /// Edit profile title
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// Bio field label
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bioLabel;

  /// Bio field hint
  ///
  /// In en, this message translates to:
  /// **'Tell us about yourself...'**
  String get bioHint;

  /// Marketing toggle label
  ///
  /// In en, this message translates to:
  /// **'Marketing emails'**
  String get marketingEmails;

  /// Marketing toggle subtitle
  ///
  /// In en, this message translates to:
  /// **'Receive recommendations and updates'**
  String get marketingEmailsSubtitle;

  /// Email unverified warning
  ///
  /// In en, this message translates to:
  /// **'Email not verified'**
  String get emailNotVerifiedWarning;

  /// Profile save success
  ///
  /// In en, this message translates to:
  /// **'Profile updated!'**
  String get profileUpdated;

  /// Email change warning
  ///
  /// In en, this message translates to:
  /// **'Changing email will require re-verification'**
  String get changeEmailWarning;

  /// Sign out dialog title
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOutTitle;

  /// Sign out confirmation
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get signOutConfirm;

  /// Delete account button
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// Delete account warning
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. All your data will be permanently deleted.'**
  String get deleteAccountWarning;

  /// Password confirmation field
  ///
  /// In en, this message translates to:
  /// **'Enter your password to confirm'**
  String get enterPasswordConfirm;

  /// Delete confirm button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Clear cache button
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get clearCache;

  /// Clear cache confirmation
  ///
  /// In en, this message translates to:
  /// **'Clear cached images and data?'**
  String get clearCacheConfirm;

  /// Cache cleared snackbar
  ///
  /// In en, this message translates to:
  /// **'Cache cleared'**
  String get cacheCleared;

  /// Language settings label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Spanish language option
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// French language option
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// German language option
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get german;

  /// Close button
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// About dialog title
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// App tagline in about dialog
  ///
  /// In en, this message translates to:
  /// **'Track your movies, build watchlists, and discover new favorites.'**
  String get appTagline;

  /// Avatar update success
  ///
  /// In en, this message translates to:
  /// **'Avatar updated'**
  String get avatarUpdated;

  /// Password change success
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChanged;

  /// Change password button
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// Current password field label
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPasswordLabel;

  /// Update button
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// Password fields required error
  ///
  /// In en, this message translates to:
  /// **'Fill in all password fields'**
  String get fillAllPasswordFields;

  /// New password min length
  ///
  /// In en, this message translates to:
  /// **'New password must be at least 8 characters'**
  String get newPasswordMinChars;

  /// Guest mode label
  ///
  /// In en, this message translates to:
  /// **'You\'re browsing as a guest'**
  String get guestBrowsing;

  /// Guest feature card title
  ///
  /// In en, this message translates to:
  /// **'Save Favorites'**
  String get saveFavorites;

  /// Guest feature card description
  ///
  /// In en, this message translates to:
  /// **'Bookmark movies you love for quick access'**
  String get saveFavoritesDesc;

  /// Guest feature card title
  ///
  /// In en, this message translates to:
  /// **'Build Watchlist'**
  String get buildWatchlist;

  /// Guest feature card description
  ///
  /// In en, this message translates to:
  /// **'Plan what to watch next'**
  String get buildWatchlistDesc;

  /// Guest feature card title
  ///
  /// In en, this message translates to:
  /// **'Track History'**
  String get trackHistory;

  /// Guest feature card description
  ///
  /// In en, this message translates to:
  /// **'Keep a record of every movie you watch'**
  String get trackHistoryDesc;

  /// Guest CTA button
  ///
  /// In en, this message translates to:
  /// **'Sign In / Create Account'**
  String get signInCreateAccount;

  /// Settings section header
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Light mode toggle
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// Dark mode toggle
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// My reviews nav
  ///
  /// In en, this message translates to:
  /// **'My Reviews'**
  String get myReviews;

  /// My lists nav
  ///
  /// In en, this message translates to:
  /// **'My Lists'**
  String get myLists;

  /// Stats nav
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get stats;

  /// Notifications nav
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Not implemented yet
  ///
  /// In en, this message translates to:
  /// **'Notification settings coming soon'**
  String get notificationComingSoon;

  /// Sessions nav
  ///
  /// In en, this message translates to:
  /// **'Manage Sessions'**
  String get manageSessions;

  /// Blocked users nav
  ///
  /// In en, this message translates to:
  /// **'Blocked Users'**
  String get blockedUsers;

  /// Movies stat label
  ///
  /// In en, this message translates to:
  /// **'Movies'**
  String get movies;

  /// Reviews stat label
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// Lists stat label
  ///
  /// In en, this message translates to:
  /// **'Lists'**
  String get lists;

  /// Followers stat label
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get followers;

  /// Following stat label
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get following;

  /// Favorites stat label
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// History section title
  ///
  /// In en, this message translates to:
  /// **'Watch History'**
  String get watchHistory;

  /// See all link
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// Empty history message
  ///
  /// In en, this message translates to:
  /// **'No watch history yet'**
  String get noWatchHistory;

  /// Marketing status in profile
  ///
  /// In en, this message translates to:
  /// **'Marketing emails enabled'**
  String get marketingEmailsEnabled;

  /// Resend verification button
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resend;

  /// Show current password tooltip
  ///
  /// In en, this message translates to:
  /// **'Show current password'**
  String get showCurrentPassword;

  /// Hide current password tooltip
  ///
  /// In en, this message translates to:
  /// **'Hide current password'**
  String get hideCurrentPassword;

  /// Show new password tooltip
  ///
  /// In en, this message translates to:
  /// **'Show new password'**
  String get showNewPassword;

  /// Hide new password tooltip
  ///
  /// In en, this message translates to:
  /// **'Hide new password'**
  String get hideNewPassword;

  /// Show confirm password tooltip
  ///
  /// In en, this message translates to:
  /// **'Show confirm password'**
  String get showConfirmPassword;

  /// Hide confirm password tooltip
  ///
  /// In en, this message translates to:
  /// **'Hide confirm password'**
  String get hideConfirmPassword;

  /// Browse page title
  ///
  /// In en, this message translates to:
  /// **'Browse Movies'**
  String get browseMovies;

  /// Recently watched section title
  ///
  /// In en, this message translates to:
  /// **'Recently Watched'**
  String get recentlyWatched;

  /// Trending section title
  ///
  /// In en, this message translates to:
  /// **'Trending Now'**
  String get trendingNow;

  /// Now playing section title
  ///
  /// In en, this message translates to:
  /// **'Now Playing'**
  String get nowPlaying;

  /// Popular section title
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get popular;

  /// Coming soon section title
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// Top rated section title
  ///
  /// In en, this message translates to:
  /// **'Top Rated'**
  String get topRated;

  /// Empty genre grid
  ///
  /// In en, this message translates to:
  /// **'No movies found'**
  String get noMoviesFound;

  /// Empty section
  ///
  /// In en, this message translates to:
  /// **'No movies available'**
  String get noMoviesAvailable;

  /// Featured carousel title
  ///
  /// In en, this message translates to:
  /// **'Featured Movies'**
  String get featuredMovies;

  /// Search field hint
  ///
  /// In en, this message translates to:
  /// **'Search movies...'**
  String get searchMoviesHint;

  /// Clear search tooltip
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// Year filter tooltip
  ///
  /// In en, this message translates to:
  /// **'Filter by year'**
  String get filterByYear;

  /// Sort filter tooltip
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// Sort option: rating
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// Sort option: newest date
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get newest;

  /// Search empty prompt
  ///
  /// In en, this message translates to:
  /// **'Search millions of movies'**
  String get searchMillions;

  /// Search empty state with query
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String noResultsFor(Object query);

  /// AppBar title fallback
  ///
  /// In en, this message translates to:
  /// **'Movie'**
  String get movie;

  /// Movie load error
  ///
  /// In en, this message translates to:
  /// **'Movie not found'**
  String get movieNotFound;

  /// Movie details error
  ///
  /// In en, this message translates to:
  /// **'Failed to load movie details'**
  String get failedToLoadMovie;

  /// Cast load error
  ///
  /// In en, this message translates to:
  /// **'Failed to load cast'**
  String get failedToLoadCast;

  /// Similar movies error
  ///
  /// In en, this message translates to:
  /// **'Failed to load similar movies'**
  String get failedToLoadSimilar;

  /// Recommendations error
  ///
  /// In en, this message translates to:
  /// **'Failed to load recommendations'**
  String get failedToLoadRecommendations;

  /// Trailer load error
  ///
  /// In en, this message translates to:
  /// **'Failed to load trailer'**
  String get failedToLoadTrailer;

  /// Retry button
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Report review dialog title
  ///
  /// In en, this message translates to:
  /// **'Report Review'**
  String get reportReview;

  /// Report reason field hint
  ///
  /// In en, this message translates to:
  /// **'Why are you reporting this review?'**
  String get reportReasonHint;

  /// Submit button
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// Report success snackbar
  ///
  /// In en, this message translates to:
  /// **'Review reported'**
  String get reviewReported;

  /// Report failure snackbar
  ///
  /// In en, this message translates to:
  /// **'Failed to report review'**
  String get failedToReportReview;

  /// Not available fallback
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get notAvailable;

  /// Hours abbreviation
  ///
  /// In en, this message translates to:
  /// **'h'**
  String get hoursAbbr;

  /// Minutes abbreviation
  ///
  /// In en, this message translates to:
  /// **'m'**
  String get minutesAbbr;

  /// Minutes suffix
  ///
  /// In en, this message translates to:
  /// **' min'**
  String get minutesSuffix;

  /// Movie overview section
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// Empty overview text
  ///
  /// In en, this message translates to:
  /// **'No overview available.'**
  String get noOverview;

  /// Cast section title
  ///
  /// In en, this message translates to:
  /// **'Cast'**
  String get cast;

  /// Similar movies section
  ///
  /// In en, this message translates to:
  /// **'Similar Movies'**
  String get similarMovies;

  /// Recommendations section title
  ///
  /// In en, this message translates to:
  /// **'Recommendations'**
  String get recommendationSection;

  /// Reviews section title
  ///
  /// In en, this message translates to:
  /// **'Ratings & Reviews'**
  String get ratingsReviews;

  /// User's own review label
  ///
  /// In en, this message translates to:
  /// **'Your review'**
  String get yourReview;

  /// Teaser button
  ///
  /// In en, this message translates to:
  /// **'Watch Teaser'**
  String get watchTeaser;

  /// Trailer button
  ///
  /// In en, this message translates to:
  /// **'Watch Trailer'**
  String get watchTrailer;

  /// Already favorited button
  ///
  /// In en, this message translates to:
  /// **'Favorited'**
  String get favorited;

  /// Favorite button
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get favoriteAction;

  /// Already in watchlist button
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// Watchlist button
  ///
  /// In en, this message translates to:
  /// **'Watchlist'**
  String get watchlistAction;

  /// Add to list button
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get listAction;

  /// Share button
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Stream CTA button
  ///
  /// In en, this message translates to:
  /// **'Watch Now'**
  String get watchNow;

  /// Edit button
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editAction;

  /// Delete action button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteAction;

  /// Review field hint
  ///
  /// In en, this message translates to:
  /// **'Write your review (optional)'**
  String get writeReviewHint;

  /// Update review button
  ///
  /// In en, this message translates to:
  /// **'Update Review'**
  String get updateReview;

  /// Submit review button
  ///
  /// In en, this message translates to:
  /// **'Submit Review'**
  String get submitReview;

  /// Share review tooltip
  ///
  /// In en, this message translates to:
  /// **'Share review'**
  String get shareReview;

  /// Report review button
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get reportAction;

  /// Landing page title
  ///
  /// In en, this message translates to:
  /// **'CineTrack'**
  String get landingTitle;

  /// Landing page tagline
  ///
  /// In en, this message translates to:
  /// **'Your personal cinema command center'**
  String get landingTagline;

  /// Landing page subtitle
  ///
  /// In en, this message translates to:
  /// **'Track every film. Discover your next obsession.'**
  String get landingSubtitle;

  /// Feature card title
  ///
  /// In en, this message translates to:
  /// **'Smart Search'**
  String get smartSearch;

  /// Feature card description
  ///
  /// In en, this message translates to:
  /// **'Find any movie instantly with powerful search'**
  String get smartSearchDesc;

  /// Feature card title
  ///
  /// In en, this message translates to:
  /// **'API-Powered Discovery'**
  String get apiDiscovery;

  /// Feature card description
  ///
  /// In en, this message translates to:
  /// **'Browse trending and top-rated movies live from TMDB'**
  String get apiDiscoveryDesc;

  /// Feature card title
  ///
  /// In en, this message translates to:
  /// **'Favorites & Watchlist'**
  String get favoritesWatchlist;

  /// Feature card description
  ///
  /// In en, this message translates to:
  /// **'Save movies to your favorites or build a watchlist'**
  String get favoritesWatchlistDesc;

  /// Guest mode explanation
  ///
  /// In en, this message translates to:
  /// **'Guest mode: browse and search only. Sign in to save favorites, build watchlists, and track history.'**
  String get guestExplanation;

  /// Landing page footer
  ///
  /// In en, this message translates to:
  /// **'© 2026 CineTrack. Powered by TMDB.'**
  String get landingFooter;

  /// Guest mode button
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get continueAsGuest;

  /// Theme toggle tooltip
  ///
  /// In en, this message translates to:
  /// **'Switch to light mode'**
  String get switchToLightMode;

  /// Theme toggle tooltip
  ///
  /// In en, this message translates to:
  /// **'Switch to dark mode'**
  String get switchToDarkMode;

  /// Onboarding page 1 title
  ///
  /// In en, this message translates to:
  /// **'Discover Movies'**
  String get discoverMovies;

  /// Onboarding page 1 description
  ///
  /// In en, this message translates to:
  /// **'Browse thousands of movies from TMDB. Search by genre, year, or popularity to find your next favorite film.'**
  String get discoverMoviesDesc;

  /// Onboarding page 2 title
  ///
  /// In en, this message translates to:
  /// **'Track Favorites'**
  String get trackFavorites;

  /// Onboarding page 2 description
  ///
  /// In en, this message translates to:
  /// **'Save movies to your favorites, build a watchlist, and keep track of everything you\'ve watched.'**
  String get trackFavoritesDesc;

  /// Onboarding page 3 title
  ///
  /// In en, this message translates to:
  /// **'Start Watching'**
  String get startWatching;

  /// Onboarding page 3 description
  ///
  /// In en, this message translates to:
  /// **'Stream movies built-in, read reviews, rate films, and explore recommendations tailored just for you.'**
  String get startWatchingDesc;

  /// Onboarding page 4 title
  ///
  /// In en, this message translates to:
  /// **'Sign In or Explore'**
  String get signInOrExplore;

  /// Onboarding page 4 description
  ///
  /// In en, this message translates to:
  /// **'Create an account to sync across devices, or browse as a guest and start watching right away.'**
  String get signInOrExploreDesc;

  /// Skip onboarding button
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Next button
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Get started button
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// Avatar sheet title
  ///
  /// In en, this message translates to:
  /// **'Change Profile Picture'**
  String get changeProfilePicture;

  /// Camera option
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// Gallery option
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// Remove avatar option
  ///
  /// In en, this message translates to:
  /// **'Remove Current Photo'**
  String get removeCurrentPhoto;

  /// Image pick error
  ///
  /// In en, this message translates to:
  /// **'Failed to pick image: {error}'**
  String failedToPickImage(Object error);

  /// Idle timer dialog title
  ///
  /// In en, this message translates to:
  /// **'Session Expiring'**
  String get sessionExpiring;

  /// Idle timer dialog body
  ///
  /// In en, this message translates to:
  /// **'Your session will expire in 2 minutes due to inactivity.\n\nTap \"Stay Logged In\" to continue.'**
  String get sessionExpiringDesc;

  /// Keep session alive button
  ///
  /// In en, this message translates to:
  /// **'Stay Logged In'**
  String get stayLoggedIn;

  /// Hide replies toggle
  ///
  /// In en, this message translates to:
  /// **'Hide replies ({count})'**
  String hideReplies(Object count);

  /// Show replies toggle
  ///
  /// In en, this message translates to:
  /// **'Replies ({count})'**
  String repliesCount(Object count);

  /// Fallback username
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get anonymous;

  /// Reply input hint
  ///
  /// In en, this message translates to:
  /// **'Write a reply...'**
  String get writeReplyHint;

  /// Movie count label in list card
  ///
  /// In en, this message translates to:
  /// **'{count} movies'**
  String movieCount(Object count);

  /// Public list badge
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get publicBadge;

  /// Private list badge
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get privateBadge;

  /// Pagination indicator
  ///
  /// In en, this message translates to:
  /// **'Page {current} of {total}'**
  String pageIndicator(Object current, Object total);

  /// Rating accessibility label
  ///
  /// In en, this message translates to:
  /// **'Rating: {rating} out of 10'**
  String ratingOutOf10(Object rating);

  /// Rating bar accessibility label
  ///
  /// In en, this message translates to:
  /// **'Rating selector'**
  String get ratingSelector;

  /// Rating bar accessibility hint
  ///
  /// In en, this message translates to:
  /// **'Select a rating from 1 to 10'**
  String get selectRatingHint;

  /// Per-star accessibility label
  ///
  /// In en, this message translates to:
  /// **'Rate {starValue} out of 10'**
  String rateOutOf10(Object starValue);

  /// Unrated state label
  ///
  /// In en, this message translates to:
  /// **'Tap to rate'**
  String get tapToRate;

  /// Selected rating display
  ///
  /// In en, this message translates to:
  /// **'{rating} / 10'**
  String ratingDisplay(Object rating);

  /// Notification settings page title
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// Follow notification toggle label
  ///
  /// In en, this message translates to:
  /// **'New Followers'**
  String get notifFollowLabel;

  /// Follow notification toggle subtitle
  ///
  /// In en, this message translates to:
  /// **'When someone follows you'**
  String get notifFollowSubtitle;

  /// Review like notification toggle label
  ///
  /// In en, this message translates to:
  /// **'Review Likes'**
  String get notifReviewLikeLabel;

  /// Review like notification toggle subtitle
  ///
  /// In en, this message translates to:
  /// **'When someone likes your review'**
  String get notifReviewLikeSubtitle;

  /// Reply notification toggle label
  ///
  /// In en, this message translates to:
  /// **'Replies'**
  String get notifReplyLabel;

  /// Reply notification toggle subtitle
  ///
  /// In en, this message translates to:
  /// **'When someone replies to your review'**
  String get notifReplySubtitle;

  /// Moderation notification toggle label
  ///
  /// In en, this message translates to:
  /// **'Moderation'**
  String get notifModerationLabel;

  /// Moderation notification toggle subtitle
  ///
  /// In en, this message translates to:
  /// **'When your content is moderated'**
  String get notifModerationSubtitle;

  /// List add notification toggle label
  ///
  /// In en, this message translates to:
  /// **'List Additions'**
  String get notifListAddLabel;

  /// List add notification toggle subtitle
  ///
  /// In en, this message translates to:
  /// **'When someone adds you to a list'**
  String get notifListAddSubtitle;

  /// Notification settings hint text
  ///
  /// In en, this message translates to:
  /// **'You\'ll also receive essential notifications about your account security.'**
  String get notificationSettingsHint;

  /// Person screen fallback title
  ///
  /// In en, this message translates to:
  /// **'Person'**
  String get person;

  /// Person not found error
  ///
  /// In en, this message translates to:
  /// **'Person not found'**
  String get personNotFound;

  /// Person load error
  ///
  /// In en, this message translates to:
  /// **'Failed to load person details'**
  String get failedToLoadPerson;

  /// Biography section header
  ///
  /// In en, this message translates to:
  /// **'Biography'**
  String get biography;

  /// Expand text action
  ///
  /// In en, this message translates to:
  /// **'Read more'**
  String get readMore;

  /// Collapse text action
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get showLess;

  /// Personal info section header
  ///
  /// In en, this message translates to:
  /// **'Personal Info'**
  String get personalInfo;

  /// Birthday info label
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get birthdayLabel;

  /// Age info label
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get ageLabel;

  /// Age display
  ///
  /// In en, this message translates to:
  /// **'{age} years old'**
  String yearsOld(Object age);

  /// Place of birth info label
  ///
  /// In en, this message translates to:
  /// **'Place of Birth'**
  String get placeOfBirth;

  /// Status info label
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// Alive status
  ///
  /// In en, this message translates to:
  /// **'Alive'**
  String get alive;

  /// Deceased status
  ///
  /// In en, this message translates to:
  /// **'Deceased'**
  String get deceased;

  /// Also known as section label
  ///
  /// In en, this message translates to:
  /// **'Also Known As'**
  String get alsoKnownAs;

  /// Known for section header
  ///
  /// In en, this message translates to:
  /// **'Known For'**
  String get knownFor;

  /// Filmography section header
  ///
  /// In en, this message translates to:
  /// **'Filmography'**
  String get filmography;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
