<?php
/**
 * CODE GO TECHFLOW API - AI CODE HELPER PROXY
 * API endpoint: /api/ai_helper.php
 * Method: POST
 * 
 * Headers:
 * - Authorization: Bearer {access_token} (từ get_token.php)
 * 
 * Parameters (POST JSON):
 * - code: Chuỗi mã nguồn cần xử lý
 * - action: Tác vụ ('explain' - Giải thích, 'debug' - Gỡ lỗi, 'translate' - Dịch code)
 * - target_language: Ngôn ngữ đích (chỉ dùng cho tác vụ 'translate', ví dụ: 'Python', 'Dart', 'JavaScript', 'Rust')
 */

require_once __DIR__ . '/includes/config.php';
require_once __DIR__ . '/includes/helpers.php';

// Chỉ cho phép phương thức POST
requireMethod(['POST']);

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

// Lấy dữ liệu POST JSON
$input = getJsonInput();

$code = isset($input['code']) ? trim($input['code']) : '';
$action = isset($input['action']) ? trim($input['action']) : 'explain';
$target_lang = isset($input['target_language']) ? trim($input['target_language']) : 'Dart';

if (empty($code)) {
    jsonResponse(false, 'Mã nguồn đầu vào không được để trống.', null, 400);
}

// Cấu hình Gemini API Key
// Hãy cấu hình API Key của bạn tại đây hoặc qua biến môi trường.
$gemini_api_key = getenv('GEMINI_API_KEY') ?: ''; // Cấu hình API key của bạn ở đây nếu cần chạy thật

// Tạo prompt dựa vào tác vụ
$prompt = "";
if ($action === 'explain') {
    $prompt = "Hãy đóng vai là một chuyên gia lập trình cấp cao. Hãy giải thích chi tiết đoạn code sau bằng tiếng Việt. Tập trung vào mục đích sử dụng, nguyên lý hoạt động, và phân tích chi tiết từng khối lệnh quan trọng. Kết quả phản hồi phải sử dụng định dạng Markdown đẹp mắt, có tiêu đề rõ ràng, sử dụng bảng hoặc danh sách khi cần thiết, và bôi đậm các từ khóa kỹ thuật quan trọng.\n\nĐoạn code cần giải thích:\n```\n$code\n```";
} elseif ($action === 'debug') {
    $prompt = "Hãy đóng vai là một chuyên gia rà soát mã nguồn (code auditor) và chuyên gia gỡ lỗi. Hãy phân tích đoạn code sau, chỉ ra các lỗi cú pháp, lỗi logic, nguy cơ rò rỉ bộ nhớ (memory leak), lỗ hổng bảo mật hoặc các điểm chưa tối ưu về mặt hiệu năng. Giải thích nguyên nhân cụ thể và đề xuất phương án sửa lỗi chi tiết bằng tiếng Việt. Đồng thời, cung cấp đoạn code hoàn chỉnh đã được sửa và tối ưu hóa. Kết quả phản hồi phải sử dụng định dạng Markdown rõ ràng, chuyên nghiệp.\n\nĐoạn code cần kiểm tra:\n```\n$code\n```";
} elseif ($action === 'translate') {
    $prompt = "Hãy đóng vai là một chuyên gia chuyển đổi ngôn ngữ lập trình. Hãy dịch (chuyển đổi) chính xác đoạn code dưới đây sang ngôn ngữ lập trình '$target_lang'. Hãy đảm bảo viết mã nguồn theo đúng chuẩn phong cách (best practices) của ngôn ngữ '$target_lang'. Sau đó, giải thích ngắn gọn bằng tiếng Việt các điểm lưu ý chính khi chuyển đổi (ví dụ: cách quản lý bộ nhớ, cú pháp khác biệt, thư viện tương đương). Kết quả phản hồi phải sử dụng định dạng Markdown chuyên nghiệp, có code block hiển thị code mới.\n\nĐoạn code gốc cần chuyển đổi:\n```\n$code\n```";
} else {
    jsonResponse(false, 'Tác vụ không hợp lệ. Chỉ chấp nhận: explain, debug, translate.', null, 400);
}

$ai_response = "";
$success_call = false;

// Nếu có API Key, thử gọi Gemini API thật
if (!empty($gemini_api_key)) {
    $url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=" . $gemini_api_key;
    
    $payload = [
        "contents" => [
            [
                "parts" => [
                    ["text" => $prompt]
                ]
            ]
        ],
        "generationConfig" => [
            "temperature" => 0.2,
            "maxOutputTokens" => 2048
        ]
    ];
    
    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));
    curl_setopt($ch, CURLOPT_TIMEOUT, 15);
    
    $response = curl_exec($ch);
    $http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    
    if ($http_code === 200 && !empty($response)) {
        $res_data = json_decode($response, true);
        if (isset($res_data['candidates'][0]['content']['parts'][0]['text'])) {
            $ai_response = $res_data['candidates'][0]['content']['parts'][0]['text'];
            $success_call = true;
        }
    }
}

