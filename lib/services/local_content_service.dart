import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Local storage service for user-edited prompts and workflows
class LocalContentService {
  static const String _promptsKey = 'local_saved_prompts';
  static const String _workflowsKey = 'local_saved_workflows';

  /// Save a user-edited prompt locally
  static Future<void> savePromptLocally({
    required int id,
    required String title,
    required String description,
    required String category,
    required String targetModel,
    required String promptText,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final prompts = prefs.getStringList(_promptsKey) ?? [];

    final newPrompt = {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'target_model': targetModel,
      'prompt_text': promptText,
      'saved_at': DateTime.now().toIso8601String(),
      'is_local': true,
    };

    // Remove old version if exists
    prompts.removeWhere((p) {
      final data = jsonDecode(p) as Map;
      return data['id'] == id;
    });

    prompts.add(jsonEncode(newPrompt));
    await prefs.setStringList(_promptsKey, prompts);
  }

  /// Save a user-edited workflow locally
  static Future<void> saveWorkflowLocally({
    required int id,
    required String title,
    required String description,
    required String toolCategory,
    required String contentMarkdown,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final workflows = prefs.getStringList(_workflowsKey) ?? [];

    final newWorkflow = {
      'id': id,
      'title': title,
      'description': description,
      'tool_category': toolCategory,
      'content_markdown': contentMarkdown,
      'saved_at': DateTime.now().toIso8601String(),
      'is_local': true,
    };

    // Remove old version if exists
    workflows.removeWhere((w) {
      final data = jsonDecode(w) as Map;
      return data['id'] == id;
    });

    workflows.add(jsonEncode(newWorkflow));
    await prefs.setStringList(_workflowsKey, workflows);
  }

  /// Get all locally saved prompts
  static Future<List<Map<String, dynamic>>> getLocalPrompts() async {
    final prefs = await SharedPreferences.getInstance();
    final prompts = prefs.getStringList(_promptsKey) ?? [];
    return prompts
        .map((p) => jsonDecode(p) as Map<String, dynamic>)
        .toList();
  }

  /// Get all locally saved workflows
  static Future<List<Map<String, dynamic>>> getLocalWorkflows() async {
    final prefs = await SharedPreferences.getInstance();
    final workflows = prefs.getStringList(_workflowsKey) ?? [];
    return workflows
        .map((w) => jsonDecode(w) as Map<String, dynamic>)
        .toList();
  }

  /// Delete a locally saved prompt
  static Future<void> deleteLocalPrompt(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final prompts = prefs.getStringList(_promptsKey) ?? [];
    prompts.removeWhere((p) {
      final data = jsonDecode(p) as Map;
      return data['id'] == id;
    });
    await prefs.setStringList(_promptsKey, prompts);
  }

  /// Delete a locally saved workflow
  static Future<void> deleteLocalWorkflow(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final workflows = prefs.getStringList(_workflowsKey) ?? [];
    workflows.removeWhere((w) {
      final data = jsonDecode(w) as Map;
      return data['id'] == id;
    });
    await prefs.setStringList(_workflowsKey, workflows);
  }

  /// Check if prompt is saved locally
  static Future<bool> isPromptSavedLocally(int id) async {
    final prompts = await getLocalPrompts();
    return prompts.any((p) => p['id'] == id);
  }

  /// Check if workflow is saved locally
  static Future<bool> isWorkflowSavedLocally(int id) async {
    final workflows = await getLocalWorkflows();
    return workflows.any((w) => w['id'] == id);
  }

  /// Get locally saved prompt by ID
  static Future<Map<String, dynamic>?> getLocalPromptById(int id) async {
    final prompts = await getLocalPrompts();
    try {
      return prompts.firstWhere((p) => p['id'] == id);
    } catch (e) {
      return null;
    }
  }

  /// Get locally saved workflow by ID
  static Future<Map<String, dynamic>?> getLocalWorkflowById(int id) async {
    final workflows = await getLocalWorkflows();
    try {
      return workflows.firstWhere((w) => w['id'] == id);
    } catch (e) {
      return null;
    }
  }
}
