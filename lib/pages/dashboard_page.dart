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
      final risk = await StudentService.getRiskStatus();
      final scores = await StudentService.getScoreBreakdown();
      final overview = await StudentService.getOverview();
      final intervention = await StudentService.getIntervention();
      final profile = await StudentService.getProfile();
      if (mounted) {
        setState(() {
          _riskData = risk;
          _scoreData = scores;
          _overviewData = overview;
          _interventionData = intervention;
      _profile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching dashboard data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false; // Still stop loading on error
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

    if (!_isLoading && _riskData != null) {
      bool isHighRisk = _riskData!.isAtRisk || 
                        _riskData!.riskLevel.toLowerCase() == 'high' || 
                        _riskData!.riskLevel.toLowerCase() == 'critical';

      if (isHighRisk) {
        riskColor = const Color(0xFFFFCDD2); // Red for High Risk
        riskText = 'Risk: ${_riskData!.riskLevel}';
        riskIcon = Icons.warning;
        riskIconColor = Colors.red;
      } else {
        riskColor = const Color(0xFFA8E6D5); // Mint for Safe
        riskText = 'Risk: ${_riskData!.riskLevel == "Unknown" ? "Safe" : _riskData!.riskLevel}';
        riskIcon = Icons.check;
        riskIconColor = Colors.green;
      }
    } else if (!_isLoading && _riskData == null) {
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

                  // App Title
                  // App Title Removed
                  const Spacer(),
                ],
              ),
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
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
                            value: '${_scoreData?.attendance ?? 0}%',
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
                      overallScore: _scoreData?.overallScore ?? _overviewData?.overallScore ?? 0,
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
            Expanded(child: _buildNavItem(context, Icons.chat_bubble_outline, 'Chatbot', false, isChat: true)),
            Expanded(child: _buildNavItem(context, Icons.map, 'Learning Path', false, isPath: true)), 
            Expanded(child: _buildNavItem(context, Icons.home, 'Home', true)),
            Expanded(child: _buildNavItem(context, Icons.bar_chart, 'Performance', false, isProgress: true)),
            Expanded(child: _buildNavItem(context, Icons.person_outline, 'Profile', false)),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, bool isActive, {bool isProgress = false, bool isPath = false, bool isChat = false}) {
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
