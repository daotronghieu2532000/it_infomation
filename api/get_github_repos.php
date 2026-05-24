<?php
/**
 * CODE GO TECHFLOW API - GET GITHUB TRENDING REPOSITORIES
 * API endpoint: /api/get_github_repos.php
 * Method: GET
 * 
 * Headers:
 * - Authorization: Bearer {access_token} (từ get_token.php)
 * - User-Token: {user_token} (optional - dùng để kiểm tra is_bookmarked)
 * 
 * Parameters (GET):
 * - period: 'daily' hoặc 'weekly' (Mặc định 'daily')
 * - language: Lọc theo ngôn ngữ lập trình (Dart, Python, v.v., mặc định là tất cả)
 */

require_once __DIR__ . '/includes/config.php';
require_once __DIR__ . '/includes/helpers.php';

// Cho phép GET hoặc POST
requireMethod(['GET', 'POST']);

// Kiểm tra Authorization header
$headers = getallheaders();
$auth_header = $headers['Authorization'] ?? $headers['authorization'] ?? '';

if (empty($auth_header) || !preg_match('/Bearer\s+(.*)$/i', $auth_header, $matches)) {
    jsonResponse(false, 'Authorization token required', null, 401);
}

$token = $matches[1];
$token_data = verifyJWT($token, 'codego_secret_key_2025');

if (!$token_data) {
    jsonResponse(false, 'Invalid or expired token', null, 401);
}

// Kiểm tra User-Token (nếu có để check bookmark)
$user_token = $headers['User-Token'] ?? $headers['user-token'] ?? '';
$user_id = 0;
if (!empty($user_token)) {
    $user_data = verifyJWT($user_token, 'codego_secret_key_2025');
    if ($user_data) {
        $user_id = intval($user_data['user_id']);
    }
}

// Lấy tham số đầu vào
$input = getRequestMethod() === 'POST' ? getJsonInput() : $_GET;

$period = isset($input['period']) ? sanitizeInput($input['period']) : 'daily';
$language = isset($input['language']) ? sanitizeInput($input['language']) : '';

if ($period !== 'weekly') {
    $period = 'daily';
}

$where_clauses = ["rank_period = ?"];
$params = [$period];
$types = "s";

if (!empty($language) && strtolower($language) !== 'all') {
    $where_clauses[] = "language = ?";
    $params[] = $language;
    $types .= "s";
}

$where_sql = implode(" AND ", $where_clauses);

// Truy vấn danh sách repository
$query = "
    SELECT r.*, 
           IF(b.id IS NOT NULL, 1, 0) as is_bookmarked
    FROM github_repos r
    LEFT JOIN user_bookmarks b ON b.user_id = ? AND b.item_type = 'repo' AND b.item_id = r.id
    WHERE $where_sql
    ORDER BY r.stars_today DESC, r.stars_count DESC
";

$stmt = $conn->prepare($query);

if (!$stmt) {
    jsonResponse(false, 'Database preparation error: ' . $conn->error, null, 500);
}

// Bind tham số
$bind_params = array_merge([$user_id], $params);
$bind_types = "i" . $types;
$stmt->bind_param($bind_types, ...$bind_params);
$stmt->execute();
$result = $stmt->get_result();

$repos = [];
while ($row = $result->fetch_assoc()) {
    $row['id'] = intval($row['id']);
    $row['stars_count'] = intval($row['stars_count']);
    $row['forks_count'] = intval($row['forks_count']);
    $row['stars_today'] = intval($row['stars_today']);
    $row['fetched_at'] = intval($row['fetched_at']);
    $row['is_bookmarked'] = $row['is_bookmarked'] == 1;
    
    $repos[] = $row;
}
$stmt->close();

jsonResponse(true, 'Fetched trending repositories successfully', $repos, 200);
?>
