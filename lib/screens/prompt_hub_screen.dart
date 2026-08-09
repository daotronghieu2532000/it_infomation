import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/prompt.dart';
import '../models/dev_workflow.dart';
import '../widgets/glassmorphic_card.dart';
import '../widgets/shimmer_loader.dart';
import '../services/local_content_service.dart';
import './prompt_editor_screen.dart';
import './workflow_editor_screen.dart';
import 'settings_screen.dart';

class PromptHubScreen extends StatefulWidget {
  const PromptHubScreen({super.key});

  @override
  State<PromptHubScreen> createState() => _PromptHubScreenState();
}

class _PromptHubScreenState extends State<PromptHubScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Map<int, bool> _expandedState = {}; // Track expanded prompt cards
  int _activeTab = 0; // 0: AI Prompts, 1: Dev Workflows

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final promptCategories = ['All', 'Refactoring', 'Debugging', 'Testing', 'Code Generation'];
    final workflowCategories = ['All', 'GitHub Actions', 'Docker', 'Cursor IDE', 'Git'];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      context.tr('TRUNG TÂM PHÁT TRIỂN', 'WORKSPACE HUB'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded, color: Colors.white70, size: 22),
                        onPressed: () {
                          if (_activeTab == 0) {
                            provider.loadPrompts();
                          } else {
                            provider.loadWorkflows();
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings_outlined, color: Colors.white70, size: 22),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const SettingsScreen()),
                          );
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),

            // Sliding Tab Toggle — Apple style phẳng phân cách bởi |
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.white12, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _activeTab = 0;
                          _searchController.clear();
                        });
                      },
                      child: Container(
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border(
                            right: const BorderSide(color: Colors.white12, width: 0.5),
                            bottom: BorderSide(
                              color: _activeTab == 0 ? const Color(0xFF0A84FF) : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          context.tr('PROMPTS', 'PROMPTS'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: _activeTab == 0 ? const Color(0xFF0A84FF) : Colors.white54,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _activeTab = 1;
                          _searchController.clear();
                        });
                      },
                      child: Container(
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border(
                            right: const BorderSide(color: Colors.white12, width: 0.5),
                            bottom: BorderSide(
                              color: _activeTab == 1 ? const Color(0xFF0A84FF) : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          context.tr('WORKFLOWS', 'WORKFLOWS'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: _activeTab == 1 ? const Color(0xFF0A84FF) : Colors.white54,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _activeTab = 2;
                          _searchController.clear();
                        });
                      },
                      child: Container(
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: _activeTab == 2 ? const Color(0xFF0A84FF) : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          context.tr('ĐÃ LƯU', 'SAVED'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: _activeTab == 2 ? const Color(0xFF0A84FF) : Colors.white54,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar (hidden in SAVED tab)
            if (_activeTab != 2)
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.white12, width: 0.5),
                  ),
                ),
                child: Container(
                  color: const Color(0xFF1C1C1E),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    onChanged: (val) {
                      if (_activeTab == 0) {
                        provider.loadPrompts(search: val);
                      } else {
                        provider.loadWorkflows(search: val);
                      }
                    },
                    decoration: InputDecoration(
                      hintText: _activeTab == 0
                          ? context.tr('Tìm kiếm prompt (ví dụ: refactor, unit test...)', 'Search prompts (e.g. refactor, unit test...)')
                          : context.tr('Tìm kiếm quy trình (ví dụ: docker, actions...)', 'Search workflows (e.g. docker, actions...)'),
                      hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                      prefixIcon: const Icon(Icons.search, color: Colors.white54, size: 20),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.white54, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                if (_activeTab == 0) {
                                  provider.loadPrompts();
                                } else {
                                  provider.loadWorkflows();
                                }
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),

            // Categories Filter Tabs (hidden in SAVED tab) — Apple style text + |
            if (_activeTab != 2)
              Container(
                height: 42,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.white12, width: 0.5),
                  ),
                ),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemCount: _activeTab == 0 ? promptCategories.length : workflowCategories.length,
                  itemBuilder: (context, index) {
                    final cats = _activeTab == 0 ? promptCategories : workflowCategories;
                    final cat = cats[index];
                    final isSelected = _activeTab == 0
                        ? provider.selectedPromptCategory == cat
                        : provider.selectedWorkflowCategory == cat;
                    final isLast = index == cats.length - 1;
                    final label = (() {
                      if (cat == 'All') return context.tr('TẤT CẢ', 'ALL');
                      if (cat == 'Refactoring') return context.tr('TỐI ƯU', 'REFACTOR');
                      if (cat == 'Debugging') return context.tr('SỬA LỖI', 'DEBUG');
                      if (cat == 'Testing') return context.tr('KIỂM THỬ', 'TESTING');
                      if (cat == 'Code Generation') return context.tr('SINH CODE', 'GEN CODE');
                      return cat.toUpperCase();
                    })();
                    return Row(
                      children: [
                        InkWell(
                          onTap: () {
                            if (_activeTab == 0) {
                              provider.setPromptCategory(cat);
                            } else {
                              provider.setWorkflowCategory(cat);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
                                color: isSelected ? const Color(0xFF0A84FF) : Colors.white54,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                        if (!isLast)
                          const Text(
                            '|',
                            style: TextStyle(color: Colors.white24, fontSize: 12, fontWeight: FontWeight.w300),
                          ),
                      ],
                    );
                  },
                ),
              ),

            // Main Content Area
            Expanded(
              child: _activeTab == 0
                  ? _buildPromptsList(provider)
                  : _activeTab == 1
                      ? _buildWorkflowsList(provider)
                      : _buildSavedList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromptsList(AppProvider provider) {
    return provider.isLoadingPrompts
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ShimmerLoader.listSkeleton(count: 3),
          )
        : provider.curatedPrompts.isEmpty
            ? Center(
                child: Text(
                  context.tr('Không tìm thấy prompt phù hợp.', 'No matching prompts found.'),
                  style: const TextStyle(color: Colors.white60),
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: provider.curatedPrompts.length,
                itemBuilder: (context, index) {
                  final prompt = provider.curatedPrompts[index];
                  return _buildPromptCard(context, prompt, provider);
                },
              );
  }

  Widget _buildWorkflowsList(AppProvider provider) {
    return provider.isLoadingWorkflows
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ShimmerLoader.listSkeleton(count: 3),
          )
        : provider.devWorkflows.isEmpty
            ? Center(
                child: Text(
                  context.tr('Không tìm thấy quy trình phù hợp.', 'No matching workflows found.'),
                  style: const TextStyle(color: Colors.white60),
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: provider.devWorkflows.length,
                itemBuilder: (context, index) {
                  final workflow = provider.devWorkflows[index];
                  return _buildWorkflowCard(context, workflow, provider);
                },
              );
  }

  Widget _buildSavedList() {
    return FutureBuilder(
      future: Future.wait([
        LocalContentService.getLocalPrompts(),
        LocalContentService.getLocalWorkflows(),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ShimmerLoader.listSkeleton(count: 3),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Center(
            child: Text(
              context.tr('Không có mục đã lưu.', 'No saved items.'),
              style: const TextStyle(color: Colors.white60),
            ),
          );
        }

        final savedPrompts = snapshot.data![0] as List<dynamic>;
        final savedWorkflows = snapshot.data![1] as List<dynamic>;
        final allSaved = [...savedPrompts, ...savedWorkflows];

        if (allSaved.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bookmark_border, size: 48, color: Colors.white30),
                const SizedBox(height: 16),
                Text(
                  context.tr('Chưa có mục đã lưu', 'No saved items yet'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr('Chỉnh sửa prompt hoặc workflow và nhấn "SAVE LOCAL"', 'Edit a prompt or workflow and press "SAVE LOCAL"'),
                  style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemCount: allSaved.length,
          itemBuilder: (context, index) {
            final item = allSaved[index];

            // Check if it's a saved prompt
            if (item is Map<String, dynamic> && item.containsKey('category')) {
              return _buildSavedPromptCard(context, item);
            } else if (item is Map<String, dynamic> && item.containsKey('toolCategory')) {
              return _buildSavedWorkflowCard(context, item);
            }

            return const SizedBox.shrink();
          },
        );
      },
    );
  }

  Widget _buildSavedPromptCard(BuildContext context, Map<String, dynamic> prompt) {
    final isExpanded = _expandedState[prompt['id']] ?? false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GlassmorphicCard(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Status Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              prompt['title'] ?? 'Untitled Prompt',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          // Local badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3), width: 0.6),
                            ),
                            child: const Text(
                              'SAVED LOCALLY',
                              style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFF10B981)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Category badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.3), width: 0.6),
                        ),
                        child: Text(
                          (prompt['category'] ?? 'General').toString().toUpperCase(),
                          style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFFC084FC)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Description
            Text(
              prompt['description'] ?? '',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white60,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),

            // Saved date
            Text(
              'Saved: ${prompt['saved_at'] ?? 'Unknown'}',
              style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.4)),
            ),
            const SizedBox(height: 12),

            // Collapsible Prompt Body
            if (isExpanded) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B0F19),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withOpacity(0.05), width: 0.8),
                ),
                child: Text(
                  prompt['prompt_text'] ?? '',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: Color(0xFFE2E8F0),
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Action row
            Row(
              children: [
                const SizedBox(width: 4),
                // Expand / Collapse
                TextButton(
                  onPressed: () {
                    setState(() {
                      _expandedState[prompt['id']] = !isExpanded;
                    });
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF8B5CF6),
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(50, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    isExpanded ? context.tr('THU GỌN', 'COLLAPSE') : context.tr('CHI TIẾT', 'DETAILS'),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                  ),
                ),
                const Spacer(),
                // Copy button
                ElevatedButton.icon(
                  onPressed: () {
                    final text = prompt['prompt_text'] ?? '';
                    Clipboard.setData(ClipboardData(text: text)).then((_) {
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: const [
                              Icon(Icons.check_circle, color: Color(0xFF10B981), size: 20),
                              SizedBox(width: 10),
                              Text(
                                'Copied to clipboard!',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                              ),
                            ],
                          ),
                          backgroundColor: const Color(0xFF161F30),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          margin: const EdgeInsets.all(16),
                        ),
                      );

                    });
                  },
                  icon: const Icon(Icons.copy_rounded, size: 12, color: Colors.black),
                  label: const Text('COPY'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: const Size(50, 28),
                    textStyle: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.4),
                  ),
                ),
                const SizedBox(width: 8),
                // Delete button
                OutlinedButton.icon(
                  onPressed: () {
                    showCupertinoDialog(
                      context: context,
                      builder: (context) => CupertinoAlertDialog(
                        title: const Text('Delete Saved Prompt?'),
                        content: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text('This will remove "${prompt['title']}" from your saved items.'),
                        ),
                        actions: [
                          CupertinoDialogAction(
                            isDefaultAction: true,
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          CupertinoDialogAction(
                            isDestructiveAction: true,
                            onPressed: () {
                              LocalContentService.deleteLocalPrompt(prompt['id']);
                              Navigator.pop(context);
                              setState(() {});
                            },
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete_outline, size: 12),
                  label: const Text('DELETE'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red, width: 0.8),
                    foregroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    minimumSize: const Size(50, 28),
                    textStyle: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedWorkflowCard(BuildContext context, Map<String, dynamic> workflow) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GlassmorphicCard(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              workflow['title'] ?? 'Untitled Workflow',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          // Local badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3), width: 0.6),
                            ),
                            child: const Text(
                              'SAVED LOCALLY',
                              style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFF10B981)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Tool category badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.3), width: 0.6),
                        ),
                        child: Text(
                          (workflow['toolCategory'] ?? 'General').toString().toUpperCase(),
                          style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFFC084FC)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Description
            Text(
              workflow['description'] ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white60,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),

            // Saved date
            Text(
              'Saved: ${workflow['saved_at'] ?? 'Unknown'}',
              style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.4)),
            ),
            const SizedBox(height: 12),

            // Action row
            Row(
              children: [
                const Spacer(),
                // Copy button
                ElevatedButton.icon(
                  onPressed: () {
                    final text = workflow['content_markdown'] ?? '';
                    Clipboard.setData(ClipboardData(text: text)).then((_) {
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: const [
                              Icon(Icons.check_circle, color: Color(0xFF10B981), size: 20),
                              SizedBox(width: 10),
                              Text(
                                'Copied to clipboard!',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                              ),
                            ],
                          ),
                          backgroundColor: const Color(0xFF161F30),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          margin: const EdgeInsets.all(16),
                        ),
                      );

                    });
                  },
                  icon: const Icon(Icons.copy_rounded, size: 12, color: Colors.black),
                  label: const Text('COPY'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    minimumSize: const Size(80, 32),
                    textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                  ),
                ),
                const SizedBox(width: 8),
                // Delete button
                OutlinedButton.icon(
                  onPressed: () {
                    showCupertinoDialog(
                      context: context,
                      builder: (context) => CupertinoAlertDialog(
                        title: const Text('Delete Saved Workflow?'),
                        content: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text('This will remove "${workflow['title']}" from your saved items.'),
                        ),
                        actions: [
                          CupertinoDialogAction(
                            isDefaultAction: true,
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          CupertinoDialogAction(
                            isDestructiveAction: true,
                            onPressed: () {
                              LocalContentService.deleteLocalWorkflow(workflow['id']);
                              Navigator.pop(context);
                              setState(() {});
                            },
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete_outline, size: 12),
                  label: const Text('DELETE'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red, width: 0.8),
                    foregroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    minimumSize: const Size(80, 32),
                    textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromptCard(BuildContext context, CuratedPrompt prompt, AppProvider provider) {
    final isExpanded = _expandedState[prompt.id] ?? false;

    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white12, width: 0.5),
        ),
      ),
      child: GlassmorphicCard(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        borderRadius: 0,
        borderWidth: 0,
        backgroundColor: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getPromptTitle(prompt, provider.isEnglish),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          // Target AI Model badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFBF5AF2).withOpacity(0.12),
                              border: Border.all(color: const Color(0xFFBF5AF2).withOpacity(0.3), width: 0.5),
                            ),
                            child: Text(
                              prompt.targetModel.toUpperCase(),
                              style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFFBF5AF2)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Category
                          Text(
                            prompt.category.toUpperCase(),
                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white38),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Bookmark icon
                if (provider.isLoggedIn)
                  GestureDetector(
                    onTap: () => provider.toggleBookmark(itemType: 'prompt', itemId: prompt.id),
                    child: Icon(
                      prompt.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: const Color(0xFF0A84FF),
                      size: 20,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // Short Description
            Text(
              _getPromptDescription(prompt, provider.isEnglish),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white60,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),

            // Collapsible Prompt Body
            if (isExpanded) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1E),
                  border: Border.all(color: Colors.white12, width: 0.5),
                ),
                child: Text(
                  _getPromptText(prompt, provider.isEnglish),
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: Color(0xFFE2E8F0),
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Action row (Like, Copy, Expand)
            Row(
              children: [
                // Hearts Likes
                if (provider.isLoggedIn) ...[
                  GestureDetector(
                    onTap: () => provider.toggleLike(itemType: 'prompt', itemId: prompt.id),
                    child: Row(
                      children: [
                        Icon(
                          prompt.isLiked ? Icons.favorite : Icons.favorite_border,
                          color: prompt.isLiked ? Colors.red : Colors.white54,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${prompt.likesCount}',
                          style: const TextStyle(fontSize: 11, color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                ],
                // Copy symbol stat
                const Icon(Icons.copy_all, size: 14, color: Colors.white38),
                const SizedBox(width: 4),
                Text(
                  '${prompt.copyCount} copies',
                  style: const TextStyle(fontSize: 11, color: Colors.white38),
                ),
                const Spacer(),
                // Expand / Collapse Action text
                TextButton(
                  onPressed: () {
                    setState(() {
                      _expandedState[prompt.id] = !isExpanded;
                    });
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF0A84FF),
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(50, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    isExpanded ? context.tr('THU GỌN', 'COLLAPSE') : context.tr('CHI TIẾT', 'DETAILS'),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                  ),
                ),
                const SizedBox(width: 12),
                // Edit button
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PromptEditorScreen(prompt: prompt),
                      ),
                    ).then((_) {
                      provider.loadPrompts();
                    });
                  },
                  icon: const Icon(Icons.edit_rounded, size: 11),
                  label: const Text('EDIT'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF0A84FF), width: 0.5),
                    foregroundColor: const Color(0xFF0A84FF),
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: const Size(50, 28),
                    textStyle: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.4),
                  ),
                ),
                const SizedBox(width: 8),
                // Premium one-click copy button
                ElevatedButton.icon(
                  onPressed: () => _copyPromptToClipboard(context, prompt, provider),
                  icon: const Icon(Icons.copy_rounded, size: 12, color: Colors.white),
                  label: const Text('COPY'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A84FF),
                    foregroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: const Size(50, 28),
                    textStyle: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkflowCard(BuildContext context, DevWorkflow workflow, AppProvider provider) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white12, width: 0.5),
        ),
      ),
      child: GlassmorphicCard(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        borderRadius: 0,
        borderWidth: 0,
        backgroundColor: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getWorkflowTitle(workflow, provider.isEnglish),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          // Tool category badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFBF5AF2).withOpacity(0.12),
                              border: Border.all(color: const Color(0xFFBF5AF2).withOpacity(0.3), width: 0.5),
                            ),
                            child: Text(
                              workflow.toolCategory.toUpperCase(),
                              style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFFBF5AF2)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Author
                          Text(
                            workflow.authorName,
                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white38),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Bookmark icon
                if (provider.isLoggedIn)
                  GestureDetector(
                    onTap: () => provider.toggleBookmark(itemType: 'workflow', itemId: workflow.id),
                    child: Icon(
                      workflow.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: const Color(0xFF0A84FF),
                      size: 20,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // Short Description
            Text(
              _getWorkflowDescription(workflow, provider.isEnglish),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white60,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),

            // Action row
            Row(
              children: [
                // Hearts Likes
                if (provider.isLoggedIn) ...[
                  GestureDetector(
                    onTap: () => provider.toggleLike(itemType: 'workflow', itemId: workflow.id),
                    child: Row(
                      children: [
                        Icon(
                          workflow.isLiked ? Icons.favorite : Icons.favorite_border,
                          color: workflow.isLiked ? Colors.red : Colors.white54,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${workflow.likesCount}',
                          style: const TextStyle(fontSize: 11, color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                ],
                // Copy count
                const Icon(Icons.copy_all, size: 14, color: Colors.white38),
                const SizedBox(width: 4),
                Text(
                  '${workflow.copyCount} copies',
                  style: const TextStyle(fontSize: 11, color: Colors.white38),
                ),
                const Spacer(),
                // Edit button
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WorkflowEditorScreen(workflow: workflow),
                      ),
                    ).then((_) {
                      provider.loadWorkflows();
                    });
                  },
                  icon: const Icon(Icons.edit_rounded, size: 14, color: Colors.black),
                  label: const Text('EDIT'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    minimumSize: const Size(80, 32),
                    textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _copyPromptToClipboard(BuildContext context, CuratedPrompt prompt, AppProvider provider) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final textToCopy = _getPromptText(prompt, provider.isEnglish);
    Clipboard.setData(ClipboardData(text: textToCopy)).then((_) {
      // Trigger Haptic feedback vibration (light impact for premium feel)
      HapticFeedback.lightImpact();

      // Update count on database and UI
      provider.incrementCopyCount(itemType: 'prompt', itemId: prompt.id);

      // Show snackbar / dynamic confirmation toast
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 20),
              const SizedBox(width: 10),
              Text(
                context.tr('Đã sao chép prompt vào bộ nhớ tạm!', 'Copied prompt to clipboard!'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF161F30),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
    });
  }

  // DỊCH THUẬT PROMPTS MẪU SANG TIẾNG ANH
  String _getPromptTitle(CuratedPrompt prompt, bool isEnglish) {
    if (!isEnglish) return prompt.title;
    switch (prompt.id) {
      case 1:
        return 'Refactor Complex Functions & Optimize Performance';
      case 2:
        return 'Auto-Generate Comprehensive Test Cases (Unit Test)';
      case 3:
        return 'Explain Bug & Propose Fixes from Error Logs';
      default:
        return prompt.title;
    }
  }

  String _getPromptDescription(CuratedPrompt prompt, bool isEnglish) {
    if (!isEnglish) return prompt.description;
    switch (prompt.id) {
      case 1:
        return 'Helps restructure overly long functions, optimize algorithms, and ensure Clean Code compliance.';
      case 2:
        return 'Create thorough test scenarios (unit tests) including boundary conditions and exception handling.';
      case 3:
        return 'Analyze stack traces or terminal error messages to pinpoint the root cause and provide corrective code.';
      default:
        return prompt.description;
    }
  }

  String _getPromptText(CuratedPrompt prompt, bool isEnglish) {
    if (!isEnglish) return prompt.promptText;
    switch (prompt.id) {
      case 1:
        return 'Act as a senior code optimization engineer. Analyze the following function of mine: [PASTE YOUR FUNCTION HERE]. Please point out performance bottlenecks, violations of Clean Code principles (SOLID, DRY), and rewrite the function in the cleanest, most optimized way. Provide detailed explanations for each change.';
      case 2:
        return 'I have a piece of code written in [PROGRAMMING LANGUAGE]: [PASTE YOUR CODE HERE]. Please write a comprehensive suite of Unit Tests for this code. Ensure coverage for: normal success scenarios, extreme boundary cases, and error input or crash-prone scenarios. Use the language\'s popular testing framework.';
      case 3:
        return 'I encountered the following error in the terminal while running the app: [PASTE ERROR LOGS/STACK TRACE]. Here is the code most likely causing the issue: [PASTE RELATED CODE]. Please explain the root cause of this error in English and provide the fully corrected code to resolve it.';
      default:
        return prompt.promptText;
    }
  }

  // DỊCH THUẬT WORKFLOWS MẪU SANG TIẾNG ANH
  String _getWorkflowTitle(DevWorkflow workflow, bool isEnglish) {
    if (!isEnglish) return workflow.title;
    switch (workflow.id) {
      case 1:
        return 'Configure CI/CD Flutter with GitHub Actions for Auto-building APK & IPA';
      case 2:
        return 'Optimal Docker Compose Setup for Local PHP 8.2 & Nginx & MySQL';
      case 3:
        return 'Best Shortcut Keys & Custom Rules Setup in Cursor IDE';
      case 4:
        return 'Auto-Format & Validate Code via Git Hooks (husky & lint-staged)';
      default:
        return workflow.title;
    }
  }

  String _getWorkflowDescription(DevWorkflow workflow, bool isEnglish) {
    if (!isEnglish) return workflow.description;
    switch (workflow.id) {
      case 1:
        return 'Complete workflow to automate building installation packages for Android and iOS on every push to main.';
      case 2:
        return 'Configure a comprehensive local development containerized stack for PHP/Laravel with a single command.';
      case 3:
        return 'Tips to customize Cursor rules for writing code twice as fast with AI using a solid .cursorrules file.';
      case 4:
        return 'Prevent dirty code from entering your repository by running automated formatter checks on pre-commit.';
      default:
        return workflow.description;
    }
  }
}