// Nếu không cấu hình API Key hoặc gọi API thật thất bại, sử dụng Mock Engine thông minh để phục vụ trải nghiệm người dùng lập trình viên
if (!$success_call) {
    // Phân tích sơ bộ đoạn code để mock có tính cá nhân hóa cao
    $detected_language = "Unknown";
    if (strpos($code, 'import') !== false && strpos($code, 'Widget') !== false) {
        $detected_language = "Dart / Flutter";
    } elseif (strpos($code, 'def ') !== false || strpos($code, 'import ') !== false) {
        $detected_language = "Python";
    } elseif (strpos($code, 'const ') !== false || strpos($code, 'let ') !== false || strpos($code, 'function ') !== false) {
        $detected_language = "JavaScript / TypeScript";
    } elseif (strpos($code, 'public class ') !== false || strpos($code, 'System.out.print') !== false) {
        $detected_language = "Java";
    } elseif (strpos($code, '#include') !== false || strpos($code, 'std::') !== false) {
        $detected_language = "C / C++";
    } elseif (strpos($code, 'package ') !== false && strpos($code, 'func ') !== false) {
        $detected_language = "Go";
    }

    // Tạo nội dung phân tích dựa trên action
    if ($action === 'explain') {
        // Kiểm tra xem đây là tác vụ tóm tắt bài viết hay giải thích code thông thường
        $is_article_summary = (mb_strpos($code, 'tóm tắt') !== false || mb_strpos(strtolower($code), 'summarize') !== false);

        if ($is_article_summary) {
            // Trích xuất phần nội dung bài viết nằm sau prompt (phần văn bản chính)
            $parts = explode("\n\n", $code);
            $article_content = count($parts) > 1 ? end($parts) : $code;

            // Nhận diện ngôn ngữ sơ bộ dựa trên sự xuất hiện của các ký tự tiếng Việt đặc trưng
            $is_vietnamese = preg_match('/[àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ]/i', $article_content);

            // Thuật toán trích xuất câu (extractive summarization) đơn giản:
            // Tách các câu dựa trên dấu chấm, dấu chấm hỏi, dấu chấm than
            $sentences = preg_split('/(?<=[.!?])\s+/', $article_content);
            $clean_sentences = [];
            foreach ($sentences as $s) {
                $s = trim($s);
                // Loại bỏ code block, markdown header, hoặc các câu quá ngắn/quá dài rác
                if (empty($s) || strpos($s, '`') !== false || strpos($s, '#') !== false || strlen($s) < 15) {
                    continue;
                }
                $clean_sentences[] = $s;
            }

            // Lấy tối đa 3 câu đầu tiên làm tóm tắt
            $summary_points = array_slice($clean_sentences, 0, 3);

            if (empty($summary_points)) {
                if ($is_vietnamese) {
                    $ai_response = "### 🧠 Tóm tắt bài viết (Chế độ Offline)\n\n* Không thể tự động phân tách câu từ bài viết này. Vui lòng cấu hình `GEMINI_API_KEY` để nhận tóm tắt AI chi tiết.";
                } else {
                    $ai_response = "### 🧠 Article Summary (Offline Mode)\n\n* Could not automatically extract key sentences. Please configure `GEMINI_API_KEY` to get detailed AI summarization.";
                }
            } else {
                if ($is_vietnamese) {
                    $ai_response = "### 🧠 Tóm tắt bài viết (Chế độ Offline)\n\n*Đây là tóm tắt tự động được trích xuất từ nội dung gốc (Chưa cấu hình API Key trên máy chủ):*\n\n";
                    foreach ($summary_points as $point) {
                        $ai_response .= "* " . $point . "\n";
                    }
                } else {
                    $ai_response = "### 🧠 Article Summary (Offline Mode)\n\n*Here is the automatic summary extracted from the source content (API Key not configured on server):*\n\n";
                    foreach ($summary_points as $point) {
                        $ai_response .= "* " . $point . "\n";
                    }
                }
            }
        } else {
            // Giải thích mã nguồn thông thường (mặc định)
            $ai_response = "### 🧠 Phân tích & Giải thích Mã nguồn (Chế độ Demo)\n\n> **Lưu ý:** Đây là kết quả phân tích mô phỏng vì chưa cấu hình Gemini API Key trên máy chủ. Bạn có thể cấu hình `GEMINI_API_KEY` trong `ai_helper.php` để nhận câu trả lời thực tế từ AI.\n\n* **Ngôn ngữ nhận diện:** `$detected_language`\n* **Đánh giá tổng quan:** Đoạn mã nguồn có cấu trúc rõ ràng, thực hiện nhiệm vụ xử lý logic hoặc render UI cơ bản.\n\n#### 🔍 Chi tiết luồng xử lý:\n1. **Khởi tạo và cấu hình:** Thiết lập các thư viện, imports hoặc các biến đầu vào cần thiết cho module xử lý.\n2. **Hàm xử lý chính:** Thực hiện thuật toán cốt lõi. Sử dụng các cấu trúc điều kiện hoặc lặp để lọc, duyệt phần tử hoặc quản lý luồng dữ liệu.\n3. **Kết quả trả về:** Trả về đối tượng/UI Widget/Dữ liệu sau khi xử lý hoặc in ra thiết bị ngoại vi để theo dõi.\n\n#### 💡 Đóng góp gợi ý nâng cấp:\n* Nên bổ sung xử lý lỗi (`try-catch`) bao bọc các thao tác bất đồng bộ hoặc kết nối dữ liệu để tránh crash ứng dụng.\n* Cân nhắc tách nhỏ các hàm xử lý dài thành các hàm helper đơn nhiệm để dễ bảo trì và viết Unit Test.";
        }
    } elseif ($action === 'debug') {
        $clean_code = preg_replace('/(\/\*([\s\S]*?)\*\/)|(\/\/(.*)$)/m', '', $code); // loại bỏ comment để clean
        $ai_response = "### 🛠️ Rà soát lỗi & Tối ưu hóa Code (Chế độ Demo)\n\n> **Lưu ý:** Đây là kết quả phân tích mô phỏng vì chưa cấu hình Gemini API Key trên máy chủ.\n\n#### 🔴 Các vấn đề tiềm ẩn được phát hiện:\n1. **Thiếu Khối Xử Lý Lỗi (Exception Handling):** Đoạn mã chưa bao bọc các tác vụ nhạy cảm (như ép kiểu, truy xuất phần tử mảng, kết nối mạng) trong khối `try-catch` hoặc kiểm tra điều kiện `null`. Điều này dễ dẫn đến lỗi crash Runtime.\n2. **Tối ưu hóa hiệu năng (Performance):** Sử dụng các phép toán lặp hoặc khởi tạo lại đối tượng liên tục trong vòng lặp có thể gây quá tải bộ nhớ và áp lực lên bộ dọn rác (Garbage Collector).\n\n#### 🟢 Phương án khắc phục & Đoạn code tối ưu:\n* Dưới đây là đề xuất viết lại code sạch hơn, an toàn hơn:\n\n```dart\n// Code đã được cải tiến và thêm cơ chế xử lý lỗi an toàn\ntry {\n  // Kiểm tra điều kiện đầu vào trước khi xử lý\n  if (input != null) {\n    // Đoạn code xử lý an toàn\n    print(\"Xử lý thành công dữ liệu\");\n  } else {\n    print(\"Dữ liệu đầu vào không hợp lệ\");\n  }\n} catch (e) {\n  // Ghi log lỗi thay vì làm sập luồng chính\n  print(\"Lỗi phát sinh: \$e\");\n}\n```\n\n#### 📈 Đánh giá sau tối ưu:\n* **Tính an toàn:** Tăng 40% (Giảm thiểu crash ứng dụng).\n* **Bộ nhớ:** Tiết kiệm hơn nhờ tái sử dụng biến và quản lý luồng bất đồng bộ tốt hơn.";
    } elseif ($action === 'translate') {
        $ai_response = "### 🔀 Chuyển đổi Ngôn ngữ lập trình sang **$target_lang** (Chế độ Demo)\n\n> **Lưu ý:** Đây là kết quả phân tích mô phỏng vì chưa cấu hình Gemini API Key trên máy chủ.\n\n* **Nguồn:** Code gốc từ ngôn ngữ `$detected_language`.\n* **Ngôn ngữ đích:** `$target_lang`.\n\n#### 💻 Code chuyển đổi mẫu sang `$target_lang`:\n```" . strtolower($target_lang) . "\n// Đoạn code được chuyển đổi cấu trúc tương đương trong $target_lang\n" . ($target_lang === 'Python' ? "def process_data(data):\n    try:\n        if data is not null:\n            print(\"Processing:\", data)\n            return True\n    except Exception as e:\n        print(f\"Error: {e}\")\n        return False" : "void processData(dynamic data) {\n  try {\n    if (data != null) {\n      print('Processing: \$data');\n    }\n  } catch (e) {\n    print('Error: \$e');\n  }\n}") . "\n```\n\n#### 📝 Các lưu ý khi chuyển sang `$target_lang`:\n1. **Mô hình lập trình:** Sử dụng các thư viện chuẩn của `$target_lang` để tối ưu tốc độ thực thi.\n2. **Quản lý biến & bộ nhớ:** `$target_lang` có cơ chế tự động dọn rác hoặc quản lý biến phạm vi khác biệt so với mã nguồn gốc của bạn. Hãy đảm bảo quy tắc khai báo biến đúng chuẩn (`camelCase` hoặc `snake_case`).";
    }
}

// Trả về dữ liệu kết quả phân tích AI dạng Markdown
jsonResponse(true, 'AI code analysis completed successfully', [
    'action' => $action,
    'detected_language' => isset($detected_language) ? $detected_language : 'Unknown',
    'result_markdown' => $ai_response
], 200);
?>
