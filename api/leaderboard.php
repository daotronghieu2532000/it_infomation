<?php
/**
 * CODE GO API - LEADERBOARD
 * API endpoint: /api/leaderboard.php
 * Method: POST
 * 
 * Mô tả: Lấy bảng xếp hạng (global hoặc theo country)
 * 
 * Headers:
 * - Authorization: Bearer {access_token} (từ get_token.php)
 * - Content-Type: application/json
 * 
 * Request Body (JSON):
 * {
 *   "type": "global",  // "global" hoặc "country"
 *   "country": "VN",  // optional, chỉ dùng khi type = "country"
 *   "limit": 100,  // optional, default: 100
 *   "offset": 0,  // optional, default: 0
 *   "user_id": 1  // optional, để lấy rank của user cụ thể
 * }
 * 
 * Response Success:
 * {
 *   "success": true,
 *   "message": "Leaderboard retrieved successfully",
 *   "data": {
 *     "type": "global",
 *     "total": 150,
 *     "user_rank": 5,  // nếu có user_id
 *     "entries": [
 *       {
 *         "rank": 1,
 *         "user_id": 10,
 *         "username": "top_user",
 *         "name": "Top User",
 *         "avatar": "https://...",
 *         "total_points": 5000,
 *         "current_streak": 30,
 *         "longest_streak": 50,
 *         "level": 10,
 *         "country": "VN"
 *       }
 *     ]
 *   }
 * }
 */

require_once __DIR__ . '/includes/config.php';
require_once __DIR__ . '/includes/helpers.php';

// Chỉ cho phép POST
requireMethod('POST');

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

// Lấy input từ request
$input = getJsonInput();

$type = $input['type'] ?? 'global';
$country = $input['country'] ?? null;
$limit = isset($input['limit']) ? intval($input['limit']) : 100;
$offset = isset($input['offset']) ? intval($input['offset']) : 0;
$user_id = isset($input['user_id']) ? intval($input['user_id']) : null;

// Validate
if (!in_array($type, ['global', 'country'])) {
    $type = 'global';
}

if ($limit < 1 || $limit > 500) {
    $limit = 100;
}

if ($offset < 0) {
    $offset = 0;
}

// Xây dựng query
$where_clause = "WHERE u.is_active = 1";
$params = [];
$param_types = "";

if ($type === 'country' && !empty($country)) {
    $country = sanitizeInput($country);
    $country = strlen($country) === 2 ? strtoupper($country) : 'VN';
    $where_clause .= " AND u.country = ?";
    $params[] = $country;
    $param_types .= "s";
}

// Query để lấy leaderboard
$query = "
    SELECT 
        u.user_id,
        u.username,
        u.name,
        u.email,
        u.avatar,
        u.total_points,
        u.current_streak,
        u.longest_streak,
        u.level,
        u.country,
        (
            SELECT COUNT(*) + 1
            FROM codego_users u2
            WHERE u2.total_points > u.total_points 
            AND u2.is_active = 1
            " . ($type === 'country' && !empty($country) ? "AND u2.country = ?" : "") . "
        ) as rank
    FROM codego_users u
    $where_clause
    ORDER BY u.total_points DESC, u.current_streak DESC, u.level DESC
    LIMIT ? OFFSET ?
";

$params[] = $limit;
$params[] = $offset;
$param_types .= "ii";

// Nếu có country filter, thêm vào subquery
if ($type === 'country' && !empty($country)) {
    // Thay thế ? trong subquery
    $query = str_replace(
        "AND u2.country = ?",
        "AND u2.country = '" . $conn->real_escape_string($country) . "'",
        $query
    );
}

$stmt = $conn->prepare($query);

if (!$stmt) {
    error_log("Prepare failed: " . $conn->error);
    jsonResponse(false, 'Database error', null, 500);
}

// Bind parameters
if (!empty($params)) {
    if ($type === 'country' && !empty($country)) {
        // Bỏ country param khỏi subquery, chỉ bind cho main query
        $stmt->bind_param("sii", $country, $limit, $offset);
    } else {
        $stmt->bind_param("ii", $limit, $offset);
    }
}

$stmt->execute();
$result = $stmt->get_result();

$entries = [];
$row_count = 0;
while ($row = $result->fetch_assoc()) {
    $entries[] = [
        'rank' => intval($row['rank']),
        'user_id' => intval($row['user_id']),
        'username' => $row['username'],
        'name' => $row['name'],
        'email' => $row['email'],
        'avatar' => $row['avatar'],
        'total_points' => intval($row['total_points']),
        'current_streak' => intval($row['current_streak']),
        'longest_streak' => intval($row['longest_streak']),
        'level' => intval($row['level']),
        'country' => $row['country']
    ];
    $row_count++;
}

$stmt->close();

// Log để debug
error_log("Leaderboard API - Type: $type, Country: " . ($country ?? 'null') . ", Total entries: $row_count");

// Đếm tổng số users
$count_query = "SELECT COUNT(*) as total FROM codego_users u $where_clause";
$count_stmt = $conn->prepare($count_query);

if ($count_stmt) {
    if ($type === 'country' && !empty($country)) {
        $count_stmt->bind_param("s", $country);
    }
    $count_stmt->execute();
    $count_result = $count_stmt->get_result();
    $total_row = $count_result->fetch_assoc();
    $total = intval($total_row['total']);
    $count_stmt->close();
} else {
    $total = count($entries);
}

// Lấy rank của user cụ thể nếu có
$user_rank = null;
if ($user_id) {
    $rank_query = "
        SELECT COUNT(*) + 1 as rank
        FROM codego_users u2
        WHERE u2.total_points > (
            SELECT total_points FROM codego_users WHERE user_id = ? AND is_active = 1
        )
        AND u2.is_active = 1
        " . ($type === 'country' && !empty($country) ? "AND u2.country = ?" : "") . "
    ";
    
    $rank_stmt = $conn->prepare($rank_query);
    if ($rank_stmt) {
        if ($type === 'country' && !empty($country)) {
            $rank_stmt->bind_param("is", $user_id, $country);
        } else {
            $rank_stmt->bind_param("i", $user_id);
        }
        $rank_stmt->execute();
        $rank_result = $rank_stmt->get_result();
        if ($rank_result->num_rows > 0) {
            $rank_row = $rank_result->fetch_assoc();
            $user_rank = intval($rank_row['rank']);
        }
        $rank_stmt->close();
    }
}

// Trả về kết quả
$response_data = [
    'type' => $type,
    'total' => $total,
    'entries' => $entries
];

if ($user_rank !== null) {
    $response_data['user_rank'] = $user_rank;
}

if ($type === 'country' && !empty($country)) {
    $response_data['country'] = $country;
}

// Log response để debug
error_log("Leaderboard API Response - Total: $total, Entries count: " . count($entries));
if (count($entries) > 0) {
    error_log("Leaderboard API - First entry: " . json_encode($entries[0]));
}

jsonResponse(true, 'Leaderboard retrieved successfully', $response_data, 200);

?>
