<?php
/**
 * CODE GO API - ACHIEVEMENTS
 * API endpoint: /api/achievements.php
 * Method: POST
 * 
 * Mô tả: Quản lý thành tích của user (lấy danh sách, mở khóa)
 * 
 * Headers:
 * - Authorization: Bearer {access_token} (từ get_token.php)
 * - Content-Type: application/json
 * 
 * Request Body (JSON):
 * {
 *   "action": "get",  // "get" hoặc "unlock"
 *   "user_id": 1
 * }
 * 
 * Hoặc để unlock:
 * {
 *   "action": "unlock",
 *   "user_id": 1,
 *   "achievement_id": "first_lesson",
 *   "achievement_name": "Bài học đầu tiên",
 *   "achievement_description": "Hoàn thành bài học đầu tiên",
 *   "points": 10
 * }
 * 
 * Response Success (get):
 * {
 *   "success": true,
 *   "message": "Achievements retrieved successfully",
 *   "data": [
 *     {
 *       "id": 1,
 *       "user_id": 1,
 *       "achievement_id": "first_lesson",
 *       "achievement_name": "Bài học đầu tiên",
 *       "achievement_description": "Hoàn thành bài học đầu tiên",
 *       "points": 10,
 *       "unlocked_at": 1705123456
 *     }
 *   ]
 * }
 * 
 * Response Success (unlock):
 * {
 *   "success": true,
 *   "message": "Achievement unlocked successfully",
 *   "data": {
 *     "id": 1,
 *     "user_id": 1,
 *     "achievement_id": "first_lesson",
 *     "achievement_name": "Bài học đầu tiên",
 *     "points": 10,
 *     "unlocked_at": 1705123456
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

// Validate action
$action = $input['action'] ?? '';
$user_id = isset($input['user_id']) ? intval($input['user_id']) : 0;

if (empty($action) || !in_array($action, ['get', 'unlock'])) {
    jsonResponse(false, 'Invalid action. Use "get" or "unlock"', null, 400);
}

if ($user_id <= 0) {
    jsonResponse(false, 'User ID is required', null, 400);
}

// Kiểm tra user có tồn tại không
$stmt = $conn->prepare("SELECT user_id FROM codego_users WHERE user_id = ? AND is_active = 1 LIMIT 1");
if (!$stmt) {
    error_log("Prepare failed: " . $conn->error);
    jsonResponse(false, 'Database error', null, 500);
}

$stmt->bind_param("i", $user_id);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    $stmt->close();
    jsonResponse(false, 'User not found', null, 404);
}
$stmt->close();

// Xử lý action
if ($action === 'get') {
    // Lấy danh sách achievements của user
    $stmt = $conn->prepare("
        SELECT id, user_id, achievement_id, achievement_name, achievement_description, 
               points, unlocked_at
        FROM codego_achievements 
        WHERE user_id = ?
        ORDER BY unlocked_at DESC
    ");
    
    if (!$stmt) {
        error_log("Prepare failed: " . $conn->error);
        jsonResponse(false, 'Database error', null, 500);
    }
    
    $stmt->bind_param("i", $user_id);
    $stmt->execute();
    $result = $stmt->get_result();
    
    $achievements = [];
    while ($row = $result->fetch_assoc()) {
        $achievements[] = $row;
    }
    
    $stmt->close();
    
    jsonResponse(true, 'Achievements retrieved successfully', $achievements, 200);
    
} elseif ($action === 'unlock') {
    // Mở khóa achievement mới
    $achievement_id = $input['achievement_id'] ?? '';
    $achievement_name = $input['achievement_name'] ?? '';
    $achievement_description = $input['achievement_description'] ?? null;
    $points = isset($input['points']) ? intval($input['points']) : 0;
    
    if (empty($achievement_id) || empty($achievement_name)) {
        jsonResponse(false, 'Achievement ID and name are required', null, 400);
    }
    
    // Sanitize
    $achievement_id = sanitizeInput($achievement_id);
    $achievement_name = sanitizeInput($achievement_name);
    $achievement_description = $achievement_description ? sanitizeInput($achievement_description) : null;
    
    // Kiểm tra achievement đã tồn tại chưa
    $stmt = $conn->prepare("
        SELECT id FROM codego_achievements 
        WHERE user_id = ? AND achievement_id = ?
        LIMIT 1
    ");
    
    if (!$stmt) {
        error_log("Prepare failed: " . $conn->error);
        jsonResponse(false, 'Database error', null, 500);
    }
    
    $stmt->bind_param("is", $user_id, $achievement_id);
    $stmt->execute();
    $result = $stmt->get_result();
    
    $unlocked_at = time();
    
    if ($result->num_rows > 0) {
        // Achievement đã tồn tại, trả về thông tin hiện tại
        $stmt->close();
        $stmt = $conn->prepare("
            SELECT id, user_id, achievement_id, achievement_name, achievement_description, 
                   points, unlocked_at
            FROM codego_achievements 
            WHERE user_id = ? AND achievement_id = ?
            LIMIT 1
        ");
        $stmt->bind_param("is", $user_id, $achievement_id);
        $stmt->execute();
        $result = $stmt->get_result();
        $achievement = $result->fetch_assoc();
        $stmt->close();
        
        jsonResponse(true, 'Achievement already unlocked', $achievement, 200);
    } else {
        // Tạo achievement mới
        $stmt->close();
        $stmt = $conn->prepare("
            INSERT INTO codego_achievements 
            (user_id, achievement_id, achievement_name, achievement_description, points, unlocked_at)
            VALUES (?, ?, ?, ?, ?, ?)
        ");
        
        if (!$stmt) {
            error_log("Prepare failed: " . $conn->error);
            jsonResponse(false, 'Database error', null, 500);
        }
        
        $stmt->bind_param("isssii", $user_id, $achievement_id, $achievement_name, $achievement_description, $points, $unlocked_at);
        
        if (!$stmt->execute()) {
            error_log("Execute failed: " . $stmt->error);
            $stmt->close();
            jsonResponse(false, 'Failed to unlock achievement', null, 500);
        }
        
        $achievement_id_db = $conn->insert_id;
        $stmt->close();
        
        // Cập nhật total_points của user nếu có points
        if ($points > 0) {
            $stmt = $conn->prepare("
                UPDATE codego_users 
                SET total_points = total_points + ?, updated_at = ?
                WHERE user_id = ?
            ");
            if ($stmt) {
                $updated_at = time();
                $stmt->bind_param("iii", $points, $updated_at, $user_id);
                $stmt->execute();
                $stmt->close();
            }
        }
        
        // Lấy achievement vừa tạo
        $stmt = $conn->prepare("
            SELECT id, user_id, achievement_id, achievement_name, achievement_description, 
                   points, unlocked_at
            FROM codego_achievements 
            WHERE id = ?
            LIMIT 1
        ");
        $stmt->bind_param("i", $achievement_id_db);
        $stmt->execute();
        $result = $stmt->get_result();
        $achievement = $result->fetch_assoc();
        $stmt->close();
        
        jsonResponse(true, 'Achievement unlocked successfully', $achievement, 201);
    }
}

?>
