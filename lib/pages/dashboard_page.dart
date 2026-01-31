import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/student_model.dart'; // Keep for other sample data if needed
import '../models/performance_model.dart';
import '../services/student_service.dart';
import 'performance_analysis_page.dart';
import 'ai_analysis_page.dart';
import 'resume_upload_page.dart';
import 'profile_page.dart';
import 'chatbot_page.dart';
import '../widgets/attendance_card.dart';
import '../widgets/lms_engagement_card.dart';
import 'score_breakdown_page.dart';
import '../widgets/overall_score_card.dart';
import '../widgets/subject_marks_card.dart';
import 'learning_path_page.dart';
import 'interventions_page.dart';
import 'three_d_mentor_page.dart';


import '../models/student_profile_model.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  RiskData? _riskData;
  ScoreBreakdown? _scoreData;
  OverviewData? _overviewData;
  InterventionData? _interventionData;
  StudentProfile? _profile; // Added profile
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRiskData();
  }

  Future<void> _fetchRiskData() async {
    try {
      // Fetch all data concurrently
      final results = await Future.wait([
        StudentService.getRiskStatus(),
        StudentService.getScoreBreakdown(),
        StudentService.getOverview(),
        StudentService.getIntervention(),
        StudentService.getProfile(),
      ]);

      if (mounted) {
        setState(() {
          _riskData = results[0] as RiskData;
          _scoreData = results[1] as ScoreBreakdown;
          _overviewData = results[2] as OverviewData;
          _interventionData = results[3] as InterventionData;
          _profile = results[4] as StudentProfile;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching dashboard data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false; 
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Keep sample data for other widgets for now as requested only Risk Status
    final attendance = DashboardData.getSampleAttendance();



    Color riskColor = const Color(0xFFA8E6D5); // Default Safe (Mint)
    String riskText = 'Loading...';
    IconData riskIcon = Icons.hourglass_empty;
    Color riskIconColor = Colors.grey;

    if (!_isLoading && (_riskData != null || _overviewData != null)) {
      String level = _riskData?.riskLevel ?? _overviewData?.riskLevel ?? 'Unknown';
      bool isHighRisk = (_riskData?.isAtRisk ?? false) || 
                        level.toLowerCase() == 'high' || 
                        level.toLowerCase() == 'critical';

      if (isHighRisk) {
        riskColor = const Color(0xFFFFCDD2); // Red for High Risk
        riskText = 'Risk: $level';
        riskIcon = Icons.warning;
        riskIconColor = Colors.red;
      } else {
        riskColor = const Color(0xFFA8E6D5); // Mint for Safe
        riskText = 'Risk: ${level == "Unknown" ? "Safe" : level}';
        riskIcon = Icons.check;
        riskIconColor = Colors.green;
      }
    } else if (!_isLoading && _riskData == null && _overviewData == null) {
       riskText = 'Risk: Unknown';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFB8E6D5), // Light mint/cyan background
      body: SafeArea(
        child: Column(
          children: [
            // Top section with avatar and status
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Avatar
                  GestureDetector(
                    onTap: () {
                       Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProfilePage()),
                      ).then((result) {
                        if (mounted) {
                           // If we got a result back, it's the new avatar URL
                           if (result != null && result is String && _profile != null) {
                             setState(() {
                               _profile = StudentProfile(
                                 name: _profile!.name,
                                 email: _profile!.email,
                                 studentId: _profile!.studentId,
                                 language: _profile!.language,
                                 avatarUrl: result,
                                 instituteName: _profile!.instituteName,
                                 classes: _profile!.classes,
                                 course: _profile!.course,
                               );
                             });
                           }
                           // Do NOT fetch fresh data to avoid overwriting the local change
                           // _fetchRiskData(); 
                        }
                      });
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 2),
                        image: DecorationImage(
                          onError: (exception, stackTrace) {
                            print('Error loading avatar: $exception');
                          },
                          image: NetworkImage(
                            (_profile?.avatarUrl != null && _profile!.avatarUrl.isNotEmpty) 
                                ? _profile!.avatarUrl 
                                : 'https://api.dicebear.com/7.x/avataaars/png?seed=Felix'
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),
                  
                  // Refresh Button
                  GestureDetector(
                    onTap: () => _fetchRiskData(),
                    child: Container(
                       padding: const EdgeInsets.all(8),
                       decoration: BoxDecoration(
                         color: Colors.white,
                         shape: BoxShape.circle,
                         border: Border.all(color: Colors.black, width: 2),
                         boxShadow: const [
                           BoxShadow(
                             color: Colors.black,
                             offset: Offset(2, 2),
                             blurRadius: 0,
                           ),
                         ],
                       ),
                       child: const Icon(
                         Icons.refresh, 
                         color: Colors.black,
                         size: 24,
                       ),
                     ),
                   ),
                  
                  const SizedBox(width: 12),

                  // Chatbot Button (Moved here)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ChatbotPage()),
                      );
                    },
                    child: Container(
                       padding: const EdgeInsets.all(12),
                       decoration: BoxDecoration(
                         color: Colors.white,
                         shape: BoxShape.circle,
                         border: Border.all(color: Colors.black, width: 2),
                         boxShadow: const [
                           BoxShadow(
                             color: Colors.black,
                             offset: Offset(2, 2),
                             blurRadius: 0,
                           ),
                         ],
                       ),
                       child: const Icon(
                         Icons.smart_toy, // Unique AI/Chatbot icon
                         color: Colors.black,
                         size: 28,
                       ),
                     ),
                   ),
                ],
              ),
            ),

            // Scrollable content
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _fetchRiskData(),
                color: Colors.black,
                backgroundColor: Colors.white,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Attendance and LMS Engagement Row
                    // LMS Engagement Card (Horizontal & Compact)
                    LMSEngagementCard(
                      engagementScore: _scoreData?.lmsEngagement ?? 0,
                    ),
                    const SizedBox(height: 16),
                    
                    // Attendance Card Row (with placeholder for next card)
                    Row(
                      children: [
                        Expanded(
                          child: AttendanceCard(
                            title: 'Attendance',
                            value: '${(_scoreData?.attendance ?? 0) > 0 ? _scoreData!.attendance : (_overviewData?.attendance ?? 0)}%',
                            color: const Color(0xFFFFD54F),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                           child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: riskColor,
                              borderRadius: BorderRadius.circular(20), // Match other cards
                              border: Border.all(color: Colors.black, width: 2),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black,
                                  offset: Offset(4, 4),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    riskText,
                                    style: const TextStyle(
                                      fontSize: 14, // Slightly reduced to fit
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    riskIcon,
                                    size: 20,
                                    color: riskIconColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Overall Score Card
                    // Overall Score Card
                    OverallScoreCard(
                      overallScore: (_scoreData?.overallScore ?? 0) > 0 
                          ? _scoreData!.overallScore 
                          : (_overviewData?.overallScore ?? 0),
                      breakdown: _scoreData,
                    ),
                    const SizedBox(height: 16),



                  
                  const SizedBox(height: 16),

                  // Interventions Card
                  GestureDetector(
                    onTap: () {
                       Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const InterventionsPage()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF40FFA7), // Specified Color
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black, width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black,
                            offset: Offset(4, 4),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black, width: 2),
                            ),
                            child: const Icon(Icons.psychology, color: Colors.black),
                          ),
                          const SizedBox(width: 16),
                           Expanded(
                             child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Interventions',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                if (_interventionData != null && _interventionData!.interventionRequired)
                                  Text(
                                    '${_interventionData!.pendingActions} Actions Pending',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                else
                                  const Text(
                                    'Personalized Actions',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black87,
                                    ),
                                  ),
                              ],
                             ),
                           ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, color: Colors.black),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Resume Analyzer Card
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ResumeUploadPage()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD54F), // Yellow pop
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black, width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black,
                            offset: Offset(4, 4),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black, width: 2),
                            ),
                            child: const Icon(Icons.cloud_upload, color: Colors.black),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Resume Analyzer',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const Text(
                                  'Get AI Feedback',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, color: Colors.black),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20), 
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(child: _buildNavItem(context, Icons.view_in_ar, '3D Mentor', false, is3DMentor: true)),
            Expanded(child: _buildNavItem(context, Icons.map, 'Learning Path', false, isPath: true)), 
            Expanded(child: _buildNavItem(context, Icons.home, 'Home', true)),
            Expanded(child: _buildNavItem(context, Icons.bar_chart, 'Performance', false, isProgress: true)),
            Expanded(child: _buildNavItem(context, Icons.person_outline, 'Profile', false)),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, bool isActive, {bool isProgress = false, bool isPath = false, bool isChat = false, bool is3DMentor = false}) {
    return GestureDetector(
      onTap: () {
        if (isProgress) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const PerformanceAnalysisPage(),
            ),
          );
        } else if (isPath) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const LearningPathPage(), // Navigate to Learning Path
            ),
          );
        } else if (isChat) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ChatbotPage(),
            ),
          );
        } else if (is3DMentor) {
           Navigator.of(context).push(
            MaterialPageRoute(
               builder: (context) => const ThreeDMentorPage(),
            ),
          );
        } else if (label == 'Profile') {
           Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ProfilePage(),
            ),
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFFFA726) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.white : Colors.grey[600],
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
