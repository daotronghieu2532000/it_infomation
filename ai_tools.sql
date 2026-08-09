-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Máy chủ: localhost:3306
-- Thời gian đã tạo: Th8 09, 2026 lúc 12:04 AM
-- Phiên bản máy phục vụ: 10.6.27-MariaDB
-- Phiên bản PHP: 8.4.23

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Cơ sở dữ liệu: `codego`
--

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `ai_tools`
--

CREATE TABLE `ai_tools` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `category` varchar(50) NOT NULL,
  `pricing_type` varchar(50) NOT NULL,
  `pricing_detail` varchar(255) NOT NULL,
  `speed_rating` varchar(50) NOT NULL,
  `context_window` varchar(100) NOT NULL,
  `efficiency_score` decimal(3,1) DEFAULT 9.0,
  `description` text NOT NULL,
  `evaluation` text NOT NULL,
  `how_to_use` longtext NOT NULL,
  `is_free_prioritized` tinyint(1) DEFAULT 0,
  `website_url` varchar(512) DEFAULT NULL,
  `created_at` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `ai_tools`
--

INSERT INTO `ai_tools` (`id`, `name`, `category`, `pricing_type`, `pricing_detail`, `speed_rating`, `context_window`, `efficiency_score`, `description`, `evaluation`, `how_to_use`, `is_free_prioritized`, `website_url`, `created_at`) VALUES
(1, 'Windsurf IDE', 'IDE', 'Trial & Freemium', 'Dùng thử dài hạn (miễn phí dùng cơ bản hàng ngày), gói Pro $15/tháng (Rẻ hơn Cursor)', 'Cực nhanh', 'Không giới hạn', 9.2, 'Trình soạn thảo mã nguồn AI thế hệ mới thế kế chuyên biệt cho việc phát triển phần mềm tự động (Agentic Coding).', 'Tính năng Cascade cho phép AI tự động phân tích và chỉnh sửa code đệ quy liên tục qua nhiều file cực kỳ thông minh. Hỗ trợ phím tắt và extension tương tự VS Code.', '## Hướng dẫn cài đặt & sử dụng Windsurf IDE\n\n### 1. Cài đặt\n1. Tải bộ cài từ trang chủ [codeium.com/windsurf](https://codeium.com/windsurf) tương thích với hệ điều hành của bạn.\n2. Cài đặt và đăng nhập bằng tài khoản Codeium.\n3. Khi khởi động, bạn có thể tự động nhập (import) toàn bộ Extensions, Settings và Keybindings từ VS Code chỉ bằng một cú click.\n\n### 2. Các phím tắt & Tính năng AI cốt lõi\n* **Cascade (Ctrl + I hoặc Cmd + I):** Đây là tính năng mạnh nhất của Windsurf. Cascade hoạt động ở 2 chế độ:\n  - `Chat`: Bạn hỏi đáp về codebase.\n  - `Write`: Cho phép AI tự động chỉnh sửa, thêm mới code đệ quy qua nhiều file đồng thời dưới sự giám sát của bạn.\n* **Auto-completion:** Tự động hoàn thành code theo ngữ cảnh siêu nhanh, gợi ý nhiều dòng cùng lúc. Nhấn `Tab` để chấp nhận.\n* **Command Palette (Ctrl + Shift + P):** Để gọi các lệnh cấu hình hoặc cài đặt extension của Windsurf.', 1, 'https://codeium.com/windsurf', 1779589276),
(2, 'Ollama', 'Local Runner', 'Free', 'Miễn phí 100% & Mã nguồn mở hoàn toàn', 'Phụ thuộc cấu hình GPU máy', 'Phụ thuộc RAM hệ thống', 8.8, 'Công cụ chạy các mô hình ngôn ngữ lớn (LLM) cục bộ trực tiếp trên máy tính cá nhân.', 'Hoạt động offline hoàn toàn, bảo mật dữ liệu tuyệt đối (không lo lộ code dự án). Tích hợp hoàn hảo với các mô hình chuyên code nhẹ như DeepSeek-Coder, Qwen2.5-Coder.', '## Hướng dẫn cài đặt & sử dụng Ollama (Chạy LLM Offline)\n\n### 1. Cài đặt\n1. Truy cập [ollama.com](https://ollama.com) và tải ứng dụng cho macOS, Windows hoặc Linux.\n2. Cài đặt Ollama vào máy. Đối với Linux, bạn chạy câu lệnh cài đặt nhanh:\n   ```bash\n   curl -fsSL https://ollama.com/install.sh | sh\n   ```\n\n### 2. Các lệnh CLI cơ bản (Tải và chạy model)\nMở terminal của bạn và chạy các lệnh sau:\n* **Tải và chạy DeepSeek-Coder (Mô hình chuyên code cực tốt):**\n   ```bash\n   ollama run deepseek-coder:6.7b\n   ```\n* **Tải và chạy Qwen2.5-Coder (Mô hình chuyên code mới nhất):**\n   ```bash\n   ollama run qwen2.5-coder:7b\n   ```\n* **Liệt kê các model đã tải trên máy:**\n   ```bash\n   ollama list\n   ```\n* **Xóa một model để giải phóng ổ cứng:**\n   ```bash\n   ollama rm deepseek-coder:6.7b\n   ```\n\n### 3. Kết nối với IDE\nBạn có thể kết nối Ollama với VS Code hoặc Cursor thông qua các extension như **Continue.dev** bằng cách cấu hình API endpoint local mặc định: `http://localhost:11434`.', 1, 'https://ollama.com', 1779589276),
(3, 'DeepSeek-Coder-V2', 'LLM Model', 'Free / Paid', 'API cực kỳ rẻ (rẻ hơn 10 lần so với GPT-4o), hoặc chạy miễn phí qua Ollama', 'Nhanh', '128k tokens', 9.3, 'Mô hình AI chuyên lập trình mã nguồn mở mạnh nhất thế giới hiện tại đến từ DeepSeek.', 'Điểm số đánh giá benchmark viết code vượt trội tiệm cận GPT-4o. Hỗ trợ đa ngôn ngữ lập trình (hơn 300 ngôn ngữ) và cấu trúc thuật toán phức tạp.', '## Hướng dẫn sử dụng DeepSeek-Coder-V2\n\n### 1. Sử dụng qua Web (Miễn phí)\nTruy cập trang chủ [chat.deepseek.com](https://chat.deepseek.com), đăng ký tài khoản và chọn mô hình DeepSeek-Coder để chat trực tiếp.\n\n### 2. Sử dụng API giá siêu rẻ trong IDE\n1. Đăng ký tài khoản API tại [platform.deepseek.com](https://platform.deepseek.com) và nạp tiền (chỉ cần 1-2$ là đủ dùng hàng tháng vì giá API siêu rẻ).\n2. Tạo một **API Key** mới.\n3. Cấu hình vào các extension lập trình như **Continue.dev** hoặc **CodeGPT** trong VS Code:\n   - Base URL: `https://api.deepseek.com`\n   - Model: `deepseek-coder`\n   - API Key: `{API_KEY_CỦA_BẠN}`\n\n### 3. Chạy offline qua Ollama\nNếu máy có GPU tốt, chạy lệnh sau để tải bản nén lượng tử 16B:\n```bash\nollama run deepseek-coder-v2:16b\n```', 1, 'https://chat.deepseek.com', 1779589276),
(4, 'Gemini 1.5 Flash', 'LLM Model', 'Free / Paid', 'Miễn phí 15 request/phút qua Google AI Studio, gói cước trả phí cực rẻ', 'Cực nhanh', '1 triệu tokens', 9.0, 'Mô hình AI đa phương thức thế hệ mới của Google với tốc độ xử lý hàng đầu.', 'Sở hữu cửa sổ ngữ cảnh khổng lồ 1.000.000 tokens giúp nhà phát triển dễ dàng tải toàn bộ thư mục dự án lên để AI đọc hiểu ngữ cảnh và sửa lỗi nhanh chóng.', '## Hướng dẫn sử dụng Gemini 1.5 Flash & Pro (Cửa sổ ngữ cảnh 1M-2M tokens)\n\n### 1. Lấy API Key miễn phí (Google AI Studio)\n1. Truy cập [aistudio.google.com](https://aistudio.google.com).\n2. Đăng nhập bằng tài khoản Google của bạn.\n3. Bấm **Get API Key** ở góc trên cùng bên trái và tạo một Key cho dự án của bạn.\n*Lưu ý: Gói Free tier cho phép gọi tới 15 requests/phút (RPM) hoàn toàn miễn phí, rất dư dả cho nhu cầu viết code cá nhân.*\n\n### 2. Tải toàn bộ Codebase vào ngữ cảnh\nDo Gemini hỗ trợ cửa sổ ngữ cảnh lên tới 1 triệu tokens (bản Pro lên tới 2 triệu), bạn có thể:\n1. Nén toàn bộ mã nguồn dự án của bạn (loại bỏ thư mục `node_modules` hoặc `build`).\n2. Kéo thả file zip trực tiếp vào giao diện Google AI Studio.\n3. Nhập câu hỏi: *\"Hãy phân tích cấu trúc dự án của tôi và tìm các lỗi bảo mật hoặc điểm chưa tối ưu\"*. AI sẽ đọc và hiểu toàn bộ dự án của bạn chỉ trong vài giây.', 1, 'https://aistudio.google.com', 1779589276),
(5, 'Cursor IDE', 'IDE', 'Freemium', 'Miễn phí 50 lần query nhanh/tháng, gói Pro $20/tháng', 'Nhanh', 'Không giới hạn', 9.5, 'Trình soạn thảo code tích hợp AI phổ biến nhất hiện nay, được phát triển dưới dạng bản Fork từ VS Code.', 'Tính năng Composer (Ctrl+I) sửa đồng thời nhiều file nguồn rất mạnh. Tự động kiểm tra lỗi build terminal để đề xuất sửa lỗi một chạm. Nhập toàn bộ extension VS Code chỉ với 1 click.', '## Hướng dẫn cài đặt & tối ưu Cursor IDE\n\n### 1. Cài đặt\n1. Tải và cài đặt Cursor từ trang chủ [cursor.sh](https://cursor.sh).\n2. Cursor sẽ tự động phát hiện và import toàn bộ cấu hình, phím tắt, extension từ VS Code sang để bạn sử dụng ngay lập tức.\n\n### 2. Các phím tắt AI hủy diệt\n* **Cmd + K (Mac) / Ctrl + K (Win):** Viết hoặc sửa đổi code trực tiếp tại con trỏ hiện tại.\n* **Cmd + L (Mac) / Ctrl + L (Win):** Mở thanh Chat AI bên hông. Bạn có thể sử dụng `@Files` hoặc `@Folders` để truyền file/thư mục làm ngữ cảnh cho AI đọc.\n* **Cmd + I (Mac) / Ctrl + I (Win):** Mở **Composer** - cho phép AI tự động chỉnh sửa đồng thời nhiều file nguồn khác nhau trong dự án của bạn dựa trên 1 yêu cầu duy nhất.\n* **Auto-debug:** Khi terminal báo lỗi build, bạn chỉ cần bấm nút **\"Fix with AI\"** xuất hiện ngay trong terminal, AI sẽ tự tìm lỗi và đề xuất code sửa đổi.', 0, 'https://cursor.sh', 1779589276),
(6, 'Claude 3.5 Sonnet', 'LLM Model', 'Freemium', 'Miễn phí giới hạn trên Web, tính phí theo lượng token tiêu thụ API', 'Nhanh', '200k tokens', 9.6, 'Mô hình AI thông minh nhất của Anthropic về mặt lập trình cấu trúc và logic.', 'Được đánh giá cao nhất bởi cộng đồng lập trình viên vì khả năng viết code sạch, giải thích thuật toán tối ưu và refactor mã nguồn phức tạp cực kỳ xuất sắc.', '## Hướng dẫn viết Prompt cho Claude 3.5 Sonnet sinh code chuẩn nhất\n\n### 1. Tận dụng tính năng Artifacts trên Claude.ai\nKhi trò chuyện trên Claude.ai, nếu bạn yêu cầu sinh code, website sẽ tự động mở một cửa sổ **Artifacts** bên phải hiển thị code riêng biệt. Bạn có thể copy, xem trực tiếp kết quả chạy (nếu là HTML/JS/CSS) rất trực quan.\n\n### 2. Cấu trúc Prompt tối ưu cho lập trình\nĐể Claude viết code sạch (Clean Code), tuân thủ SOLID, hãy cấu trúc prompt như sau:\n```markdown\nVai trò: Bạn là một chuyên gia lập trình Flutter/Go/Python cấp cao.\nYêu cầu kỹ thuật:\n- Sử dụng State Pattern để quản lý trạng thái giao dịch.\n- Code phải có Unit Test đi kèm che phủ 80% luồng.\n- Luôn sử dụng const constructor cho Widget (nếu là Flutter).\nMã nguồn hiện tại của tôi:\n[DÁN CODE LIÊN QUAN VÀO ĐÂY]\n```', 0, 'https://claude.ai', 1779589276),
(7, 'GitHub Copilot', 'IDE Extension', 'Paid', '$10/tháng hoặc $100/năm. Miễn phí cho Học sinh & Maintainer nguồn mở', 'Cực nhanh', '32k tokens', 9.1, 'Extension hỗ trợ tự động hoàn thành code (autocomplete) huyền thoại của GitHub và Microsoft.', 'Khả năng đoán trước dòng code tiếp theo khi bạn đang gõ rất chính xác. Tích hợp sâu vào hệ sinh thái JetBrains, VS Code, Visual Studio. Tốt nhất cho thói quen gõ phím nhanh.', '## Hướng dẫn sử dụng GitHub Copilot cho Lập trình viên\n\n### 1. Đăng ký & Kích hoạt tài khoản\n1. Truy cập [github.com/features/copilot](https://github.com/features/copilot).\n2. Đăng ký gói sử dụng cá nhân ($10/tháng hoặc $100/năm).\n*Mẹo: Nếu bạn là **Học sinh/Sinh viên** có email trường học `.edu` hoặc là **Người duy trì thư viện nguồn mở lớn (Maintainer)**, bạn có thể đăng ký sử dụng GitHub Copilot hoàn toàn miễn phí.*\n\n### 2. Cài đặt Extension\n1. Mở VS Code, JetBrains hoặc Visual Studio.\n2. Tìm kiếm extension **GitHub Copilot** trong chợ ứng dụng và cài đặt.\n3. Đăng nhập vào tài khoản GitHub đã kích hoạt Copilot của bạn.\n\n### 3. Phím tắt sử dụng hàng ngày\n* **Nhận gợi ý code:** Khi bạn gõ code, Copilot sẽ tự động hiển thị gợi ý mờ. Nhấn `Tab` để đồng ý toàn bộ, hoặc `Ctrl + Mũi tên phải` để đồng ý từng từ.\n* **Xem gợi ý tiếp theo/trước đó:** Nhấn `Alt + [` hoặc `Alt + ]`.\n* **Mở bảng Chat Copilot:** Nhấn `Ctrl + Shift + I` hoặc click biểu tượng chat bên thanh sidebar.', 0, 'https://github.com/features/copilot', 1779589276),
(8, 'Continue.dev', 'IDE Extension', 'Free', 'Miễn phí 100% & Mã nguồn mở hoàn toàn', 'Phụ thuộc model kết nối', 'Không giới hạn (Tự cấu hình)', 9.0, 'Extension autopilot mã nguồn mở miễn phí cho phép kết nối bất kỳ mô hình AI nào vào IDE của bạn.', 'Cho phép bạn cắm API Key của Claude, Gemini, GPT-4o, hoặc kết nối local với Ollama để code hoàn toàn miễn phí. Rất được ưa chuộng bởi cộng đồng developer yêu thích mã nguồn mở.', '## Hướng dẫn cấu hình Autopilot nguồn mở Continue.dev\n\n### 1. Cài đặt\n1. Mở VS Code hoặc JetBrains.\n2. Cài đặt extension mang tên **Continue**.\n3. Bạn sẽ thấy biểu tượng chữ **C** lớn xuất hiện ở thanh công cụ bên trái.\n\n### 2. Kết nối với API LLM miễn phí hoặc Local (Ollama)\nFile cấu hình của Continue nằm tại `~/.continue/config.json`. Bạn có thể cấu hình như sau:\n\n* **Kết nối Ollama chạy cục bộ (Offline):**\n```json\n{\n  \"models\": [\n    {\n      \"title\": \"DeepSeek Coder local\",\n      \"provider\": \"ollama\",\n      \"model\": \"deepseek-coder:6.7b\"\n    }\n  ]\n}\n```\n\n* **Kết nối Gemini API (Sử dụng key Free từ Google AI Studio):**\n```json\n{\n  \"models\": [\n    {\n      \"title\": \"Gemini 1.5 Flash\",\n      \"provider\": \"google\",\n      \"model\": \"gemini-1.5-flash\",\n      \"apiKey\": \"API_KEY_GOOGLE_CỦA_BẠN\"\n    }\n  ]\n}\n```', 1, 'https://github.com/continuedev/continue', 1779589276),
(9, 'Supermaven', 'IDE Extension', 'Freemium', 'Bản miễn phí autocomplete tốc độ cao không giới hạn, gói Pro $10/tháng', 'Cực nhanh (Gần như không trễ)', '300k tokens', 9.3, 'Extension autocomplete nhanh nhất thế giới hiện nay với cửa sổ ngữ cảnh cực lớn.', 'Supermaven nổi tiếng với độ trễ phản hồi gần như bằng 0 và sở hữu cửa sổ ngữ cảnh autocomplete lên tới 300.000 tokens giúp hiểu toàn bộ các tệp tin đang mở.', '## Hướng dẫn sử dụng Supermaven - AI Autocomplete siêu tốc độ\n\n### 1. Cài đặt\n1. Mở VS Code, JetBrains hoặc Neovim.\n2. Cài đặt extension **Supermaven**.\n3. Nhấp vào biểu tượng Supermaven ở thanh trạng thái dưới cùng và đăng nhập (hoặc dùng tài khoản miễn phí).\n\n### 2. Mẹo sử dụng\n* Nhấn `Tab` để chấp nhận toàn bộ gợi ý.\n* Nhấn `Alt + ]` để chấp nhận từng từ của gợi ý nếu bạn không muốn lấy toàn bộ đoạn code AI sinh ra.', 1, 'https://supermaven.com', 1779589276),
(10, 'Cody AI', 'IDE Extension', 'Freemium', 'Miễn phí cơ bản hàng tháng, gói Pro $9/tháng', 'Nhanh', 'Không giới hạn (Theo model)', 8.9, 'Trợ lý AI lập trình của Sourcegraph nổi tiếng với khả năng đọc và hiểu ngữ cảnh toàn bộ dự án.', 'Cody sử dụng bộ máy tìm kiếm của Sourcegraph để lập chỉ mục toàn bộ codebase của bạn cục bộ giúp trả lời các câu hỏi về luồng xử lý và sửa lỗi rất thông minh.', '## Hướng dẫn sử dụng Cody AI (Sourcegraph) trong dự án lớn\n\n### 1. Cài đặt\n1. Mở VS Code hoặc JetBrains.\n2. Tìm và cài đặt extension **Cody AI**.\n3. Đăng nhập bằng tài khoản Sourcegraph (miễn phí dùng cơ bản).\n\n### 2. Tính năng đọc hiểu ngữ cảnh Codebase mạnh mẽ\nCody nổi bật nhờ thuật toán nhúng (embeddings) giúp đọc và hiểu toàn bộ cấu trúc thư mục dự án.\n* **Hỏi đáp về codebase:** Mở khung chat Cody, gõ lệnh `@codebase` kèm câu hỏi của bạn. Cody sẽ tự động tìm các file liên quan để trả lời chính xác.\n* **Tự động sinh Unit Test:** Bấm chuột phải vào class/hàm bất kỳ, chọn **Cody > Generate Unit Tests**, AI sẽ tự phân tích file hiện tại và viết test case chuẩn mực cho bạn.', 0, 'https://sourcegraph.com/cody', 1779589276);

--
-- Chỉ mục cho các bảng đã đổ
--

--
-- Chỉ mục cho bảng `ai_tools`
--
ALTER TABLE `ai_tools`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT cho các bảng đã đổ
--

--
-- AUTO_INCREMENT cho bảng `ai_tools`
--
ALTER TABLE `ai_tools`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
