/// Kho câu hỏi đố vui lập trình hàng ngày dành cho lập trình viên (Daily Tech Quiz)
/// Hỗ trợ đa ngôn ngữ đầy đủ (English & Tiếng Việt) kèm giải thích chi tiết.
final List<Map<String, dynamic>> quizQuestions = [
  {
    'question_vi': 'Lệnh nào trong Git được dùng để gộp các commit cũ lại thành một commit duy nhất khi merge?',
    'question_en': 'Which Git command is used to combine multiple commits into a single one during merge?',
    'options': ['git merge --squash', 'git merge --rebase', 'git merge --no-ff', 'git commit --amend'],
    'correct_index': 0,
    'explanation_vi': '`git merge --squash` gộp tất cả các commit từ nhánh phụ thành một commit duy nhất trên nhánh đích, giúp lịch sử Git sạch sẽ.',
    'explanation_en': '`git merge --squash` combines all changes from the source branch into a single commit on the destination branch, keeping Git history clean.'
  },
  {
    'question_vi': 'Trong Flutter, Widget nào hỗ trợ lắng nghe các cử chỉ vuốt, chạm, nhấn đúp mà không có hiệu ứng gợn sóng (ripple effect)?',
    'question_en': 'In Flutter, which Widget handles gestures like tap, swipe, double tap without showing a ripple effect?',
    'options': ['InkWell', 'GestureDetector', 'TextButton', 'IconButton'],
    'correct_index': 1,
    'explanation_vi': '`GestureDetector` dùng để lắng nghe cử chỉ thuần túy không hiệu ứng. `InkWell` có tích hợp hiệu ứng Material ripple.',
    'explanation_en': '`GestureDetector` is used for pure gesture detection without effects. `InkWell` includes Material ripple effects.'
  },
  {
    'question_vi': 'Trong JavaScript, kết quả của biểu thức "[] == ![]" là gì?',
    'question_en': 'In JavaScript, what is the output of "[] == ![]"?',
    'options': ['true', 'false', 'TypeError', 'undefined'],
    'correct_index': 0,
    'explanation_vi': 'Do cơ chế ép kiểu (coercion) của JS: `![]` chuyển thành `false`. Sau đó `[] == false` được so sánh bằng cách chuyển cả hai thành số (đều là `0`), kết quả trả về `true`.',
    'explanation_en': 'Due to JS coercion: `![]` becomes `false`. Then `[] == false` compares their numeric values (both become `0`), resulting in `true`.'
  },
  {
    'question_vi': 'Docker directive nào được sử dụng để tối ưu dung lượng ảnh bằng cách sao chép file từ stage trước đó trong Multi-stage build?',
    'question_en': 'Which Docker directive is used to copy files from a previous build stage in a Multi-stage build?',
    'options': ['COPY --from', 'ADD --from', 'FROM --stage', 'COPY --stage'],
    'correct_index': 0,
    'explanation_vi': '`COPY --from=<stage_name_or_index>` cho phép sao chép các tệp tin sản phẩm (build artifacts) từ một stage build trung gian sang stage chạy tinh gọn cuối cùng.',
    'explanation_en': '`COPY --from=<stage_name_or_index>` allows you to copy built artifacts from an intermediate build stage into the final lightweight image stage.'
  },
  {
    'question_vi': 'Giao thức bảo mật HTTPS sử dụng thuật toán mã hóa nào ở giai đoạn trao đổi khóa thiết lập kết nối ban đầu?',
    'question_en': 'Which encryption method does HTTPS use during the key exchange phase of connection setup?',
    'options': ['Mã hóa bất đối xứng (Asymmetric)', 'Mã hóa đối xứng (Symmetric)', 'Băm (Hashing)', 'Mã hóa lượng tử'],
    'correct_index': 0,
    'explanation_vi': 'HTTPS sử dụng mã hóa bất đối xứng (như RSA hoặc ECC) để thiết lập kết nối an toàn và trao đổi khóa đối xứng. Sau đó, mã hóa đối xứng (như AES) được dùng để truyền dữ liệu thực tế vì hiệu năng cao.',
    'explanation_en': 'HTTPS uses asymmetric encryption (like RSA or ECC) for secure handshake and key exchange. After that, symmetric encryption (like AES) is used for bulk data transfer due to its high speed.'
  },
  {
    'question_vi': 'Ngôn ngữ Dart quản lý bộ nhớ thông qua cơ chế nào?',
    'question_en': 'How does Dart language manage memory allocation and deallocation?',
    'options': ['Garbage Collection (GC)', 'Automatic Reference Counting (ARC)', 'Manual Memory Management', 'Rust-like Ownership & Borrowing'],
    'correct_index': 0,
    'explanation_vi': 'Dart sử dụng cơ chế dọn rác tự động (Garbage Collection) phân thế hệ (Generational GC) rất tối ưu cho việc tạo và hủy widget nhanh chóng trong ứng dụng UI.',
    'explanation_en': 'Dart uses an advanced generational Garbage Collection (GC) mechanism optimized for fast widget creation and destruction in UI applications.'
  },
  {
    'question_vi': 'Trong REST API, mã trạng thái HTTP 409 mang ý nghĩa gì?',
    'question_en': 'In REST API, what does the HTTP status code 409 mean?',
    'options': ['Conflict (Xung đột dữ liệu)', 'Forbidden (Bị cấm truy cập)', 'Unprocessable Entity', 'Bad Request'],
    'correct_index': 0,
    'explanation_vi': 'Mã `409 Conflict` chỉ ra rằng yêu cầu không thể hoàn thành do xung đột với trạng thái hiện tại của tài nguyên (ví dụ: đăng ký tài khoản có email đã tồn tại).',
    'explanation_en': 'The `409 Conflict` code indicates that the request could not be completed due to a conflict with the current state of the resource (e.g., registering an email that already exists).'
  },
  {
    'question_vi': 'Trong SQL, từ khóa nào dùng để lọc kết quả sau khi đã sử dụng GROUP BY?',
    'question_en': 'In SQL, which keyword is used to filter results after grouping with GROUP BY?',
    'options': ['HAVING', 'WHERE', 'FILTER', 'LIMIT'],
    'correct_index': 0,
    'explanation_vi': '`HAVING` được sử dụng thay thế cho `WHERE` để lọc các nhóm được tạo ra bởi mệnh đề `GROUP BY`.',
    'explanation_en': '`HAVING` is used instead of `WHERE` to filter groups created by the `GROUP BY` clause.'
  },
  {
    'question_vi': 'Trong CSS, thuộc tính "position: sticky" hoạt động dựa trên sự kết hợp của hai kiểu vị trí nào?',
    'question_en': 'In CSS, "position: sticky" behaves as a hybrid of which two positioning contexts?',
    'options': ['relative và fixed', 'relative và absolute', 'static và fixed', 'absolute và fixed'],
    'correct_index': 0,
    'explanation_vi': '`sticky` hoạt động như `relative` cho đến khi vị trí cuộn của viewport chạm tới điểm ngưỡng xác định, lúc đó nó chuyển sang hành vi `fixed`.',
    'explanation_en': '`sticky` behaves like `relative` until the scroll position of the viewport reaches a specified threshold, at which point it acts as `fixed`.'
  },
  {
    'question_vi': 'Độ phức tạp thời gian trung bình của thuật toán sắp xếp nhanh (Quick Sort) là gì?',
    'question_en': 'What is the average time complexity of the Quick Sort algorithm?',
    'options': ['O(n log n)', 'O(n^2)', 'O(log n)', 'O(n)'],
    'correct_index': 0,
    'explanation_vi': 'Trung bình Quick Sort phân chia mảng thành hai nửa và sắp xếp, tốn `O(n log n)`. Trường hợp xấu nhất (mảng đã sắp xếp và chọn chốt tệ) là `O(n^2)`.',
    'explanation_en': 'On average, Quick Sort splits the array and sorts, taking `O(n log n)`. The worst-case is `O(n^2)` when pivot choices are poor.'
  },
  {
    'question_vi': 'Phương thức HTTP nào được thiết kế có tính "Idempotent" (Lặp lại nhiều lần không đổi trạng thái tài nguyên trên server)?',
    'question_en': 'Which HTTP method is designed to be Idempotent?',
    'options': ['GET, PUT, DELETE', 'POST, PATCH', 'GET, POST', 'POST, DELETE'],
    'correct_index': 0,
    'explanation_vi': '`GET`, `PUT`, `DELETE` là idempotent vì gọi chúng 1 lần hay nhiều lần liên tiếp đều tạo ra cùng một kết quả trạng thái trên server. `POST` không idempotent vì tạo tài nguyên mới mỗi lần gọi.',
    'explanation_en': '`GET`, `PUT`, and `DELETE` are idempotent because multiple identical requests have the same effect as a single request. `POST` is not idempotent.'
  },
  {
    'question_vi': 'Trong Python, từ khóa "yield" dùng để làm gì?',
    'question_en': 'In Python, what is the purpose of the "yield" keyword?',
    'options': ['Tạo một Generator function', 'Thoát khỏi vòng lặp vô tận', 'Bắt ngoại lệ runtime', 'Định nghĩa một hằng số'],
    'correct_index': 0,
    'explanation_vi': '`yield` tạm dừng thực thi hàm và trả về một giá trị cho người gọi, đồng thời lưu trạng thái để có thể tiếp tục chạy từ vị trí đó khi được gọi tiếp (tạo ra Generator).',
    'explanation_en': '`yield` suspends function execution and returns a value to the caller, saving state to resume from that point, creating a Generator.'
  },
  {
    'question_vi': 'Trong Git, làm cách nào để hủy bỏ hoàn toàn các thay đổi chưa commit ở thư mục làm việc (working directory)?',
    'question_en': 'In Git, how do you discard all uncommitted changes in your working directory?',
    'options': ['git reset --hard HEAD', 'git reset --soft HEAD', 'git clean -f', 'git checkout -- .'],
    'correct_index': 0,
    'explanation_vi': '`git reset --hard HEAD` xóa bỏ tất cả các thay đổi ở cả Stage area và Working directory, đưa code về trạng thái của commit HEAD gần nhất.',
    'explanation_en': '`git reset --hard HEAD` discards all changes in both the staging area and working directory, reverting code to the latest commit.'
  },
  {
    'question_vi': 'Định dạng mã hóa ký tự mặc định của file mã nguồn Python 3 là gì?',
    'question_en': 'What is the default character encoding for Python 3 source files?',
    'options': ['UTF-8', 'ASCII', 'ISO-8859-1', 'UTF-16'],
    'correct_index': 0,
    'explanation_vi': 'Python 3 mặc định đọc và xử lý file nguồn bằng chuẩn UTF-8, cho phép viết các ký tự unicode trực tiếp trong code một cách tự nhiên.',
    'explanation_en': 'Python 3 encodes source files using UTF-8 by default, allowing unicode characters to be written directly in the code.'
  },
  {
    'question_vi': 'Trong các loại Index của MySQL, loại nào giúp tìm kiếm các từ khóa văn bản dài hiệu quả nhất?',
    'question_en': 'Which type of index in MySQL is most efficient for searching long text keywords?',
    'options': ['FULLTEXT', 'B-TREE', 'HASH', 'SPATIAL'],
    'correct_index': 0,
    'explanation_vi': '`FULLTEXT` index cho phép tìm kiếm từ khóa phức tạp (như tìm kiếm tương tự, tách từ) trên các cột văn bản lớn như CHAR, VARCHAR, TEXT.',
    'explanation_en': '`FULLTEXT` indexes enable keyword search (like match and natural language search) on char, varchar, or text columns.'
  },
  {
    'question_vi': 'Trong MongoDB, công cụ nào được dùng để phân tích hiệu năng và cách thực thi của một truy vấn SQL-like?',
    'question_en': 'In MongoDB, which method is used to analyze the execution performance of a query?',
    'options': ['explain()', 'profile()', 'analyze()', 'hint()'],
    'correct_index': 0,
    'explanation_vi': 'Phương thức `explain()` trả về thông tin chi tiết về kế hoạch thực thi câu lệnh (execution plan), chỉ số index được sử dụng và số tài liệu đã quét.',
    'explanation_en': 'The `explain()` method returns details on the query execution plan, index usage, and number of scanned documents.'
  },
  {
    'question_vi': 'Mục tiêu chính của kỹ thuật Multi-stage build trong Dockerfile là gì?',
    'question_en': 'What is the primary goal of Multi-stage builds in Dockerfiles?',
    'options': ['Giảm dung lượng ảnh Docker cuối cùng', 'Tăng tốc độ build container', 'Cho phép chạy nhiều container song song', 'Bảo mật cổng mạng nội bộ'],
    'correct_index': 0,
    'explanation_vi': 'Multi-stage build tách biệt môi trường build (chứa compiler, SDK nặng) và môi trường run (chỉ chứa file chạy), giúp giảm đáng kể kích thước Image.',
    'explanation_en': 'Multi-stage builds separate the build environment (containing heavy SDKs) from the runtime environment, dramatically reducing final image size.'
  },
  {
    'question_vi': 'Trong Dart, sự khác biệt chính giữa "const" và "final" là gì?',
    'question_en': 'In Dart, what is the key difference between "const" and "final"?',
    'options': ['const được gán ở compile-time, final gán ở run-time', 'final được gán ở compile-time, const gán ở run-time', 'const có thể thay đổi giá trị, final thì không', 'Không có sự khác biệt nào'],
    'correct_index': 0,
    'explanation_vi': '`const` là hằng số biên dịch (compile-time constant) được xác định ngay khi build. `final` là hằng số chạy (run-time constant) được gán duy nhất một lần khi chạy.',
    'explanation_en': '`const` defines compile-time constants. `final` variables can only be set once but their values are determined at runtime.'
  },
  {
    'question_vi': 'Trong lập trình hướng đối tượng, nguyên lý L trong SOLID viết tắt của từ gì?',
    'question_en': 'In Object-Oriented Design, what does the letter L in SOLID stand for?',
    'options': ['Liskov Substitution Principle', 'Least Common Interface', 'Loose Coupling Principle', 'Layered Architecture Principle'],
    'correct_index': 0,
    'explanation_vi': 'Nguyên lý thay thế Liskov phát biểu rằng các đối tượng của lớp con phải có thể thay thế cho các đối tượng của lớp cha mà không làm hỏng tính đúng đắn của chương trình.',
    'explanation_en': 'The Liskov Substitution Principle states that subclasses must be substitutable for their superclasses without affecting program correctness.'
  },
  {
    'question_vi': 'Giao thức WebSocket hoạt động ở tầng nào trong mô hình OSI?',
    'question_en': 'At which layer of the OSI model does the WebSocket protocol operate?',
    'options': ['Tầng ứng dụng (Application)', 'Tầng giao vận (Transport)', 'Tầng mạng (Network)', 'Tầng liên kết dữ liệu (Data Link)'],
    'correct_index': 0,
    'explanation_vi': 'WebSocket là một giao thức tầng ứng dụng (Application Layer), thiết lập kết nối hai chiều liên tục trên cùng một kết nối TCP duy nhất.',
    'explanation_en': 'WebSocket is an application layer protocol providing full-duplex communication channels over a single TCP connection.'
  },
  {
    'question_vi': 'Trong Kubernetes, đối tượng nào được sử dụng để quản lý các ứng dụng có lưu trạng thái (Stateful Applications) yêu cầu định danh duy nhất?',
    'question_en': 'In Kubernetes, which resource is used to manage stateful applications that require unique identities?',
    'options': ['StatefulSet', 'Deployment', 'ReplicaSet', 'DaemonSet'],
    'correct_index': 0,
    'explanation_vi': '`StatefulSet` quản lý việc triển khai tập hợp các Pods có lưu trạng thái, gán định danh duy nhất và duy trì thứ tự khởi động/tắt cho từng Pod.',
    'explanation_en': '`StatefulSet` is the workload API object used to manage stateful applications, maintaining a sticky identity for each of their Pods.'
  },
  {
    'question_vi': 'Cơ sở dữ liệu Redis lưu trữ dữ liệu chính ở vùng nhớ nào để đạt tốc độ truy xuất cực nhanh?',
    'question_en': 'Where does Redis primarily store its data to achieve high-speed access?',
    'options': ['RAM (Bộ nhớ trong)', 'Ổ cứng SSD', 'Bộ nhớ đệm CPU L2', 'Ổ đĩa mạng SAN'],
    'correct_index': 0,
    'explanation_vi': 'Redis là hệ thống lưu trữ cấu trúc dữ liệu trong bộ nhớ (In-memory database), lưu toàn bộ dữ liệu trên RAM để có thời gian phản hồi ở mức micro giây.',
    'explanation_en': 'Redis is an in-memory data store, keeping all dataset in RAM to provide sub-millisecond response times.'
  },
  {
    'question_vi': 'Trong hệ điều hành Linux, câu lệnh nào được dùng để theo dõi tài nguyên hệ thống (CPU, RAM, Processes) theo thời gian thực?',
    'question_en': 'In Linux, which command is used to monitor system resources (CPU, RAM, Processes) in real-time?',
    'options': ['top hoặc htop', 'ps -ef', 'df -h', 'free -m'],
    'correct_index': 0,
    'explanation_vi': '`top` và `htop` hiển thị động các tiến trình đang chạy và mức độ sử dụng tài nguyên hệ thống theo thời gian thực tế.',
    'explanation_en': '`top` and `htop` provide a dynamic real-time view of running processes and system resource utilization.'
  },
  {
    'question_vi': 'Trong TypeScript, từ khóa "unknown" khác gì với "any"?',
    'question_en': 'In TypeScript, what is the main difference between "unknown" and "any"?',
    'options': ['unknown an toàn kiểu hơn, bắt buộc phải ép kiểu hoặc kiểm tra kiểu trước khi dùng', 'any an toàn kiểu hơn unknown', 'Không có sự khác biệt', 'unknown chỉ dùng cho kiểu nguyên thủy'],
    'correct_index': 0,
    'explanation_vi': '`unknown` là phiên bản an toàn của `any`. Bạn không thể thực hiện hành động nào trên kiểu `unknown` mà chưa thu hẹp kiểu (Type Narrowing) hoặc ép kiểu.',
    'explanation_en': '`unknown` is type-safe: you cannot perform operations on an `unknown` value without first asserting or narrowing its type.'
  },
  {
    'question_vi': 'Lỗ hổng bảo mật SQL Injection xảy ra do nguyên nhân cốt lõi nào?',
    'question_en': 'What is the root cause of SQL Injection vulnerability?',
    'options': ['Nối chuỗi trực tiếp đầu vào từ người dùng vào câu truy vấn SQL mà không sanitize', 'Cấu hình cổng database public ra ngoài', 'Không cài đặt HTTPS cho trang web', 'Sử dụng hệ quản trị cơ sở dữ liệu phiên bản cũ'],
    'correct_index': 0,
    'explanation_vi': 'SQL Injection xảy ra khi dữ liệu đầu vào chưa được kiểm duyệt được ghép thẳng vào chuỗi câu lệnh SQL, cho phép kẻ tấn công thay đổi logic câu truy vấn. Sử dụng Parameterized Queries giúp ngăn chặn triệt để.',
    'explanation_en': 'SQL Injection happens when user input is concatenated directly into SQL query strings without sanitization, allowing attackers to manipulate queries.'
  },
  {
    'question_vi': 'Nguyên lý thiết kế "Dependency Inversion" (chữ D trong SOLID) khuyên chúng ta nên phụ thuộc vào điều gì?',
    'question_en': 'What does the Dependency Inversion Principle (D in SOLID) advise us to depend on?',
    'options': ['Các lớp Trừu tượng (Abstractions)', 'Các lớp Cụ thể (Concretions)', 'Các thư viện bên thứ ba', 'Hệ điều hành bên dưới'],
    'correct_index': 0,
    'explanation_vi': 'Nguyên lý quy định: Các mô-đun cấp cao không nên phụ thuộc vào các mô-đun cấp thấp; cả hai nên phụ thuộc vào sự trừu tượng (Interface hoặc Abstract class).',
    'explanation_en': 'It states that high-level modules should not depend on low-level modules; both should depend on abstractions.'
  },
  {
    'question_vi': 'Trong mạng máy tính, giao thức DNS (Domain Name System) mặc định sử dụng cổng (Port) nào và giao thức truyền tải nào?',
    'question_en': 'In computer networking, which default port and transport protocol does DNS use?',
    'options': ['Port 53 qua UDP', 'Port 80 qua TCP', 'Port 443 qua TCP', 'Port 22 qua UDP'],
    'correct_index': 0,
    'explanation_vi': 'DNS sử dụng cổng 53 qua giao thức UDP cho các truy vấn thông thường vì tốc độ nhanh. TCP được dùng khi gói tin phản hồi vượt quá 512 bytes hoặc khi truyền vùng (zone transfer).',
    'explanation_en': 'DNS primarily uses port 53 over UDP for quick query-response times, falling back to TCP for large transfers.'
  },
  {
    'question_vi': 'Trong lập trình Java, từ khóa "transient" dùng để đánh dấu thuộc tính nào?',
    'question_en': 'In Java programming, what does the "transient" keyword mean when applied to a field?',
    'options': ['Thuộc tính đó sẽ không được tuần tự hóa (Serialization)', 'Thuộc tính đó là hằng số', 'Thuộc tính đó an toàn luồng (Thread-safe)', 'Thuộc tính đó lưu trữ trên cache CPU'],
    'correct_index': 0,
    'explanation_vi': 'Từ khóa `transient` báo hiệu cho JVM biết thuộc tính này không nên được ghi lại khi đối tượng được chuyển đổi sang dạng byte stream (Serialization).',
    'explanation_en': 'The `transient` keyword in Java is used to indicate that a field should not be serialized when the class instance is serialized.'
  },
  {
    'question_vi': 'Trong mô hình kiến trúc MVC, thành phần nào chịu trách nhiệm giao tiếp trực tiếp với cơ sở dữ liệu và xử lý nghiệp vụ chính?',
    'question_en': 'In the MVC architectural pattern, which component interacts directly with the database and processes business logic?',
    'options': ['Model', 'View', 'Controller', 'Router'],
    'correct_index': 0,
    'explanation_vi': '`Model` đại diện cho cấu trúc dữ liệu và xử lý logic nghiệp vụ, trực tiếp tương tác với Database để truy vấn và lưu trữ dữ liệu.',
    'explanation_en': '`Model` manages the behavior and data of the application domain, directly querying and updating the database.'
  },
  {
    'question_vi': 'Thuật toán mã hóa đối xứng (Symmetric Encryption) nổi tiếng và được sử dụng rộng rãi nhất hiện nay cho bảo mật thương mại là gì?',
    'question_en': 'Which symmetric key encryption algorithm is currently the most widely used standard for secure data?',
    'options': ['AES', 'RSA', 'MD5', 'SHA-256'],
    'correct_index': 0,
    'explanation_vi': 'AES (Advanced Encryption Standard) là chuẩn mã hóa đối xứng phổ biến nhất, cực kỳ an toàn và được hỗ trợ tăng tốc phần cứng trên hầu hết CPU hiện đại.',
    'explanation_en': 'AES (Advanced Encryption Standard) is the global standard for symmetric encryption, selected by NIST for its high security and speed.'
  },
  {
    'question_vi': 'Trong Git, lệnh "git cherry-pick" dùng để làm gì?',
    'question_en': 'In Git, what does "git cherry-pick" do?',
    'options': ['Áp dụng một thay đổi của một commit cụ thể từ nhánh khác vào nhánh hiện tại', 'Xóa bỏ một commit đã đẩy lên server', 'Gộp nhiều nhánh thành một nhánh', 'Tạo ra một commit rỗng để test CI'],
    'correct_index': 0,
    'explanation_vi': '`git cherry-pick <commit-hash>` cho phép chọn một commit cụ thể từ một nhánh bất kỳ và áp dụng chính xác các thay đổi của commit đó vào nhánh làm việc hiện tại.',
    'explanation_en': '`git cherry-pick` applies the changes introduced by some existing commits onto the current working branch.'
  },
  {
    'question_vi': 'Trong các cơ sở dữ liệu quan hệ, thuộc tính ACID nào đảm bảo rằng một giao dịch (Transaction) hoặc là thành công hoàn toàn hoặc là rollback không để lại dấu vết?',
    'question_en': 'In relational databases, which ACID property guarantees that a transaction is either fully completed or rolled back completely?',
    'options': ['Atomicity (Tính khả phân)', 'Consistency (Tính nhất quán)', 'Isolation (Tính cô lập)', 'Durability (Tính bền vững)'],
    'correct_index': 0,
    'explanation_vi': '`Atomicity` (Tính khả phân/Tính nguyên tử) đảm bảo giao dịch hoạt động như một đơn vị duy nhất: tất cả các lệnh SQL thực hiện thành công, hoặc không lệnh nào được áp dụng.',
    'explanation_en': '`Atomicity` ensures that all operations within a work unit are completed successfully; otherwise, the transaction is aborted and rolled back.'
  },
  {
    'question_vi': 'Trong Python, sự khác biệt giữa list và tuple là gì?',
    'question_en': 'In Python, what is the main difference between a list and a tuple?',
    'options': ['List có thể thay đổi (mutable), Tuple không thể thay đổi (immutable)', 'Tuple có thể thay đổi, List thì không', 'List có hiệu năng truy xuất nhanh hơn Tuple', 'Tuple dùng ngoặc vuông, List dùng ngoặc tròn'],
    'correct_index': 0,
    'explanation_vi': 'List là kiểu dữ liệu mutable (cho phép thêm/sửa/xóa phần tử sau khi tạo). Tuple là immutable (cố định kích thước và giá trị sau khi tạo), giúp an toàn dữ liệu và tối ưu bộ nhớ.',
    'explanation_en': 'Lists are mutable (can be changed after creation), whereas tuples are immutable (read-only).'
  },
  {
    'question_vi': 'Khái niệm "Deadlock" trong lập trình đa luồng (Multithreading) xảy ra khi nào?',
    'question_en': 'When does a "Deadlock" occur in multithreading?',
    'options': ['Hai hoặc nhiều tiến trình cùng chờ đợi lẫn nhau giải phóng tài nguyên vô thời hạn', 'Hệ điều hành bị hết dung lượng RAM', 'Mạng kết nối bị ngắt đột ngột', 'Có lỗi cú pháp trong hàm đồng bộ hóa'],
    'correct_index': 0,
    'explanation_vi': 'Deadlock xảy ra khi tiến trình A giữ tài nguyên X và đợi tài nguyên Y; đồng thời tiến trình B đang giữ tài nguyên Y và đợi tài nguyên X. Cả hai chờ nhau vô hạn.',
    'explanation_en': 'Deadlock occurs when two or more threads are blocked forever, each waiting for the resource held by the other.'
  },
  {
    'question_vi': 'Trong Docker, lệnh "docker system prune" dùng để làm gì?',
    'question_en': 'In Docker, what is the purpose of the "docker system prune" command?',
    'options': ['Dọn dẹp các container đã dừng, network không dùng, image rác và build cache', 'Xóa toàn bộ engine Docker khỏi máy tính', 'Cập nhật hệ điều hành cho tất cả container đang chạy', 'Khởi động lại dịch vụ Docker'],
    'correct_index': 0,
    'explanation_vi': 'Lệnh này giúp giải phóng dung lượng ổ cứng bằng cách xóa sạch container đã dừng, volume không dùng, các dangling images và cache build cũ.',
    'explanation_en': '`docker system prune` removes stopped containers, unused networks, dangling images, and build cache to reclaim disk space.'
  },
  {
    'question_vi': 'Trong thiết kế API, cơ chế "Rate Limiting" được dùng để làm gì?',
    'question_en': 'In API design, what is the primary purpose of "Rate Limiting"?',
    'options': ['Hạn chế số lượng yêu cầu mà một client có thể gửi trong một khoảng thời gian nhất định', 'Tăng tốc độ phản hồi của API', 'Mã hóa dữ liệu truyền tải', 'Phân quyền người dùng dựa trên vai trò'],
    'correct_index': 0,
    'explanation_vi': 'Rate Limiting giới hạn tần suất yêu cầu để bảo vệ hệ thống khỏi các cuộc tấn công từ chối dịch vụ (DoS), cào dữ liệu quá mức hoặc spam API.',
    'explanation_en': '`rate limiting` controls the rate of traffic sent or received by a network interface or API to prevent abuse and DDoS.'
  },
  {
    'question_vi': 'Lợi ích lớn nhất của việc sử dụng Connection Pool khi kết nối Database trong ứng dụng backend là gì?',
    'question_en': 'What is the main benefit of using a Connection Pool in a backend application?',
    'options': ['Tránh việc liên tục tạo mới và đóng kết nối TCP đắt đỏ tới Database', 'Mã hóa tự động dữ liệu lưu trữ', 'Tự động sửa lỗi cú pháp SQL', 'Phân tán dữ liệu ra nhiều server khác nhau'],
    'correct_index': 0,
    'explanation_vi': 'Việc thiết lập kết nối Database (gồm handshake TCP, xác thực) tốn nhiều tài nguyên. Connection Pool giữ các kết nối mở sẵn để tái sử dụng giúp tăng đáng kể hiệu năng ứng dụng.',
    'explanation_en': 'Connection pools reuse active database connections instead of establishing new ones for every query, reducing latency.'
  },
  {
    'question_vi': 'Trong JavaScript, sự khác biệt giữa toán tử "==" và "===" là gì?',
    'question_en': 'In JavaScript, what is the difference between the "==" and "===" operators?',
    'options': ['"==" so sánh giá trị sau khi ép kiểu, "===" so sánh cả giá trị và kiểu dữ liệu', '"===" so sánh giá trị sau khi ép kiểu, "==" so sánh cả kiểu dữ liệu', 'Không có sự khác biệt', '"===" chỉ dùng cho so sánh đối tượng'],
    'correct_index': 0,
    'explanation_vi': 'Toán tử `==` thực hiện ép kiểu tự động (coercion) trước khi so sánh. Toán tử `===` so sánh nghiêm ngặt (strict equality), trả về false nếu kiểu dữ liệu khác nhau.',
    'explanation_en': '`==` compares value after type coercion, while `===` checks both type and value without coercion.'
  },
  {
    'question_vi': 'Trong kiến trúc Microservices, thành phần "API Gateway" đóng vai trò gì?',
    'question_en': 'In Microservices architecture, what is the role of an "API Gateway"?',
    'options': ['Là cổng đầu mối duy nhất nhận mọi request từ client và phân phối đến microservices tương ứng', 'Là cơ sở dữ liệu tập trung lưu trữ toàn bộ log hệ thống', 'Là dịch vụ kiểm thử code tự động', 'Là máy chủ lưu trữ file tĩnh'],
    'correct_index': 0,
    'explanation_vi': 'API Gateway hoạt động như một reverse proxy, tiếp nhận mọi request, thực hiện các tác vụ chung như xác thực, phân tải, định tuyến và giới hạn tần suất gửi tin.',
    'explanation_en': 'API Gateway sits between clients and services, routing requests, handling authentication, SSL termination, and rate limiting.'
  },
  {
    'question_vi': 'Độ phức tạp thời gian khi tìm kiếm phần tử trên cây nhị phân tìm kiếm cân bằng (AVL hoặc Red-Black Tree) là bao nhiêu?',
    'question_en': 'What is the time complexity of searching an element in a balanced binary search tree?',
    'options': ['O(log n)', 'O(n)', 'O(n log n)', 'O(1)'],
    'correct_index': 0,
    'explanation_vi': 'Nhờ cấu trúc cân bằng, chiều cao của cây luôn được duy trì ở mức xấp xỉ log2(n), giúp các thao tác tìm kiếm, thêm, xóa chỉ tốn thời gian `O(log n)`.',
    'explanation_en': 'In a balanced BST, search space is halved at each step, resulting in a time complexity of `O(log n)`.'
  },
  {
    'question_vi': 'Trong CSS, sự khác biệt giữa hai đơn vị đo lường "em" và "rem" là gì?',
    'question_en': 'In CSS, what is the key difference between "em" and "rem" units?',
    'options': ['"em" tính theo cỡ chữ của phần tử cha, "rem" tính theo cỡ chữ của phần tử gốc html', '"rem" tính theo cỡ chữ của phần tử cha, "em" tính theo html', '"em" là đơn vị tuyệt đối, "rem" là đơn vị tỷ lệ màn hình', 'Không có sự khác biệt'],
    'correct_index': 0,
    'explanation_vi': '`em` tính tương đối dựa trên cỡ chữ (font-size) kế thừa từ phần tử cha trực tiếp. `rem` (root em) tính tương đối dựa trên cỡ chữ của thẻ gốc html (mặc định thường là 16px).',
    'explanation_en': '`em` is relative to the font-size of its parent element, while `rem` is relative to the font-size of the root `<html>` element.'
  },
  {
    'question_vi': 'Trong phát triển phần mềm, kỹ thuật CI/CD (Continuous Integration / Continuous Delivery) giải quyết bài toán lớn nhất nào?',
    'question_en': 'In software engineering, what is the main problem solved by CI/CD?',
    'options': ['Tự động hóa hoàn toàn quy trình tích hợp, kiểm thử và triển khai mã nguồn', 'Tự động viết tài liệu dự án bằng AI', 'Tự động tối ưu thuật toán trong mã nguồn', 'Hạn chế lập trình viên viết code sai cú pháp'],
    'correct_index': 0,
    'explanation_vi': 'CI/CD tự động hóa việc build, chạy test, đóng gói và deploy code lên server, giảm thiểu sai sót thủ công của con người và đẩy nhanh tiến độ release.',
    'explanation_en': 'CI/CD automates integration, testing, and deployment processes, enabling faster, more reliable software releases.'
  },
  {
    'question_vi': 'Trong lập trình Go (Golang), cơ chế "Goroutine" tiêu tốn khoảng bao nhiêu dung lượng bộ nhớ stack ban đầu?',
    'question_en': 'In Go (Golang), about how much stack memory does a Goroutine consume initially?',
    'options': ['Khoảng 2 KB', 'Khoảng 1 MB', 'Khoảng 8 MB', 'Khoảng 512 bytes'],
    'correct_index': 0,
    'explanation_vi': 'Một Goroutine khởi tạo cực nhẹ, chỉ tốn khoảng 2 KB bộ nhớ stack và có thể co giãn động. Điều này giúp Go chạy hàng vạn Goroutine đồng thời mà không bị cạn bộ nhớ như OS Thread thông thường (thường tốn 1MB-8MB).',
    'explanation_en': 'A goroutine starts with a small stack of only 2 KB, which grows and shrinks as needed, allowing millions of concurrent tasks.'
  },
  {
    'question_vi': 'Mẫu thiết kế (Design Pattern) nào cung cấp một cổng giao tiếp duy nhất để khởi tạo một đối tượng duy nhất trong suốt vòng đời ứng dụng?',
    'question_en': 'Which design pattern restricts the instantiation of a class to one single instance?',
    'options': ['Singleton Pattern', 'Factory Pattern', 'Builder Pattern', 'Observer Pattern'],
    'correct_index': 0,
    'explanation_vi': '`Singleton Pattern` đảm bảo một class chỉ có duy nhất một instance toàn cục và cung cấp một điểm truy cập tĩnh duy nhất tới nó.',
    'explanation_en': '`Singleton` ensures that a class has only one instance and provides a global point of access to it.'
  },
  {
    'question_vi': 'Thuật toán băm (Hashing) nào sau đây được coi là an toàn nhất hiện nay để lưu trữ Mật khẩu người dùng trong cơ sở dữ liệu?',
    'question_en': 'Which hashing algorithm is currently recommended as secure for storing user Passwords?',
    'options': ['bcrypt hoặc Argon2', 'MD5', 'SHA-1', 'SHA-256'],
    'correct_index': 0,
    'explanation_vi': 'MD5 và SHA-1 bị bẻ khóa dễ dàng. SHA-256 chạy quá nhanh nên dễ bị dò mật khẩu (brute-force). `bcrypt` hoặc `Argon2` sử dụng kỹ thuật kéo giãn key (key stretching) và salt ngẫu nhiên giúp chống tấn công hiệu quả.',
    'explanation_en': '`bcrypt` and `Argon2` use key stretching and slow-hashing techniques to prevent brute-force and rainbow table attacks.'
  },
  {
    'question_vi': 'Trong lập trình C++, khái niệm "Smart Pointer" nào cho phép nhiều con trỏ cùng sở hữu chung một tài nguyên vùng nhớ?',
    'question_en': 'In C++, which smart pointer allows multiple pointers to own the same resource?',
    'options': ['std::shared_ptr', 'std::unique_ptr', 'std::weak_ptr', 'std::auto_ptr'],
    'correct_index': 0,
    'explanation_vi': '`std::shared_ptr` quản lý tài nguyên thông qua đếm số tham chiếu (reference counting). Khi số tham chiếu giảm về 0, tài nguyên vùng nhớ sẽ tự động được giải phóng.',
    'explanation_en': '`std::shared_ptr` retains shared ownership of a resource through a reference counter, freeing it when the count reaches zero.'
  },
  {
    'question_vi': 'Trong cơ sở dữ liệu, việc lập chỉ mục (Indexing) giúp tăng tốc độ truy vấn SELECT nhưng lại làm chậm thao tác nào?',
    'question_en': 'In databases, indexing speeds up SELECT queries but slows down which operations?',
    'options': ['INSERT, UPDATE, DELETE', 'JOIN, GROUP BY', 'Lưu trữ file log', 'Không làm chậm thao tác nào'],
    'correct_index': 0,
    'explanation_vi': 'Mỗi khi dữ liệu thay đổi (thêm, sửa, xóa), cơ sở dữ liệu phải cập nhật lại cấu trúc cây index tương ứng, dẫn tới giảm hiệu năng của các thao tác ghi.',
    'explanation_en': 'Every INSERT, UPDATE, or DELETE operation requires the database to update index structures, causing write overhead.'
  },
  {
    'question_vi': 'Giao thức DNS hoạt động trên cổng mặc định nào?',
    'question_en': 'Which port does DNS run on by default?',
    'options': ['53', '80', '443', '21'],
    'correct_index': 0,
    'explanation_vi': 'Giao thức hệ thống tên miền (DNS) mặc định lắng nghe và trao đổi thông tin truy vấn IP thông qua cổng 53.',
    'explanation_en': 'The Domain Name System (DNS) protocol uses port 53 for name resolution queries.'
  },
  {
    'question_vi': 'Trong phát triển Web, kỹ thuật CORS (Cross-Origin Resource Sharing) được dùng để làm gì?',
    'question_en': 'In Web development, what is CORS used for?',
    'options': ['Cho phép trình duyệt gửi yêu cầu HTTP đến một domain khác với domain của trang hiện tại một cách an toàn', 'Tự động nén ảnh trên website', 'Quản lý cookie của người dùng', 'Chống tấn công từ chối dịch vụ'],
    'correct_index': 0,
    'explanation_vi': 'CORS là một cơ chế bảo mật của trình duyệt cho phép tài nguyên trên một trang web được yêu cầu từ một tên miền (origin) khác bên ngoài.',
    'explanation_en': 'CORS is a browser security mechanism that allows web pages to request resources from a domain different from the original domain.'
  },
  {
    'question_vi': 'Trong cấu trúc dữ liệu, cấu trúc nào hoạt động theo nguyên lý LIFO (Last In, First Out)?',
    'question_en': 'Which data structure operates on the LIFO (Last In, First Out) principle?',
    'options': ['Stack (Ngăn xếp)', 'Queue (Hàng đợi)', 'Linked List (Danh sách liên kết)', 'Heap'],
    'correct_index': 0,
    'explanation_vi': '`Stack` hoạt động theo cơ chế LIFO: phần tử được thêm vào sau cùng (Push) sẽ là phần tử đầu tiên được lấy ra khỏi ngăn xếp (Pop).',
    'explanation_en': 'A `Stack` operates on LIFO principle, where the last added element is the first one to be removed.'
  },
  {
    'question_vi': 'Sự khác biệt cốt lõi giữa hai giao thức kiến trúc API là REST và SOAP là gì?',
    'question_en': 'What is the core difference between REST and SOAP API architectures?',
    'options': ['SOAP là giao thức chuẩn dựa trên XML nghiêm ngặt, REST là phong cách kiến trúc hỗ trợ nhiều định dạng như JSON', 'REST bảo mật hơn SOAP', 'SOAP chạy nhanh hơn REST', 'REST bắt buộc sử dụng XML làm body'],
    'correct_index': 0,
    'explanation_vi': 'SOAP là giao thức định nghĩa cấu trúc tin nghiêm ngặt bằng XML thông qua chuẩn WSDL. REST linh hoạt hơn, chỉ là phong cách thiết kế, hỗ trợ truyền tải cả JSON, XML, Plain Text.',
    'explanation_en': 'SOAP is a strict protocol based on XML. REST is an architectural style that supports JSON, XML, and other formats.'
  },
  {
    'question_vi': 'Trong phân quyền OAuth2, "Implicit Grant Type" đã bị phản đối (deprecated) vì lý do bảo mật chính nào?',
    'question_en': 'In OAuth2, why has the "Implicit Grant Type" been deprecated?',
    'options': ['Access Token được trả về trực tiếp qua URL của trình duyệt, dễ bị rò rỉ qua log/history', 'Nó chạy quá chậm', 'Nó không hỗ trợ HTTPS', 'Nó yêu cầu client secret lưu trên app di động'],
    'correct_index': 0,
    'explanation_vi': 'Vì luồng Implicit trả token trực tiếp qua redirection URI (trên browser), dễ bị tấn công đánh cắp token. Luồng an toàn thay thế là Authorization Code kèm PKCE.',
    'explanation_en': 'Because the Access Token is returned directly in the redirect URI, exposing it to leak via browser logs and history.'
  },
  {
    'question_vi': 'Trong cấu trúc của một JSON Web Token (JWT), ba phần cấu thành được phân tách nhau bằng ký tự nào?',
    'question_en': 'In a JSON Web Token (JWT), which character is used to separate the three parts?',
    'options': ['Dấu chấm (.)', 'Dấu gạch ngang (-)', 'Dấu hai chấm (:)', 'Dấu gạch chéo (/)'],
    'correct_index': 0,
    'explanation_vi': 'Một chuỗi JWT gồm 3 phần: Header, Payload và Signature được mã hóa Base64Url và phân cách bằng dấu chấm `.`.',
    'explanation_en': 'A JWT consists of Header, Payload, and Signature, separated by dots (.).'
  },
  {
    'question_vi': 'Lệnh nào trong Git cho phép lưu tạm các thay đổi chưa commit để lấy code mới về, sau đó khôi phục lại các thay đổi đó?',
    'question_en': 'Which Git command allows you to temporarily shelve uncommitted changes to pull new code, then restore them?',
    'options': ['git stash', 'git checkout', 'git commit --amend', 'git merge --abort'],
    'correct_index': 0,
    'explanation_vi': '`git stash` đưa các thay đổi chưa commit vào hàng đợi tạm thời. Dùng `git stash pop` để khôi phục và áp dụng lại sau đó.',
    'explanation_en': '`git stash` temporarily shelves changes. Use `git stash pop` to apply them back later.'
  },
  {
    'question_vi': 'Web server Nginx thường được sử dụng làm "Reverse Proxy". Khái niệm này nghĩa là gì?',
    'question_en': 'What does using Nginx as a "Reverse Proxy" mean?',
    'options': ['Nhận request từ internet và chuyển tiếp tới các máy chủ backend nội bộ phù hợp', 'Mã hóa ổ cứng của web server', 'Tự động kiểm tra lỗi code PHP', 'Hạn chế quyền root của hệ điều hành'],
    'correct_index': 0,
    'explanation_vi': 'Reverse Proxy đứng trước các máy chủ backend, tiếp nhận mọi request từ client, điều phối, load balancing, bảo vệ hạ tầng nội bộ và trả kết quả về.',
    'explanation_en': 'A reverse proxy accepts client requests, forwards them to backend servers, and returns the server\'s response to clients.'
  },
  {
    'question_vi': 'Quyền truy cập tệp tin "chmod 755" trong Linux cấp quyền gì cho các đối tượng?',
    'question_en': 'What permissions does "chmod 755" assign in Linux?',
    'options': ['Owner có toàn quyền, Group và Others có quyền Đọc và Thực thi', 'Tất cả mọi người có toàn quyền', 'Owner có quyền Đọc, Others có quyền Ghi', 'Không ai có quyền Thực thi'],
    'correct_index': 0,
    'explanation_vi': '7 (rwx - đọc ghi chạy) cho Owner. 5 (r-x - đọc chạy) cho Group. 5 (r-x - đọc chạy) cho Others.',
    'explanation_en': '7 (rwx) for owner, 5 (r-x) for group, and 5 (r-x) for others.'
  },
  {
    'question_vi': 'Tại sao lớp cha (Base Class) trong C++ luôn cần định nghĩa hàm hủy là ảo (virtual destructor)?',
    'question_en': 'Why should a Base Class in C++ always define a virtual destructor?',
    'options': ['Đảm bảo hàm hủy của lớp con được gọi đúng cách khi giải phóng đối tượng bằng con trỏ lớp cha', 'Để tăng tốc độ biên dịch chương trình', 'Để cho phép kế thừa nhiều lớp cha cùng lúc', 'Để bắt buộc lớp con phải viết hàm hủy'],
    'correct_index': 0,
    'explanation_vi': 'Nếu không khai báo `virtual`, khi xóa đối tượng lớp con qua con trỏ lớp cha, chỉ hàm hủy lớp cha được gọi, gây rò rỉ bộ nhớ (memory leak) của lớp con.',
    'explanation_en': 'Without a virtual destructor, deleting a derived class object through a base class pointer causes undefined behavior (memory leaks).'
  },
  {
    'question_vi': 'Trong các cơ sở dữ liệu quan hệ, phép nối "CROSS JOIN" trả về kết quả gì?',
    'question_en': 'In relational databases, what does a "CROSS JOIN" return?',
    'options': ['Tích Descartes của hai bảng (mọi hàng của bảng A kết hợp với mọi hàng của bảng B)', 'Chỉ các hàng trùng nhau giữa hai bảng', 'Tất cả các hàng của bảng bên trái', 'Toàn bộ các hàng của bảng bên phải'],
    'correct_index': 0,
    'explanation_vi': 'CROSS JOIN tạo ra tích Descartes (Cartesian product): Số dòng trả về bằng tích số dòng của bảng A nhân số dòng của bảng B.',
    'explanation_en': 'CROSS JOIN returns the Cartesian product of the two tables, combining every row of the first table with every row of the second.'
  },
  {
    'question_vi': 'Thuộc tính "Durability" (Tính bền vững) trong ACID của Transaction được hiện thực hóa cốt lõi nhờ kỹ thuật nào của DBMS?',
    'question_en': 'Which technique is primarily used by databases to implement the "Durability" property of ACID?',
    'options': ['Ghi nhật ký trước khi ghi dữ liệu (Write-Ahead Logging - WAL)', 'Tạo chỉ mục tự động', 'Sao lưu nén định kỳ hàng ngày', 'Mã hóa khóa đối xứng'],
    'correct_index': 0,
    'explanation_vi': 'WAL đảm bảo mọi thay đổi được ghi vào file log tuần tự trên ổ đĩa trước khi ghi vào database chính. Khi crash, database dựa trên WAL để khôi phục (durability).',
    'explanation_en': 'Write-Ahead Logging (WAL) ensures database transactions are committed to non-volatile storage before actual database blocks are modified.'
  },
  {
    'question_vi': 'Sự khác biệt lớn nhất giữa Flexbox và Grid Layout trong CSS là gì?',
    'question_en': 'What is the main difference between Flexbox and Grid Layout in CSS?',
    'options': ['Flexbox xử lý bố cục 1 chiều (dòng hoặc cột), Grid Layout xử lý 2 chiều song song (dòng và cột)', 'Grid Layout chỉ chạy trên di động', 'Flexbox không hỗ trợ căn giữa phần tử', 'Grid Layout chạy nhanh hơn Flexbox'],
    'correct_index': 0,
    'explanation_vi': 'Flexbox được thiết kế để phân bổ không gian 1 chiều (ngang OR dọc). Grid Layout được tối ưu hóa cho bố cục 2 chiều phức tạp (đồng thời cả hàng AND cột).',
    'explanation_en': 'Flexbox is designed for one-dimensional layouts (row OR column), while Grid is for two-dimensional layouts (rows AND columns).'
  },
  {
    'question_vi': 'Trong giao thức HTTP, mã trạng thái 502 Bad Gateway chỉ ra điều gì?',
    'question_en': 'In HTTP, what does a 502 Bad Gateway status code indicate?',
    'options': ['Máy chủ proxy nhận được phản hồi không hợp lệ từ máy chủ thượng nguồn (upstream)', 'Máy chủ bị quá tải thời gian chờ phản hồi (timeout)', 'Không tìm thấy trang web yêu cầu', 'Client gửi thiếu Header xác thực'],
    'correct_index': 0,
    'explanation_vi': 'Mã 502 có nghĩa là Nginx/Apache đóng vai trò Gateway/Proxy nhận được phản hồi không hợp lệ hoặc lỗi từ app backend (ví dụ: Node.js/PHP-FPM bị sập).',
    'explanation_en': 'A 502 status code indicates that the server, while acting as a gateway or proxy, received an invalid response from the upstream server.'
  },
  {
    'question_vi': 'Hệ thống Apache Kafka được thiết kế tối ưu cho bài toán chính nào?',
    'question_en': 'What is Apache Kafka primarily optimized for?',
    'options': ['Xử lý luồng dữ liệu thời gian thực với thông lượng cực lớn và lưu trữ bền vững', 'Lưu trữ tài liệu dạng JSON giống MongoDB', 'Mã hóa và bảo mật mạng VPN', 'Chạy các tác vụ đồ họa GPU'],
    'correct_index': 0,
    'explanation_vi': 'Kafka là một nền tảng phân tán xử lý luồng dữ liệu (distributed event streaming platform), ghi log tuần tự hiệu năng cao với độ trễ thấp.',
    'explanation_en': 'Kafka is optimized for high-throughput, fault-tolerant, and real-time distributed event streaming.'
  },
  {
    'question_vi': 'Trong bảo mật ứng dụng, tấn công CSRF (Cross-Site Request Forgery) nhắm vào cơ chế xác thực nào của trình duyệt?',
    'question_en': 'In security, what authentication mechanism does a CSRF attack exploit?',
    'options': ['Cơ chế tự động gửi kèm Cookie của trình duyệt khi gửi request đến một domain', 'Cơ chế lưu trữ LocalStorage', 'Khóa bất đối xứng RSA', 'JWT lưu trong Memory'],
    'correct_index': 0,
    'explanation_vi': 'CSRF lợi dụng việc trình duyệt tự động đính kèm Cookie định danh của nạn nhân khi gửi yêu cầu đến website mục tiêu từ một trang web độc hại khác.',
    'explanation_en': 'CSRF exploits the trust that a site has in a user\'s browser, which automatically sends cookies with cross-site requests.'
  },
  {
    'question_vi': 'Trong các loại cơ sở dữ liệu NoSQL, Neo4j thuộc nhóm kiến trúc lưu trữ nào?',
    'question_en': 'Which type of NoSQL database architecture does Neo4j represent?',
    'options': ['Graph Database (Cơ sở dữ liệu đồ thị)', 'Key-Value Store', 'Document Store', 'Wide-Column Store'],
    'correct_index': 0,
    'explanation_vi': 'Neo4j là cơ sở dữ liệu đồ thị hàng đầu, biểu diễn dữ liệu bằng các Nút (Nodes), Cạnh (Edges/Relationships) và Thuộc tính (Properties).',
    'explanation_en': 'Neo4j is a Graph Database, storing data in terms of nodes and relationships instead of tables or documents.'
  },
  {
    'question_vi': 'Kỹ thuật "Lazy Loading" trong lập trình Web mang lại lợi ích lớn nhất nào?',
    'question_en': 'What is the primary benefit of "Lazy Loading" in Web development?',
    'options': ['Trì hoãn việc tải các tài nguyên nặng (như ảnh, video) cho đến khi cần hiển thị, giảm thời gian tải trang ban đầu', 'Mã hóa dữ liệu gửi lên server', 'Tự động kiểm tra chính tả văn bản', 'Hạn chế lỗi tràn bộ nhớ của trình duyệt'],
    'correct_index': 0,
    'explanation_vi': 'Lazy loading trì hoãn load tài nguyên chưa cần thiết (ví dụ: ảnh ở cuối trang chưa cuộn tới) giúp trang web phản hồi nhanh hơn khi tải lần đầu.',
    'explanation_en': 'Lazy loading defers the loading of non-critical resources at page load time, accelerating initial page speed.'
  },
  {
    'question_vi': 'Trong Git, lệnh "git rebase" khác biệt gì so với "git merge"?',
    'question_en': 'In Git, how does "git rebase" differ from "git merge"?',
    'options': ['Rebase viết lại lịch sử commit bằng cách đặt các commit mới lên trên commit HEAD của nhánh đích, tạo lịch sử tuyến tính', 'Merge viết lại lịch sử, Rebase giữ nguyên', 'Rebase luôn tạo ra một commit merge mới', 'Rebase chỉ hoạt động trên local'],
    'correct_index': 0,
    'explanation_vi': '`git rebase` di chuyển gốc của nhánh sang commit mới trên nhánh đích, tạo ra một chuỗi commit tuyến tính sạch đẹp. `git merge` gộp nhánh và tạo ra một commit merge mới.',
    'explanation_en': '`git rebase` reapplies commits on top of another base tip to create a linear history, whereas `git merge` joins branches with a merge commit.'
  },
  {
    'question_vi': 'Trong mô hình bảo mật, mã hóa bất đối xứng sử dụng cặp khóa nào để hoạt động?',
    'question_en': 'In asymmetric cryptography, which key pair is used?',
    'options': ['Khóa công khai (Public Key) và Khóa bí mật (Private Key)', 'Hai khóa bí mật giống hệt nhau', 'Khóa công khai và Khóa phiên (Session Key)', 'Khóa băm (Hash Key) và muối (Salt)'],
    'correct_index': 0,
    'explanation_vi': 'Mã hóa bất đối xứng sử dụng Public Key để mã hóa (ai cũng có thể xem) và Private Key để giải mã (chỉ chủ sở hữu nắm giữ) hoặc ngược lại để ký số.',
    'explanation_en': 'Asymmetric cryptography uses a public key for encryption and a private key for decryption.'
  },
  {
    'question_vi': 'Trong Docker, sự khác biệt giữa "RUN" và "CMD" trong Dockerfile là gì?',
    'question_en': 'In Docker, what is the difference between "RUN" and "CMD" directives in a Dockerfile?',
    'options': ['RUN chạy trong quá trình build image, CMD chạy khi khởi chạy container', 'CMD chạy trong quá trình build image, RUN chạy khi chạy container', 'RUN chỉ dùng cho hệ điều hành Linux', 'CMD là bắt buộc, RUN thì không'],
    'correct_index': 0,
    'explanation_vi': '`RUN` thực thi lệnh và commit kết quả tạo thành một lớp (layer) mới trong quá trình build Image. `CMD` thiết lập lệnh mặc định sẽ thực thi khi Container khởi chạy.',
    'explanation_en': '`RUN` executes commands and commits results during image build time. `CMD` sets the default command to execute when starting a container.'
  },
  {
    'question_vi': 'Mã trạng thái HTTP nào biểu thị lỗi "Gateway Timeout" (Máy chủ trung gian không nhận được phản hồi đúng hạn từ máy chủ gốc)?',
    'question_en': 'Which HTTP status code represents "Gateway Timeout"?',
    'options': ['504', '502', '500', '503'],
    'correct_index': 0,
    'explanation_vi': 'Mã `504 Gateway Timeout` chỉ ra rằng máy chủ proxy hoặc gateway đã hết thời gian chờ đợi phản hồi từ máy chủ gốc (upstream server) để hoàn thành request.',
    'explanation_en': 'The `504 Gateway Timeout` status code indicates that the server, while acting as a gateway or proxy, did not receive a timely response.'
  },
  {
    'question_vi': 'Trong công nghệ ảo hóa, container khác với máy ảo (Virtual Machine - VM) ở điểm cốt lõi nào?',
    'question_en': 'What is the key structural difference between a Container and a Virtual Machine (VM)?',
    'options': ['Container chia sẻ chung nhân hệ điều hành host (Kernel), VM chạy hệ điều hành khách (Guest OS) riêng biệt', 'VM chạy nhanh hơn Container', 'Container bảo mật và cô lập tốt hơn VM', 'Container tốn nhiều dung lượng ổ cứng hơn VM'],
    'correct_index': 0,
    'explanation_vi': 'VM cần Hypervisor và chạy một hệ điều hành khách hoàn chỉnh (tốn RAM và ổ cứng). Container dùng chung nhân OS host và cô lập qua Namespace/Cgroups nên siêu nhẹ.',
    'explanation_en': 'Containers share the host OS kernel, making them lightweight. VMs run a full guest OS on top of a hypervisor, consuming more resources.'
  },
  {
    'question_vi': 'Mục tiêu chính của giao thức OAuth2 là gì?',
    'question_en': 'What is the primary purpose of OAuth2?',
    'options': ['Ủy quyền truy cập (Authorization) cho bên thứ ba mà không cần chia sẻ mật khẩu của người dùng', 'Xác thực danh tính người dùng (Authentication)', 'Mã hóa kết nối mạng xã hội', 'Đồng bộ hóa dữ liệu danh bạ'],
    'correct_index': 0,
    'explanation_vi': 'OAuth2 là khung ủy quyền (authorization framework) cho phép ứng dụng bên thứ ba truy cập có giới hạn tài nguyên của người dùng (ví dụ: đăng nhập bằng Google).',
    'explanation_en': 'OAuth2 is an authorization framework that enables third-party applications to obtain limited access to user accounts.'
  },
  {
    'question_vi': 'Trong Redis, kiểu cấu trúc dữ liệu "Sorted Set" (ZSET) khác biệt gì so với Set thông thường?',
    'question_en': 'In Redis, what is the difference between a Set and a Sorted Set (ZSET)?',
    'options': ['Mỗi phần tử trong ZSET đi kèm với một điểm số (score) để sắp xếp tự động', 'ZSET cho phép trùng lặp phần tử', 'ZSET được lưu trên ổ đĩa thay vì RAM', 'ZSET chỉ chứa được các ký tự số'],
    'correct_index': 0,
    'explanation_vi': 'Sorted Set liên kết mỗi phần tử với một điểm số thực (score). Dữ liệu được sắp xếp tự động dựa trên điểm số này, rất hữu ích cho các bài toán Leaderboard.',
    'explanation_en': 'In a Sorted Set, every member is associated with a score, which is used to order the set from the smallest to the greatest score.'
  },
  {
    'question_vi': 'Trong thiết kế API RESTful, HTTP method "PATCH" được thiết kế tối ưu cho mục đích nào?',
    'question_en': 'In RESTful API design, what is the HTTP "PATCH" method optimized for?',
    'options': ['Cập nhật một phần tài nguyên (chỉ thay đổi một vài trường cụ thể)', 'Thay thế toàn bộ tài nguyên bằng dữ liệu mới', 'Xóa hoàn toàn tài nguyên trên máy chủ', 'Tạo mới một tài nguyên con'],
    'correct_index': 0,
    'explanation_vi': '`PUT` được dùng để thay thế toàn bộ thực thể. `PATCH` được dùng để cập nhật một phần (partial update) thực thể đó, giúp tiết kiệm băng thông.',
    'explanation_en': '`PATCH` is used to apply partial modifications to a resource, whereas `PUT` replaces the entire resource.'
  },
  {
    'question_vi': 'Trong cơ sở dữ liệu Elasticsearch, cấu trúc lập chỉ mục cốt lõi nào giúp tìm kiếm văn bản toàn văn (Full-text search) siêu nhanh?',
    'question_en': 'Which core indexing structure does Elasticsearch use to achieve fast full-text searches?',
    'options': ['Inverted Index (Chỉ mục đảo ngược)', 'B-Tree Index', 'LSM Tree', 'Hash Index'],
    'correct_index': 0,
    'explanation_vi': 'Inverted Index lập bản đồ từ mỗi từ duy nhất đến danh sách các tài liệu chứa từ đó. Giống như mục lục tra cứu từ ở cuối sách.',
    'explanation_en': 'Elasticsearch uses an Inverted Index, which maps words to their locations in documents, enabling rapid full-text lookups.'
  },
  {
    'question_vi': 'Trong ngôn ngữ lập trình JavaScript, cơ chế "Event Loop" giải quyết vấn đề cốt lõi nào?',
    'question_en': 'In JavaScript, what core issue does the "Event Loop" solve?',
    'options': ['Cho phép thực thi bất đồng bộ phi chặn (Non-blocking Asynchronous) trên một luồng duy nhất (Single-threaded)', 'Tự động dọn rác bộ nhớ Heap', 'Đồng bộ hóa dữ liệu giữa các tab trình duyệt', 'Tối ưu hóa các vòng lặp for/while'],
    'correct_index': 0,
    'explanation_vi': 'Vì JS chạy đơn luồng (Single-thread), Event Loop liên tục giám sát Call Stack và Task Queue để điều phối việc thực thi mã bất đồng bộ mà không làm treo UI.',
    'explanation_en': 'The Event Loop allows JavaScript to perform non-blocking I/O operations despite being single-threaded.'
  },
  {
    'question_vi': 'Mục tiêu chính của tấn công XSS (Cross-Site Scripting) là gì?',
    'question_en': 'What is the primary goal of a Cross-Site Scripting (XSS) attack?',
    'options': ['Tiêm mã kịch bản độc hại (thường là JavaScript) để thực thi trên trình duyệt của người dùng khác', 'Làm sập máy chủ cơ sở dữ liệu bằng cách gửi quá nhiều request', 'Đánh cắp mật khẩu root của hệ điều hành Linux', 'Thay đổi cấu hình DNS của tên miền'],
    'correct_index': 0,
    'explanation_vi': 'XSS xảy ra khi ứng dụng hiển thị dữ liệu chưa được kiểm duyệt lên trang web, cho phép hacker chèn mã kịch bản độc hại chạy trên trình duyệt của nạn nhân để lấy cookie, session.',
    'explanation_en': 'XSS injects malicious scripts into trusted websites, executing JavaScript in the victim\'s browser to steal cookies or session tokens.'
  },
  {
    'question_vi': 'Trong Git, sự khác biệt giữa "git fetch" và "git pull" là gì?',
    'question_en': 'In Git, what is the difference between "git fetch" and "git pull"?',
    'options': ['git fetch chỉ tải dữ liệu mới từ remote về nhưng không merge, git pull tự động tải và merge luôn vào nhánh hiện tại', 'git pull chỉ tải dữ liệu nhưng không merge', 'git fetch tự động xóa các nhánh cũ', 'Không có sự khác biệt nào'],
    'correct_index': 0,
    'explanation_vi': '`git fetch` cập nhật các tham chiếu từ remote về local. `git pull` thực chất bằng lệnh `git fetch` chạy tiếp theo lệnh `git merge` nhánh đó vào workspace.',
    'explanation_en': '`git fetch` downloads new data from a remote repository without merging it. `git pull` downloads and merges it immediately.'
  },
  {
    'question_vi': 'Trong kiến trúc cơ sở dữ liệu, kỹ thuật "Sharding" giải quyết vấn đề gì?',
    'question_en': 'In database architecture, what problem does "Sharding" solve?',
    'options': ['Phân chia dữ liệu của một bảng lớn ra nhiều máy chủ vật lý khác nhau để mở rộng quy mô theo chiều ngang', 'Tự động tạo các bản backup nén dữ liệu', 'Mã hóa thông tin nhạy cảm của bảng', 'Tối ưu hóa tốc độ của phép nối JOIN'],
    'correct_index': 0,
    'explanation_vi': 'Sharding chia nhỏ cơ sở dữ liệu lớn thành các phần nhỏ hơn (shards) nằm trên các database server độc lập, giúp vượt qua giới hạn lưu trữ và năng lực xử lý của một máy đơn lẻ.',
    'explanation_en': 'Sharding partitions a database into smaller, faster, and more manageable pieces (shards) spread across multiple servers.'
  },
  {
    'question_vi': 'Trong Docker, vùng lưu trữ "Volume" khác gì với "Bind Mount"?',
    'question_en': 'In Docker, what is the main difference between a Volume and a Bind Mount?',
    'options': ['Volume được quản lý hoàn toàn bởi Docker trong thư mục riêng, Bind Mount liên kết trực tiếp với một thư mục cụ thể trên máy host', 'Volume chạy nhanh hơn Bind Mount', 'Bind Mount an toàn hơn Volume', 'Volume chỉ lưu được file đọc ghi, không chạy được ứng dụng'],
    'correct_index': 0,
    'explanation_vi': 'Volume là giải pháp chuẩn hóa dữ liệu bền vững của Docker, cô lập tốt và không phụ thuộc cấu trúc file của máy host. Bind Mount ánh xạ trực tiếp đường dẫn tuyệt đối của host vào container.',
    'explanation_en': 'Volumes are managed by Docker. Bind mounts depend on the directory structure and OS of the host machine.'
  },
  {
    'question_vi': 'Trong các mẫu thiết kế (Design Patterns), "Observer Pattern" giải quyết bài toán cốt lõi nào?',
    'question_en': 'In Design Patterns, what core problem does the "Observer Pattern" solve?',
    'options': ['Định nghĩa mối quan hệ phụ thuộc một-nhiều giữa các đối tượng để khi một đối tượng đổi trạng thái, các đối tượng liên quan tự động nhận thông báo', 'Khởi tạo đối tượng từ xa qua mạng', 'Đảm bảo ứng dụng chạy đơn luồng an toàn', 'Tách biệt giao diện người dùng và cơ sở dữ liệu'],
    'correct_index': 0,
    'explanation_vi': 'Observer Pattern cho phép các đối tượng đăng ký lắng nghe sự kiện của một đối tượng nguồn (Subject) và tự động cập nhật khi Subject thay đổi (mô hình Pub-Sub).',
    'explanation_en': 'Observer pattern defines a one-to-many dependency between objects so that when one object changes state, all its dependents are notified.'
  },
  {
    'question_vi': 'Trong lập trình Java, khối lệnh "try-with-resources" giúp giải quyết vấn đề gì?',
    'question_en': 'In Java, what is the main benefit of "try-with-resources" statement?',
    'options': ['Tự động đóng các tài nguyên (như file, socket) thực thi xong mà không cần viết khối finally', 'Bắt toàn bộ các ngoại lệ kể cả OutOfMemoryError', 'Tăng tốc độ xử lý các vòng lặp', 'Cho phép khai báo biến toàn cục bên trong try'],
    'correct_index': 0,
    'explanation_vi': 'Bất kỳ class nào kế thừa `AutoCloseable` đều có thể dùng trong try-with-resources, Java sẽ tự động gọi phương thức `close()` để giải phóng tài nguyên hệ thống, tránh rò rỉ rác.',
    'explanation_en': 'It ensures that each resource is closed at the end of the statement, avoiding resource leaks without manual close in finally.'
  },
  {
    'question_vi': 'Trong giao thức mã hóa SSH, thuật toán băm khóa công khai (Fingerprint) phổ biến nhất hiện nay là gì?',
    'question_en': 'In SSH, which fingerprint format is standard for verifying host keys?',
    'options': ['SHA-256', 'MD5', 'Blowfish', 'AES-128'],
    'correct_index': 0,
    'explanation_vi': 'Chuẩn SSH mới sử dụng SHA-256 mã hóa Base64 làm Fingerprint mặc định để xác thực khóa máy chủ, thay thế cho MD5 cũ đã lỗi thời và không an toàn.',
    'explanation_en': 'SHA-256 fingerprints are the modern standard in SSH to verify the identity of remote hosts, replacing MD5.'
  },
  {
    'question_vi': 'Trong Linux, câu lệnh nào được dùng để liệt kê tất cả các tệp tin bao gồm cả tệp ẩn kèm theo thông tin chi tiết (quyền hạn, dung lượng)?',
    'question_en': 'In Linux, which command lists all files, including hidden ones, with details like permissions and size?',
    'options': ['ls -la', 'ls -f', 'list -all', 'show -la'],
    'correct_index': 0,
    'explanation_vi': '`-l` hiển thị danh sách dạng cột chi tiết. `-a` (all) hiển thị tất cả các file kể cả các file ẩn bắt đầu bằng dấu chấm `.`.',
    'explanation_en': '`ls -la` lists directory contents in long format (`-l`) including hidden files (`-a`).'
  },
  {
    'question_vi': 'Trong các giải thuật tìm kiếm, thuật toán tìm kiếm nhị phân (Binary Search) yêu cầu mảng đầu vào phải thỏa mãn điều kiện gì?',
    'question_en': 'In search algorithms, what condition must the input array satisfy for Binary Search to work?',
    'options': ['Mảng phải được sắp xếp trước', 'Mảng không được chứa các số âm', 'Mảng phải là mảng tĩnh', 'Mảng phải có kích thước lũy thừa của 2'],
    'correct_index': 0,
    'explanation_vi': 'Binary search hoạt động bằng cách so sánh phần tử giữa và chia đôi không gian tìm kiếm, đòi hỏi mảng bắt buộc phải được sắp xếp tăng/giảm dần trước khi chạy.',
    'explanation_en': 'Binary Search requires a sorted array to correctly halve the search space at each iteration.'
  },
  {
    'question_vi': 'Trong lập trình mạng, giao thức UDP (User Datagram Protocol) khác biệt gì so với TCP?',
    'question_en': 'In networking, how does UDP differ from TCP?',
    'options': ['UDP không tin cậy, không hướng kết nối nhưng có tốc độ truyền tải cực nhanh', 'UDP an toàn hơn TCP nhờ mã hóa mặc định', 'UDP đảm bảo truyền tin theo đúng thứ tự gửi', 'UDP tiêu tốn nhiều băng thông kết nối hơn TCP'],
    'correct_index': 0,
    'explanation_vi': 'TCP thiết lập kết nối, kiểm soát luồng và sửa lỗi để đảm bảo tin cậy. UDP bỏ qua các bước này để truyền tin tức thời, phù hợp cho truyền video, livestream, gaming.',
    'explanation_en': 'UDP is a connectionless, unreliable transport protocol optimized for speed rather than error-checking or packet ordering.'
  },
  {
    'question_vi': 'Trong phát triển Web, khái niệm "Session" khác "Cookie" ở điểm cốt lõi nào?',
    'question_en': 'What is the primary difference between a Session and a Cookie?',
    'options': ['Session lưu trữ dữ liệu trên máy chủ, Cookie lưu trữ dữ liệu trực tiếp trên trình duyệt client', 'Cookie lưu trữ dữ liệu trên máy chủ, Session lưu ở client', 'Session tự động bị xóa sau 1 giờ', 'Cookie chỉ lưu được thông tin dạng số'],
    'correct_index': 0,
    'explanation_vi': 'Session lưu thông tin trạng thái ở Server (an toàn hơn). Cookie lưu thông tin dạng text trực tiếp tại Browser của Client và được gửi kèm theo mỗi request HTTP.',
    'explanation_en': 'Sessions are server-side files that store user data. Cookies are client-side files stored on the user\'s web browser.'
  },
  {
    'question_vi': 'Trong Kubernetes, Pod đại diện cho khái niệm gì?',
    'question_en': 'In Kubernetes, what does a Pod represent?',
    'options': ['Là đơn vị triển khai nhỏ nhất, chứa một hoặc nhiều container chia sẻ chung tài nguyên mạng và lưu trữ', 'Là máy chủ vật lý chạy Kubernetes', 'Là cơ sở dữ liệu cấu hình của cluster', 'Là giao diện điều khiển dòng lệnh (CLI)'],
    'correct_index': 0,
    'explanation_vi': 'Pod là đơn vị trừu tượng cơ bản của K8s. Các container bên trong Pod chạy chung localhost, dùng chung cổng mạng và có thể trao đổi dữ liệu trực tiếp.',
    'explanation_en': 'A Pod is the smallest deployable unit in Kubernetes, representing a single instance of a running process.'
  },
  {
    'question_vi': 'Lỗ hổng bảo mật "CSRF" viết tắt của cụm từ nào?',
    'question_en': 'What does the security acronym CSRF stand for?',
    'options': ['Cross-Site Request Forgery', 'Cross-Site Resource Filter', 'Client-Side Request Filter', 'Cyber Security Resource File'],
    'correct_index': 0,
    'explanation_vi': 'CSRF (Tấn công giả mạo yêu cầu chéo trang) ép trình duyệt nạn nhân gửi yêu cầu thực thi hành động trái ý muốn lên một ứng dụng web mà họ đã xác thực.',
    'explanation_en': 'CSRF stands for Cross-Site Request Forgery, an attack that forces an end user to execute unwanted actions on a web app.'
  },
  {
    'question_vi': 'Trong mô hình cơ sở dữ liệu quan hệ, mục đích chính của quá trình "Chuẩn hóa dữ liệu" (Normalization) là gì?',
    'question_en': 'In relational database design, what is the primary goal of Normalization?',
    'options': ['Giảm thiểu sự dư thừa dữ liệu và tránh các dị thường khi thêm, sửa, xóa', 'Tăng tốc độ của các câu lệnh SELECT JOIN', 'Tự động tạo backup dữ liệu', 'Nén dung lượng ổ cứng lưu trữ'],
    'correct_index': 0,
    'explanation_vi': 'Chuẩn hóa (1NF, 2NF, 3NF...) phân rã bảng to thành các bảng nhỏ liên kết để loại bỏ trùng lặp dữ liệu, đảm bảo tính nhất quán và bảo toàn toàn vẹn tham chiếu.',
    'explanation_en': 'Normalization organizes database columns and tables to minimize data redundancy and dependency.'
  },
  {
    'question_vi': 'Trong lập trình hướng đối tượng, đa hình (Polymorphism) thời gian chạy (Runtime) được thể hiện qua cơ chế nào?',
    'question_en': 'In OOP, which mechanism represents runtime polymorphism?',
    'options': ['Ghi đè phương thức (Method Overriding)', 'Nạp chồng phương thức (Method Overloading)', 'Kế thừa lớp trừu tượng', 'Đóng gói thuộc tính'],
    'correct_index': 0,
    'explanation_vi': 'Method Overriding cho phép lớp con định nghĩa lại hàm của lớp cha. Trình thông dịch quyết định hàm nào được gọi khi chạy dựa trên kiểu đối tượng thực tế.',
    'explanation_en': 'Runtime polymorphism is achieved via method overriding, where the overridden method call is resolved at execution time.'
  },
  {
    'question_vi': 'Trong Dockerfile, lệnh "ENV" dùng để làm gì?',
    'question_en': 'In a Dockerfile, what does the "ENV" directive do?',
    'options': ['Thiết lập các biến môi trường (Environment Variables) trong container', 'Chỉ định thư mục làm việc mặc định', 'Khai báo cổng mạng container lắng nghe', 'Sao chép file từ host vào container'],
    'correct_index': 0,
    'explanation_vi': '`ENV` khai báo biến môi trường khả dụng cho cả quá trình build image và khi container chạy thực tế. Ví dụ: `ENV PORT=3000`.',
    'explanation_en': '`ENV` sets the environment variables both during the build stage and when the container is run.'
  },
  {
    'question_vi': 'Trong giao thức HTTP, mã phản hồi 403 Forbidden mang ý nghĩa gì?',
    'question_en': 'In HTTP, what does a 403 Forbidden status code mean?',
    'options': ['Máy chủ hiểu yêu cầu nhưng client không có quyền truy cập tài nguyên', 'Client chưa thực hiện đăng nhập để xác thực', 'Không tìm thấy tài nguyên yêu cầu trên server', 'Yêu cầu của client bị lỗi cú pháp'],
    'correct_index': 0,
    'explanation_vi': 'Khác với `401 Unauthorized` (chưa xác thực danh tính), `403 Forbidden` thông báo client đã xác thực nhưng không có quyền hạn truy cập tài nguyên này.',
    'explanation_en': 'A 403 status code means the server understands the request but refuses to authorize it due to lack of permissions.'
  },
  {
    'question_vi': 'Hệ quản trị cơ sở dữ liệu PostgreSQL là loại cơ sở dữ liệu nào?',
    'question_en': 'What type of database is PostgreSQL?',
    'options': ['Object-Relational Database (Cơ sở dữ liệu đối tượng - quan hệ)', 'NoSQL Document Store', 'Key-Value Database', 'Pure Graph Database'],
    'correct_index': 0,
    'explanation_vi': 'PostgreSQL là hệ quản trị cơ sở dữ liệu đối tượng - quan hệ (ORDBMS) mã nguồn mở mạnh mẽ, tuân thủ chuẩn SQL nghiêm ngặt và hỗ trợ mở rộng cao.',
    'explanation_en': 'PostgreSQL is an open-source object-relational database system (ORDBMS) known for extensibility and SQL compliance.'
  },
  {
    'question_vi': 'Trong Git, lệnh "git checkout -b <branch-name>" dùng để làm gì?',
    'question_en': 'In Git, what does the command "git checkout -b <branch-name>" accomplish?',
    'options': ['Tạo một nhánh mới đồng thời chuyển sang hoạt động trên nhánh đó ngay lập tức', 'Xóa một nhánh cũ và tạo lại nhánh mới', 'Đổi tên nhánh hiện tại thành tên mới', 'Tải một nhánh từ remote về local'],
    'correct_index': 0,
    'explanation_vi': 'Lệnh này là viết tắt của hai lệnh liên tiếp: `git branch <branch-name>` (tạo nhánh) và `git checkout <branch-name>` (chuyển nhánh).',
    'explanation_en': 'It is a shortcut for creating a new branch and switching to it immediately.'
  },
  {
    'question_vi': 'Trong lập trình Python, khối "finally" trong cấu trúc try-except-finally hoạt động như thế nào?',
    'question_en': 'In Python, how does the "finally" block in try-except-finally behave?',
    'options': ['Luôn luôn được thực thi dù có xảy ra ngoại lệ (exception) hay không', 'Chỉ thực thi nếu có ngoại lệ xảy ra', 'Chỉ thực thi nếu không có ngoại lệ nào', 'Chỉ thực thi khi chương trình bị crash'],
    'correct_index': 0,
    'explanation_vi': 'Khối `finally` chứa các lệnh dọn dẹp hệ thống (đóng file, ngắt kết nối mạng) và luôn chạy cuối cùng bất kể khối try có ném ra lỗi hay không.',
    'explanation_en': 'The `finally` block is always executed, whether an exception occurred or not during the try block.'
  },
  {
    'question_vi': 'Khái niệm "CI" trong CI/CD viết tắt của từ nào?',
    'question_en': 'What does the acronym "CI" stand for in CI/CD?',
    'options': ['Continuous Integration', 'Continuous Improvement', 'Code Inspection', 'Computer Integration'],
    'correct_index': 0,
    'explanation_vi': 'CI (Tích hợp liên tục) là thực hành kiểm tra tự động mã nguồn mỗi khi dev push code mới lên kho lưu trữ chung để phát hiện lỗi sớm.',
    'explanation_en': 'CI stands for Continuous Integration, the practice of automating the integration of code changes from multiple contributors.'
  },
  {
    'question_vi': 'Trong mạng máy tính, giao thức TCP thiết lập kết nối an toàn thông qua cơ chế nào?',
    'question_en': 'Through which mechanism does TCP establish a connection?',
    'options': ['Bắt tay 3 bước (Three-way Handshake)', 'Mã hóa khóa công khai', 'Bắt tay 2 bước (Two-way Handshake)', 'Xác thực SSL/TLS'],
    'correct_index': 0,
    'explanation_vi': 'Bắt tay 3 bước của TCP gồm: SYN (client gửi yêu cầu kết nối) -> SYN-ACK (server phản hồi đồng ý) -> ACK (client xác nhận lại kết nối thiết lập).',
    'explanation_en': 'TCP uses a three-way handshake (SYN, SYN-ACK, ACK) to establish a reliable connection between client and server.'
  },
  {
    'question_vi': 'Trong lập trình C++, từ khóa "const" đặt ở cuối khai báo một phương thức thành viên có ý nghĩa gì?',
    'question_en': 'In C++, what does the "const" keyword at the end of a member function declaration mean?',
    'options': ['Hàm đó cam kết không thay đổi bất kỳ thuộc tính thành viên nào của đối tượng', 'Hàm đó trả về một hằng số', 'Hàm đó không được gọi từ lớp con', 'Hàm đó chạy nhanh hơn hàm thông thường'],
    'correct_index': 0,
    'explanation_vi': 'Đặt `const` ở cuối hàm thành viên (ví dụ: `void print() const;`) ngăn cấm lập trình viên thay đổi giá trị của các biến thuộc lớp bên trong hàm đó.',
    'explanation_en': 'A const member function cannot modify any non-static data members or call non-const member functions.'
  },
  {
    'question_vi': 'Trong cơ sở dữ liệu, phép nối "LEFT JOIN" trả về kết quả như thế nào?',
    'question_en': 'In databases, what does a "LEFT JOIN" return?',
    'options': ['Tất cả các dòng của bảng bên trái và các dòng khớp của bảng bên phải (nếu không khớp điền NULL)', 'Chỉ các dòng khớp nhau của hai bảng', 'Tất cả các dòng của bảng bên phải', 'Tất cả các dòng của cả hai bảng'],
    'correct_index': 0,
    'explanation_vi': 'LEFT JOIN giữ lại toàn bộ dữ liệu của bảng viết bên trái mệnh đề JOIN. Ở bảng bên phải, nếu không tìm thấy dòng khớp, giá trị cột sẽ là NULL.',
    'explanation_en': 'LEFT JOIN returns all records from the left table, and the matched records from the right table. Unmatched right rows get NULL.'
  },
  {
    'question_vi': 'Độ phức tạp thời gian của thuật toán tìm kiếm nhị phân (Binary Search) trên mảng đã sắp xếp là bao nhiêu?',
    'question_en': 'What is the time complexity of Binary Search on a sorted array?',
    'options': ['O(log n)', 'O(n)', 'O(n log n)', 'O(1)'],
    'correct_index': 0,
    'explanation_vi': 'Vì mỗi bước so sánh loại bỏ được một nửa số lượng phần tử cần tìm kiếm, số bước tối đa để tìm ra phần tử tỷ lệ thuận với log2(n), tức `O(log n)`.',
    'explanation_en': 'Binary Search divides the search interval in half each step, resulting in a logarithmic time complexity of `O(log n)`.'
  },
  {
    'question_vi': 'Trong CSS, thuộc tính nào được dùng để thay đổi khoảng cách giữa các chữ cái trong một đoạn văn?',
    'question_en': 'In CSS, which property is used to change the spacing between letters in a text?',
    'options': ['letter-spacing', 'word-spacing', 'line-height', 'text-indent'],
    'correct_index': 0,
    'explanation_vi': '`letter-spacing` tăng hoặc giảm khoảng cách giữa các ký tự chữ. `word-spacing` thay đổi khoảng cách giữa các từ.',
    'explanation_en': '`letter-spacing` adjusts the space between characters in a block of text, while `word-spacing` adjusts space between words.'
  },
  {
    'question_vi': 'Trong lập trình hướng đối tượng, tính chất nào giúp che giấu thông tin chi tiết bên trong đối tượng và chỉ lộ ra các giao thức cần thiết?',
    'question_en': 'In OOP, which concept is used to restrict direct access to object components and hide implementation details?',
    'options': ['Tính đóng gói (Encapsulation)', 'Tính kế thừa (Inheritance)', 'Tính đa hình (Polymorphism)', 'Tính trừu tượng (Abstraction)'],
    'correct_index': 0,
    'explanation_vi': 'Tính đóng gói (Encapsulation) gom các biến và hàm liên quan vào một lớp, đồng thời giới hạn quyền truy cập qua các từ khóa `private`, `protected`.',
    'explanation_en': 'Encapsulation is the bundling of data and methods that operate on that data, hiding internal state from outside access.'
  },
  {
    'question_vi': 'Trong giao thức HTTP, mã phản hồi 301 Moved Permanently mang ý nghĩa gì?',
    'question_en': 'In HTTP, what does a 301 Moved Permanently status code mean?',
    'options': ['Tài nguyên yêu cầu đã được di chuyển vĩnh viễn sang một URI mới', 'Tài nguyên bị di chuyển tạm thời', 'Yêu cầu bị chuyển hướng do thiếu bảo mật', 'Máy chủ proxy bị lỗi định tuyến'],
    'correct_index': 0,
    'explanation_vi': 'Mã 301 báo hiệu cho trình duyệt hoặc công cụ tìm kiếm (SEO) biết trang web đã đổi URL vĩnh viễn, trình duyệt sẽ tự động cache và redirect sang URL mới.',
    'explanation_en': 'The 301 redirect code indicates that the requested resource has been permanently moved to the URL given in the Location header.'
  },
  {
    'question_vi': 'Cơ sở dữ liệu Elasticsearch được xây dựng dựa trên thư viện tìm kiếm mã nguồn mở nào của Apache?',
    'question_en': 'Which Apache open-source search library is Elasticsearch built on?',
    'options': ['Apache Lucene', 'Apache Solr', 'Apache Spark', 'Apache Hadoop'],
    'correct_index': 0,
    'explanation_vi': 'Elasticsearch kế thừa bộ lõi tìm kiếm mạnh mẽ Apache Lucene viết bằng Java để phân tích cú pháp và lập chỉ mục văn bản đảo ngược.',
    'explanation_en': 'Elasticsearch is built on top of Apache Lucene, a high-performance, full-featured text search engine library.'
  },
  {
    'question_vi': 'Trong thiết kế phần mềm, "Factory Pattern" thuộc nhóm mẫu thiết kế nào?',
    'question_en': 'In software design, which group of design patterns does "Factory Pattern" belong to?',
    'options': ['Nhóm khởi tạo (Creational)', 'Nhóm cấu trúc (Structural)', 'Nhóm hành vi (Behavioral)', 'Nhóm đồng bộ (Concurrency)'],
    'correct_index': 0,
    'explanation_vi': 'Factory Method nằm trong nhóm Creational Patterns (khởi tạo), giúp đóng gói logic tạo đối tượng thay vì khởi tạo trực tiếp bằng từ khóa new.',
    'explanation_en': 'Factory pattern is a Creational design pattern because it deals with the initialization and instantiation of objects.'
  },
  {
    'question_vi': 'Trong JavaScript, hàm "setTimeout(callback, 0)" hoạt động như thế nào?',
    'question_en': 'In JavaScript, how does "setTimeout(callback, 0)" behave?',
    'options': ['Đặt callback vào Task Queue và chỉ chạy sau khi Call Stack đã trống rỗng', 'Thực thi callback ngay lập tức không trễ', 'Treo UI của trình duyệt cho đến khi callback chạy', 'Chạy callback trên một luồng worker chạy ngầm'],
    'correct_index': 0,
    'explanation_vi': 'Dù set trễ bằng 0ms, callback vẫn bắt buộc phải đi qua Task Queue của Event Loop và đợi toàn bộ mã đồng bộ trong Call Stack chạy xong mới được gọi.',
    'explanation_en': 'It pushes the callback to the macrotask queue. The callback runs only after the current call stack is entirely cleared.'
  },
  {
    'question_vi': 'Trong Linux, câu lệnh nào được sử dụng để theo dõi luồng đầu ra của một file log liên tục theo thời gian thực?',
    'question_en': 'In Linux, which command is used to monitor a log file output continuously in real-time?',
    'options': ['tail -f <file-name>', 'cat <file-name>', 'less <file-name>', 'watch <file-name>'],
    'correct_index': 0,
    'explanation_vi': '`-f` (follow) trong lệnh `tail` giữ kết nối mở và in ra màn hình các dòng văn bản mới ngay khi chúng được ghi thêm vào cuối file log.',
    'explanation_en': '`tail -f` outputs appended data in real-time as the file grows, which is useful for monitoring active logs.'
  },
  {
    'question_vi': 'Từ khóa "defer" trong ngôn ngữ Go (Golang) có tác dụng gì?',
    'question_en': 'In Go (Golang), what is the purpose of the "defer" keyword?',
    'options': ['Trì hoãn việc thực thi câu lệnh cho đến khi hàm bao quanh nó chạy xong và chuẩn bị return', 'Chạy câu lệnh bất đồng bộ trên một luồng khác', 'Tránh việc ném ngoại lệ khi có lỗi', 'Định nghĩa một hằng số chỉ được đọc'],
    'correct_index': 0,
    'explanation_vi': '`defer` cực kỳ hữu ích để dọn dẹp tài nguyên (đóng file, unlock mutex) ngay tại vị trí khai báo, đảm bảo chúng luôn được đóng trước khi thoát hàm.',
    'explanation_en': '`defer` schedules a function call to be run immediately before the surrounding function returns.'
  },
  {
    'question_vi': 'Trong bảo mật mạng, chứng chỉ SSL/TLS được sử dụng để làm gì?',
    'question_en': 'In network security, what is the primary purpose of SSL/TLS certificates?',
    'options': ['Xác thực danh tính website và thiết lập kênh truyền tải dữ liệu mã hóa giữa client và server', 'Diệt virus và mã độc trên web server', 'Hạn chế các cuộc tấn công DDoS', 'Tự động sao lưu dữ liệu máy chủ'],
    'correct_index': 0,
    'explanation_vi': 'SSL/TLS kết hợp mã hóa bất đối xứng để trao đổi khóa bảo mật và mã hóa đối xứng để truyền dữ liệu, đảm bảo dữ liệu không bị nghe lén hay sửa đổi.',
    'explanation_en': 'SSL/TLS certificates authenticate website identity and enable encrypted connections between browser and server.'
  },
  {
    'question_vi': 'Trong CSS, thuộc tính "box-sizing: border-box" có tác dụng gì?',
    'question_en': 'In CSS, what does "box-sizing: border-box" do?',
    'options': ['Bao gồm cả padding và border vào tổng chiều rộng và chiều cao của phần tử', 'Chỉ tính chiều rộng dựa trên content, không tính padding', 'Ẩn đường viền của hộp', 'Cố định kích thước hộp không thay đổi được'],
    'correct_index': 0,
    'explanation_vi': 'Mặc định (`content-box`), chiều rộng hộp bằng width + padding + border. Với `border-box`, width khai báo bao trọn cả padding và border giúp tính toán layout cực dễ.',
    'explanation_en': '`border-box` tells the browser to account for any border and padding in the values you specify for an element\'s width and height.'
  },
  {
    'question_vi': 'Trong Git, lệnh "git reset --soft HEAD~1" có tác dụng gì?',
    'question_en': 'In Git, what does "git reset --soft HEAD~1" do?',
    'options': ['Hủy commit gần nhất nhưng giữ lại các thay đổi của commit đó trong Stage area để sửa đổi', 'Hủy commit và xóa sạch toàn bộ code thay đổi', 'Đẩy code commit đó lên nhánh remote', 'Gộp commit đó vào nhánh master'],
    'correct_index': 0,
    'explanation_vi': '`--soft` chỉ di chuyển con trỏ HEAD về commit trước đó, giữ nguyên toàn bộ file thay đổi ở Stage area (sẵn sàng commit lại). `--hard` mới xóa sạch code.',
    'explanation_en': 'It undoes the last commit, but keeps your changes in the staging area so you can edit and commit again.'
  },
  {
    'question_vi': 'Trong lập trình, khái niệm "Recursion" (Đệ quy) hoạt động dựa trên cấu trúc dữ liệu ngầm định nào của hệ thống?',
    'question_en': 'In programming, recursion relies on which underlying system data structure?',
    'options': ['Call Stack (Ngăn xếp cuộc gọi)', 'Queue (Hàng đợi)', 'B-Tree', 'Heap'],
    'correct_index': 0,
    'explanation_vi': 'Khi một hàm gọi lại chính nó, hệ điều hành đẩy trạng thái của hàm hiện tại vào Call Stack. Khi đệ quy chạm điều kiện dừng, các hàm sẽ lần lượt được pop ra khỏi stack.',
    'explanation_en': 'Each recursive call pushes a new stack frame onto the Call Stack, storing local variables and return addresses.'
  },
  {
    'question_vi': 'Trong giao thức HTTP, mã phản hồi 401 Unauthorized chỉ ra điều gì?',
    'question_en': 'In HTTP, what does a 401 Unauthorized status code indicate?',
    'options': ['Yêu cầu thiếu thông tin xác thực danh tính (như Token hoặc Password)', 'Client không có quyền truy cập dù đã đăng nhập', 'Không tìm thấy máy chủ web', 'Máy chủ bị lỗi xử lý bên trong'],
    'correct_index': 0,
    'explanation_vi': 'Mã 401 chỉ ra rằng yêu cầu cần phải có thông tin xác thực người dùng (Authentication) trước khi được xử lý tiếp.',
    'explanation_en': 'The 401 status code indicates that the request has not been applied because it lacks valid authentication credentials.'
  },
  {
    'question_vi': 'Cơ sở dữ liệu MongoDB lưu trữ dữ liệu tài liệu dưới dạng định dạng nhị phân nào?',
    'question_en': 'In which binary format does MongoDB store its documents?',
    'options': ['BSON (Binary JSON)', 'JSON', 'XML', 'Protocol Buffers'],
    'correct_index': 0,
    'explanation_vi': 'MongoDB lưu dữ liệu dưới dạng BSON (Binary JSON), giúp mở rộng kiểu dữ liệu (như Date, Binary) và tối ưu tốc độ phân tích, duyệt tài liệu.',
    'explanation_en': 'MongoDB stores documents in BSON, a binary-serialized representation of JSON-like documents.'
  },
  {
    'question_vi': 'Trong Dockerfile, sự khác biệt giữa "ADD" và "COPY" là gì?',
    'question_en': 'In a Dockerfile, what is the key difference between "ADD" and "COPY"?',
    'options': ['ADD hỗ trợ tải file từ URL từ xa và tự động giải nén file tar/gzip, COPY chỉ sao chép file local', 'COPY hỗ trợ giải nén file tự động', 'ADD chạy nhanh hơn COPY', 'COPY chỉ dùng cho file thư mục, ADD dùng cho file văn bản'],
    'correct_index': 0,
    'explanation_vi': '`COPY` là giải pháp an toàn và tường minh để copy file local. `ADD` có thêm tính năng nâng cao như tải link url và tự động uncompress các file nén dạng .tar.gz.',
    'explanation_en': '`COPY` only supports local files copy. `ADD` can pull files from remote URLs and unpack tar/gzip archives automatically.'
  },
  {
    'question_vi': 'Hệ thống hàng đợi tin nhắn RabbitMQ sử dụng giao thức chuẩn nào để giao tiếp mặc định?',
    'question_en': 'Which network protocol does RabbitMQ use by default for messaging?',
    'options': ['AMQP (Advanced Message Queuing Protocol)', 'HTTP/2', 'MQTT', 'gRPC'],
    'correct_index': 0,
    'explanation_vi': 'RabbitMQ được xây dựng trên chuẩn AMQP, một giao thức tầng ứng dụng được thiết kế cho việc truyền dẫn tin nhắn hướng hàng đợi an toàn.',
    'explanation_en': 'RabbitMQ uses AMQP as its primary default protocol, ensuring interoperability between clients and brokers.'
  },
  {
    'question_vi': 'Trong lập trình hướng đối tượng, chữ S trong SOLID đại diện cho nguyên lý nào?',
    'question_en': 'In SOLID principles, what does the letter S stand for?',
    'options': ['Single Responsibility Principle (Nguyên lý đơn nhiệm)', 'Substitution Principle', 'State Management Principle', 'Scope Isolation Principle'],
    'correct_index': 0,
    'explanation_vi': 'Nguyên lý đơn nhiệm phát biểu rằng một class chỉ nên có một và chỉ một lý do duy nhất để thay đổi (tức là chỉ làm một nhiệm vụ duy nhất).',
    'explanation_en': 'The Single Responsibility Principle states that a class should have one, and only one, reason to change.'
  }
];
