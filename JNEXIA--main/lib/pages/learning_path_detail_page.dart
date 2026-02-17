import 'package:flutter/material.dart';
import '../models/performance_model.dart';
import '../services/student_service.dart';
import '../widgets/celebration_overlay.dart';
import '../widgets/roadmap_completion_overlay.dart';

class LearningPathDetailPage extends StatefulWidget {
  final LearningPath path;

  const LearningPathDetailPage({super.key, required this.path});

  @override
  State<LearningPathDetailPage> createState() => _LearningPathDetailPageState();
}

class _LearningPathDetailPageState extends State<LearningPathDetailPage> {
  late LearningPath _path;
  bool _isLoading = false; // Initial load or major refresh
  bool _isStepUpdating = false; // Specific step updating
  int? _expandedStepIndex; // Track expanded step
  bool _showCelebration = false;
  bool _showFinalCelebration = false;

  @override
  void initState() {
    super.initState();
    _path = widget.path;
  }

  Future<void> _updateProgress(String pathId, int completedSteps) async {
    // Show celebration immediately
    setState(() {
       _showCelebration = true;
       _isStepUpdating = true;
    });

    try {
      await StudentService.updateLearningProgress(pathId, completedSteps);
      // Fetch updated path silently
      final updatedPath = await StudentService.getLearningPath(pathId);
      
      bool isFinalStep = completedSteps >= _path.steps.length;

      if (mounted) {
        setState(() {
          _path = updatedPath;
          _isStepUpdating = false;
          _expandedStepIndex = null; // Collapse after update
          if (isFinalStep) {
            _showFinalCelebration = true;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isStepUpdating = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update progress: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        title: Text(_path.title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context, true), 
        ),
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.black))
              : SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeaderCard(_path),
                        const SizedBox(height: 30),
                        const Text(
                          'YOUR ROADMAP',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.2, color: Colors.black54),
                        ),
                        const SizedBox(height: 20),
                        ..._path.steps.asMap().entries.map((entry) {
                          return Column(
                            children: [
                              _buildPathStep(
                                step: entry.key + 1,
                                data: entry.value,
                                index: entry.key,
                                isLast: entry.key == _path.steps.length - 1,
                              ),
                              if (entry.key != _path.steps.length - 1)
                                _buildPathConnector(entry.value.status == 'completed'),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                
          if (_showCelebration)
             CelebrationOverlay(
               onFinished: () {
                 if (mounted) setState(() => _showCelebration = false);
               },
             ),
             
          if (_showFinalCelebration)
            RoadmapCompletionOverlay(
              earnedPoints: 50, // Standard reward
              badgeName: "${_path.title} Master",
              onFinished: () {
                if (mounted) setState(() => _showFinalCelebration = false);
              },
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
    required int index,
    required bool isLast,
  }) {
    Color color;
    IconData icon;
    bool isCurrent = false;
    bool isExpanded = _expandedStepIndex == index;

    if (data.status.toLowerCase() == 'completed') {
      color = const Color(0xFFA5D6A7); // Green
      icon = Icons.check_circle;
    } else if (data.status.toLowerCase() == 'in-progress') {
      color = const Color(0xFFFFF59D); // Yellow
      isCurrent = true;
      icon = isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down;
    } else {
      color = Colors.grey.shade300;
      icon = Icons.lock;
    }

    return GestureDetector(
      onTap: () {
        if (data.status == 'locked') {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Finish previous steps first!')));
           return;
        }
        setState(() {
          if (_expandedStepIndex == index) {
            _expandedStepIndex = null; // Collapse if already expanded
          } else {
            _expandedStepIndex = index; // Expand this one
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: isCurrent 
              ? const [BoxShadow(color: Colors.black, offset: Offset(4, 4), blurRadius: 0)]
              : [],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
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
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            data.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            overflow: TextOverflow.fade,
                            softWrap: true,
                            maxLines: 2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Flexible(
                          child: Text(
                            data.description,
                            style: const TextStyle(color: Colors.black87, fontSize: 12),
                            overflow: TextOverflow.fade,
                            softWrap: true,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(icon, size: 28, color: Colors.black),
                ],
              ),
            ),
            
            // Expanded Content
            if (isExpanded)
              Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(color: Colors.black54),
                    const SizedBox(height: 10),
                    const Text(
                      "Key Concepts & Theory:",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data.content,
                      style: const TextStyle(fontSize: 14, height: 1.5),
                      softWrap: true,
                    ),
                    const SizedBox(height: 20),
                    
                    if (data.status == 'in-progress')
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isStepUpdating ? null : () {
                            _updateProgress(_path.id, index + 1);
                          },
                          icon: _isStepUpdating 
                             ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                             : const Icon(Icons.check_circle_outline, color: Colors.white),
                          label: Text(
                             _isStepUpdating ? "Completing..." : "Complete & Continue", 
                             style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPathConnector(bool isActive) {
    return Container(
      height: 30,
      width: 4,
      margin: const EdgeInsets.only(left: 40), 
      color: isActive ? Colors.black : Colors.grey.shade400,
    );
  }
}
