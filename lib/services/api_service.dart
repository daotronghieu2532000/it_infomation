import 'dart:ui';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/article.dart';
import '../models/github_repo.dart';
import '../models/prompt.dart';
import '../models/dev_workflow.dart';
import '../models/ai_tool.dart';

class ApiService {
  // Thay đổi URL này thành IP server/hosting của bạn.
  static String baseUrl = 'https://codego.io.vn/api';

  final _storage = const FlutterSecureStorage();

  static const String _keyAccessToken = 'access_token';
  static const String _keyUserToken = 'user_token';
  static const String _keyUserInfo = 'user_info';
  static const String _keyLanguage = 'app_language';

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // ============================================
  // QUẢN LÝ SECURE TOKENS & THÔNG TIN USER
  // ============================================

  Future<void> _secureWrite(String key, String value) async {
    try {
      await _storage.write(
        key: key,
        value: value,
        iOptions: const IOSOptions(
          accessibility: KeychainAccessibility.first_unlock,
        ),
      );
    } catch (e) {
      // Bắt lỗi iOS keychain duplicate item bug (-25299)
      try {
        await _storage.delete(key: key);
        await _storage.write(
          key: key,
          value: value,
          iOptions: const IOSOptions(
            accessibility: KeychainAccessibility.first_unlock,
          ),
        );
      } catch (_) {}
    }
  }

