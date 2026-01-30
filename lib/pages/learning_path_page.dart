import 'package:flutter/material.dart';
import '../services/student_service.dart';
import '../models/performance_model.dart';

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
    // Simple dialog to get topic
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
      try {
        await StudentService.generateLearningPath(topic);
        await _fetchPaths(); // Refresh
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
        title: const Text('My Learning Path', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
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
        ? const Center(child: CircularProgressIndicator(color: Colors.black))
        : SafeArea(
            child: _paths == null || _paths!.isEmpty
              ? _buildEmptyState()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       // Display the first/latest path for now
                       if (_paths!.isNotEmpty) ...[
                         _buildHeaderCard(_paths!.first),
                         const SizedBox(height: 30),
                         const Text(
                           'YOUR ROADMAP',
                           style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.2, color: Colors.black54),
                         ),
                         const SizedBox(height: 20),
                         ..._paths!.first.steps.asMap().entries.map((entry) {
                           return Column(
                             children: [
                               _buildPathStep(
                                 step: entry.key + 1,
                                 data: entry.value,
                                 isLast: entry.key == _paths!.first.steps.length - 1,
                               ),
                               if (entry.key != _paths!.first.steps.length - 1)
                                 _buildPathConnector(entry.value.status == 'completed'),
                             ],
                           );
                         }),
                       ]
                    ],
                  ),
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

  Widget _buildHeaderCard(LearningPath path) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Colors.grey, offset: Offset(6, 6), blurRadius: 0)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Current Goal', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(path.title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF64B5F6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('${path.progress}% Completed', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ),
          const Icon(Icons.flag, color: Colors.white, size: 48),
        ],
      ),
    );
  }

  Widget _buildPathStep({
    required int step,
    required LearningStep data,
    required bool isLast,
  }) {
    Color color;
    IconData icon;
    bool isCurrent = false;

    if (data.status.toLowerCase() == 'completed') {
      color = const Color(0xFFA5D6A7); // Green
      icon = Icons.check_circle;
    } else if (data.status.toLowerCase() == 'in-progress') {
      color = const Color(0xFFFFF59D); // Yellow
      icon = Icons.play_circle_fill;
      isCurrent = true;
    } else {
      color = Colors.grey.shade300;
      icon = Icons.lock;
    }

    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: isCurrent 
            ? const [BoxShadow(color: Colors.black, offset: Offset(4, 4), blurRadius: 0)]
            : [],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: Center(
            child: Text(
              '$step',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ),
        title: Text(data.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), // Smaller font
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(data.description, style: const TextStyle(color: Colors.black87, fontSize: 12)),
          ],
        ),
        trailing: Icon(icon, size: 28, color: Colors.black),
      ),
    );
  }

  Widget _buildPathConnector(bool isActive) {
    return Container(
      height: 30,
      width: 4,
      margin: const EdgeInsets.only(left: 40), // Align with circle center
      color: isActive ? Colors.black : Colors.grey.shade400,
    );
  }
}
