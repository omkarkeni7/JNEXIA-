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
            child: _paths == null || _paths!.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: _paths!.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    return _buildPathCard(_paths![index]);
                  },
                ),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(path.title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  backgroundColor: Colors.black,
                ),
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
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF64B5F6)),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Text(
              '${path.progress}% Completed',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
