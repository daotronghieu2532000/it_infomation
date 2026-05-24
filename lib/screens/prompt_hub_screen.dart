import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/prompt.dart';
import '../models/dev_workflow.dart';
import '../widgets/glassmorphic_card.dart';
import '../widgets/shimmer_loader.dart';
import './workflow_detail_screen.dart';

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
      backgroundColor: const Color(0xFF0B0F19),
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
                  const Text(
                    'WORKSPACE HUB',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white70, size: 22),
                    onPressed: () {
                      if (_activeTab == 0) {
                        provider.loadPrompts();
                      } else {
                        provider.loadWorkflows();
                      }
                    },
                  )
                ],
              ),
            ),

            // Sliding Tab Toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                height: 42,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: const Color(0xFF161F30),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.04), width: 0.8),
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
                          decoration: BoxDecoration(
                            color: _activeTab == 0 ? const Color(0xFF8B5CF6) : Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'AI PROMPTS',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _activeTab == 0 ? Colors.black : Colors.white70,
                              letterSpacing: 0.5,
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
                          decoration: BoxDecoration(
                            color: _activeTab == 1 ? const Color(0xFF8B5CF6) : Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'DEV WORKFLOWS',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _activeTab == 1 ? Colors.black : Colors.white70,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF161F30),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.05), width: 0.8),
                ),
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
                        ? 'Tìm kiếm prompt (ví dụ: refactor, unit test...)'
                        : 'Tìm kiếm quy trình (ví dụ: docker, actions...)',
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

            // Categories Filter Tabs
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                itemCount: _activeTab == 0 ? promptCategories.length : workflowCategories.length,
                itemBuilder: (context, index) {
                  final cat = _activeTab == 0 ? promptCategories[index] : workflowCategories[index];
                  final isSelected = _activeTab == 0
                      ? provider.selectedPromptCategory == cat
                      : provider.selectedWorkflowCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(
                        cat.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? Colors.black : Colors.white70,
                          letterSpacing: 0.8,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (_) {
                        if (_activeTab == 0) {
                          provider.setPromptCategory(cat);
                        } else {
                          provider.setWorkflowCategory(cat);
                        }
                      },
                      selectedColor: const Color(0xFF8B5CF6), // Tech Purple for Workspace
                      backgroundColor: const Color(0xFF161F30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? const Color(0xFF8B5CF6) : Colors.white.withOpacity(0.05),
                          width: 0.8,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Main Content Area
            Expanded(
              child: _activeTab == 0
                  ? _buildPromptsList(provider)
                  : _buildWorkflowsList(provider),
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
            ? const Center(
                child: Text(
                  'Không tìm thấy prompt phù hợp.',
                  style: TextStyle(color: Colors.white60),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
            ? const Center(
                child: Text(
                  'Không tìm thấy quy trình phù hợp.',
                  style: TextStyle(color: Colors.white60),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: provider.devWorkflows.length,
                itemBuilder: (context, index) {
                  final workflow = provider.devWorkflows[index];
                  return _buildWorkflowCard(context, workflow, provider);
                },
              );
  }

  Widget _buildPromptCard(BuildContext context, CuratedPrompt prompt, AppProvider provider) {
    final isExpanded = _expandedState[prompt.id] ?? false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GlassmorphicCard(
        padding: const EdgeInsets.all(16.0),
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
                        prompt.title,
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
                              color: const Color(0xFF8B5CF6).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.3), width: 0.6),
                            ),
                            child: Text(
                              prompt.targetModel.toUpperCase(),
                              style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFF8B5CF6)),
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
                      color: const Color(0xFF8B5CF6),
                      size: 20,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // Short Description
            Text(
              prompt.description,
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
                  color: const Color(0xFF0B0F19),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withOpacity(0.05), width: 0.8),
                ),
                child: Text(
                  prompt.promptText,
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
                    foregroundColor: const Color(0xFF8B5CF6),
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(50, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    isExpanded ? 'THU GỌN' : 'CHI TIẾT',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                  ),
                ),
                const SizedBox(width: 12),
                // Premium one-click copy button
                ElevatedButton.icon(
                  onPressed: () => _copyPromptToClipboard(context, prompt, provider),
                  icon: const Icon(Icons.copy_rounded, size: 12, color: Colors.black),
                  label: const Text('COPY'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: const Size(60, 32),
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

  Widget _buildWorkflowCard(BuildContext context, DevWorkflow workflow, AppProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GlassmorphicCard(
        padding: const EdgeInsets.all(16.0),
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
                        workflow.title,
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
                              color: const Color(0xFF8B5CF6).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.3), width: 0.6),
                            ),
                            child: Text(
                              workflow.toolCategory.toUpperCase(),
                              style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFFC084FC)),
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
                      color: const Color(0xFF8B5CF6),
                      size: 20,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // Short Description
            Text(
              workflow.description,
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
                // Details button
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WorkflowDetailScreen(workflow: workflow),
                      ),
                    ).then((_) {
                      provider.loadWorkflows();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    minimumSize: const Size(80, 32),
                    textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                  ),
                  child: const Text('CHI TIẾT'),
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
    Clipboard.setData(ClipboardData(text: prompt.promptText)).then((_) {
      // Trigger Haptic feedback vibration (light impact for premium feel)
      HapticFeedback.lightImpact();

      // Update count on database and UI
      provider.incrementCopyCount(itemType: 'prompt', itemId: prompt.id);

      // Show snackbar / dynamic confirmation toast
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Color(0xFF10B981), size: 20),
              SizedBox(width: 10),
              Text(
                'Copied prompt to clipboard!',
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
  }
}
