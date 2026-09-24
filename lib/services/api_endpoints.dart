class ApiEndpoints {
  // Admin
  static const dashboard = '/admin/dashboard.php';
  static const users = '/admin/users.php';
  static const updateUserRole = '/admin/users/update_role.php';
  static const toggleBan = '/admin/users/toggle_ban.php';
  static const deleteUser = '/admin/users/delete.php';
  static const reviews = '/admin/reviews.php';
  static const moderateReview = '/admin/reviews/moderate.php';
  static const bulkModerateReview = '/admin/reviews/bulk_moderate.php';
  static const deleteReview = '/admin/reviews/delete.php';
  static const movies = '/admin/movies.php';
  static const movieAdd = '/admin/movies/add.php';
  static const movieUpdate = '/admin/movies/update.php';
  static const movieDelete = '/admin/movies/delete.php';
  static const movieSearchTmdb = '/admin/movies/search_tmdb.php';
  static const activity = '/admin/activity.php';
  static const loginAudit = '/admin/activity/login_audit.php';
  static const settings = '/admin/settings.php';
  static const settingsUpdate = '/admin/settings/update.php';
  // Banners
  static const banners = '/admin/banners.php';
  static const bannerAdd = '/admin/banners/add.php';
  static const bannerUpdate = '/admin/banners/update.php';
  static const bannerDelete = '/admin/banners/delete.php';
  static const publicBanners = '/banners.php';
  // Featured movies
  static const featuredMovies = '/movies/featured.php';
  // Reviews
  static const reviewList = '/reviews/list.php';
  static const reviewAdd = '/reviews/add.php';
  static const reviewDelete = '/reviews/delete.php';
  static const reviewReport = '/reviews/report.php';
  static const reviewLike = '/reviews/like.php';
  static const reviewReplies = '/reviews/replies.php';
  static const reviewReply = '/reviews/reply.php';
  static const deleteReviewReply = '/admin/reviews/delete_reply.php';
  static const deleteMyReviewReply = '/reviews/delete_my_reply.php';
  // History
  static const historyList = '/history/list.php';
  static const historyAdd = '/history/add.php';
  static const historyDelete = '/history/delete.php';
  static const historyClear = '/history/clear.php';
  // Notifications
  static const notificationList = '/notifications/list.php';
  static const notificationRead = '/notifications/read.php';
  static const notificationUnreadCount = '/notifications/unread_count.php';
  static const notificationRegisterToken = '/notifications/register_token.php';
  static const notificationUnregisterToken = '/notifications/unregister_token.php';
  static const notificationPreferences = '/notifications/preferences.php';
  // Analytics
  static const analyticsOverview = '/admin/analytics/overview.php';
  static const analyticsTrends = '/admin/analytics/trends.php';
  static const analyticsExport = '/admin/analytics/export.php';
  // Lists
  static const listCreate = '/lists/create.php';
  static const listUpdate = '/lists/update.php';
  static const listDelete = '/lists/delete.php';
  static const listDetail = '/lists/detail.php';
  static const listAddMovie = '/lists/add_movie.php';
  static const listRemoveMovie = '/lists/remove_movie.php';
  static const listReorder = '/lists/reorder.php';
  static const userLists = '/lists/list.php';
  // Social / Users
  static const userProfile = '/users/profile.php';
  static const userStats = '/users/stats.php';
  static const follow = '/users/follow.php';
  static const followers = '/users/followers.php';
  static const following = '/users/following.php';
  static const block = '/users/block.php';
  static const blockedUsers = '/users/blocked.php';
  static const userActivity = '/users/activity.php';
  // Feed
  static const timeline = '/feed/timeline.php';
  // Search
  static const searchUsers = '/search/users.php';
  static const searchMovies = '/search/movies.php';
}
