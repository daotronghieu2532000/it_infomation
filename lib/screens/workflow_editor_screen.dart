import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import '../models/dev_workflow.dart';
import '../providers/app_provider.dart';
import '../services/local_content_service.dart';

class WorkflowEditorScreen extends StatefulWidget {
  final DevWorkflow workflow;

  const WorkflowEditorScreen({super.key, required this.workflow});

  @override
  State<WorkflowEditorScreen> createState() => _WorkflowEditorScreenState();
}

class _WorkflowEditorScreenState extends State<WorkflowEditorScreen> {
  late TextEditingController _contentController;
  bool _isSavedLocally = false;
  bool _isEdited = false;
  bool _showPreview = false;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.workflow.contentMarkdown);
    _checkIfSavedLocally();
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _checkIfSavedLocally() async {
    final isSaved = await LocalContentService.isWorkflowSavedLocally(widget.workflow.id);
    setState(() {
      _isSavedLocally = isSaved;
    });
  }

  void _onContentChanged() {
    setState(() {
      _isEdited = _contentController.text != widget.workflow.contentMarkdown;
    });
  }

  Future<void> _saveToLocal() async {
    await LocalContentService.saveWorkflowLocally(
      id: widget.workflow.id,
      title: widget.workflow.title,
      description: widget.workflow.description,
      toolCategory: widget.workflow.toolCategory,
      contentMarkdown: _contentController.text,
    );

    setState(() {
      _isSavedLocally = true;
      _isEdited = false;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle, color: Color(0xFF30D158), size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Saved to local storage!',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
              ),
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
  }

  void _copyToClipboard() {
    String contentToCopy = _contentController.text;
    
    // Extract code blocks from markdown if possible
    final regex = RegExp(r'```[a-zA-Z]*\n([\s\S]*?)\n```');
    final match = regex.firstMatch(_contentController.text);
    if (match != null && match.groupCount >= 1) {
      contentToCopy = match.group(1) ?? _contentController.text;
    }

    Clipboard.setData(ClipboardData(text: contentToCopy)).then((_) {
      HapticFeedback.lightImpact();
      Provider.of<AppProvider>(context, listen: false)
          .incrementCopyCount(itemType: 'workflow', itemId: widget.workflow.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Color(0xFF30D158), size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Copied to clipboard!',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header with tab toggle — Apple style
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'EDIT WORKFLOW',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        if (_isSavedLocally)
                          Text(
                            '✓ Saved locally',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF30D158),
                              letterSpacing: 0.5,
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Toggle preview button
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A84FF).withOpacity(0.12),
                      border: Border.all(color: const Color(0xFF0A84FF).withOpacity(0.4), width: 0.5),
                    ),
                    child: TextButton.icon(
                      onPressed: () => setState(() => _showPreview = !_showPreview),
                      icon: Icon(_showPreview ? Icons.edit : Icons.preview, size: 16, color: const Color(0xFF0A84FF)),
                      label: Text(
                        _showPreview ? 'EDIT' : 'PREVIEW',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0A84FF),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: _showPreview
                  ? _buildPreviewView()
                  : _buildEditView(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: Color(0xFF1C1C1E),
          border: Border(top: BorderSide(color: Colors.white12, width: 0.5)),
        ),
        child: Row(
          children: [
            // Copy button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _copyToClipboard,
                icon: const Icon(Icons.copy_all_rounded, size: 16),
                label: const Text('COPY'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF0A84FF), width: 0.5),
                  foregroundColor: const Color(0xFF0A84FF),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Save button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _saveToLocal,
                icon: const Icon(Icons.cloud_download_rounded, size: 16, color: Colors.white),
                label: const Text('SAVE LOCAL'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A84FF),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Workflow info
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
          
          Text(
            widget.workflow.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          
          Text(
            widget.workflow.description,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
              color: Colors.white70,
              height: 1.4,
            ),
          ),
          const Divider(color: Colors.white12, height: 28),
          
          // Editable content
          Text(
            'Editable Content (You can modify this)',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E),
              border: Border.all(
                color: _isEdited ? const Color(0xFFFF9F0A) : Colors.white12,
                width: 0.5,
              ),
            ),
            child: TextField(
              controller: _contentController,
              onChanged: (_) => _onContentChanged(),
              maxLines: 20,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                height: 1.6,
                fontFamily: 'monospace',
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(14),
                hintText: 'Edit the workflow content here...',
                hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
              ),
            ),
          ),
          
          if (_isEdited)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: const [
                  Icon(Icons.info_outline, size: 14, color: Color(0xFFFF9F0A)),
                  SizedBox(width: 6),
                  Text(
                    'You have unsaved changes',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFF9F0A),
                    ),
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildPreviewView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Workflow info
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
          
          Text(
            widget.workflow.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          
          Text(
            widget.workflow.description,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
              color: Colors.white70,
              height: 1.4,
            ),
          ),
          const Divider(color: Colors.white12, height: 28),
          
          // Markdown preview
          MarkdownBody(
            data: _contentController.text,
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
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}
