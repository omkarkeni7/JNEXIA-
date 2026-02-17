class PerformanceData {
  final int score;
  final String riskLevel;
  final String trends;
  final List<String> recommendations;
  final int attendance;
  final int internalMarks;

  PerformanceData({
    required this.score,
    required this.riskLevel,
    required this.trends,
    required this.recommendations,
    required this.attendance,
    required this.internalMarks,
  });

  factory PerformanceData.fromJson(Map<String, dynamic> json) {
    return PerformanceData(
      score: (double.tryParse((json['score'] ?? json['overallScore'] ?? 0).toString()) ?? 0).toInt(),
      riskLevel: json['riskLevel']?.toString() ?? 'Unknown',
      trends: json['trends']?.toString() ?? 'Stable',
      recommendations: List<String>.from(json['recommendations'] ?? []),
      attendance: (double.tryParse((json['attendance'] ?? 0).toString()) ?? 0).toInt(),
      internalMarks: (double.tryParse((json['internalMarks'] ?? 0).toString()) ?? 0).toInt(),
    );
  }
}

class RiskData {
  final bool isAtRisk;
  final String riskLevel;
  final List<String> riskFactors;

  RiskData({
    required this.isAtRisk,
    required this.riskLevel,
    required this.riskFactors,
  });

  factory RiskData.fromJson(Map<String, dynamic> json) {
    return RiskData(
      isAtRisk: json['isAtRisk'] ?? false,
      riskLevel: json['riskLevel'] ?? 'Unknown',
      riskFactors: List<String>.from(json['riskFactors'] ?? []),
    );
  }
}

class ScoreBreakdown {
  final int attendance;
  final int internalMarks;
  final int assignmentScore;
  final int overallScore;
  final int lmsEngagement;

  ScoreBreakdown({
    required this.attendance,
    required this.internalMarks,
    required this.assignmentScore,
    required this.overallScore,
    required this.lmsEngagement,
  });

  factory ScoreBreakdown.fromJson(Map<String, dynamic> json) {
    return ScoreBreakdown(
      attendance: (double.tryParse((json['attendance'] ?? 0).toString()) ?? 0).toInt(),
      internalMarks: (double.tryParse((json['internalMarks'] ?? 0).toString()) ?? 0).toInt(),
      assignmentScore: (double.tryParse((json['assignmentScore'] ?? 0).toString()) ?? 0).toInt(),
      overallScore: (double.tryParse((json['overallScore'] ?? json['score'] ?? 0).toString()) ?? 0).toInt(),
      lmsEngagement: (double.tryParse((json['lmsEngagement'] ?? 0).toString()) ?? 0).toInt(),
    );
  }
}

class TrendsData {
  final String trends;
  final String analysisDate;
  final int totalAnalyses;

  TrendsData({
    required this.trends,
    required this.analysisDate,
    required this.totalAnalyses,
  });

  factory TrendsData.fromJson(Map<String, dynamic> json) {
    return TrendsData(
      trends: json['trends'] ?? 'Unknown',
      analysisDate: json['analysisDate'] ?? '',
      totalAnalyses: json['totalAnalyses'] ?? 0,
    );
  }
}

class RecommendationsData {
  final List<String> recommendations;
  final List<String> strengths;
  final List<String> concerns;

  RecommendationsData({
    required this.recommendations,
    required this.strengths,
    required this.concerns,
  });

  factory RecommendationsData.fromJson(Map<String, dynamic> json) {
    return RecommendationsData(
      recommendations: List<String>.from(json['recommendations'] ?? []),
      strengths: List<String>.from(json['strengths'] ?? []),
      concerns: List<String>.from(json['concerns'] ?? []),
    );
  }
}

class OverviewData {
  final String riskLevel;
  final int overallScore;
  final int attendance;

  OverviewData({
    required this.riskLevel,
    required this.overallScore,
    required this.attendance,
  });

  factory OverviewData.fromJson(Map<String, dynamic> json) {
    return OverviewData(
      riskLevel: json['riskLevel']?.toString() ?? 'Unknown',
      overallScore: (double.tryParse((json['overallScore'] ?? json['score'] ?? 0).toString()) ?? 0).toInt(),
      attendance: (double.tryParse((json['attendance'] ?? 0).toString()) ?? 0).toInt(),
    );
  }
}

