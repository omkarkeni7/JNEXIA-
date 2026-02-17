import 'package:flutter/material.dart';
import '../services/student_service.dart';
import '../models/performance_model.dart';
import 'learning_path_detail_page.dart';
import '../widgets/analyzing_animation.dart';

class LearningPathPage extends StatefulWidget {
  const LearningPathPage({super.key});

  @override
  State<LearningPathPage> createState() => _LearningPathPageState();
}

class _LearningPathPageState extends State<LearningPathPage> {
  List<LearningPath>? _paths;
  bool _isLoading = true;
  int _badgeCount = 0;
  List<String> _completedRoadmaps = [];

  @override
  void initState() {
    super.initState();
    _fetchPaths();
  }

  Future<void> _fetchPaths() async {
    try {
      final paths = await StudentService.getLearningPaths();
      if (mounted) {
        setState(() {
          _paths = paths;
          _isLoading = false;
          // Robust badge detection: Progress >= 90% or all steps completed
          final completed = paths.where((p) => p.progress >= 95 || p.steps.every((s) => s.status == 'completed')).toList();
          _badgeCount = completed.length;
          _completedRoadmaps = completed.map((p) => p.title).toList();
        });
      }
    } catch (e) {
      print('Error fetching paths: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _generatePath() async {
    String? topic = await showDialog<String>(
      context: context,
      builder: (context) {
        String value = '';
        return AlertDialog(
          title: const Text('New Learning Goal'),
          content: TextField(
            onChanged: (v) => value = v,
            decoration: const InputDecoration(hintText: 'e.g. Physics, Python, History'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(context, value), child: const Text('Generate')),
          ],
        );
      },
    );

    if (topic != null && topic.isNotEmpty) {
      if (mounted) setState(() => _isLoading = true);
      // Simulate "Generating" process for animation
      await Future.delayed(const Duration(seconds: 4)); 
      try {
        await StudentService.generateLearningPath(topic);
        await _fetchPaths(); 
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        await _fetchPaths();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        title: const Text('My Learning Paths', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _generatePath,
        label: const Text('New Goal', style: TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: _isLoading 
        ? const AnalyzingAnimation(
            messages: [
              "Parsing Topic...",
              "Generating Roadmap...", 
              "Structuring Modules...",
              "Finalizing Path..."
            ],
          )
        : SafeArea(
            child: Column(
              children: [
                if (_paths != null && _paths!.isNotEmpty) _buildBadgeHeader(),
                Expanded(
                  child: _paths == null || _paths!.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        itemCount: _paths!.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          return _buildPathCard(_paths![index]);
                        },
                      ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildBadgeHeader() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF40FFA7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4), blurRadius: 0)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "ACHIEVEMENTS",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$_badgeCount Badges Earned",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.stars, color: Color(0xFF40FFA7), size: 24),
                ),
              ],
            ),
          ),

          // Collection Row
          if (_completedRoadmaps.isNotEmpty)
            Container(
              height: 70,
              padding: const EdgeInsets.only(bottom: 20),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _completedRoadmaps.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified, color: Color(0xFF40FFA7), size: 16),
                        const SizedBox(width: 8),
                        Text(
                          _completedRoadmaps[index],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.map_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No learning paths yet.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _generatePath,
            child: const Text('Create your first roadmap!'),
          ),
        ],
      ),
    );
  }

  Widget _buildPathCard(LearningPath path) {
    final bool isCompleted = path.progress >= 100;
    
    return GestureDetector(
      onTap: () async {
        // Navigate to details page logic
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LearningPathDetailPage(path: path),
          ),
        );
        // Refresh when coming back (in case progress changed)
        _fetchPaths();
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4), blurRadius: 0)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isCompleted ? const Color(0xFF40FFA7) : Colors.black,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        if (isCompleted) ...[
                          const Icon(Icons.check_circle, color: Colors.black, size: 16),
                          const SizedBox(width: 6),
                        ],
                        Expanded(
                          child: Text(
                            path.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isCompleted ? Colors.black : Colors.white,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (isCompleted)
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red, width: 1.5),
                      ),
                      child: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                    ),
                    onPressed: () => _confirmDelete(path),
                    tooltip: 'Delete completed path',
                  )
                else
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600]),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              path.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: path.progress / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                isCompleted ? const Color(0xFF40FFA7) : const Color(0xFF64B5F6),
              ),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${path.progress}% Completed',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                if (isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF40FFA7),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: const Text(
                      'COMPLETED',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(LearningPath path) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.black, width: 2),
          ),
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Delete Learning Path?',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete "${path.title}"?',
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.info_outline, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This action cannot be undone.',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.black, width: 2),
                ),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _deletePath(path);
    }
  }

  Future<void> _deletePath(LearningPath path) async {
    try {
      // Show loading indicator
      if (mounted) setState(() => _isLoading = true);

      // Call delete API
      await StudentService.deleteLearningPath(path.id);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Learning path deleted successfully!',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF40FFA7),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Colors.black, width: 2),
            ),
          ),
        );
      }

      // Refresh the list
      await _fetchPaths();
    } catch (e) {
      print('Error deleting path: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Failed to delete: ${e.toString()}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Colors.black, width: 2),
            ),
          ),
        );
      }
    }
  }
}
