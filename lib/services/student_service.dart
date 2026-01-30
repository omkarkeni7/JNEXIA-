import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../models/performance_model.dart';
import '../models/student_profile_model.dart';

class StudentService {
  static const String _baseUrl = 'https://techxpression-hackathon.onrender.com/api';

  static Future<PerformanceData> getPerformance() async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('No token found');

    final response = await http.get(
      Uri.parse('$_baseUrl/student/performance'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    print('Get Performance Status: ${response.statusCode}');
    print('Get Performance Body: ${response.body}');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['success'] == true && json['data'] != null && json['data']['currentPerformance'] != null) {
        return PerformanceData.fromJson(json['data']['currentPerformance']);
      } else {
        throw Exception('Invalid data structure');
      }
    } else {
      throw Exception('Failed to load performance data');
    }
  }

  static Future<RiskData> getRiskStatus() async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('No token found');

    final response = await http.get(
      Uri.parse('$_baseUrl/student/performance/risk'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['success'] == true && json['data'] != null) {
        return RiskData.fromJson(json['data']);
      } else {
        throw Exception('Invalid data structure');
      }
    } else {
      throw Exception('Failed to load risk status');
    }
  }

  static Future<ScoreBreakdown> getScoreBreakdown() async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('No token found');

    final response = await http.get(
      Uri.parse('$_baseUrl/student/performance/scores'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['success'] == true && json['data'] != null) {
        return ScoreBreakdown.fromJson(json['data']);
      } else {
        throw Exception('Invalid data structure');
      }
    } else {
      throw Exception('Failed to load score breakdown');
    }
  }

  static Future<TrendsData> getTrends() async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('No token found');

    final response = await http.get(
      Uri.parse('$_baseUrl/student/performance/trends'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['success'] == true && json['data'] != null) {
        return TrendsData.fromJson(json['data']);
      } else {
        throw Exception('Invalid data structure');
      }
    } else {
      throw Exception('Failed to load trends');
    }
  }

  static Future<RecommendationsData> getRecommendations() async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('No token found');

    final response = await http.get(
      Uri.parse('$_baseUrl/student/performance/recommendations'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['success'] == true && json['data'] != null) {
        return RecommendationsData.fromJson(json['data']);
      } else {
        throw Exception('Invalid data structure');
      }
    } else {
      throw Exception('Failed to load recommendations');
    }
  }

  static Future<OverviewData> getOverview() async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('No token found');

    final response = await http.get(
      Uri.parse('$_baseUrl/student/performance/overview'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['success'] == true && json['data'] != null) {
        return OverviewData.fromJson(json['data']);
      } else {
        throw Exception('Invalid data structure');
      }
    } else {
      throw Exception('Failed to load overview');
    }
  }

  static Future<List<LearningPath>> getLearningPaths() async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('No token found');

    final response = await http.get(
      Uri.parse('$_baseUrl/learning'), 
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['success'] == true && json['data'] != null) {
        return (json['data'] as List)
            .map((item) => LearningPath.fromJson(item))
            .toList();
      } else {
        return []; // Return empty list if no data
      }
    } else {
      throw Exception('Failed to load learning paths');
    }
  }
  
  static Future<void> generateLearningPath(String topic) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('No token found');

    final response = await http.post(
      Uri.parse('$_baseUrl/learning'), // Changed from /learning/generate
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'topic': topic}),
    );

    print('Generate Path Response: ${response.statusCode} - ${response.body}'); // Debug log

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to generate path: ${response.statusCode} ${response.body}');
    }
  }

  static Future<InterventionData> getIntervention() async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('No token found');

    final response = await http.get(
      Uri.parse('$_baseUrl/student/performance/intervention'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    print('Get Intervention Status: ${response.statusCode}');
    print('Get Intervention Body: ${response.body}');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['success'] == true && json['data'] != null) {
        return InterventionData.fromJson(json['data']);
      } else {
        throw Exception('Invalid data structure');
      }
    } else {
      throw Exception('Failed to load intervention data');
    }
  }

  static Future<StudentProfile> getProfile() async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('No token found');

    final response = await http.get(
      Uri.parse('$_baseUrl/student/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    print('Get Profile Status: ${response.statusCode}');
    print('Get Profile Body: ${response.body}');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      // Assuming response structure { status: success, data: { ... } } or just { ... }
      // User didn't specify GET response structure, assuming standard wrapping or direct
      // Based on Resume API, likely wrapped in 'data'
      if (json['data'] != null) {
        return StudentProfile.fromJson(json['data']);
      } else {
        return StudentProfile.fromJson(json);
      }
    } else {
      throw Exception('Failed to load profile');
    }
  }

  static Future<void> updateProfile(String name, String language, String avatarUrl) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('No token found');

    final response = await http.put(
      Uri.parse('$_baseUrl/student/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'language': language,
        'avatar': avatarUrl,
      }),
    );

    print('Update Profile Status: ${response.statusCode}');
    print('Update Profile Body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to update profile: ${response.body}');
    }
  }
}