class LearningStep {
  final String title;
  final String description;
  final String content; // Theory or detailed data
  final String status; // 'completed', 'in-progress', 'locked'

  LearningStep({
    required this.title,
    required this.description,
    required this.content,
    required this.status,
  });

  factory LearningStep.fromJson(Map<String, dynamic> json) {
    return LearningStep(
      title: json['title'] ?? 'Untitled Step',
      description: json['description'] ?? '',
      content: json['content'] ?? json['theory'] ?? 'Detailed theory and learning materials for this step will appear here. Mastering this concept is key to progressing further in your roadmap.',
      status: json['status'] ?? 'locked',
    );
  }
}

class LearningPath {
  final String id;
  final String title;
  final String description;
  final int progress;
  final List<LearningStep> steps;

  LearningPath({
    required this.id,
    required this.title,
    required this.description,
    required this.progress,
    required this.steps,
  });

  factory LearningPath.fromJson(Map<String, dynamic> json) {
    int completedCount = json['completedSteps'] ?? 0;
    
    // 1. Flatten all steps from all courses into a single list of raw maps
    List<dynamic> headers = [];
    if (json['courses'] != null) {
      for (var course in json['courses']) {
         if (course['steps'] != null) {
           headers.addAll(course['steps']);
         }
      }
    } else if (json['steps'] != null) {
      headers.addAll(json['steps']);
    }

    // 2. Map raw data to LearningStep objects with calculated status
    List<LearningStep> parsedSteps = [];
    for (int i = 0; i < headers.length; i++) {
       String derivedStatus;
       if (i < completedCount) {
         derivedStatus = 'completed';
       } else if (i == completedCount) {
         derivedStatus = 'in-progress';
       } else {
         derivedStatus = 'locked';
       }

       parsedSteps.add(LearningStep(
         title: headers[i]['title'] ?? 'Untitled Step',
         description: headers[i]['description'] ?? '',
         content: headers[i]['content'] ?? headers[i]['theory'] ?? 'Overview of ${headers[i]['title']}: \n\nThis module covers the fundamental concepts and practical applications. Read through the provided materials and complete the exercises to verify your understanding.',
         status: derivedStatus,
       ));
    }

    // Limit to 6 steps for better user engagement
    final limitedSteps = parsedSteps.take(6).toList();

    return LearningPath(
      id: json['_id'] ?? '',
      title: json['topic'] ?? 'General Path',
      description: json['description'] ?? 'Your personalized roadmap',
      progress: json['progress'] ?? 0,
      steps: limitedSteps,
    );
  }
}

class InterventionAction {
  final String id;
  final String title;
  final String description;
  final String status;

  InterventionAction({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
  });

  factory InterventionAction.fromJson(Map<String, dynamic> json) {
    // Map 'type' to title if title is missing, and handle description
    String displayTitle = json['title'] ?? json['type']?.toString().replaceAll('_', ' ').toUpperCase() ?? 'ACTION';
    
    return InterventionAction(
      id: json['_id'] ?? json['id'] ?? '',
      title: displayTitle,
      description: json['description'] ?? '',
      status: json['status'] ?? 'pending',
    );
  }
}

class InterventionData {
  final bool interventionRequired;
  final String priority;
  final String owner;
  final List<InterventionAction> actions;
  final int daysUntilReview;
  final int pendingActions;

  InterventionData({
    required this.interventionRequired,
    required this.priority,
    required this.owner,
    required this.actions,
    required this.daysUntilReview,
    required this.pendingActions,
  });

  factory InterventionData.fromJson(Map<String, dynamic> json) {
    return InterventionData(
      interventionRequired: json['interventionRequired'] ?? false,
      priority: json['priority'] ?? 'Low',
      owner: json['owner'] ?? 'Unknown',
      actions: (json['actions'] as List<dynamic>?)
              ?.map((e) => InterventionAction.fromJson(e))
              .toList() ??
          [],
      daysUntilReview: json['daysUntilReview'] ?? 0,
      pendingActions: json['pendingActions'] ?? 0,
    );
  }
}
