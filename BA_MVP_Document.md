# TÀI LIỆU ĐẶC TẢ YÊU CẦU NGHIỆP VỤ & KỸ THUẬT (BA/PRD)
## DỰ ÁN: CODEGO TECHFLOW - ỨNG DỤNG BẢN TIN CÔNG NGHỆ & DEVELOPER HUB (MVP)

> [!NOTE]  
> Tài liệu này được thiết kế chi tiết nhằm phục vụ phát triển ứng dụng di động đa nền tảng bằng **Flutter** (Frontend) kết hợp hệ thống backend **PHP (REST API) & MySQL** hiện có tại thư mục `api`. Mục tiêu là xây dựng một sản phẩm chất lượng cao, thẩm mỹ hiện đại (Premium Design), hoạt động mượt mà và sẵn sàng phát hành trên Apple App Store & Google Play Store.

---

## MỤC LỤC
1. [TỔNG QUAN DỰ ÁN](#1-tổng-quan-dự-án)
2. [KIẾN TRÚC HỆ THỐNG & CƠ SỞ DỮ LIỆU (DATABASE SCHEMA)](#2-kiến-trúc-hệ-thống--cơ-sở-dữ-liệu-database-schema)
3. [ĐẶC TẢ CHỨC NĂNG CHI TIẾT (FUNCTIONAL SPECIFICATIONS)](#3-đặc-tả-chức-năng-chi-tiết-functional-specifications)
4. [KẾT NỐI API & ĐỊNH DẠNG DỮ LIỆU (API SPECIFICATION)](#4-kết-nối-api--định-dạng-dữ-liệu-api-specification)
5. [THIẾT KẾ GIAO DIỆN & TRẢI NGHIỆM NGƯỜI DÙNG (UI/UX PREMIUM AESTHETICS)](#5-thiết-kế-giao-diện--trải-nghiệm-người-dùng-uiux-premium-aesthetics)
6. [KẾ HOẠCH DỰ BỊ PUBLIC APP STORE (PRODUCTION READY CHECKLIST)](#6-kế-hoạch-dự-bị-public-app-store-production-ready-checklist)

---

## 1. TỔNG QUAN DỰ ÁN

### 1.1 Tên Ứng Dụng (Dự Kiến)
*   **CodeGo TechFlow** (Tích hợp thương hiệu "CodeGo" sẵn có từ backend).
*   **Slogan:** *Your Daily Source of Developer Inspiration.*

### 1.2 Tầm Nhìn & Mục Tiêu Sản Phẩm
Ứng dụng đóng vai trò là một **Developer Hub** – nơi tổng hợp thông tin, tài nguyên lập trình hằng ngày và hằng tuần nhanh nhất, chất lượng nhất. 
Thay vì chỉ hiển thị tin tức báo chí đơn thuần, app tập trung vào các tài nguyên thực chiến cho lập trình viên và người làm AI:
*   **GitHub Hot Repos:** Xu hướng các kho mã nguồn mở nổi bật theo ngày/tuần.
*   **AI Packages & Tools:** Các thư viện AI mới nổi, mô hình LLM, framework nổi bật (LangChain, HuggingFace, LlamaIndex, v.v.).
*   **IDE Workflows:** Các tiện ích (Extensions), phím tắt, quy trình tự động hóa công việc lập trình đột phá.
*   **Curated Prompts:** Kho prompt chất lượng cao giúp lập trình viên tối ưu hóa việc sử dụng ChatGPT, Claude, Gemini trong viết mã, gỡ lỗi và phân tích hệ thống.

### 1.3 Đối Tượng Người Dùng Mục Tiêu
*   Lập trình viên phần mềm (Software Engineers), kỹ sư dữ liệu & AI.
*   Học sinh, sinh viên ngành CNTT muốn cập nhật công nghệ mới.
*   Tech Leaders, Product Managers cần nắm bắt xu hướng công nghệ hàng tuần để định hướng dự án.

---

## 2. KIẾN TRÚC HỆ THỐNG & CƠ SỞ DỮ LIỆU (DATABASE SCHEMA)

Để tích hợp liền mạch với hệ thống database MySQL hiện tại của `codego` (đang có cấu trúc cho user, leaderboard, notification), chúng ta sẽ thêm các bảng dữ liệu sau đây vào cơ sở dữ liệu.

### 2.1 Bảng `tech_articles` (Tin tức công nghệ hàng ngày/hàng tuần)
Bảng lưu trữ các bài viết, tin tức nổi bật được cập nhật tự động qua API hoặc quản trị viên biên soạn.

```sql
CREATE TABLE `tech_articles` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `title` VARCHAR(255) NOT NULL,
  `slug` VARCHAR(255) NOT NULL UNIQUE,
  `summary` TEXT NOT NULL,
  `content` LONGTEXT NULL,
  `thumbnail_url` VARCHAR(512) NULL,
  `source_name` VARCHAR(100) DEFAULT 'TechFlow',
  `source_url` VARCHAR(512) NULL,
  `category` VARCHAR(50) DEFAULT 'General', -- AI, Mobile, Frontend, Backend, Devops, Security
  `view_count` INT DEFAULT 0,
  `is_weekly_highlight` TINYINT(1) DEFAULT 0, -- 1: Thuộc tiêu điểm tuần, 0: Tin thường ngày
  `published_at` INT NOT NULL, -- Unix timestamp
  `created_at` INT NOT NULL,
  `updated_at` INT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### 2.2 Bảng `github_repos` (Xu hướng GitHub Repository)
Lưu thông tin các repo hot thu thập được từ GitHub API (có cơ chế cache trên server để tránh rate-limit).

```sql
CREATE TABLE `github_repos` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `repo_name` VARCHAR(150) NOT NULL, -- Ví dụ: "flutter/flutter"
  `owner` VARCHAR(100) NOT NULL,
  `description` TEXT NULL,
  `language` VARCHAR(50) NULL, -- Ví dụ: "Dart", "Python", "TypeScript"
  `stars_count` INT DEFAULT 0,
  `forks_count` INT DEFAULT 0,
  `stars_today` INT DEFAULT 0, -- Số star tăng trong ngày/tuần
  `repo_url` VARCHAR(512) NOT NULL,
  `rank_period` VARCHAR(10) DEFAULT 'daily', -- 'daily', 'weekly'
  `fetched_at` INT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### 2.3 Bảng `ai_packages` (Thư viện & Gói công nghệ AI)
Lưu thông tin các package, thư viện AI chuyên dụng.

```sql
CREATE TABLE `ai_packages` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `package_name` VARCHAR(150) NOT NULL, -- Ví dụ: "langchain-core"
  `platform` VARCHAR(50) NOT NULL, -- Ví dụ: "npm", "pip", "pub.dev", "huggingface"
  `description` TEXT NOT NULL,
  `install_command` VARCHAR(255) NULL, -- Ví dụ: "pip install langchain"
  `github_url` VARCHAR(512) NULL,
  `docs_url` VARCHAR(512) NULL,
  `author` VARCHAR(100) NULL,
  `version` VARCHAR(30) NULL,
  `stars` INT DEFAULT 0,
  `created_at` INT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### 2.4 Bảng `dev_workflows` (Workflow Hot & Tiện ích IDE)
Lưu trữ các tips tối ưu, workflow tự động hóa, extension khuyên dùng.

```sql
CREATE TABLE `dev_workflows` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `title` VARCHAR(255) NOT NULL,
  `description` TEXT NOT NULL,
  `tool_category` VARCHAR(50) NOT NULL, -- Ví dụ: "VS Code", "Cursor IDE", "GitHub Actions", "Docker"
  `content_markdown` LONGTEXT NOT NULL,
  `author_name` VARCHAR(100) DEFAULT 'Admin',
  `likes_count` INT DEFAULT 0,
  `created_at` INT NOT NULL,
  `updated_at` INT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### 2.5 Bảng `curated_prompts` (Kho Prompt Lập trình viên)
Lưu trữ các mẫu prompt hữu ích có tương tác sao chép nhanh.

```sql
CREATE TABLE `curated_prompts` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `title` VARCHAR(255) NOT NULL,
  `target_model` VARCHAR(100) NOT NULL, -- Ví dụ: "Claude 3.5 Sonnet", "GPT-4o", "Gemini 1.5 Pro"
  `category` VARCHAR(50) NOT NULL, -- "Refactoring", "Debugging", "Code Generation", "Testing"
  `description` TEXT NOT NULL,
  `prompt_text` LONGTEXT NOT NULL,
  `copy_count` INT DEFAULT 0,
  `likes_count` INT DEFAULT 0,
  `created_at` INT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### 2.6 Bảng `user_bookmarks` (Lưu trữ Bookmarks Đa Năng)
Bảng trung gian quản lý việc bookmark của người dùng, liên kết đa hình thông qua cột `item_type`.

```sql
CREATE TABLE `user_bookmarks` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL,
  `item_type` VARCHAR(30) NOT NULL, -- 'article', 'repo', 'ai_package', 'workflow', 'prompt'
  `item_id` INT NOT NULL,
  `created_at` INT NOT NULL,
  FOREIGN KEY (`user_id`) REFERENCES `codego_users`(`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### 2.7 Bảng `user_likes` (Lượt thích cho bài viết, prompts, workflows)
```sql
CREATE TABLE `user_likes` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL,
  `item_type` VARCHAR(30) NOT NULL, -- 'workflow', 'prompt', 'article'
  `item_id` INT NOT NULL,
  `created_at` INT NOT NULL,
  FOREIGN KEY (`user_id`) REFERENCES `codego_users`(`user_id`) ON DELETE CASCADE,
  UNIQUE KEY `unique_user_like` (`user_id`, `item_type`, `item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## 3. ĐẶC TẢ CHỨC NĂNG CHI TIẾT (FUNCTIONAL SPECIFICATIONS)

### 3.1 Nhóm Chức Năng 1: Đăng Ký, Đăng Nhập & Hồ Sơ Cá Nhân (Auth & Profile)
*   **Mô tả:** Tích hợp trực tiếp với cơ chế xác thực JWT và mã hóa password từ backend PHP có sẵn (`login.php`, `register.php`, `get_token.php`).
*   **Luồng hoạt động:**
    1. Ứng dụng client gửi API key & secret của Client App lên `get_token.php` để lấy **Access Token** hệ thống (có thời hạn lâu dài, lưu trong bộ nhớ an toàn).
    2. Người dùng điền thông tin đăng nhập/đăng ký. Client gửi request POST kèm header `Authorization: Bearer {Access_Token}` lên `login.php`/`register.php` để lấy **User Token**.
    3. User Token được lưu trữ an toàn trên thiết bị thông qua thư viện `flutter_secure_storage`.
    4. Màn hình Profile hiển thị: Avatar (có chức năng upload ảnh lên `upload_avatar.php`), Tên, Cấp độ, Điểm tích lũy, Chuỗi ngày truy cập (Streaks - kích thích retention rate).

### 3.2 Nhóm Chức Năng 2: Tin Tức Công Nghệ Nổi Bật (Weekly & Daily Tech News)
*   **Mô tả:** Hiển thị luồng tin tức công nghệ nóng hổi nhất được phân chia theo bộ lọc trực quan.
*   **Phân loại hiển thị:**
    *   *Tiêu điểm hàng tuần (Weekly Highlights):* Hiển thị ở dạng thanh trượt (Carousel) ở trên đầu trang chủ với hình ảnh chất lượng cao, thiết kế tràn viền cực kỳ sang trọng.
    *   *Bản tin hàng ngày (Daily Feed):* Danh sách bài viết cuộn vô tận (Infinite Scroll), tải thêm dữ liệu khi vuốt xuống.
*   **Bộ lọc danh mục (Tags/Tabs):** AI, Lập trình di động (Flutter/Kotlin/Swift), Web dev, DevOps & Cloud, An toàn thông tin.
*   **Tương tác bài viết:** 
    *   Xem bài viết chi tiết dưới dạng Rich Text / Markdown tối ưu.
    *   Chia sẻ nhanh link bài viết qua hệ thống Share của hệ điều hành.
    *   Bookmark để đọc sau (Hỗ trợ lưu trữ offline).

### 3.3 Nhóm Chức Năng 3: Bảng Xếp Hạng Xu Hướng GitHub (GitHub Explorer)
*   **Mô tả:** Giúp lập trình viên khám phá các dự án open-source tiềm năng, tìm kiếm thư viện để học hỏi hoặc đóng góp.
*   **Các tính năng chính:**
    *   *Chọn mốc thời gian:* Xem xu hướng theo Ngày (Daily) hoặc Tuần (Weekly).
    *   *Lọc theo ngôn ngữ:* Menu Dropdown hoặc Ngang cho phép chọn: Tất cả, Dart, Python, JavaScript/TypeScript, Rust, Go, C++.
    *   *Thông số hiển thị:* Số sao hiện tại (Stars), lượt chia nhánh (Forks), số sao tăng thêm trong ngày/tuần (Stars gained).
    *   *Liên kết:* Nhấn vào repo sẽ mở giao diện WebView nội bộ (In-app WebView) hiển thị trực tiếp trang GitHub của dự án hoặc tùy chọn mở bằng trình duyệt bên ngoài.

### 3.4 Nhóm Chức Năng 4: Thư Viện AI & Tiện Ích Lập Trình (AI & SDK Hub)
*   **Mô tả:** Nơi tập trung thông tin các SDK, công cụ AI và quy trình làm việc (Workflows) tiên tiến nhất.
*   **Phần 1: AI & SDKs:**
    *   Hiển thị danh sách các thư viện AI đang bùng nổ.
    *   Cung cấp mã lệnh cài đặt nhanh (nút Copy dòng lệnh: ví dụ `pip install langchain`).
    *   Xem link tài liệu chính thức (Official Documentation).
*   **Phần 2: IDE & Dev Workflows:**
    *   Cung cấp các bài viết chất lượng dạng hướng dẫn từng bước (Step-by-step) về việc tối ưu hóa IDE (VS Code, Cursor, WebStorm).
    *   Chia sẻ các file cấu hình mẫu (ví dụ `.github/workflows/deploy.yml` hoặc các script automation viết bằng Bash/Python).
    *   Hỗ trợ chế độ hiển thị Code Block có tô sáng cú pháp (Syntax Highlighting) cực đẹp.

### 3.5 Nhóm Chức Năng 5: Kho Prompt Bản Quyền Dành Cho Developer (Curated Prompt Hub)
*   **Mô tả:** Cực kỳ hữu dụng trong kỷ nguyên AI. Giúp dev tiết kiệm hàng giờ suy nghĩ prompt để code hoặc test.
*   **Danh mục prompt:**
    *   *Code Generator:* Tạo code từ yêu cầu.
    *   *Refactoring:* Tối ưu hóa cấu trúc code, dọn dẹp code rác.
    *   *Debugging:* Tìm lỗi và đề xuất cách khắc phục.
    *   *Unit Testing:* Tự động viết test case cho các ngôn ngữ khác nhau.
*   **Tương tác cốt lõi:**
    *   **Nút Sao Chép Nhanh (Copy Prompt):** Nhấp một chạm sao chép toàn bộ prompt vào khay nhớ tạm cùng micro-animation thông báo thành công.
    *   **Mẹo sử dụng (Tips):** Đi kèm hướng dẫn cụ thể nên dùng với model nào (Claude 3.5 Sonnet, GPT-4o, hay Gemini 1.5 Pro) để có kết quả tối ưu nhất.
    *   **Yêu thích & Đánh giá (Like & Rate):** Người dùng có thể thả tim để đưa prompt lên top xu hướng.

### 3.6 Nhóm Chức Năng 6: Quản Lý Đọc Sau & Thông Báo Đẩy (Bookmarks & Push Notifications)
*   **Bookmark Offline:**
    *   Cho phép lưu bất kỳ bài viết, repository, package AI hay prompt nào vào danh sách "Saved".
    *   Dữ liệu được cache dưới SQLite hoặc Hive trên máy để người dùng có thể truy cập đọc ngay cả khi không có kết nối Internet.
*   **Push Notifications thông minh:**
    *   *Bản tin sáng:* Gửi notification tự động lúc 8:00 AM tổng hợp 3 tin nóng nhất trong ngày.
    *   *Tiêu điểm cuối tuần:* Gửi notification lúc 9:00 AM Chủ Nhật tổng hợp Top 5 Github Repos và Prompt của tuần.
    *   *Tích hợp:* Sử dụng API `send_notification.php` và cập nhật Token thiết bị qua `update_device_token.php`.

---

## 4. KẾT NỐI API & ĐỊNH DẠNG DỮ LIỆU (API SPECIFICATION)

Để đảm bảo hiệu suất truyền tải dữ liệu và tính bảo mật, tất cả dữ liệu gửi đi và nhận về sẽ sử dụng chuẩn JSON dưới giao thức HTTPS.

### 4.1 Luồng Xác Thực Hai Lớp (Authentication Flow)

1. Client gửi credentials (api_key, api_secret) lên `get_token.php` -> Nhận Access Token.
2. Với mọi API tiếp theo, client gửi header `Authorization: Bearer {Access_Token}`.
3. Khi đăng nhập, client gửi POST `login.php` -> Nhận `user_token`.
4. Các API cần quyền user (like, bookmark) sẽ yêu cầu cả header `Authorization: Bearer {Access_Token}` và `User-Token: {user_token}`.

### 4.2 Đặc tả các API Endpoint Mới

#### 4.2.1 API Lấy Tin Tức Công Nghệ (`/api/get_tech_news.php`)
*   **Method:** GET
*   **Parameters:** `category` (string), `type` ('daily'|'weekly'), `page` (int), `limit` (int).
*   **Response Success:**
```json
{
  "success": true,
  "message": "Fetched articles successfully",
  "data": {
    "articles": [
      {
        "id": 12,
        "title": "Flutter 4.0 công bố thay đổi mang tính cách mạng trong thiết kế UI",
        "slug": "flutter-4-0-revolutionary-ui-design",
        "summary": "Google vừa chính thức ra mắt phiên bản Flutter mới với cơ chế rendering engine Impeller cải tiến vượt trội.",
        "thumbnail_url": "https://codego.app/uploads/thumbnails/flutter4.jpg",
        "source_name": "Flutter Official Blog",
        "source_url": "https://medium.com/flutter/flutter-4-release-notes",
        "category": "Mobile",
        "view_count": 1420,
        "is_weekly_highlight": 1,
        "published_at": 1779603200,
        "is_bookmarked": false
      }
    ],
    "pagination": {
      "current_page": 1,
      "total_pages": 5,
      "total_items": 48
    }
  }
}
```

#### 4.2.2 API Lấy Xu Hướng GitHub (`/api/get_github_repos.php`)
*   **Method:** GET
*   **Parameters:** `period` ('daily'|'weekly'), `language` (string).
*   **Response Success:**
```json
{
  "success": true,
  "message": "Fetched trending repositories successfully",
  "data": [
    {
      "id": 45,
      "repo_name": "langchain-ai/langchain",
      "owner": "langchain-ai",
      "description": "Building applications with LLMs through composability.",
      "language": "Python",
      "stars_count": 87200,
      "forks_count": 12400,
      "stars_today": 342,
      "repo_url": "https://github.com/langchain-ai/langchain",
      "rank_period": "daily",
      "is_bookmarked": true
    }
  ]
}
```

#### 4.2.3 API Lấy Danh Sách Prompt AI (`/api/get_prompts.php`)
*   **Method:** GET
*   **Parameters:** `category` (string), `search` (string).
*   **Response Success:**
```json
{
  "success": true,
  "message": "Fetched curated prompts successfully",
  "data": [
    {
      "id": 8,
      "title": "Tối Ưu Hóa Hàm Phức Tạp (Clean Code & Performance)",
      "target_model": "Claude 3.5 Sonnet",
      "category": "Refactoring",
      "description": "Prompt này giúp bạn tái cấu trúc một hàm quá dài.",
      "prompt_text": "Hãy đóng vai là một kỹ sư tối ưu hóa mã nguồn cấp cao. Phân tích hàm sau...",
      "copy_count": 521,
      "likes_count": 84,
      "is_liked": true,
      "is_bookmarked": false,
      "created_at": 1779500000
    }
  ]
}
```

#### 4.2.4 API Lưu Trạng Thay Đổi Tương Tác (`/api/interact.php`)
*   **Method:** POST
*   **Body Request:**
```json
{
  "action": "bookmark", -- "bookmark" hoặc "like"
  "item_type": "prompt", -- "article", "repo", "ai_package", "workflow", "prompt"
  "item_id": 8,
  "state": true
}
```

---

## 5. THIẾT KẾ GIAO DIỆN & TRẢI NGHIỆM NGƯỜI DÙNG (UI/UX PREMIUM AESTHETICS)

### 5.1 Hệ Màu Sắc Tương Lai (Futuristic Dark Palette)
*   **Màu Nền Chính (Background):** Deep Dark Charcoal `#0B0F19`
*   **Màu Nền Card/Container (Surface):** Glassmorphic Slate `#161F30`
*   **Màu Điểm Nhấn Chủ Đạo (Accent Primary):** Electric Cyan / Royal Blue `#2563EB`
*   **Màu Điểm Nhấn Phụ (Secondary Accent):** Tech Purple `#8B5CF6` (Tượng trưng cho AI)
*   **Màu Trạng Thái Thành Công/Hot:** Radiant Mint `#10B981`

### 5.2 Phong cách Glassmorphism
*   Các AppBar và BottomNavigationBar sử dụng hiệu ứng mờ nhòe kính cường lực (`BackdropFilter` với `sigmaX: 10, sigmaY: 10`).
*   Viền của Card sử dụng màu bán trong suốt siêu mảnh (`Border.all(color: Colors.white.withOpacity(0.08), width: 0.8)`).
*   Sử dụng bóng đổ tỏa lan (soft box shadow) để tạo chiều sâu lập thể 3D.

### 5.3 Typography hiện đại
*   **Outfit** dùng cho các Header, Title cỡ lớn tạo độ sang trọng, công nghệ cao.
*   **Inter** dùng cho nội dung văn bản thường để đảm bảo mật độ chữ thoáng mát, dễ đọc.
*   Tích hợp gói `flutter_markdown` với style tùy chỉnh để hiển thị các đoạn code và bảng biểu Markdown mượt mà, đúng chuẩn lập trình.

### 5.4 Hiệu ứng chuyển động vi mô (Micro-animations)
*   Hiệu ứng nổ bóng nước khi thả tim (sử dụng package `like_button`).
*   Haptic Feedback (rung vật lý nhẹ) khi sao chép Prompt thành công.
*   Shimmering loading skeletons thay vì vòng tròn quay tròn nhàm chán.

---

## 6. KẾ HOẠCH DỰ BỊ PUBLIC APP STORE (PRODUCTION READY CHECKLIST)

### 6.1 Cơ chế bảo mật lưu trữ
*   Lưu thông tin đăng nhập (`user_token`) bằng **Keychain** (iOS) và **Keystore** (Android) qua package `flutter_secure_storage`.
*   Bật cơ chế mã hóa SSL pinning hoặc tối thiểu giao tiếp HTTPS hoàn toàn.

### 6.2 Xử lý mất kết nối
*   Hiển thị màn hình No Connection hoạt họa đẹp mắt kèm nút bấm Tải lại (Retry).
*   Lưu tạm dữ liệu (Caching) bằng `hive` hoặc `sqflite` để hỗ trợ đọc báo ngoại tuyến hoàn hảo.

### 6.3 Tuân thủ chính sách App Store
*   **Chính sách Quyền riêng tư (Privacy Policy):** Cấu hình trang web công khai chính sách xử lý dữ liệu tại server `/api/privacy_policy.html`.
*   **Xóa Tài Khoản (Account Deletion):** Cung cấp chức năng "Xóa tài khoản vĩnh viễn" trực tiếp trong màn hình Profile. Khi kích hoạt, gửi API xóa toàn bộ bản ghi user ở server để đạt chuẩn quy định 2022 của Apple.
*   **Hỗ trợ đa ngôn ngữ:** Chuẩn hóa chuỗi text qua gói `easy_localization` (hỗ trợ tiếng Việt và tiếng Anh).

### 6.4 Build Production Tối Ưu
*   Nén tất cả hình ảnh tài nguyên về định dạng **WebP** hoặc dùng vector **SVG**.
*   Build Android: `flutter build appbundle` giúp tối ưu dung lượng tải về trên Google Play.
*   Build iOS: `flutter build ipa --obfuscate --split-debug-info=build/app/outputs/symbols` để chống dịch ngược mã nguồn.
