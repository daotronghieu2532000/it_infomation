<?php
/**
 * CODE GO API - PROGRESS MANAGEMENT
 * API endpoint: /api/codego_progress.php
 * Method: POST
 * 
 * Mô tả: Quản lý progress của user (lưu và lấy progress)
 * 
 * Headers:
 * - Authorization: Bearer {access_token} (từ get_token.php)
 * - Content-Type: application/json
 * 
 * Request Body (JSON):
 * 
 * Để lưu progress:
 * {
 *   "action": "complete",  // "complete" hoặc "get"
 *   "user_id": 1,
 *   "content_type": "lesson",  // "lesson" hoặc "exercise"
 *   "content_id": "python_lesson_01",
 *   "language": "python",
 *   "is_completed": 1,  // 1: đã hoàn thành, 0: chưa
 *   "points_earned": 10
 * }
 * 
 * Để lấy progress:
 * {
 *   "action": "get",
 *   "user_id": 1,
 *   "language": "python"  // optional, lọc theo ngôn ngữ
 * }
 * 
 * Response Success (complete):
 * {
 *   "success": true,
 *   "message": "Progress saved successfully",
 *   "data": {
 *     "id": 123,
 *     "user_id": 1,
 *     "content_type": "lesson",
 *     "content_id": "python_lesson_01",
 *     "language": "python",
 *     "is_completed": 1,
 *     "points_earned": 10,
 *     "completed_at": 1705123456
 *   }
 * }
 * 
 * Response Success (get):
 * {
 *   "success": true,
 *   "message": "Progress retrieved successfully",
 *   "data": [
 *     {
 *       "id": 123,
 *       "user_id": 1,
 *       "content_type": "lesson",
 *       "content_id": "python_lesson_01",
 *       "language": "python",
 *       "is_completed": 1,
 *       "points_earned": 10,
 *       "completed_at": 1705123456
 *     }
 *   ]
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

    // Validate action
    $action = isset($input['action']) ? trim($input['action']) : '';
    $user_id = isset($input['user_id']) ? intval($input['user_id']) : 0;

    if (empty($action) || !in_array($action, ['complete', 'get'])) {
        jsonResponse(false, 'Invalid action. Use "complete" or "get"', null, 400);
        exit;
    }

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

    if ($action === 'complete') {
        // Lưu progress
        $content_type = isset($input['content_type']) ? trim($input['content_type']) : '';
        $content_id = isset($input['content_id']) ? trim($input['content_id']) : '';
        $language = isset($input['language']) ? trim($input['language']) : '';
        $is_completed = isset($input['is_completed']) ? intval($input['is_completed']) : 0;
        $points_earned = isset($input['points_earned']) ? intval($input['points_earned']) : 0;

        if (empty($content_type) || !in_array($content_type, ['lesson', 'exercise'])) {
            jsonResponse(false, 'content_type must be "lesson" or "exercise"', null, 400);
            exit;
        }

        if (empty($content_id)) {
            jsonResponse(false, 'content_id is required', null, 400);
            exit;
        }

        if (empty($language)) {
            jsonResponse(false, 'language is required', null, 400);
            exit;
        }

        $now = time();
        $completed_at = $is_completed ? $now : null;

        // Insert hoặc update progress
        $stmt = $conn->prepare("
            INSERT INTO codego_progress 
            (user_id, content_type, content_id, language, is_completed, points_earned, completed_at, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            ON DUPLICATE KEY UPDATE
                is_completed = VALUES(is_completed),
                points_earned = VALUES(points_earned),
                completed_at = VALUES(completed_at),
                updated_at = VALUES(updated_at)
        ");
        
        if (!$stmt) {
            throw new Exception("Prepare failed: " . $conn->error);
        }

        $stmt->bind_param("isssiiiii", $user_id, $content_type, $content_id, $language, $is_completed, $points_earned, $completed_at, $now, $now);
        
        if (!$stmt->execute()) {
            $error = $stmt->error;
            $stmt->close();
            throw new Exception("Execute failed: " . $error);
        }

        $progress_id = $conn->insert_id;
        $stmt->close();

        // Nếu đã hoàn thành và có điểm, cập nhật total_points trong codego_users
        if ($is_completed && $points_earned > 0) {
            $stmt = $conn->prepare("
                UPDATE codego_users 
                SET total_points = total_points + ?,
                    updated_at = ?
                WHERE user_id = ?
            ");
            if ($stmt) {
                $stmt->bind_param("iii", $points_earned, $now, $user_id);
                $stmt->execute();
                $stmt->close();
            }
        }

        // Lấy lại progress vừa lưu
        $stmt = $conn->prepare("
            SELECT id, user_id, content_type, content_id, language, 
                   is_completed, points_earned, completed_at, created_at, updated_at
            FROM codego_progress
            WHERE id = ?
        ");
        $stmt->bind_param("i", $progress_id);
        $stmt->execute();
        $result = $stmt->get_result();
        $progress_data = $result->fetch_assoc();
        $stmt->close();

        // Đảm bảo các field numeric là int
        if ($progress_data) {
            $progress_data['id'] = intval($progress_data['id']);
            $progress_data['user_id'] = intval($progress_data['user_id']);
            $progress_data['is_completed'] = intval($progress_data['is_completed']);
            $progress_data['points_earned'] = intval($progress_data['points_earned']);
            $progress_data['completed_at'] = $progress_data['completed_at'] ? intval($progress_data['completed_at']) : null;
            $progress_data['created_at'] = intval($progress_data['created_at']);
            $progress_data['updated_at'] = $progress_data['updated_at'] ? intval($progress_data['updated_at']) : null;
        }

        ob_end_clean();
        jsonResponse(true, 'Progress saved successfully', $progress_data);

    } else {
        // Lấy progress
        $language = isset($input['language']) ? trim($input['language']) : null;

        $sql = "
            SELECT id, user_id, content_type, content_id, language, 
                   is_completed, points_earned, completed_at, created_at, updated_at
            FROM codego_progress
            WHERE user_id = ?
        ";
        
        $params = [];
        $param_types = "i";
        $params[] = $user_id;

        if ($language !== null && !empty($language)) {
            $sql .= " AND language = ?";
            $params[] = $language;
            $param_types .= "s";
        }

        $sql .= " ORDER BY completed_at DESC, created_at DESC";

        $stmt = $conn->prepare($sql);
        if (!$stmt) {
            throw new Exception("Prepare failed: " . $conn->error);
        }

        $stmt->bind_param($param_types, ...$params);
        $stmt->execute();
        $result = $stmt->get_result();

        $progress_list = [];
        while ($row = $result->fetch_assoc()) {
            $progress_list[] = [
                'id' => intval($row['id']),
                'user_id' => intval($row['user_id']),
                'content_type' => $row['content_type'],
                'content_id' => $row['content_id'],
                'language' => $row['language'],
                'is_completed' => intval($row['is_completed']),
                'points_earned' => intval($row['points_earned']),
                'completed_at' => $row['completed_at'] ? intval($row['completed_at']) : null,
                'created_at' => intval($row['created_at']),
                'updated_at' => $row['updated_at'] ? intval($row['updated_at']) : null,
            ];
        }
        $stmt->close();

        ob_end_clean();
        jsonResponse(true, 'Progress retrieved successfully', $progress_list);
    }

} catch (Exception $e) {
    ob_end_clean();
    error_log("Progress API error: " . $e->getMessage());
    jsonResponse(false, 'Server error: ' . $e->getMessage(), null, 500);
}
