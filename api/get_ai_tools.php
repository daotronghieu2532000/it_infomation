<?php
/**
 * CODE GO TECHFLOW API - GET AI TOOLS
 * API endpoint: /api/get_ai_tools.php
 * Method: GET
 * 
 * Headers:
 * - Authorization: Bearer {access_token} (từ get_token.php)
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

// Lấy danh sách công cụ AI
$query = "SELECT * FROM ai_tools ORDER BY is_free_prioritized DESC, efficiency_score DESC, id ASC";
$result = $conn->query($query);

$ai_tools = [];
if ($result) {
    while ($row = $result->fetch_assoc()) {
        $row['id'] = intval($row['id']);
        $row['efficiency_score'] = floatval($row['efficiency_score']);
        $row['is_free_prioritized'] = intval($row['is_free_prioritized']) == 1;
        $row['created_at'] = intval($row['created_at']);
        $ai_tools[] = $row;
    }
}

jsonResponse(true, 'Fetched AI tools successfully', $ai_tools, 200);
?>
