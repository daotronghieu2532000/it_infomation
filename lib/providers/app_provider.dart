import 'package:flutter/material.dart';
import '../models/article.dart';
import '../models/github_repo.dart';
import '../models/prompt.dart';
import '../models/dev_workflow.dart';
import '../models/ai_tool.dart';
import '../services/api_service.dart';

class AppProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  // User State
  bool _isLoggedIn = false;
  Map<String, dynamic>? _userInfo;
  bool get isLoggedIn => _isLoggedIn;
  Map<String, dynamic>? get userInfo => _userInfo;

  // Lists Data State
  List<Article> _weeklyHighlights = [];
  List<Article> _dailyNews = [];
  List<GitHubRepo> _trendingRepos = [];
  List<CuratedPrompt> _curatedPrompts = [];
  List<DevWorkflow> _devWorkflows = [];
  
  List<Article> get weeklyHighlights => _weeklyHighlights;
  List<Article> get dailyNews => _dailyNews;
  List<GitHubRepo> get trendingRepos => _trendingRepos;
  List<CuratedPrompt> get curatedPrompts => _curatedPrompts;
  List<DevWorkflow> get devWorkflows => _devWorkflows;
  List<AiTool> _aiTools = [];
  List<AiTool> get aiTools => _aiTools;

  // Bookmarks State (for easy offline bookmarks tab)
  List<Article> _bookmarkedArticles = [];
  List<GitHubRepo> _bookmarkedRepos = [];
  List<CuratedPrompt> _bookmarkedPrompts = [];
  List<DevWorkflow> _bookmarkedWorkflows = [];

  List<Article> get bookmarkedArticles => _bookmarkedArticles;
  List<GitHubRepo> get bookmarkedRepos => _bookmarkedRepos;
  List<CuratedPrompt> get bookmarkedPrompts => _bookmarkedPrompts;
  List<DevWorkflow> get bookmarkedWorkflows => _bookmarkedWorkflows;

  bool _isLoadingNews = false;
  bool _isLoadingRepos = false;
  bool _isLoadingPrompts = false;
  bool _isLoadingWorkflows = false;
  bool _isLoadingAiTools = false;
  bool _isLoadingAuth = false;
  bool _isSyncingGitHub = false;
  bool _isSyncingNews = false;

  bool get isLoadingNews => _isLoadingNews;
  bool get isLoadingRepos => _isLoadingRepos;
  bool get isLoadingPrompts => _isLoadingPrompts;
  bool get isLoadingWorkflows => _isLoadingWorkflows;
  bool get isLoadingAiTools => _isLoadingAiTools;
  bool get isLoadingAuth => _isLoadingAuth;
  bool get isSyncingGitHub => _isSyncingGitHub;
  bool get isSyncingNews => _isSyncingNews;

  // Filters State
  String _selectedNewsCategory = 'All';
  String _selectedRepoPeriod = 'daily';
  String _selectedRepoLanguage = 'All';
  String _selectedPromptCategory = 'All';
  String _selectedWorkflowCategory = 'All';

  String get selectedNewsCategory => _selectedNewsCategory;
  String get selectedRepoPeriod => _selectedRepoPeriod;
  String get selectedRepoLanguage => _selectedRepoLanguage;
  String get selectedPromptCategory => _selectedPromptCategory;
  String get selectedWorkflowCategory => _selectedWorkflowCategory;

  // Initialize and check login
  Future<void> init() async {
    _isLoggedIn = await _apiService.isLoggedIn();
    if (_isLoggedIn) {
      _userInfo = await _apiService.getUserInfo();
    }
    notifyListeners();
    
    // Tải dữ liệu ban đầu
    loadAllData();
  }

  Future<void> loadAllData() async {
    await Future.wait([
      loadNews(),
      loadTrendingRepos(),
      loadPrompts(),
      loadWorkflows(),
      loadAiTools(),
    ]);
  }

  // ============================================
  // XỬ LÝ AUTHENTICATION (ĐĂNG NHẬP / ĐĂNG KÝ)
  // ============================================

  Future<Map<String, dynamic>> login(String username, String password) async {
    _isLoadingAuth = true;
    notifyListeners();
    
    final res = await _apiService.login(username, password);
    _isLoadingAuth = false;
    
    if (res['success'] == true) {
      _isLoggedIn = true;
      _userInfo = res['user'];
      
      // Load lại toàn bộ dữ liệu để cập nhật trạng thái bookmark của user mới
      loadAllData();
    }
    notifyListeners();
    return res;
  }

  Future<Map<String, dynamic>> register(String username, String email, String password, String name) async {
    _isLoadingAuth = true;
    notifyListeners();
    final res = await _apiService.register(username, email, password, name);
    _isLoadingAuth = false;
    notifyListeners();
    return res;
  }

  Future<void> logout() async {
    await _apiService.logout();
    _isLoggedIn = false;
    _userInfo = null;
    
    // Clear bookmarks lists
    _bookmarkedArticles.clear();
    _bookmarkedRepos.clear();
    _bookmarkedPrompts.clear();
    
    // Reload data to reset bookmarks state to false
    loadAllData();
    notifyListeners();
  }

  // ============================================
  // XỬ LÝ TRUY VẤN DỮ LIỆU
  // ============================================

  // Cập nhật bộ lọc News
  void setNewsCategory(String category) {
    _selectedNewsCategory = category;
    loadNews();
  }

  Future<void> loadNews() async {
    _isLoadingNews = true;
    notifyListeners();
    
    try {
      // Tải weekly highlights
      _weeklyHighlights = await _apiService.getTechNews(
        category: _selectedNewsCategory,
        type: 'weekly',
      );

      // Tải daily news
      _dailyNews = await _apiService.getTechNews(
        category: _selectedNewsCategory,
        type: 'daily',
      );

      // Cập nhật danh sách bookmarks
      _updateBookmarkedArticles();
    } catch (_) {}

    _isLoadingNews = false;
    notifyListeners();
  }

  // Cập nhật bộ lọc Repos
  void setRepoFilters({String? period, String? language}) {
    if (period != null) _selectedRepoPeriod = period;
    if (language != null) _selectedRepoLanguage = language;
    loadTrendingRepos();
  }

  Future<void> loadTrendingRepos() async {
    _isLoadingRepos = true;
    notifyListeners();

    try {
      _trendingRepos = await _apiService.getGitHubRepos(
        period: _selectedRepoPeriod,
        language: _selectedRepoLanguage,
      );

      _updateBookmarkedRepos();
    } catch (_) {}

    _isLoadingRepos = false;
    notifyListeners();
  }

  // Cập nhật bộ lọc Prompts
  void setPromptCategory(String category) {
    _selectedPromptCategory = category;
    loadPrompts();
  }

  Future<void> loadPrompts({String search = ''}) async {
    _isLoadingPrompts = true;
    notifyListeners();

    try {
      _curatedPrompts = await _apiService.getPrompts(
        category: _selectedPromptCategory,
        search: search,
      );

      _updateBookmarkedPrompts();
    } catch (_) {}

    _isLoadingPrompts = false;
    notifyListeners();
  }

  // Cập nhật bộ lọc Workflows
  void setWorkflowCategory(String category) {
    _selectedWorkflowCategory = category;
    loadWorkflows();
  }

  Future<void> loadWorkflows({String search = ''}) async {
    _isLoadingWorkflows = true;
    notifyListeners();

    try {
      _devWorkflows = await _apiService.getDevWorkflows(
        category: _selectedWorkflowCategory,
        search: search,
      );

      _updateBookmarkedWorkflows();
    } catch (_) {}

    _isLoadingWorkflows = false;
    notifyListeners();
  }

  Future<void> loadAiTools() async {
    _isLoadingAiTools = true;
    notifyListeners();

    try {
      _aiTools = await _apiService.getAiTools();
    } catch (_) {}

    _isLoadingAiTools = false;
    notifyListeners();
  }

  // ============================================
  // ĐỒNG BỘ DỮ LIỆU THỦ CÔNG (MANUAL SYNC TRIGGERS)
  // ============================================

  Future<Map<String, dynamic>> triggerSyncGitHub() async {
    _isSyncingGitHub = true;
    notifyListeners();
    
    final res = await _apiService.syncGitHubRepos();
    if (res['success'] == true) {
      await loadTrendingRepos();
    }
    
    _isSyncingGitHub = false;
    notifyListeners();
    return res;
  }

  Future<Map<String, dynamic>> triggerSyncNews() async {
    _isSyncingNews = true;
    notifyListeners();
    
    final res = await _apiService.syncTechNews();
    if (res['success'] == true) {
      await loadNews();
    }
    
    _isSyncingNews = false;
    notifyListeners();
    return res;
  }

  // ============================================
  // XỬ LÝ LIKE, BOOKMARK, COPY
  // ============================================

  /// Thao tác Bookmark (Lưu đọc sau)
  Future<void> toggleBookmark({required String itemType, required int itemId}) async {
    if (!_isLoggedIn) return; // Yêu cầu đăng nhập

    // Tìm item trong list để phản hồi UI ngay lập tức (Optimistic UI)
    bool oldState = false;
    if (itemType == 'article') {
      final article = _findArticle(itemId);
      if (article != null) {
        oldState = article.isBookmarked;
        article.isBookmarked = !oldState;
        _updateBookmarkedArticles();
        notifyListeners();
      }
    } else if (itemType == 'repo') {
      final repo = _findRepo(itemId);
      if (repo != null) {
        oldState = repo.isBookmarked;
        repo.isBookmarked = !oldState;
        _updateBookmarkedRepos();
        notifyListeners();
      }
    } else if (itemType == 'prompt') {
      final prompt = _findPrompt(itemId);
      if (prompt != null) {
        oldState = prompt.isBookmarked;
        prompt.isBookmarked = !oldState;
        _updateBookmarkedPrompts();
        notifyListeners();
      }
    } else if (itemType == 'workflow') {
      final workflow = _findWorkflow(itemId);
      if (workflow != null) {
        oldState = workflow.isBookmarked;
        workflow.isBookmarked = !oldState;
        _updateBookmarkedWorkflows();
        notifyListeners();
      }
    }

    // Gọi API lưu lên server
    final success = await _apiService.interact(
      action: 'bookmark',
      itemType: itemType,
      itemId: itemId,
      state: !oldState,
    );

    // Rollback nếu gọi API thất bại
    if (!success) {
      if (itemType == 'article') {
        final article = _findArticle(itemId);
        if (article != null) article.isBookmarked = oldState;
      } else if (itemType == 'repo') {
        final repo = _findRepo(itemId);
        if (repo != null) repo.isBookmarked = oldState;
      } else if (itemType == 'prompt') {
        final prompt = _findPrompt(itemId);
        if (prompt != null) prompt.isBookmarked = oldState;
      } else if (itemType == 'workflow') {
        final workflow = _findWorkflow(itemId);
        if (workflow != null) workflow.isBookmarked = oldState;
      }
      _updateBookmarkedArticles();
      _updateBookmarkedRepos();
      _updateBookmarkedPrompts();
      _updateBookmarkedWorkflows();
      notifyListeners();
    }
  }

  /// Thao tác Like (Thả tim)
  Future<void> toggleLike({required String itemType, required int itemId}) async {
    if (!_isLoggedIn) return;

    bool oldState = false;
    if (itemType == 'article') {
      final article = _findArticle(itemId);
      if (article != null) {
        oldState = article.isLiked;
        article.isLiked = !oldState;
        article.isLiked ? article.viewCount : null; // Sim view
        notifyListeners();
      }
    } else if (itemType == 'prompt') {
      final prompt = _findPrompt(itemId);
      if (prompt != null) {
        oldState = prompt.isLiked;
        prompt.isLiked = !oldState;
        prompt.isLiked ? prompt.likesCount++ : prompt.likesCount--;
        notifyListeners();
      }
    } else if (itemType == 'workflow') {
      final workflow = _findWorkflow(itemId);
      if (workflow != null) {
        oldState = workflow.isLiked;
        workflow.isLiked = !oldState;
        workflow.isLiked ? workflow.likesCount++ : workflow.likesCount--;
        notifyListeners();
      }
    }

    final success = await _apiService.interact(
      action: 'like',
      itemType: itemType,
      itemId: itemId,
      state: !oldState,
    );

    if (!success) {
      // Rollback
      if (itemType == 'article') {
        final article = _findArticle(itemId);
        if (article != null) article.isLiked = oldState;
      } else if (itemType == 'prompt') {
        final prompt = _findPrompt(itemId);
        if (prompt != null) {
          prompt.isLiked = oldState;
          prompt.isLiked ? prompt.likesCount++ : prompt.likesCount--;
        }
      } else if (itemType == 'workflow') {
        final workflow = _findWorkflow(itemId);
        if (workflow != null) {
          workflow.isLiked = oldState;
          workflow.isLiked ? workflow.likesCount++ : workflow.likesCount--;
        }
      }
      notifyListeners();
    }
  }

  /// Tăng lượt sao chép Prompt/Workflow
  Future<void> incrementCopyCount({required String itemType, required int itemId}) async {
    if (itemType == 'prompt') {
      final prompt = _findPrompt(itemId);
      if (prompt != null) {
        prompt.copyCount++;
        notifyListeners();
      }
    } else if (itemType == 'workflow') {
      final workflow = _findWorkflow(itemId);
      if (workflow != null) {
        workflow.copyCount++;
        notifyListeners();
      }
    }
    
    // Gửi API ngầm (không chặn UI)
    _apiService.interact(
      action: 'copy',
      itemType: itemType,
      itemId: itemId,
      state: true,
    );
  }

  // ============================================
  // HELPERS PHỤ TRỢ
  // ============================================
  
  Article? _findArticle(int id) {
    try {
      return _weeklyHighlights.firstWhere((a) => a.id == id);
    } catch (_) {
      try {
        return _dailyNews.firstWhere((a) => a.id == id);
      } catch (_) {
        try {
          return _bookmarkedArticles.firstWhere((a) => a.id == id);
        } catch (_) {
          return null;
        }
      }
    }
  }

  GitHubRepo? _findRepo(int id) {
    try {
      return _trendingRepos.firstWhere((r) => r.id == id);
    } catch (_) {
      try {
        return _bookmarkedRepos.firstWhere((r) => r.id == id);
      } catch (_) {
        return null;
      }
    }
  }

  CuratedPrompt? _findPrompt(int id) {
    try {
      return _curatedPrompts.firstWhere((p) => p.id == id);
    } catch (_) {
      try {
        return _bookmarkedPrompts.firstWhere((p) => p.id == id);
      } catch (_) {
        return null;
      }
    }
  }

  DevWorkflow? _findWorkflow(int id) {
    try {
      return _devWorkflows.firstWhere((w) => w.id == id);
    } catch (_) {
      try {
        return _bookmarkedWorkflows.firstWhere((w) => w.id == id);
      } catch (_) {
        return null;
      }
    }
  }

  void _updateBookmarkedArticles() {
    _bookmarkedArticles = [
      ..._weeklyHighlights.where((a) => a.isBookmarked),
      ..._dailyNews.where((a) => a.isBookmarked),
    ].fold<List<Article>>([], (list, article) {
      if (!list.any((a) => a.id == article.id)) {
        list.add(article);
      }
      return list;
    });
  }

  void _updateBookmarkedRepos() {
    _bookmarkedRepos = _trendingRepos.where((r) => r.isBookmarked).toList();
  }

  void _updateBookmarkedPrompts() {
    _bookmarkedPrompts = _curatedPrompts.where((p) => p.isBookmarked).toList();
  }

  void _updateBookmarkedWorkflows() {
    _bookmarkedWorkflows = _devWorkflows.where((w) => w.isBookmarked).toList();
  }
}
