import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/dev_workflow.dart';
import '../providers/app_provider.dart';

class WorkflowDetailScreen extends StatefulWidget {
  final DevWorkflow workflow;

  const WorkflowDetailScreen({super.key, required this.workflow});

  @override
  State<WorkflowDetailScreen> createState() => _WorkflowDetailScreenState();
}

class _WorkflowDetailScreenState extends State<WorkflowDetailScreen> {
  void _copyToClipboard(BuildContext context) {
    // Extract code blocks from markdown if possible, otherwise copy whole markdown
    String contentToCopy = widget.workflow.contentMarkdown;
    
    // Simple regex to extract content inside the first code block if it exists
    final regex = RegExp(r'```[a-zA-Z]*\n([\s\S]*?)\n```');
    final match = regex.firstMatch(widget.workflow.contentMarkdown);
    if (match != null && match.groupCount >= 1) {
      contentToCopy = match.group(1) ?? widget.workflow.contentMarkdown;
    }

    final provider = Provider.of<AppProvider>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    Clipboard.setData(ClipboardData(text: contentToCopy)).then((_) {
      HapticFeedback.lightImpact();
      
      // Increment copy count in database
      provider.incrementCopyCount(itemType: 'workflow', itemId: widget.workflow.id);

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF30D158), size: 20),
              const SizedBox(width: 10),
              Text(
                context.tr('Đã copy code cấu hình thành công!', 'Configuration code copied successfully!'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1C1C1E),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          margin: const EdgeInsets.all(16),
        ),
      );

    });
  }

  void _shareWorkflow() {
    final text = '${context.tr('Quy trình', 'Workflow')}: ${widget.workflow.title}\n\nMô tả: ${widget.workflow.description}\n\n${context.tr('Xem chi tiết tại CodeGo TechFlow.', 'View details on CodeGo TechFlow.')}';
    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isLiked = widget.workflow.isLiked;
    final isBookmarked = widget.workflow.isBookmarked;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Glassmorphic Custom AppBar — Apple Style flat
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF1C1C1E),
                border: Border(bottom: BorderSide(color: Colors.white12, width: 0.5)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      context.tr('QUY TRÌNH PHÁT TRIỂN', 'DEV WORKFLOW'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.share_outlined, color: Colors.white70, size: 20),
                    onPressed: _shareWorkflow,
                  ),
                ],
              ),
            ),
            
            // Content List
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tool Category Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFBF5AF2).withOpacity(0.15),
                        border: Border.all(color: const Color(0xFFBF5AF2).withOpacity(0.4), width: 0.5),
                      ),
                      child: Text(
                        widget.workflow.toolCategory.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFBF5AF2),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Title
                    Text(
                      widget.workflow.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Metadata (Author & Copy Count)
                    Row(
                      children: [
                        const Icon(Icons.person_outline_rounded, size: 14, color: Colors.white54),
                        const SizedBox(width: 4),
                        Text(
                          widget.workflow.authorName,
                          style: const TextStyle(fontSize: 12, color: Colors.white54, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.copy_all_rounded, size: 14, color: Colors.white54),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.workflow.copyCount} ${context.tr('lượt copy', 'copies')}',
                          style: const TextStyle(fontSize: 12, color: Colors.white54),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white12, height: 28),
                    
                    // Summary description
                    Text(
                      widget.workflow.description,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Markdown rendering
                    MarkdownBody(
                      data: widget.workflow.contentMarkdown,
                      selectable: true,
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.6),
                        h1: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800, height: 1.8),
                        h2: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700, height: 1.6),
                        h3: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700, height: 1.4),
                        code: const TextStyle(
                          color: Color(0xFFBF5AF2),
                          backgroundColor: Color(0xFF1E1E2E),
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                        codeblockDecoration: BoxDecoration(
                          color: const Color(0xFF1C1C1E),
                          border: Border.all(color: Colors.white12, width: 0.5),
                        ),
                        blockquote: const TextStyle(color: Colors.white54, fontSize: 12, fontStyle: FontStyle.italic),
                        blockquoteDecoration: const BoxDecoration(
                          border: Border(left: BorderSide(color: Color(0xFFBF5AF2), width: 3)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: provider.isLoggedIn
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF1C1C1E),
                border: Border(top: BorderSide(color: Colors.white12, width: 0.5)),
              ),
              child: Row(
                children: [
                  // Like action
                  IconButton(
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : Colors.white70,
                    ),
                    onPressed: () {
                      provider.toggleLike(itemType: 'workflow', itemId: widget.workflow.id);
                      setState(() {
                        widget.workflow.isLiked = !isLiked;
                        isLiked ? widget.workflow.likesCount-- : widget.workflow.likesCount++;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  // Bookmark action
                  IconButton(
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: isBookmarked ? const Color(0xFF0A84FF) : Colors.white70,
                    ),
                    onPressed: () {
                      provider.toggleBookmark(itemType: 'workflow', itemId: widget.workflow.id);
                      setState(() {
                        widget.workflow.isBookmarked = !isBookmarked;
                      });
                    },
                  ),
                  const SizedBox(width: 16),
                  // Copy config action
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _copyToClipboard(context),
                      icon: const Icon(Icons.copy_all_rounded, color: Colors.white, size: 18),
                      label: Text(context.tr('SAO CHÉP CẤU HÌNH', 'COPY CONFIG / CODE')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0A84FF),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
