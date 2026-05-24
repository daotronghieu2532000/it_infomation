<?php
/**
 * CODE GO API - DELETE USER ACCOUNT
 * API endpoint: /api/delete_account.php
 * Method: POST
 * 
 * Mô tả: Người dùng yêu cầu xóa tài khoản vĩnh viễn (soft delete bằng cách đặt is_active = 0).
 * 
 * Headers:
 * - Authorization: Bearer {user_token}
 * - Content-Type: application/json
 */

error_reporting(E_ALL);
ini_set('display_errors', 0);
ini_set('log_errors', 1);

if (ob_get_level() == 0) {
    ob_start();
}

try {
    require_once __DIR__ . '/includes/config.php';
    require_once __DIR__ . '/includes/helpers.php';
    
    if (!isset($conn) || $conn === null) {
        if (ob_get_level() > 0) {
            ob_end_clean();
        }
        jsonResponse(false, 'Database connection not initialized', null, 500);
    }
    
    if ($conn->connect_error) {
        if (ob_get_level() > 0) {
            ob_end_clean();
        }
        jsonResponse(false, 'Database connection error', null, 500);
    }
} catch (Exception $e) {
    if (ob_get_level() > 0) {
        ob_end_clean();
    }
    jsonResponse(false, 'Initialization error', ['error' => $e->getMessage()], 500);
}

// Chỉ cho phép POST
try {
    requireMethod('POST');
} catch (Exception $e) {
    if (ob_get_level() > 0) {
        ob_end_clean();
    }
    jsonResponse(false, 'Method error: ' . $e->getMessage(), null, 405);
}

// Kiểm tra Authorization header (Token của User)
$headers = getallheaders();
$auth_header = $headers['Authorization'] ?? $headers['authorization'] ?? '';

if (empty($auth_header) || !preg_match('/Bearer\s+(.*)$/i', $auth_header, $matches)) {
    if (ob_get_level() > 0) {
        ob_end_clean();
    }
    jsonResponse(false, 'Authorization token required', null, 401);
}

$token = $matches[1];
$token_data = verifyJWT($token, 'codego_secret_key_2025');

if (!$token_data) {
    if (ob_get_level() > 0) {
        ob_end_clean();
    }
    jsonResponse(false, 'Invalid or expired token', null, 401);
}

$user_id = intval($token_data['user_id']);

if ($user_id <= 0) {
    if (ob_get_level() > 0) {
        ob_end_clean();
    }
    jsonResponse(false, 'Invalid user ID in token', null, 400);
}

// Cập nhật trạng thái người dùng thành is_active = 0
try {
    $now = time();
    $stmt = $conn->prepare("UPDATE codego_users SET is_active = 0, updated_at = ? WHERE user_id = ? AND is_active = 1");
    
    if (!$stmt) {
        error_log("Prepare failed for delete account: " . $conn->error);
        if (ob_get_level() > 0) {
            ob_end_clean();
        }
        jsonResponse(false, 'Database prepare error', null, 500);
    }
    
    $stmt->bind_param("ii", $now, $user_id);
    
    if (!$stmt->execute()) {
        error_log("Execute failed for delete account: " . $stmt->error);
        $stmt->close();
        if (ob_get_level() > 0) {
            ob_end_clean();
        }
        jsonResponse(false, 'Database execute error', null, 500);
    }
    
    $affected_rows = $stmt->affected_rows;
    $stmt->close();
    
    if (ob_get_level() > 0) {
        ob_end_clean();
    }
    
    if ($affected_rows > 0) {
        jsonResponse(true, 'Tài khoản của bạn đã được xóa vĩnh viễn trên máy chủ.', null, 200);
    } else {
        jsonResponse(false, 'Tài khoản không tồn tại hoặc đã bị xóa trước đó.', null, 404);
    }
} catch (Exception $e) {
    if (ob_get_level() > 0) {
        ob_end_clean();
    }
    error_log("Exception in delete account: " . $e->getMessage());
    jsonResponse(false, 'System error processing request', null, 500);
}
?>