  Future<void> saveAccessToken(String token) async {
    await _secureWrite(_keyAccessToken, token);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _keyAccessToken);
  }

  Future<void> saveUserToken(String token) async {
    await _secureWrite(_keyUserToken, token);
  }

  Future<String?> getUserToken() async {
    return await _storage.read(key: _keyUserToken);
  }

  Future<void> saveUserInfo(Map<String, dynamic> userInfo) async {
    await _secureWrite(_keyUserInfo, jsonEncode(userInfo));
  }

  Future<Map<String, dynamic>?> getUserInfo() async {
    final infoStr = await _storage.read(key: _keyUserInfo);
    if (infoStr == null) return null;
    try {
      return jsonDecode(infoStr) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: _keyUserToken);
    await _storage.delete(key: _keyUserInfo);
  }

  Future<bool> getLanguagePreference() async {
    final lang = await _storage.read(key: _keyLanguage);
    if (lang != null) {
      return lang == 'en';
    }
    // Default to system language if not set yet
    try {
      final systemLocale = PlatformDispatcher.instance.locale;
      final isVi = systemLocale.languageCode.toLowerCase() == 'vi';
      return !isVi; // If Vietnamese, not English (isEnglish = false). Otherwise default to English (isEnglish = true)
    } catch (e) {
      return false; // Fallback to Vietnamese
    }
  }

  Future<void> setLanguagePreference(bool isEn) async {
    await _storage.write(key: _keyLanguage, value: isEn ? 'en' : 'vi');
  }

  Future<bool> isLoggedIn() async {
    final token = await getUserToken();
    return token != null && token.isNotEmpty;
  }

  // ============================================
  // XÁC THỰC HỆ THỐNG & USER (AUTHENTICATION)
  // ============================================

  /// Bước 1: Lấy Token Hệ Thống (Client App Token)
  Future<String> fetchSystemAccessToken({
    String apiKey = 'codego_api_key_2025',
    String apiSecret = 'codego_secret_2025',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/get_token.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'api_key': apiKey, 'api_secret': apiSecret}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        final token = data['data']['access_token'] as String;
        await saveAccessToken(token);
        return token;
      } else {
        throw Exception(data['message'] ?? 'Failed to get system token');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối xác thực hệ thống: $e');
    }
  }

  /// Helper lấy Authorization Header
  Future<Map<String, String>> _getHeaders({bool requireUser = false}) async {
    var token = await getAccessToken();
    if (token == null) {
      // Nếu chưa có, lấy mới tự động
      token = await fetchSystemAccessToken();
    }

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    if (requireUser) {
      final userToken = await getUserToken();
      if (userToken != null) {
        headers['User-Token'] = userToken;
      }
    } else {
      // Đính kèm nếu có (dành cho API lấy tin check bookmark)
      final userToken = await getUserToken();
      if (userToken != null) {
        headers['User-Token'] = userToken;
      }
    }

    return headers;
  }

  /// Đăng nhập User
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/login.php'),
        headers: headers,
        body: jsonEncode({
          'username': username,
          'password': password,
          'platform': 'ios',
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        final userToken = data['data']['user_token'] as String;
        final userInfo = data['data']['user'] as Map<String, dynamic>;

        await saveUserToken(userToken);
        await saveUserInfo(userInfo);

        return {'success': true, 'user': userInfo};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Đăng nhập thất bại',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi đăng nhập: $e'};
    }
  }

  /// Đăng ký User
  Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
    String name,
  ) async {
    try {
      final headers = await _getHeaders();
      final url = '$baseUrl/register.php';
      final bodyMap = {
        'username': username,
        'email': email,
        'password': password,
        'name': name,
        'country': 'VN',
      };

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(bodyMap),
      );

      final data = jsonDecode(response.body);
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data['success'] == true) {
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Đăng ký thất bại',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi đăng ký: $e'};
    }
  }

  // ============================================
  // TRUY VẤN DỮ LIỆU TECHFLOW (BUSINESS ENDPOINTS)
  // ============================================

  /// Lấy danh sách tin tức công nghệ
  Future<List<Article>> getTechNews({
    String category = '',
    String type = '',
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse(
        '$baseUrl/get_tech_news.php?category=$category&type=$type&page=$page&limit=$limit',
      );

      final response = await http.get(url, headers: headers);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final List list = data['data']['articles'] as List;
        return list.map((json) => Article.fromJson(json)).toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch news');
      }
    } catch (e) {
      print('Error getTechNews: $e');
      return [];
    }
  }

  /// Lấy danh sách GitHub Trending Repos
  Future<List<GitHubRepo>> getGitHubRepos({
    String period = 'daily',
    String language = '',
  }) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse(
        '$baseUrl/get_github_repos.php?period=$period&language=$language',
      );

      final response = await http.get(url, headers: headers);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final List list = data['data'] as List;
        return list.map((json) => GitHubRepo.fromJson(json)).toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch repos');
      }
    } catch (e) {
      print('Error getGitHubRepos: $e');
      return [];
    }
  }

  /// Lấy danh sách Curated Prompts
  Future<List<CuratedPrompt>> getPrompts({
    String category = '',
    String search = '',
  }) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse(
        '$baseUrl/get_prompts.php?category=$category&search=$search',
      );

      final response = await http.get(url, headers: headers);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final List list = data['data'] as List;
        return list.map((json) => CuratedPrompt.fromJson(json)).toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch prompts');
      }
    } catch (e) {
      print('Error getPrompts: $e');
      return [];
    }
  }

  /// Lấy danh sách Dev Workflows
  Future<List<DevWorkflow>> getDevWorkflows({
    String category = '',
    String search = '',
  }) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse(
        '$baseUrl/get_workflows.php?category=$category&search=$search',
      );

      final response = await http.get(url, headers: headers);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final List list = data['data'] as List;
        return list.map((json) => DevWorkflow.fromJson(json)).toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch workflows');
      }
    } catch (e) {
      print('Error getDevWorkflows: $e');
      return [];
    }
  }

  /// Lấy danh sách Công cụ AI (AI Tools Hub)
  Future<List<AiTool>> getAiTools() async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/get_ai_tools.php');

      final response = await http.get(url, headers: headers);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final List list = data['data'] as List;
        return list.map((json) => AiTool.fromJson(json)).toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch AI tools');
      }
    } catch (e) {
      print('Error getAiTools: $e');
      return [];
    }
  }

  // ============================================
  // TƯƠNG TÁC NGƯỜI DÙNG (LIKE, BOOKMARK, COPY)
  // ============================================

  /// Thực hiện Like/Bookmark
  Future<bool> interact({
    required String action, // 'like', 'bookmark', 'copy'
    required String
    itemType, // 'article', 'repo', 'ai_package', 'workflow', 'prompt'
    required int itemId,
    required bool state, // true: like/bookmark, false: unlike/unbookmark
  }) async {
    try {
      final headers = await _getHeaders(requireUser: true);
      final response = await http.post(
        Uri.parse('$baseUrl/interact.php'),
        headers: headers,
        body: jsonEncode({
          'action': action,
          'item_type': itemType,
          'item_id': itemId,
          'state': state,
        }),
      );

      final data = jsonDecode(response.body);
      return response.statusCode == 200 && data['success'] == true;
    } catch (e) {
      print('Error interact: $e');
      return false;
    }
  }

  /// Lưu tiến trình học tập / làm quiz và cộng điểm cho user
  Future<Map<String, dynamic>> saveUserProgress({
    required int userId,
    required String contentType, // 'lesson' hoặc 'exercise'
    required String contentId, // ví dụ: 'quiz_daily_2026_08_09'
    required String language, // ví dụ: 'general' hoặc 'dart'
    required int pointsEarned,
  }) async {
    try {
      final headers = await _getHeaders(requireUser: true);
      final response = await http.post(
        Uri.parse('$baseUrl/codego_progress.php'),
        headers: headers,
        body: jsonEncode({
          'action': 'complete',
          'user_id': userId,
          'content_type': contentType,
          'content_id': contentId,
          'language': language,
          'is_completed': 1,
          'points_earned': pointsEarned,
        }),
      );
      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      print('Error saveUserProgress: $e');
      return {'success': false, 'message': 'Lỗi kết nối lưu tiến trình: $e'};
    }
  }

  // ============================================
  // ĐỒNG BỘ DỮ LIỆU CHỦ ĐỘNG (TRIGGER SYNC)
  // ============================================

  /// Kích hoạt cào và đồng bộ GitHub repos mới
  Future<Map<String, dynamic>> syncGitHubRepos() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/cron_sync_github.php'),
        headers: headers,
      );
      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối đồng bộ GitHub: $e'};
    }
  }

  /// Kích hoạt cào và đồng bộ tin tức mới
  Future<Map<String, dynamic>> syncTechNews() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/cron_sync_news.php'),
        headers: headers,
      );
      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối đồng bộ tin tức: $e'};
    }
  }

  /// Kích hoạt đồng bộ danh sách Công cụ AI từ registry trung tâm
  Future<Map<String, dynamic>> syncAiTools() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/cron_sync_ai_tools.php'),
        headers: headers,
      );
      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối đồng bộ Công cụ AI: $e'};
    }
  }

  /// Gọi API Trợ lý AI để giải thích, debug, dịch code
  Future<Map<String, dynamic>> callAIHelper({
    required String code,
    required String action,
    String targetLanguage = 'Dart',
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/ai_helper.php'),
        headers: headers,
        body: jsonEncode({
          'code': code,
          'action': action,
          'target_language': targetLanguage,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'result_markdown': data['data']['result_markdown'] as String,
          'detected_language': data['data']['detected_language'] as String,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Lỗi phân tích AI',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối API AI: $e'};
    }
  }

  /// Yêu cầu xóa tài khoản
  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/delete_account.php'),
        headers: headers,
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Xóa tài khoản thành công',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Xóa tài khoản thất bại',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối máy chủ: $e'};
    }
  }

  /// Cập nhật thông tin User (name, email)
  Future<Map<String, dynamic>> updateProfile(int userId, {String? name, String? email}) async {
    try {
      final headers = await _getHeaders();
      final Map<String, dynamic> body = {
        'user_id': userId,
      };
      if (name != null) body['name'] = name;
      if (email != null) body['email'] = email;

      final response = await http.post(
        Uri.parse('$baseUrl/update_profile.php'),
        headers: headers,
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'message': data['message'], 'user': data['data']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Cập nhật thông tin thất bại'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi cập nhật thông tin: $e'};
    }
  }

  /// Upload ảnh đại diện
  Future<Map<String, dynamic>> uploadAvatar(int userId, String imagePath) async {
    try {
      final headers = await _getHeaders();
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload_avatar.php'));
      
      // Copy headers (Authorization Bearer token)
      headers.forEach((key, value) {
        request.headers[key] = value;
      });
      
      request.fields['user_id'] = userId.toString();
      request.files.add(await http.MultipartFile.fromPath('avatar', imagePath));
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'],
          'avatar_url': data['data']['avatar_url']
        };
      } else {
        return {'success': false, 'message': data['message'] ?? 'Upload avatar thất bại'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi upload avatar: $e'};
    }
  }

  /// Lấy danh sách Bảng xếp hạng (Leaderboard)
  Future<Map<String, dynamic>> getLeaderboard({
    String type = 'global',
    int limit = 50,
  }) async {
    try {
      final headers = await _getHeaders(requireUser: true);
      final response = await http.post(
        Uri.parse('$baseUrl/leaderboard.php'),
        headers: headers,
        body: jsonEncode({
          'type': type,
          'limit': limit,
        }),
      );
      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      print('Error getLeaderboard: $e');
      return {'success': false, 'message': 'Lỗi kết nối bảng xếp hạng: $e'};
    }
  }
}
