<?php
/**
 * CODE GO TECHFLOW API - INTERACT (LIKE, BOOKMARK, COPY COUNT)
 * API endpoint: /api/interact.php
 * Method: POST
 * 
 * Headers:
 * - Authorization: Bearer {access_token} (từ get_token.php)
 * - User-Token: {user_token} (Bắt buộc - xác định user thực hiện hành động)
 * - Content-Type: application/json
 * 
 * Request Body (JSON):
 * {
 *   "action": "bookmark", -- 'bookmark', 'like', 'copy'
 *   "item_type": "prompt", -- 'article', 'repo', 'ai_package', 'workflow', 'prompt'
 *   "item_id": 8,
 *   "state": true -- true: Thích/Bookmark, false: Hủy thích/Bỏ bookmark (chỉ dùng cho 'bookmark', 'like')
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

// Kiểm tra User-Token (Bắt buộc)
$user_token = $headers['User-Token'] ?? $headers['user-token'] ?? '';
if (empty($user_token)) {
    jsonResponse(false, 'User token required for interaction', null, 401);
}

$user_data = verifyJWT($user_token, 'codego_secret_key_2025');
if (!$user_data) {
    jsonResponse(false, 'Invalid or expired user token', null, 401);
}

$user_id = intval($user_data['user_id']);

// Lấy input từ request body
$input = getJsonInput();

$action = isset($input['action']) ? sanitizeInput($input['action']) : '';
$item_type = isset($input['item_type']) ? sanitizeInput($input['item_type']) : '';
$item_id = isset($input['item_id']) ? intval($input['item_id']) : 0;
$state = isset($input['state']) ? (bool)$input['state'] : false;

// Validate input
if (empty($action) || empty($item_type) || $item_id <= 0) {
    jsonResponse(false, 'Missing required fields', null, 400);
}

if (!in_array($action, ['bookmark', 'like', 'copy'])) {
    jsonResponse(false, 'Invalid action', null, 400);
}

if (!in_array($item_type, ['article', 'repo', 'ai_package', 'workflow', 'prompt'])) {
    jsonResponse(false, 'Invalid item type', null, 400);
}

$created_at = time();

// ============================================
// XỬ LÝ HÀNH ĐỘNG 'COPY' (Tăng lượt copy prompt/workflow)
// ============================================
if ($action === 'copy') {
    $table = "";
    if ($item_type === 'prompt') {
        $table = 'curated_prompts';
    } elseif ($item_type === 'workflow') {
        $table = 'dev_workflows';
    } else {
        jsonResponse(false, 'Copy action only supported for prompts and workflows', null, 400);
    }
    
    $stmt = $conn->prepare("UPDATE $table SET copy_count = copy_count + 1 WHERE id = ?");
    $stmt->bind_param("i", $item_id);
    $stmt->execute();
    $stmt->close();
    
    jsonResponse(true, 'Copy count updated successfully', [
        'item_type' => $item_type,
        'item_id' => $item_id
    ], 200);
}

// ============================================
// XỬ LÝ HÀNH ĐỘNG 'BOOKMARK' (Lưu đọc sau)
// ============================================
if ($action === 'bookmark') {
    if ($state) {
        // Thêm bookmark (INSERT IGNORE)
        $stmt = $conn->prepare("
            INSERT IGNORE INTO user_bookmarks (user_id, item_type, item_id, created_at)
            VALUES (?, ?, ?, ?)
        ");
        $stmt->bind_param("isii", $user_id, $item_type, $item_id, $created_at);
        $stmt->execute();
        $stmt->close();
        
        jsonResponse(true, 'Bookmarked successfully', [
            'item_type' => $item_type,
            'item_id' => $item_id,
            'is_bookmarked' => true
        ], 200);
    } else {
        // Hủy bookmark (DELETE)
        $stmt = $conn->prepare("
            DELETE FROM user_bookmarks 
            WHERE user_id = ? AND item_type = ? AND item_id = ?
        ");
        $stmt->bind_param("isi", $user_id, $item_type, $item_id);
        $stmt->execute();
        $stmt->close();
        
        jsonResponse(true, 'Unbookmarked successfully', [
            'item_type' => $item_type,
            'item_id' => $item_id,
            'is_bookmarked' => false
        ], 200);
    }
}

// ============================================
// XỬ LÝ HÀNH ĐỘNG 'LIKE' (Thả tim)
// ============================================
if ($action === 'like') {
    // Xác định bảng tương ứng để cập nhật tổng số like
    $table = "";
    if ($item_type === 'article') {
        $table = 'tech_articles';
    } elseif ($item_type === 'prompt') {
        $table = 'curated_prompts';
    } elseif ($item_type === 'workflow') {
        $table = 'dev_workflows';
    } else {
        jsonResponse(false, 'Like action not supported for this item type', null, 400);
    }
    
    if ($state) {
        // Thêm like vào bảng user_likes
        $stmt = $conn->prepare("
            INSERT IGNORE INTO user_likes (user_id, item_type, item_id, created_at)
            VALUES (?, ?, ?, ?)
        ");
        $stmt->bind_param("isii", $user_id, $item_type, $item_id, $created_at);
        $stmt->execute();
        $affected = $stmt->affected_rows;
        $stmt->close();
        
        // Nếu thêm thành công thì tăng likes_count trong bảng đích
        if ($affected > 0 && !empty($table)) {
            $stmt_update = $conn->prepare("UPDATE $table SET likes_count = likes_count + 1 WHERE id = ?");
            $stmt_update->bind_param("i", $item_id);
            $stmt_update->execute();
            $stmt_update->close();
        }
        
        jsonResponse(true, 'Liked successfully', [
            'item_type' => $item_type,
            'item_id' => $item_id,
            'is_liked' => true
        ], 200);
    } else {
        // Xóa like khỏi bảng user_likes
        $stmt = $conn->prepare("
            DELETE FROM user_likes 
            WHERE user_id = ? AND item_type = ? AND item_id = ?
        ");
        $stmt->bind_param("isi", $user_id, $item_type, $item_id);
        $stmt->execute();
        $affected = $stmt->affected_rows;
        $stmt->close();
        
        // Nếu xóa thành công thì giảm likes_count trong bảng đích
        if ($affected > 0 && !empty($table)) {
            $stmt_update = $conn->prepare("UPDATE $table SET likes_count = GREATEST(0, likes_count - 1) WHERE id = ?");
            $stmt_update->bind_param("i", $item_id);
            $stmt_update->execute();
            $stmt_update->close();
        }
        
        jsonResponse(true, 'Unliked successfully', [
            'item_type' => $item_type,
            'item_id' => $item_id,
            'is_liked' => false
        ], 200);
    }
}
?>
