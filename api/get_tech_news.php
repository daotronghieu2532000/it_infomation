<?php
/**
 * CODE GO TECHFLOW API - GET TECH ARTICLES
 * API endpoint: /api/get_tech_news.php
 * Method: GET
 * 
 * Headers:
 * - Authorization: Bearer {access_token} (từ get_token.php)
 * - User-Token: {user_token} (optional - dùng để kiểm tra is_bookmarked)
 * 
 * Parameters (GET):
 * - category: Lọc theo chuyên mục (Mobile, AI, General, v.v.)
 * - type: 'daily' hoặc 'weekly' (tiêu điểm tuần)
 * - page: Mặc định 1
 * - limit: Mặc định 10
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

$category = isset($input['category']) ? sanitizeInput($input['category']) : '';
$type = isset($input['type']) ? sanitizeInput($input['type']) : '';
$page = isset($input['page']) ? intval($input['page']) : 1;
$limit = isset($input['limit']) ? intval($input['limit']) : 10;

if ($page < 1) $page = 1;
if ($limit < 1 || $limit > 50) $limit = 10;
$offset = ($page - 1) * $limit;

// Xây dựng câu truy vấn SQL
$where_clauses = ["1=1"];
$params = [];
$types = "";

if (!empty($category) && $category !== 'All') {
    $where_clauses[] = "category = ?";
    $params[] = $category;
    $types .= "s";
}

if ($type === 'weekly') {
    $where_clauses[] = "is_weekly_highlight = 1";
} elseif ($type === 'daily') {
    $where_clauses[] = "is_weekly_highlight = 0";
}

$where_sql = implode(" AND ", $where_clauses);

// Đếm tổng số bài viết
$count_query = "SELECT COUNT(*) as total FROM tech_articles WHERE $where_sql";
$stmt_count = $conn->prepare($count_query);

if (!empty($params)) {
    $stmt_count->bind_param($types, ...$params);
}
$stmt_count->execute();
$count_result = $stmt_count->get_result()->fetch_assoc();
$total_items = intval($count_result['total'] ?? 0);
$stmt_count->close();

$total_pages = ceil($total_items / $limit);

// Truy vấn danh sách bài viết
$query = "
    SELECT a.*, 
           IF(b.id IS NOT NULL, 1, 0) as is_bookmarked,
           IF(l.id IS NOT NULL, 1, 0) as is_liked
    FROM tech_articles a
    LEFT JOIN user_bookmarks b ON b.user_id = ? AND b.item_type = 'article' AND b.item_id = a.id
    LEFT JOIN user_likes l ON l.user_id = ? AND l.item_type = 'article' AND l.item_id = a.id
    WHERE $where_sql
    ORDER BY a.published_at DESC
    LIMIT ? OFFSET ?
";

$stmt = $conn->prepare($query);

if (!$stmt) {
    jsonResponse(false, 'Database preparation error: ' . $conn->error, null, 500);
}

// Bind tham số
$bind_params = array_merge([$user_id, $user_id], $params, [$limit, $offset]);
$bind_types = "ii" . $types . "ii";
$stmt->bind_param($bind_types, ...$bind_params);
$stmt->execute();
$result = $stmt->get_result();

$articles = [];
while ($row = $result->fetch_assoc()) {
    // Ép kiểu dữ liệu
    $row['id'] = intval($row['id']);
    $row['view_count'] = intval($row['view_count']);
    $row['is_weekly_highlight'] = intval($row['is_weekly_highlight']);
    $row['published_at'] = intval($row['published_at']);
    $row['created_at'] = intval($row['created_at']);
    $row['updated_at'] = intval($row['updated_at']);
    $row['is_bookmarked'] = $row['is_bookmarked'] == 1;
    $row['is_liked'] = $row['is_liked'] == 1;
    
    $articles[] = $row;
}
$stmt->close();

jsonResponse(true, 'Fetched articles successfully', [
    'articles' => $articles,
    'pagination' => [
        'current_page' => $page,
        'total_pages' => $total_pages,
        'total_items' => $total_items,
        'limit' => $limit
    ]
], 200);
?>
