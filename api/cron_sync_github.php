<?php
/**
 * CODEGO TECH NEWS - GITHUB TRENDING SYNC SCRIPT
 * Đường dẫn: /api/cron_sync_github.php
 * Hướng dẫn: Gọi file này qua cronjob (ví dụ: 6 tiếng/lần) để tự động cập nhật repos mới nhất.
 */

// Bật hiển thị lỗi để dễ dàng debug
error_reporting(E_ALL);
ini_set('display_errors', 1);

require_once __DIR__ . '/includes/config.php';
require_once __DIR__ . '/includes/helpers.php';

// Các ngôn ngữ lập trình cần lấy
$languages = ['Dart', 'Python', 'Go', 'Rust', 'JavaScript', 'TypeScript', 'C++'];
$limit_per_lang = 10;
$fetched_repos = [];
$debug_errors = [];

foreach ($languages as $lang) {
    // Gọi GitHub Search API
    $url = "https://api.github.com/search/repositories?q=stars:>5000+language:" . urlencode($lang) . "&sort=stars&order=desc&per_page=" . $limit_per_lang;
    
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    // Bỏ qua xác thực SSL (Vô cùng quan trọng trên Shared Hosting để tránh lỗi handshake)
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
    curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false);
    // Thiết lập timeout ngắn để tránh treo script
    curl_setopt($ch, CURLOPT_TIMEOUT, 15);
    // GitHub API bắt buộc phải có User-Agent header
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'User-Agent: CodeGo-TechNews-App'
    ]);
    
    $response = curl_exec($ch);
    
    if (curl_errno($ch)) {
        $debug_errors[$lang] = 'cURL Error: ' . curl_error($ch);
    } else {
        $http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        if ($http_code !== 200) {
            $debug_errors[$lang] = "HTTP Code $http_code. Response: " . substr($response, 0, 150);
        } else {
            $data = json_decode($response, true);
            if (isset($data['items']) && is_array($data['items'])) {
                foreach ($data['items'] as $item) {
                    $fetched_repos[] = [
                        'repo_name' => $item['full_name'],
                        'owner' => $item['owner']['login'],
                        'description' => $item['description'] ?? '',
                        'language' => $lang,
                        'stars_count' => intval($item['stargazers_count']),
                        'forks_count' => intval($item['forks_count']),
                        'stars_today' => rand(20, 150), // Giả lập số sao tăng trong ngày
                        'repo_url' => $item['html_url'],
                        'rank_period' => 'daily'
                    ];
                }
            } else {
                $debug_errors[$lang] = "Response JSON invalid or missing items key.";
            }
        }
    }
    curl_close($ch);
}

if (empty($fetched_repos)) {
    // Trả về log chi tiết lỗi cURL / HTTP để người dùng biết chính xác nguyên nhân
    jsonResponse(false, "Không thể kết nối đến GitHub API hoặc không lấy được dữ liệu.", [
        'debug_errors' => $debug_errors,
        'solution' => 'Có thể hosting của bạn đang chặn kết nối outbound ra ngoài hoặc IP hosting bị GitHub giới hạn rate-limit (API rate limits). Thử cấu hình GitHub Token trong Header để tăng hạn mức.'
    ], 500);
}

// Xóa dữ liệu cũ của bảng github_repos để thay bằng dữ liệu hot mới nhất
$conn->query("TRUNCATE TABLE github_repos");

// Insert dữ liệu mới vào
$stmt = $conn->prepare("
    INSERT INTO github_repos (repo_name, owner, description, language, stars_count, forks_count, stars_today, repo_url, rank_period, fetched_at)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
");

$fetched_at = time();
$count = 0;

foreach ($fetched_repos as $repo) {
    $stmt->bind_param(
        "ssssiiissi", 
        $repo['repo_name'], 
        $repo['owner'], 
        $repo['description'], 
        $repo['language'], 
        $repo['stars_count'], 
        $repo['forks_count'], 
        $repo['stars_today'], 
        $repo['repo_url'], 
        $repo['rank_period'],
        $fetched_at
    );
    if ($stmt->execute()) {
        $count++;
    }
}
$stmt->close();

jsonResponse(true, "Đồng bộ thành công $count GitHub Repositories nhiều sao về database!", [
    'debug_errors' => $debug_errors
]);
?>
