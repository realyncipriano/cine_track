<?php
require_once __DIR__ . '/../config/database.php';

header('Access-Control-Allow-Origin: ' . getAllowedOrigin());
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit;
}

$movieId = (int) ($_GET['movie_id'] ?? 0);
if ($movieId <= 0) {
    jsonError('movie_id is required');
}

$pdo = getDb();

$currentUserId = null;
$headers = getallheaders();
$auth = $headers['Authorization'] ?? $headers['authorization'] ?? '';
$token = str_replace('Bearer ', '', $auth);

if (!empty($token)) {
    $tokenStmt = $pdo->prepare('SELECT user_id FROM api_tokens WHERE token = ? AND (expires_at IS NULL OR expires_at > NOW())');
    $tokenStmt->execute([$token]);
    $tokenRow = $tokenStmt->fetch();
    if ($tokenRow) {
        $currentUserId = (int) $tokenRow['user_id'];
    }
}

$isLikedSubquery = $currentUserId
    ? '(SELECT COUNT(*) FROM review_likes WHERE review_id = r.id AND user_id = ' . $currentUserId . ') AS is_liked'
    : '0 AS is_liked';

$blockFilter = '';
$params = [$movieId];
if ($currentUserId) {
    $blockFilter = 'AND r.user_id NOT IN (SELECT blocked_id FROM user_blocks WHERE blocker_id = ?)';
    $params[] = $currentUserId;
}

$stmt = $pdo->prepare("
    SELECT r.id, r.user_id, r.movie_id, r.rating, r.review_text, r.created_at, r.updated_at, r.status, u.name as user_name,
           (SELECT COUNT(*) FROM review_likes WHERE review_id = r.id) AS likes_count,
           $isLikedSubquery
    FROM reviews r
    JOIN users u ON u.id = r.user_id
    WHERE r.movie_id = ? AND r.status = 'approved'
    $blockFilter
    ORDER BY r.created_at DESC
");
$stmt->execute($params);
$reviews = $stmt->fetchAll();

$summaryStmt = $pdo->prepare('SELECT AVG(rating) as average, COUNT(*) as count FROM reviews WHERE movie_id = ?');
$summaryStmt->execute([$movieId]);
$summary = $summaryStmt->fetch();

$userReview = null;

if ($currentUserId) {
    $userStmt = $pdo->prepare("
        SELECT r.id, r.user_id, r.movie_id, r.rating, r.review_text, r.created_at, r.updated_at, r.status, u.name as user_name,
               (SELECT COUNT(*) FROM review_likes WHERE review_id = r.id) AS likes_count,
               (SELECT COUNT(*) FROM review_likes WHERE review_id = r.id AND user_id = ?) AS is_liked
        FROM reviews r
        JOIN users u ON u.id = r.user_id
        WHERE r.movie_id = ? AND r.user_id = ?
    ");
    $userStmt->execute([$currentUserId, $movieId, $currentUserId]);
    $userReview = $userStmt->fetch();
    if ($userReview === false) {
        $userReview = null;
    }
}

jsonResponse([
    'reviews' => $reviews,
    'summary' => [
        'average' => $summary['average'] ? round((float) $summary['average'], 1) : null,
        'count' => (int) $summary['count'],
    ],
    'user_review' => $userReview,
]);
