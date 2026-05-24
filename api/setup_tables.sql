-- CODEGO TECHFLOW - DATABASE INITIALIZATION SCRIPT (MVP)
-- HƯỚNG DẪN: Import file này vào MySQL database `codego` của bạn trên hosting Interdata.

-- 1. BẢNG TIN TỨC CÔNG NGHỆ (tech_articles)
CREATE TABLE IF NOT EXISTS `tech_articles` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `title` VARCHAR(255) NOT NULL,
  `slug` VARCHAR(255) NOT NULL UNIQUE,
  `summary` TEXT NOT NULL,
  `content` LONGTEXT NULL,
  `thumbnail_url` VARCHAR(512) NULL,
  `source_name` VARCHAR(100) DEFAULT 'TechFlow',
  `source_url` VARCHAR(512) NULL,
  `category` VARCHAR(50) DEFAULT 'General',
  `view_count` INT DEFAULT 0,
  `is_weekly_highlight` TINYINT(1) DEFAULT 0,
  `published_at` INT NOT NULL, -- Unix timestamp
  `created_at` INT NOT NULL,
  `updated_at` INT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. BẢNG XU HƯỚNG GITHUB (github_repos)
CREATE TABLE IF NOT EXISTS `github_repos` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `repo_name` VARCHAR(150) NOT NULL,
  `owner` VARCHAR(100) NOT NULL,
  `description` TEXT NULL,
  `language` VARCHAR(50) NULL,
  `stars_count` INT DEFAULT 0,
  `forks_count` INT DEFAULT 0,
  `stars_today` INT DEFAULT 0,
  `repo_url` VARCHAR(512) NOT NULL,
  `rank_period` VARCHAR(10) DEFAULT 'daily', -- 'daily', 'weekly'
  `fetched_at` INT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. BẢNG THƯ VIỆN & CÔNG CỤ AI (ai_packages)
CREATE TABLE IF NOT EXISTS `ai_packages` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `package_name` VARCHAR(150) NOT NULL,
  `platform` VARCHAR(50) NOT NULL, -- 'npm', 'pip', 'pub.dev', 'huggingface'
  `description` TEXT NOT NULL,
  `install_command` VARCHAR(255) NULL,
  `github_url` VARCHAR(512) NULL,
  `docs_url` VARCHAR(512) NULL,
  `author` VARCHAR(100) NULL,
  `version` VARCHAR(30) NULL,
  `stars` INT DEFAULT 0,
  `created_at` INT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. BẢNG TIỆN ÍCH IDE & QUY TRÌNH PHÁT TRIỂN (dev_workflows)
CREATE TABLE IF NOT EXISTS `dev_workflows` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `title` VARCHAR(255) NOT NULL,
  `description` TEXT NOT NULL,
  `tool_category` VARCHAR(50) NOT NULL, -- 'VS Code', 'Cursor IDE', 'GitHub Actions'
  `content_markdown` LONGTEXT NOT NULL,
  `author_name` VARCHAR(100) DEFAULT 'Admin',
  `likes_count` INT DEFAULT 0,
  `copy_count` INT DEFAULT 0,
  `created_at` INT NOT NULL,
  `updated_at` INT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. BẢNG KHO PROMPT LẬP TRÌNH VIÊN (curated_prompts)
CREATE TABLE IF NOT EXISTS `curated_prompts` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `title` VARCHAR(255) NOT NULL,
  `target_model` VARCHAR(100) NOT NULL, -- 'Claude 3.5 Sonnet', 'GPT-4o'
  `category` VARCHAR(50) NOT NULL, -- 'Refactoring', 'Debugging', 'Testing'
  `description` TEXT NOT NULL,
  `prompt_text` LONGTEXT NOT NULL,
  `copy_count` INT DEFAULT 0,
  `likes_count` INT DEFAULT 0,
  `created_at` INT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. BẢNG LƯU TRỮ BOOKMARKS (user_bookmarks)
