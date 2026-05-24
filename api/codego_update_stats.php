<?php
/**
 * CODE GO API - UPDATE USER STATS
 * API endpoint: /api/codego_update_stats.php
 * Method: POST
 * 
 * Mô tả: Cập nhật thống kê của user (streak, level, points)
 * 
 * Headers:
 * - Authorization: Bearer {access_token} (từ get_token.php)
 * - Content-Type: application/json
 * 
 * Request Body (JSON):
 * {
 *   "user_id": 1,
 *   "current_streak": 5,  // optional
 *   "longest_streak": 10,  // optional
 *   "level": 3  // optional
 * }
 * 
 * Response Success:
 * {
 *   "success": true,
 *   "message": "Stats updated successfully",
 *   "data": {
 *     "user_id": 1,
 *     "total_points": 150,
 *     "current_streak": 5,
 *     "longest_streak": 10,
 *     "level": 3
 *   }
 * }
 */

require_once __DIR__ . '/includes/config.php';
require_once __DIR__ . '/includes/helpers.php';

// Enable output buffering
ob_start();

header('Content-Type: application/json; charset=utf-8');

try {
    // Kiểm tra method
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        jsonResponse(false, 'Method not allowed', null, 405);
        exit;
    }

    // Đọc JSON input
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!$input) {
        jsonResponse(false, 'Invalid JSON input', null, 400);
        exit;
    }

    // Validate required fields
    $user_id = isset($input['user_id']) ? intval($input['user_id']) : 0;
    $current_streak = isset($input['current_streak']) ? intval($input['current_streak']) : null;
    $longest_streak = isset($input['longest_streak']) ? intval($input['longest_streak']) : null;
    $level = isset($input['level']) ? intval($input['level']) : null;

    if ($user_id <= 0) {
        jsonResponse(false, 'user_id is required and must be positive', null, 400);
        exit;
    }

    // Kiểm tra user tồn tại
    $stmt = $conn->prepare("SELECT user_id FROM codego_users WHERE user_id = ? AND is_active = 1 LIMIT 1");
    if (!$stmt) {
        throw new Exception("Prepare failed: " . $conn->error);
    }
    $stmt->bind_param("i", $user_id);
    $stmt->execute();
    $result = $stmt->get_result();
    if ($result->num_rows === 0) {
        $stmt->close();
        jsonResponse(false, 'User not found', null, 404);
        exit;
    }
    $stmt->close();

    // Build UPDATE query động dựa trên fields được cung cấp
    $update_fields = [];
    $update_values = [];
    $param_types = "";

    if ($current_streak !== null) {
        $update_fields[] = "current_streak = ?";
        $update_values[] = $current_streak;
        $param_types .= "i";
    }

    if ($longest_streak !== null) {
        $update_fields[] = "longest_streak = ?";
        $update_values[] = $longest_streak;
        $param_types .= "i";
    }

    if ($level !== null) {
        $update_fields[] = "level = ?";
        $update_values[] = $level;
        $param_types .= "i";
    }

    if (empty($update_fields)) {
        jsonResponse(false, 'At least one field (current_streak, longest_streak, or level) must be provided', null, 400);
        exit;
    }

    $update_fields[] = "updated_at = ?";
    $update_values[] = time();
    $param_types .= "i";

    $update_values[] = $user_id;
    $param_types .= "i";

    $sql = "UPDATE codego_users SET " . implode(", ", $update_fields) . " WHERE user_id = ?";
    
    $stmt = $conn->prepare($sql);
    if (!$stmt) {
        throw new Exception("Prepare failed: " . $conn->error);
    }

    $stmt->bind_param($param_types, ...$update_values);
    
    if (!$stmt->execute()) {
        $error = $stmt->error;
        $stmt->close();
        throw new Exception("Execute failed: " . $error);
    }
    $stmt->close();

    // Lấy lại user data đã cập nhật
    $stmt = $conn->prepare("
        SELECT user_id, total_points, current_streak, longest_streak, level
        FROM codego_users
        WHERE user_id = ?
    ");
    $stmt->bind_param("i", $user_id);
    $stmt->execute();
    $result = $stmt->get_result();
    $user_data = $result->fetch_assoc();
    $stmt->close();

    // Đảm bảo các field numeric là int
    if ($user_data) {
        $user_data['user_id'] = intval($user_data['user_id']);
        $user_data['total_points'] = intval($user_data['total_points']);
        $user_data['current_streak'] = intval($user_data['current_streak']);
        $user_data['longest_streak'] = intval($user_data['longest_streak']);
        $user_data['level'] = intval($user_data['level']);
    }

    ob_end_clean();
    jsonResponse(true, 'Stats updated successfully', $user_data);

} catch (Exception $e) {
    ob_end_clean();
    error_log("Update stats error: " . $e->getMessage());
    jsonResponse(false, 'Server error: ' . $e->getMessage(), null, 500);
}
