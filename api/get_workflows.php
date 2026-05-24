<?php
/**
 * CODE GO TECHFLOW API - GET DEV WORKFLOWS
 * API endpoint: /api/get_workflows.php
 * Method: GET
 * 
 * Headers:
 * - Authorization: Bearer {access_token} (từ get_token.php)
 * - User-Token: {user_token} (optional - dùng để kiểm tra is_bookmarked, is_liked)
 * 
 * Parameters (GET):
 * - category: Lọc theo chuyên mục (VS Code, Cursor IDE, GitHub Actions, Docker, Linux, etc.)
 * - search: Từ khóa tìm kiếm trong title hoặc description
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

// Kiểm tra User-Token (nếu có để check bookmark & like)
$user_id = 0;
$user_token = $headers['User-Token'] ?? $headers['user-token'] ?? '';
if (!empty($user_token)) {
    $user_data = verifyJWT($user_token, 'codego_secret_key_2025');
    if ($user_data) {
        $user_id = intval($user_data['user_id']);
    }
}

// Tự động nâng cấp bảng nếu thiếu trường copy_count
$check_column = $conn->query("SHOW COLUMNS FROM dev_workflows LIKE 'copy_count'");
if ($check_column && $check_column->num_rows == 0) {
    $conn->query("ALTER TABLE dev_workflows ADD COLUMN copy_count INT DEFAULT 0 AFTER likes_count");
}

// Lấy tham số đầu vào
$input = getRequestMethod() === 'POST' ? getJsonInput() : $_GET;

$category = isset($input['category']) ? sanitizeInput($input['category']) : '';
$search = isset($input['search']) ? sanitizeInput($input['search']) : '';

$where_clauses = ["1=1"];
$params = [];
$types = "";

if (!empty($category) && strtolower($category) !== 'all') {
    $where_clauses[] = "tool_category = ?";
    $params[] = $category;
    $types .= "s";
}

if (!empty($search)) {
    $where_clauses[] = "(title LIKE ? OR description LIKE ? OR content_markdown LIKE ?)";
    $search_param = "%" . $search . "%";
    $params[] = $search_param;
    $params[] = $search_param;
    $params[] = $search_param;
    $types .= "sss";
}

$where_sql = implode(" AND ", $where_clauses);

// Truy vấn danh sách workflows
$query = "
    SELECT w.*, 
           IF(b.id IS NOT NULL, 1, 0) as is_bookmarked,
           IF(l.id IS NOT NULL, 1, 0) as is_liked
    FROM dev_workflows w
    LEFT JOIN user_bookmarks b ON b.user_id = ? AND b.item_type = 'workflow' AND b.item_id = w.id
    LEFT JOIN user_likes l ON l.user_id = ? AND l.item_type = 'workflow' AND l.item_id = w.id
    WHERE $where_sql
    ORDER BY w.likes_count DESC, w.created_at DESC
";

$stmt = $conn->prepare($query);

if (!$stmt) {
    jsonResponse(false, 'Database preparation error: ' . $conn->error, null, 500);
}

// Bind tham số
$bind_params = array_merge([$user_id, $user_id], $params);
$bind_types = "ii" . $types;
$stmt->bind_param($bind_types, ...$bind_params);
$stmt->execute();
$result = $stmt->get_result();

$workflows = [];
while ($row = $result->fetch_assoc()) {
    $row['id'] = intval($row['id']);
    $row['likes_count'] = intval($row['likes_count']);
    $row['copy_count'] = isset($row['copy_count']) ? intval($row['copy_count']) : 0;
    $row['created_at'] = intval($row['created_at']);
    $row['updated_at'] = intval($row['updated_at']);
    $row['is_bookmarked'] = $row['is_bookmarked'] == 1;
    $row['is_liked'] = $row['is_liked'] == 1;
    
    $workflows[] = $row;
}
$stmt->close();

jsonResponse(true, 'Fetched dev workflows successfully', $workflows, 200);
?>