CREATE TABLE IF NOT EXISTS `user_bookmarks` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL,
  `item_type` VARCHAR(30) NOT NULL, -- 'article', 'repo', 'ai_package', 'workflow', 'prompt'
  `item_id` INT NOT NULL,
  `created_at` INT NOT NULL,
  UNIQUE KEY `unique_bookmark` (`user_id`, `item_type`, `item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 7. BẢNG THẢ TIM/THÍCH TÀI NGUYÊN (user_likes)
CREATE TABLE IF NOT EXISTS `user_likes` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL,
  `item_type` VARCHAR(30) NOT NULL, -- 'workflow', 'prompt', 'article'
  `item_id` INT NOT NULL,
  `created_at` INT NOT NULL,
  UNIQUE KEY `unique_user_like` (`user_id`, `item_type`, `item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- =========================================================================
-- CHÈN DỮ LIỆU MẪU (MOCK DATA) ĐỂ HIỂN THỊ NGAY TRÊN APP MVP
-- =========================================================================

-- 1. Mock Tech Articles
INSERT IGNORE INTO `tech_articles` (`id`, `title`, `slug`, `summary`, `content`, `thumbnail_url`, `source_name`, `source_url`, `category`, `view_count`, `is_weekly_highlight`, `published_at`, `created_at`, `updated_at`) VALUES
(1, 'Flutter công bố kết xuất Impeller đột phá trên mọi nền tảng', 'flutter-impeller-engine-evolution', 'Google công bố động cơ kết xuất đồ họa Impeller đã chính thức hỗ trợ hoàn hảo iOS và Android, giải quyết triệt để vấn đề giật lag khung hình lần đầu tiên.', '# Kỷ Nguyên Mới Của Flutter Rendering Engine: Impeller\n\nTrong những bản cập nhật gần đây, Google đã chính thức xác nhận việc thay thế hoàn toàn Skia bằng **Impeller** làm công cụ kết xuất đồ họa mặc định. Đây được coi là bước ngoặt lớn nhất kể từ khi Flutter ra mắt.\n\n### Tại sao lại là Impeller?\nSkia tuy mạnh mẽ nhưng gặp điểm yếu cố hữu là **Shader Compilation Jank** (hiện tượng khựng khung hình khi shader được biên dịch lần đầu trong thời gian chạy). Impeller giải quyết triệt để điều này bằng cách biên dịch tất cả shader trước khi đóng gói ứng dụng (Ahead-Of-Time).\n\n### Kết quả thử nghiệm\n- **Tốc độ khung hình (FPS):** Duy trì ổn định ở mức 60 FPS đến 120 FPS trên các màn hình tần số quét cao.\n- **Dung lượng ram tối ưu:** Tiết kiệm khoảng 15% dung lượng RAM tiêu thụ khi render các hình hoạt họa SVG phức tạp.', 'https://images.unsplash.com/photo-1618401471353-b98aedd07871?auto=format&fit=crop&w=600&q=80', 'Flutter Dev Blog', 'https://medium.com/flutter', 'Mobile', 2450, 1, UNIX_TIMESTAMP() - 172800, UNIX_TIMESTAMP() - 172800, UNIX_TIMESTAMP() - 172800),
(2, 'Claude 3.5 Sonnet thống trị bảng xếp hạng trí tuệ nhân tạo dành cho lập trình', 'claude-3-5-sonnet-dominates-swe-bench', 'Với khả năng giải quyết các tác vụ lập trình thực tế vượt trội, mô hình ngôn ngữ lớn của Anthropic chính thức vượt qua GPT-4o về điểm số SWE-bench.', '# Claude 3.5 Sonnet: Vị Vua Mới Của Coding AI\n\nAnthropic vừa phát hành Claude 3.5 Sonnet, thiết lập tiêu chuẩn mới trong ngành AI về khả năng suy luận logic, giải toán và đặc biệt là khả năng viết mã nguồn.\n\n### SWE-bench: Thử thách cực hạn\nTrên bảng xếp hạng SWE-bench (bộ kiểm thử AI giải quyết các issue thực tế trên các Github Repo nguồn mở), Claude 3.5 Sonnet đạt điểm số cao chưa từng có, tự động sửa lỗi và deploy thành công các pull request phức tạp mà không cần sự can thiệp của con người.\n\n> "Khả năng phân tích mã nguồn và tự sửa lỗi của Claude 3.5 thực sự khiến chúng tôi ngỡ ngàng." - Chia sẻ từ một kỹ sư phần mềm cao cấp.', 'https://images.unsplash.com/photo-1677442136019-21780efad99a?auto=format&fit=crop&w=600&q=80', 'Anthropic News', 'https://www.anthropic.com/news/claude-3-5-sonnet', 'AI', 3890, 1, UNIX_TIMESTAMP() - 86400, UNIX_TIMESTAMP() - 86400, UNIX_TIMESTAMP() - 86400),
(3, 'Tại sao lập trình viên hiện đại đang chuyển hướng từ VS Code sang Cursor IDE?', 'cursor-ide-the-ai-native-vs-code-evolution', 'Cursor IDE đang tạo nên cơn sốt toàn cầu nhờ tích hợp AI sâu sắc vào nhân VS Code, thay đổi hoàn toàn thói quen viết mã hàng ngày.', '# Cursor IDE - Kẻ thách thức VS Code nâng tầm bằng AI\n\nCursor không phải là một IDE xây dựng mới hoàn toàn, nó là một bản fork trực tiếp từ VS Code. Điều đó có nghĩa là bạn giữ lại toàn bộ extension, phím tắt và thói quen cũ, nhưng được trang bị thêm một bộ não AI cực kỳ thông minh.\n\n### Các tính năng hủy diệt:\n1. **Composer (Ctrl + I):** Cho phép AI chỉnh sửa đồng thời nhiều file nguồn trong dự án.\n2. **Chat context thông minh:** Gõ `@Files` hoặc `@Folders` để AI hiểu chính xác cấu trúc code của bạn.\n3. **Auto-debug:** Khi terminal báo lỗi, chỉ cần click một nút, AI tự sửa lỗi ngay tại chỗ.', 'https://images.unsplash.com/photo-1542831371-29b0f74f9713?auto=format&fit=crop&w=600&q=80', 'TechCrunch', 'https://techcrunch.com', 'General', 1890, 0, UNIX_TIMESTAMP() - 43200, UNIX_TIMESTAMP() - 43200, UNIX_TIMESTAMP() - 43200);

-- 2. Mock GitHub Trending Repos
INSERT IGNORE INTO `github_repos` (`id`, `repo_name`, `owner`, `description`, `language`, `stars_count`, `forks_count`, `stars_today`, `repo_url`, `rank_period`, `fetched_at`) VALUES
(1, 'langchain-ai/langchain', 'langchain-ai', 'Building applications with LLMs through composability. Flexible, robust, and highly adoptable.', 'Python', 87430, 12510, 420, 'https://github.com/langchain-ai/langchain', 'daily', UNIX_TIMESTAMP()),
(2, 'flutter/flutter', 'flutter', 'Flutter makes it easy and fast to build beautiful apps for mobile and beyond.', 'Dart', 165400, 26700, 110, 'https://github.com/flutter/flutter', 'daily', UNIX_TIMESTAMP()),
(3, 'huggingface/transformers', 'huggingface', 'State-of-the-art Machine Learning for PyTorch, TensorFlow, and JAX.', 'Python', 125100, 24500, 312, 'https://github.com/huggingface/transformers', 'weekly', UNIX_TIMESTAMP()),
(4, 'vercel/next.js', 'vercel', 'The React Framework for the Web. Optimized for fast rendering and supreme developer experience.', 'JavaScript', 121500, 26100, 95, 'https://github.com/vercel/next.js', 'daily', UNIX_TIMESTAMP());

-- 3. Mock AI Packages
INSERT IGNORE INTO `ai_packages` (`id`, `package_name`, `platform`, `description`, `install_command`, `github_url`, `docs_url`, `author`, `version`, `stars`, `created_at`) VALUES
(1, 'google_generative_ai', 'pub.dev', 'Flutter/Dart SDK chính thức để kết nối và gọi mô hình Gemini Pro và Gemini Flash từ Google.', 'flutter pub add google_generative_ai', 'https://github.com/google/generative-ai-dart', 'https://pub.dev/packages/google_generative_ai', 'Google', '0.4.6', 420, UNIX_TIMESTAMP()),
(2, 'langchain', 'pip', 'Framework xây dựng các ứng dụng dựa trên mô hình ngôn ngữ lớn (LLM) thông qua liên kết các thành phần.', 'pip install langchain', 'https://github.com/langchain-ai/langchain', 'https://python.langchain.com/', 'Harrison Chase', '0.1.20', 87400, UNIX_TIMESTAMP());

-- 4. Mock Dev Workflows
INSERT IGNORE INTO `dev_workflows` (`id`, `title`, `description`, `tool_category`, `content_markdown`, `author_name`, `likes_count`, `copy_count`, `created_at`, `updated_at`) VALUES
(1, 'Cài Đặt Cấu Hình CI/CD Flutter Với GitHub Actions Tự Động Build APK & IPA', 'Quy trình hoàn chỉnh để tự động hóa việc build file cài đặt Android và iOS mỗi khi bạn push code lên nhánh main.', 'GitHub Actions', '## Quy Trình Tự Động Build Flutter Bằng GitHub Actions\n\nTập tin cấu hình mẫu này giúp bạn tự động kiểm thử và build bản phát hành (.apk và .ipa) mỗi khi đẩy code lên git.\n\n### Tệp tin cấu hình `.github/workflows/flutter_build.yml`:\n```yaml\nname: Flutter Build & Deploy\n\non:\n  push:\n    branches: [ main ]\n\njobs:\n  build:\n    runs-on: macos-latest\n    steps:\n    - uses: actions/checkout@v3\n    \n    - name: Set up Java\n      uses: actions/setup-java@v3\n      with:\n        distribution: \'zulu\'\n        java-version: \'17\'\n        \n    - name: Set up Flutter\n      uses: subosito/flutter-action@v2\n      with:\n        channel: \'stable\'\n        \n    - name: Install dependencies\n      run: flutter pub get\n      \n    - name: Run Tests\n      run: flutter test\n      \n    - name: Build APK\n      run: flutter build apk --release\n      \n    - name: Build IPA\n      run: flutter build ipa --no-codesign\n```', 'Lâm Developer', 124, 452, UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
(2, 'Cấu Hình Docker Compose Tối Ưu Cho Dự Án PHP 8.2 & Nginx & MySQL Local', 'Thiết lập môi trường phát triển local hoàn chỉnh cho PHP/Laravel bằng Docker container hóa chỉ với 1 câu lệnh.', 'Docker', '## Docker Development Environment For PHP 8.2\n\nTập tin cấu hình này giúp thiết lập container hóa toàn bộ ứng dụng PHP, web server Nginx và database MySQL để phát triển cục bộ.\n\n### 1. Tệp tin cấu hình `docker-compose.yml`:\n```yaml\nversion: \'3.8\'\n\nservices:\n  # PHP Service\n  app:\n    build:\n      context: .\n      dockerfile: Dockerfile\n    image: codego-php-app\n    container_name: codego-app\n    restart: unless-stopped\n    working_dir: /var/www\n    volumes:\n      - ./:/var/www\n    networks:\n      - codego-network\n\n  # Nginx Service\n  webserver:\n    image: nginx:alpine\n    container_name: codego-webserver\n    restart: unless-stopped\n    ports:\n      - "8080:80"\n    volumes:\n      - ./:/var/www\n      - ./nginx.conf:/etc/nginx/conf.d/default.conf\n    networks:\n      - codego-network\n\n  # MySQL Service\n  db:\n    image: mysql:8.0\n    container_name: codego-db\n    restart: unless-stopped\n    ports:\n      - "3306:3306"\n    environment:\n      MYSQL_DATABASE: codego_db\n      MYSQL_ROOT_PASSWORD: root\n    volumes:\n      - dbdata:/var/lib/mysql\n    networks:\n      - codego-network\n\nnetworks:\n  codego-network:\n    driver: bridge\n\nvolumes:\n  dbdata:\n    driver: local\n```\n\n### 2. Tệp tin cấu hình `nginx.conf`:\n```nginx\nserver {\n    listen 80;\n    index index.php index.html;\n    error_log  /var/log/nginx/error.log;\n    access_log /var/log/nginx/access.log;\n    root /var/www/public;\n    location ~ \\.php$ {\n        try_files $uri =404;\n        fastcgi_split_path_info ^(.+\\.php)(/.+)$;\n        fastcgi_pass app:9000;\n        fastcgi_index index.php;\n        include fastcgi_params;\n        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;\n        fastcgi_param PATH_INFO $fastcgi_path_info;\n    }\n    location / {\n        try_files $uri $uri/ /index.php?$query_string;\n        gzip_static on;\n    }\n}\n```\n\n### 3. Cách sử dụng:\nKhởi chạy môi trường bằng lệnh:\n```bash\ndocker-compose up -d\n```', 'Huy DevOps', 98, 235, UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
(3, 'Các Thiết Lập Phím Tắt Và Custom Rules Tối Ưu Trong Cursor IDE', 'Mẹo cấu hình Cursor để viết code nhanh hơn gấp 2 lần với trí tuệ nhân tạo, thiết lập file .cursorrules chuẩn.', 'Cursor IDE', '## Cấu Hình Luật Cursor (.cursorrules) Cho AI\n\nTạo một file mang tên `.cursorrules` ở thư mục gốc của dự án để ép AI luôn viết code chuẩn chỉ.\n\n### Nội dung tệp `.cursorrules` mẫu:\n```markdown\n# Lập trình viên AI rules\n\n- Luôn luôn ưu tiên các giải pháp Clean Code, tuân thủ nguyên tắc SOLID và DRY.\n- Viết code có giải thích ngắn gọn bằng Tiếng Việt ở các hàm phức tạp.\n- Không được sử dụng các thư viện đã bị deprecate.\n- Khi viết Flutter, bắt buộc sử dụng const constructor cho các Widget tĩnh để tối ưu hóa hiệu năng render.\n- Viết kèm Unit Test tương ứng cho bất kỳ class logic mới nào.\n- Các file định dạng JSON trả về từ API bắt buộc phải wrap trong cấu hình chuẩn: `{"success": true, "message": "...", "data": ...}`.\n```\n\n### Các phím tắt tăng hiệu suất Cursor:\n* `Ctrl + K` (Windows) / `Cmd + K` (Mac): Chỉnh sửa hoặc tạo code trực tiếp ngay dòng hiện tại.\n* `Ctrl + L` (Windows) / `Cmd + L` (Mac): Mở bảng chat với AI để hỏi về file hiện tại.\n* `Ctrl + I` (Windows) / `Cmd + I` (Mac): Composer - cho phép AI sửa cùng lúc nhiều file trong workspace.\n* `@Files` hoặc `@Folders`: Chỉ định trực tiếp tệp tin hoặc thư mục cần AI đọc làm ngữ cảnh.', 'Minh TechLead', 142, 612, UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
(4, 'Tự Động Định Dạng & Kiểm Tra Code Lỗi Với Git Hooks (husky & lint-staged)', 'Quy trình ngăn chặn mã nguồn bẩn (dirty code) được commit lên repository bằng cách kiểm tra format tự động.', 'Git', '## Tự Động Hóa Kiểm Tra Code Với Husky và Lint-Staged\n\nĐể đảm bảo toàn bộ thành viên trong dự án trước khi commit code đều đã được chạy qua công cụ Format & Lint, chúng ta cấu hình Git Hook.\n\n### 1. Cài đặt các gói npm phụ trợ:\n```bash\nnpm install husky lint-staged --save-dev\nnpx husky install\n```\n\n### 2. Cấu hình tệp tin `package.json`:\n```json\n{\n  "scripts": {\n    "prepare": "husky install"\n  },\n  "lint-staged": {\n    "*.{js,ts,dart}": [\n      "prettier --write",\n      "eslint --fix"\n    ]\n  }\n}\n```\n\n### 3. Tạo hook `pre-commit`:\nChạy lệnh sau trong terminal:\n```bash\nnpx husky add .husky/pre-commit "npx lint-staged"\n```\n\nTừ nay, mỗi khi gõ `git commit`, Husky sẽ chặn và tự động chạy `lint-staged`. Nếu có lỗi cú pháp không thể tự fix, commit sẽ bị hủy bỏ, bảo vệ repository khỏi code lỗi.', 'Thành Git', 78, 189, UNIX_TIMESTAMP(), UNIX_TIMESTAMP());

-- 5. Mock Curated Prompts
INSERT IGNORE INTO `curated_prompts` (`id`, `title`, `target_model`, `category`, `description`, `prompt_text`, `copy_count`, `likes_count`, `created_at`) VALUES
(1, 'Tái Cấu Trúc Hàm Phức Tạp & Tối Ưu Hiệu Năng', 'Claude 3.5 Sonnet', 'Refactoring', 'Giúp cấu trúc lại một hàm quá dài, tối ưu thuật toán và đảm bảo tuân thủ nguyên tắc Clean Code.', 'Hãy đóng vai là một kỹ sư tối ưu hóa mã nguồn cấp cao. Phân tích hàm sau đây của tôi: [DÁN HÀM VÀO ĐÂY]. Hãy chỉ ra các điểm nghẽn hiệu năng (performance bottlenecks), các phần vi phạm nguyên tắc Clean Code (SOLID, DRY) và viết lại hàm đó một cách sạch sẽ, tối ưu nhất. Cung cấp cả lời giải thích chi tiết cho từng thay đổi.', 892, 142, UNIX_TIMESTAMP()),
(2, 'Tự Động Sinh Bộ Test Case Toàn Diện (Unit Test)', 'GPT-4o', 'Testing', 'Tạo ra các kịch bản kiểm thử (unit tests) đầy đủ bao gồm cả các trường hợp biên và ngoại lệ lỗi.', 'Tôi có đoạn code viết bằng ngôn ngữ [TÊN NGÔN NGỮ]: [DÁN ĐOẠN CODE CỦA BẠN]. Hãy viết toàn bộ mã nguồn Unit Test toàn diện cho đoạn code này. Đảm bảo bao quát: các case chạy thành công thông thường, các case biên cực trị (boundary cases), và các trường hợp truyền tham số lỗi hoặc gây crash. Sử dụng framework test phổ biến của ngôn ngữ này.', 534, 76, UNIX_TIMESTAMP()),
(3, 'Giải Thích Bug & Đề Xuất Sửa Lỗi Từ Log Lỗi', 'Claude 3.5 Sonnet', 'Debugging', 'Phân tích stack trace hoặc thông báo lỗi từ terminal để chỉ rõ nguyên nhân gốc rễ và code sửa lỗi.', 'Tôi gặp lỗi sau đây trong terminal khi đang chạy ứng dụng: [DÁN ĐOẠN LOG LỖI/STACK TRACE]. Đây là đoạn code có khả năng gây lỗi cao nhất: [DÁN ĐOẠN CODE LIÊN QUAN]. Hãy giải thích nguyên nhân gây ra lỗi này bằng tiếng Việt và cung cấp đoạn code đã được sửa hoàn chỉnh để khắc phục lỗi đó.', 651, 98, UNIX_TIMESTAMP());

-- 8. BẢNG CÔNG CỤ AI (ai_tools)
CREATE TABLE IF NOT EXISTS `ai_tools` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(100) NOT NULL,
  `category` VARCHAR(50) NOT NULL,
  `pricing_type` VARCHAR(50) NOT NULL,
  `pricing_detail` VARCHAR(255) NOT NULL,
  `speed_rating` VARCHAR(50) NOT NULL,
  `context_window` VARCHAR(100) NOT NULL,
  `efficiency_score` DECIMAL(3,1) DEFAULT 9.0,
  `description` TEXT NOT NULL,
  `evaluation` TEXT NOT NULL,
  `how_to_use` LONGTEXT NOT NULL,
  `is_free_prioritized` TINYINT(1) DEFAULT 0,
  `website_url` VARCHAR(512) NULL,
  `created_at` INT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 8. Mock AI Tools Data
INSERT IGNORE INTO `ai_tools` 
(`id`, `name`, `category`, `pricing_type`, `pricing_detail`, `speed_rating`, `context_window`, `efficiency_score`, `description`, `evaluation`, `how_to_use`, `is_free_prioritized`, `website_url`, `created_at`) 
VALUES
(1, 'Windsurf IDE', 'IDE', 'Trial & Freemium', 'Dùng thử dài hạn (miễn phí dùng cơ bản hàng ngày), gói Pro $15/tháng (Rẻ hơn Cursor)', 'Cực nhanh', 'Không giới hạn', 9.2, 'Trình soạn thảo mã nguồn AI thế hệ mới thế kế chuyên biệt cho việc phát triển phần mềm tự động (Agentic Coding).', 'Tính năng Cascade cho phép AI tự động phân tích và chỉnh sửa code đệ quy liên tục qua nhiều file cực kỳ thông minh. Hỗ trợ phím tắt và extension tương tự VS Code.', '## Hướng dẫn cài đặt & sử dụng Windsurf IDE\n\n### 1. Cài đặt\n1. Tải bộ cài từ trang chủ [codeium.com/windsurf](https://codeium.com/windsurf) tương thích với hệ điều hành của bạn.\n2. Cài đặt và đăng nhập bằng tài khoản Codeium.\n3. Khi khởi động, bạn có thể tự động nhập (import) toàn bộ Extensions, Settings và Keybindings từ VS Code chỉ bằng một cú click.\n\n### 2. Các phím tắt & Tính năng AI cốt lõi\n* **Cascade (Ctrl + I hoặc Cmd + I):** Đây là tính năng mạnh nhất của Windsurf. Cascade hoạt động ở 2 chế độ:\n  - `Chat`: Bạn hỏi đáp về codebase.\n  - `Write`: Cho phép AI tự động chỉnh sửa, thêm mới code đệ quy qua nhiều file đồng thời dưới sự giám sát của bạn.\n* **Auto-completion:** Tự động hoàn thành code theo ngữ cảnh siêu nhanh, gợi ý nhiều dòng cùng lúc. Nhấn `Tab` để chấp nhận.\n* **Command Palette (Ctrl + Shift + P):** Để gọi các lệnh cấu hình hoặc cài đặt extension của Windsurf.', 1, 'https://codeium.com/windsurf', UNIX_TIMESTAMP()),

(2, 'Ollama', 'Local Runner', 'Free', 'Miễn phí 100% & Mã nguồn mở hoàn toàn', 'Phụ thuộc cấu hình GPU máy', 'Phụ thuộc RAM hệ thống', 8.8, 'Công cụ chạy các mô hình ngôn ngữ lớn (LLM) cục bộ trực tiếp trên máy tính cá nhân.', 'Hoạt động offline hoàn toàn, bảo mật dữ liệu tuyệt đối (không lo lộ code dự án). Tích hợp hoàn hảo với các mô hình chuyên code nhẹ như DeepSeek-Coder, Qwen2.5-Coder.', '## Hướng dẫn cài đặt & sử dụng Ollama (Chạy LLM Offline)\n\n### 1. Cài đặt\n1. Truy cập [ollama.com](https://ollama.com) và tải ứng dụng cho macOS, Windows hoặc Linux.\n2. Cài đặt Ollama vào máy. Đối với Linux, bạn chạy câu lệnh cài đặt nhanh:\n   ```bash\n   curl -fsSL https://ollama.com/install.sh | sh\n   ```\n\n### 2. Các lệnh CLI cơ bản (Tải và chạy model)\nMở terminal của bạn và chạy các lệnh sau:\n* **Tải và chạy DeepSeek-Coder (Mô hình chuyên code cực tốt):**\n   ```bash\n   ollama run deepseek-coder:6.7b\n   ```\n* **Tải và chạy Qwen2.5-Coder (Mô hình chuyên code mới nhất):**\n   ```bash\n   ollama run qwen2.5-coder:7b\n   ```\n* **Liệt kê các model đã tải trên máy:**\n   ```bash\n   ollama list\n   ```\n* **Xóa một model để giải phóng ổ cứng:**\n   ```bash\n   ollama rm deepseek-coder:6.7b\n   ```\n\n### 3. Kết nối với IDE\nBạn có thể kết nối Ollama với VS Code hoặc Cursor thông qua các extension như **Continue.dev** bằng cách cấu hình API endpoint local mặc định: `http://localhost:11434`.', 1, 'https://ollama.com', UNIX_TIMESTAMP()),

(3, 'DeepSeek-Coder-V2', 'LLM Model', 'Free / Paid', 'API cực kỳ rẻ (rẻ hơn 10 lần so với GPT-4o), hoặc chạy miễn phí qua Ollama', 'Nhanh', '128k tokens', 9.3, 'Mô hình AI chuyên lập trình mã nguồn mở mạnh nhất thế giới hiện tại đến từ DeepSeek.', 'Điểm số đánh giá benchmark viết code vượt trội tiệm cận GPT-4o. Hỗ trợ đa ngôn ngữ lập trình (hơn 300 ngôn ngữ) và cấu trúc thuật toán phức tạp.', '## Hướng dẫn sử dụng DeepSeek-Coder-V2\n\n### 1. Sử dụng qua Web (Miễn phí)\nTruy cập trang chủ [chat.deepseek.com](https://chat.deepseek.com), đăng ký tài khoản và chọn mô hình DeepSeek-Coder để chat trực tiếp.\n\n### 2. Sử dụng API giá siêu rẻ trong IDE\n1. Đăng ký tài khoản API tại [platform.deepseek.com](https://platform.deepseek.com) và nạp tiền (chỉ cần 1-2$ là đủ dùng hàng tháng vì giá API siêu rẻ).\n2. Tạo một **API Key** mới.\n3. Cấu hình vào các extension lập trình như **Continue.dev** hoặc **CodeGPT** trong VS Code:\n   - Base URL: `https://api.deepseek.com`\n   - Model: `deepseek-coder`\n   - API Key: `{API_KEY_CỦA_BẠN}`\n\n### 3. Chạy offline qua Ollama\nNếu máy có GPU tốt, chạy lệnh sau để tải bản nén lượng tử 16B:\n```bash\nollama run deepseek-coder-v2:16b\n```', 1, 'https://chat.deepseek.com', UNIX_TIMESTAMP()),

(4, 'Gemini 1.5 Flash', 'LLM Model', 'Free / Paid', 'Miễn phí 15 request/phút qua Google AI Studio, gói cước trả phí cực rẻ', 'Cực nhanh', '1 triệu tokens', 9.0, 'Mô hình AI đa phương thức thế hệ mới của Google với tốc độ xử lý hàng đầu.', 'Sở hữu cửa sổ ngữ cảnh khổng lồ 1.000.000 tokens giúp nhà phát triển dễ dàng tải toàn bộ thư mục dự án lên để AI đọc hiểu ngữ cảnh và sửa lỗi nhanh chóng.', '## Hướng dẫn sử dụng Gemini 1.5 Flash & Pro (Cửa sổ ngữ cảnh 1M-2M tokens)\n\n### 1. Lấy API Key miễn phí (Google AI Studio)\n1. Truy cập [aistudio.google.com](https://aistudio.google.com).\n2. Đăng nhập bằng tài khoản Google của bạn.\n3. Bấm **Get API Key** ở góc trên cùng bên trái và tạo một Key cho dự án của bạn.\n*Lưu ý: Gói Free tier cho phép gọi tới 15 requests/phút (RPM) hoàn toàn miễn phí, rất dư dả cho nhu cầu viết code cá nhân.*\n\n### 2. Tải toàn bộ Codebase vào ngữ cảnh\nDo Gemini hỗ trợ cửa sổ ngữ cảnh lên tới 1 triệu tokens (bản Pro lên tới 2 triệu), bạn có thể:\n1. Nén toàn bộ mã nguồn dự án của bạn (loại bỏ thư mục `node_modules` hoặc `build`).\n2. Kéo thả file zip trực tiếp vào giao diện Google AI Studio.\n3. Nhập câu hỏi: *\"Hãy phân tích cấu trúc dự án của tôi và tìm các lỗi bảo mật hoặc điểm chưa tối ưu\"*. AI sẽ đọc và hiểu toàn bộ dự án của bạn chỉ trong vài giây.', 1, 'https://aistudio.google.com', UNIX_TIMESTAMP()),

(5, 'Cursor IDE', 'IDE', 'Freemium', 'Miễn phí 50 lần query nhanh/tháng, gói Pro $20/tháng', 'Nhanh', 'Không giới hạn', 9.5, 'Trình soạn thảo code tích hợp AI phổ biến nhất hiện nay, được phát triển dưới dạng bản Fork từ VS Code.', 'Tính năng Composer (Ctrl+I) sửa đồng thời nhiều file nguồn rất mạnh. Tự động kiểm tra lỗi build terminal để đề xuất sửa lỗi một chạm. Nhập toàn bộ extension VS Code chỉ với 1 click.', '## Hướng dẫn cài đặt & tối ưu Cursor IDE\n\n### 1. Cài đặt\n1. Tải và cài đặt Cursor từ trang chủ [cursor.sh](https://cursor.sh).\n2. Cursor sẽ tự động phát hiện và import toàn bộ cấu hình, phím tắt, extension từ VS Code sang để bạn sử dụng ngay lập tức.\n\n### 2. Các phím tắt AI hủy diệt\n* **Cmd + K (Mac) / Ctrl + K (Win):** Viết hoặc sửa đổi code trực tiếp tại con trỏ hiện tại.\n* **Cmd + L (Mac) / Ctrl + L (Win):** Mở thanh Chat AI bên hông. Bạn có thể sử dụng `@Files` hoặc `@Folders` để truyền file/thư mục làm ngữ cảnh cho AI đọc.\n* **Cmd + I (Mac) / Ctrl + I (Win):** Mở **Composer** - cho phép AI tự động chỉnh sửa đồng thời nhiều file nguồn khác nhau trong dự án của bạn dựa trên 1 yêu cầu duy nhất.\n* **Auto-debug:** Khi terminal báo lỗi build, bạn chỉ cần bấm nút **\"Fix with AI\"** xuất hiện ngay trong terminal, AI sẽ tự tìm lỗi và đề xuất code sửa đổi.', 0, 'https://cursor.sh', UNIX_TIMESTAMP()),

(6, 'Claude 3.5 Sonnet', 'LLM Model', 'Freemium', 'Miễn phí giới hạn trên Web, tính phí theo lượng token tiêu thụ API', 'Nhanh', '200k tokens', 9.6, 'Mô hình AI thông minh nhất của Anthropic về mặt lập trình cấu trúc và logic.', 'Được đánh giá cao nhất bởi cộng đồng lập trình viên vì khả năng viết code sạch, giải thích thuật toán tối ưu và refactor mã nguồn phức tạp cực kỳ xuất sắc.', '## Hướng dẫn viết Prompt cho Claude 3.5 Sonnet sinh code chuẩn nhất\n\n### 1. Tận dụng tính năng Artifacts trên Claude.ai\nKhi trò chuyện trên Claude.ai, nếu bạn yêu cầu sinh code, website sẽ tự động mở một cửa sổ **Artifacts** bên phải hiển thị code riêng biệt. Bạn có thể copy, xem trực tiếp kết quả chạy (nếu là HTML/JS/CSS) rất trực quan.\n\n### 2. Cấu trúc Prompt tối ưu cho lập trình\nĐể Claude viết code sạch (Clean Code), tuân thủ SOLID, hãy cấu trúc prompt như sau:\n```markdown\nVai trò: Bạn là một chuyên gia lập trình Flutter/Go/Python cấp cao.\nYêu cầu kỹ thuật:\n- Sử dụng State Pattern để quản lý trạng thái giao dịch.\n- Code phải có Unit Test đi kèm che phủ 80% luồng.\n- Luôn sử dụng const constructor cho Widget (nếu là Flutter).\nMã nguồn hiện tại của tôi:\n[DÁN CODE LIÊN QUAN VÀO ĐÂY]\n```', 0, 'https://claude.ai', UNIX_TIMESTAMP()),

(7, 'GitHub Copilot', 'IDE Extension', 'Paid', '$10/tháng hoặc $100/năm. Miễn phí cho Học sinh & Maintainer nguồn mở', 'Cực nhanh', '32k tokens', 9.1, 'Extension hỗ trợ tự động hoàn thành code (autocomplete) huyền thoại của GitHub và Microsoft.', 'Khả năng đoán trước dòng code tiếp theo khi bạn đang gõ rất chính xác. Tích hợp sâu vào hệ sinh thái JetBrains, VS Code, Visual Studio. Tốt nhất cho thói quen gõ phím nhanh.', '## Hướng dẫn sử dụng GitHub Copilot cho Lập trình viên\n\n### 1. Đăng ký & Kích hoạt tài khoản\n1. Truy cập [github.com/features/copilot](https://github.com/features/copilot).\n2. Đăng ký gói sử dụng cá nhân ($10/tháng hoặc $100/năm).\n*Mẹo: Nếu bạn là **Học sinh/Sinh viên** có email trường học `.edu` hoặc là **Người duy trì thư viện nguồn mở lớn (Maintainer)**, bạn có thể đăng ký sử dụng GitHub Copilot hoàn toàn miễn phí.*\n\n### 2. Cài đặt Extension\n1. Mở VS Code, JetBrains hoặc Visual Studio.\n2. Tìm kiếm extension **GitHub Copilot** trong chợ ứng dụng và cài đặt.\n3. Đăng nhập vào tài khoản GitHub đã kích hoạt Copilot của bạn.\n\n### 3. Phím tắt sử dụng hàng ngày\n* **Nhận gợi ý code:** Khi bạn gõ code, Copilot sẽ tự động hiển thị gợi ý mờ. Nhấn `Tab` để đồng ý toàn bộ, hoặc `Ctrl + Mũi tên phải` để đồng ý từng từ.\n* **Xem gợi ý tiếp theo/trước đó:** Nhấn `Alt + [` hoặc `Alt + ]`.\n* **Mở bảng Chat Copilot:** Nhấn `Ctrl + Shift + I` hoặc click biểu tượng chat bên thanh sidebar.', 0, 'https://github.com/features/copilot', UNIX_TIMESTAMP()),

(8, 'Continue.dev', 'IDE Extension', 'Free', 'Miễn phí 100% & Mã nguồn mở hoàn toàn', 'Phụ thuộc model kết nối', 'Không giới hạn (Tự cấu hình)', 9.0, 'Extension autopilot mã nguồn mở miễn phí cho phép kết nối bất kỳ mô hình AI nào vào IDE của bạn.', 'Cho phép bạn cắm API Key của Claude, Gemini, GPT-4o, hoặc kết nối local với Ollama để code hoàn toàn miễn phí. Rất được ưa chuộng bởi cộng đồng developer yêu thích mã nguồn mở.', '## Hướng dẫn cấu hình Autopilot nguồn mở Continue.dev\n\n### 1. Cài đặt\n1. Mở VS Code hoặc JetBrains.\n2. Cài đặt extension mang tên **Continue**.\n3. Bạn sẽ thấy biểu tượng chữ **C** lớn xuất hiện ở thanh công cụ bên trái.\n\n### 2. Kết nối với API LLM miễn phí hoặc Local (Ollama)\nFile cấu hình của Continue nằm tại `~/.continue/config.json`. Bạn có thể cấu hình như sau:\n\n* **Kết nối Ollama chạy cục bộ (Offline):**\n```json\n{\n  \"models\": [\n    {\n      \"title\": \"DeepSeek Coder local\",\n      \"provider\": \"ollama\",\n      \"model\": \"deepseek-coder:6.7b\"\n    }\n  ]\n}\n```\n\n* **Kết nối Gemini API (Sử dụng key Free từ Google AI Studio):**\n```json\n{\n  \"models\": [\n    {\n      \"title\": \"Gemini 1.5 Flash\",\n      \"provider\": \"google\",\n      \"model\": \"gemini-1.5-flash\",\n      \"apiKey\": \"API_KEY_GOOGLE_CỦA_BẠN\"\n    }\n  ]\n}\n```', 1, 'https://github.com/continuedev/continue', UNIX_TIMESTAMP()),

(9, 'Supermaven', 'IDE Extension', 'Freemium', 'Bản miễn phí autocomplete tốc độ cao không giới hạn, gói Pro $10/tháng', 'Cực nhanh (Gần như không trễ)', '300k tokens', 9.3, 'Extension autocomplete nhanh nhất thế giới hiện nay với cửa sổ ngữ cảnh cực lớn.', 'Supermaven nổi tiếng với độ trễ phản hồi gần như bằng 0 và sở hữu cửa sổ ngữ cảnh autocomplete lên tới 300.000 tokens giúp hiểu toàn bộ các tệp tin đang mở.', '## Hướng dẫn sử dụng Supermaven - AI Autocomplete siêu tốc độ\n\n### 1. Cài đặt\n1. Mở VS Code, JetBrains hoặc Neovim.\n2. Cài đặt extension **Supermaven**.\n3. Nhấp vào biểu tượng Supermaven ở thanh trạng thái dưới cùng và đăng nhập (hoặc dùng tài khoản miễn phí).\n\n### 2. Mẹo sử dụng\n* Nhấn `Tab` để chấp nhận toàn bộ gợi ý.\n* Nhấn `Alt + ]` để chấp nhận từng từ của gợi ý nếu bạn không muốn lấy toàn bộ đoạn code AI sinh ra.', 1, 'https://supermaven.com', UNIX_TIMESTAMP()),

(10, 'Cody AI', 'IDE Extension', 'Freemium', 'Miễn phí cơ bản hàng tháng, gói Pro $9/tháng', 'Nhanh', 'Không giới hạn (Theo model)', 8.9, 'Trợ lý AI lập trình của Sourcegraph nổi tiếng với khả năng đọc và hiểu ngữ cảnh toàn bộ dự án.', 'Cody sử dụng bộ máy tìm kiếm của Sourcegraph để lập chỉ mục toàn bộ codebase của bạn cục bộ giúp trả lời các câu hỏi về luồng xử lý và sửa lỗi rất thông minh.', '## Hướng dẫn sử dụng Cody AI (Sourcegraph) trong dự án lớn\n\n### 1. Cài đặt\n1. Mở VS Code hoặc JetBrains.\n2. Tìm và cài đặt extension **Cody AI**.\n3. Đăng nhập bằng tài khoản Sourcegraph (miễn phí dùng cơ bản).\n\n### 2. Tính năng đọc hiểu ngữ cảnh Codebase mạnh mẽ\nCody nổi bật nhờ thuật toán nhúng (embeddings) giúp đọc và hiểu toàn bộ cấu trúc thư mục dự án.\n* **Hỏi đáp về codebase:** Mở khung chat Cody, gõ lệnh `@codebase` kèm câu hỏi của bạn. Cody sẽ tự động tìm các file liên quan để trả lời chính xác.\n* **Tự động sinh Unit Test:** Bấm chuột phải vào class/hàm bất kỳ, chọn **Cody > Generate Unit Tests**, AI sẽ tự phân tích file hiện tại và viết test case chuẩn mực cho bạn.', 0, 'https://sourcegraph.com/cody', UNIX_TIMESTAMP());
