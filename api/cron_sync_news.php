<?php
/**
 * CODEGO TECH NEWS - RSS TECH NEWS SYNC SCRIPT
 * Đường dẫn: /api/cron_sync_news.php
 * Hướng dẫn: Gọi file này qua cronjob (ví dụ: 3 tiếng/lần) để cập nhật tin tức tự động.
 */

// Bật hiển thị lỗi để dễ dàng debug
error_reporting(E_ALL);
ini_set('display_errors', 1);

require_once __DIR__ . '/includes/config.php';
require_once __DIR__ . '/includes/helpers.php';

// Tự động sửa các ảnh trùng lặp cũ từ Unsplash sang ảnh Picsum có seed độc lập theo tiêu đề để hiển thị phong phú hơn
$conn->query("
    UPDATE tech_articles 
    SET thumbnail_url = CONCAT('https://picsum.photos/seed/', SUBSTRING(MD5(title), 1, 10), '/600/400')
    WHERE thumbnail_url LIKE '%unsplash.com%'
");

// Các nguồn RSS tin tức uy tín và chất lượng (đảm bảo có hình ảnh)
$feeds = [
    'AI' => [
        'https://www.wired.com/feed/tag/ai/latest/rss'
    ],
    'Mobile' => [
        'https://dev.to/feed/tag/flutter',
        'https://dev.to/feed/tag/mobile'
    ],
    'General' => [
        'https://feeds.arstechnica.com/arstechnica/index',
        'https://www.wired.com/feed/rss'
    ]
];

$count = 0;
$created_time = time();
$debug_errors = [];

foreach ($feeds as $category => $urls) {
    foreach ($urls as $feed_url) {
        // Sử dụng cURL thay vì simplexml_load_file để hoạt động được khi hosting tắt allow_url_fopen
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $feed_url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
        curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false);
        curl_setopt($ch, CURLOPT_TIMEOUT, 15);
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
        ]);
        
        $xml_content = curl_exec($ch);
        
        if (curl_errno($ch)) {
            $debug_errors[$category . ' (' . $feed_url . ')'] = 'cURL Error: ' . curl_error($ch);
            curl_close($ch);
            continue;
        }
        curl_close($ch);
        
        // Parse XML nội dung
        $xml = @simplexml_load_string($xml_content);
        if ($xml === false) {
            $debug_errors[$category . ' (' . $feed_url . ')'] = 'Failed to parse RSS XML. Invalid format.';
            continue;
        }
        
        // Đọc danh sách bài viết từ RSS
        $items = $xml->channel->item;
        if (!$items) {
            $debug_errors[$category . ' (' . $feed_url . ')'] = 'No RSS items found in channel.';
            continue;
        }
        
        foreach ($items as $item) {
            $title = (string)$item->title;
            $link = (string)$item->link;
            $pubDate = strtotime((string)$item->pubDate);
            if (!$pubDate) $pubDate = time();
            
            // Tạo slug từ tiêu đề bài viết
            $slug = preg_replace('/[^A-Za-z0-9-]+/', '-', strtolower($title));
            $slug = trim($slug, '-');
            
            // Tóm tắt ngắn gọn bài viết
            $description = strip_tags((string)$item->description);
            $summary = mb_strimwidth($description, 0, 200, "...");
            
            // Nội dung chi tiết (nếu có hoặc dùng summary làm content)
            $content = '';
            if (isset($item->children('content', true)->encoded)) {
                $content = (string)$item->children('content', true)->encoded;
            }
            
            if (empty($content)) {
                $content = "# " . $title . "\n\n" . $description;
            }
            
            // Bóc tách ảnh thật từ RSS Feed
            $thumbnail_url = '';

            // Cách 1: Tìm trong namespace media:content (Phổ biến ở WordPress / TechCrunch / Ars Technica)
            $media = $item->children('media', true);
            if (!$media || $media->count() == 0) {
                $media = $item->children('http://search.yahoo.com/mrss/');
            }
            if ($media && $media->content) {
                $attrs = $media->content->attributes();
                if (isset($attrs['url'])) {
                    $thumbnail_url = (string)$attrs['url'];
                }
            }

            // Cách 2: Tìm trong namespace media:thumbnail (Phổ biến ở Wired / Ars Technica)
            if (empty($thumbnail_url) && $media && $media->thumbnail) {
                $attrs = $media->thumbnail->attributes();
                if (isset($attrs['url'])) {
                    $thumbnail_url = (string)$attrs['url'];
                }
            }

            // Cách 3: Tìm từ thẻ enclosure (Phổ biến ở Engadget / một số feed RSS khác)
            if (empty($thumbnail_url) && $item->enclosure) {
                $attrs = $item->enclosure->attributes();
                if (isset($attrs['url'])) {
                    $thumbnail_url = (string)$attrs['url'];
                }
            }

            // Cách 4: Dùng Regex tìm thẻ img đầu tiên trong description hoặc content:encoded (Phổ biến ở DEV.to)
            if (empty($thumbnail_url)) {
                $html_to_search = (string)$item->description . ' ' . $content;
                preg_match('/<img[^>]+src=["\']([^"\']+)["\']/', $html_to_search, $img_matches);
                if (isset($img_matches[1])) {
                    $thumbnail_url = $img_matches[1];
                }
            }

            // Cách 5: Fallback nếu hoàn toàn không có ảnh nào trong RSS thì dùng ảnh ngẫu nhiên có seed theo tiêu đề để không bị trùng lặp
            if (empty($thumbnail_url)) {
                $thumbnail_url = 'https://picsum.photos/seed/' . substr(md5($title), 0, 10) . '/600/400';
            }
            
            // Kiểm tra xem bài viết đã tồn tại chưa để tránh trùng lặp
            $stmt_check = $conn->prepare("SELECT id FROM tech_articles WHERE slug = ? LIMIT 1");
            $stmt_check->bind_param("s", $slug);
            $stmt_check->execute();
            $result = $stmt_check->get_result();
            $exists = $result->num_rows > 0;
            $stmt_check->close();
            
            if (!$exists) {
                // Chèn bài viết mới vào database
                $stmt = $conn->prepare("
                    INSERT INTO tech_articles (title, slug, summary, content, thumbnail_url, source_name, source_url, category, view_count, is_weekly_highlight, published_at, created_at, updated_at)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                ");
                
                $source_name = parse_url($link, PHP_URL_HOST);
                $view_count = rand(100, 1500);
                $is_weekly = (rand(1, 10) > 8) ? 1 : 0; // Tỉ lệ 20% bài viết làm tiêu điểm tuần
                
                $stmt->bind_param(
                    "ssssssssiiiii", 
                    $title, 
                    $slug, 
                    $summary, 
                    $content, 
                    $thumbnail_url, 
                    $source_name, 
                    $link, 
                    $category, 
                    $view_count, 
                    $is_weekly, 
                    $pubDate, 
                    $created_time, 
                    $created_time
                );
                
                if ($stmt->execute()) {
                    $count++;
                }
                $stmt->close();
            }
        }
    }
}

jsonResponse(true, "Đồng bộ thành công $count bài viết công nghệ mới về database!", [
    'debug_errors' => $debug_errors
]);
?>
