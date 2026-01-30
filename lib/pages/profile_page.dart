import 'package:flutter/material.dart';
import '../models/student_profile_model.dart';
import '../services/student_service.dart';
import '../services/auth_service.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _languageController;
  
  StudentProfile? _profile;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _selectedAvatarUrl;

  final Map<String, List<String>> _avatarOptions = {
    'Male': [
      'https://api.dicebear.com/7.x/avataaars/png?seed=Felix',
      'https://api.dicebear.com/7.x/avataaars/png?seed=Jack',
      'https://api.dicebear.com/7.x/avataaars/png?seed=Jude',
    ],
    'Female': [
      'https://api.dicebear.com/7.x/avataaars/png?seed=Aneka',
      'https://api.dicebear.com/7.x/avataaars/png?seed=Mila',
      'https://api.dicebear.com/7.x/avataaars/png?seed=Zoe',
    ],
    'Heroes': [
      'https://api.dicebear.com/7.x/adventurer/png?seed=Batman',
      'https://api.dicebear.com/7.x/adventurer/png?seed=Superman',
      'https://api.dicebear.com/7.x/adventurer/png?seed=WonderWoman',
      'https://api.dicebear.com/7.x/adventurer/png?seed=Spiderman',
    ],
  };

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _languageController = TextEditingController();
    _fetchProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _languageController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfile() async {
    try {
      final profile = await StudentService.getProfile();
      setState(() {
        _profile = profile;
        _nameController.text = profile.name;
        _languageController.text = profile.language;
        _selectedAvatarUrl = profile.avatarUrl;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    
    try {
      await StudentService.updateProfile(
        _nameController.text,
        _languageController.text,
        _selectedAvatarUrl ?? _profile!.avatarUrl,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB8E6D5), // Mint background
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Avatar Display
                      Center(
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white, 
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 3),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black,
                                offset: Offset(4, 4),
                                blurRadius: 0,
                              ),
                            ],
                            image: _selectedAvatarUrl != null 
                              ? DecorationImage(image: NetworkImage(_selectedAvatarUrl!), fit: BoxFit.cover)
                              : null,
                          ),
                          child: _selectedAvatarUrl == null 
                            ? const Icon(Icons.person, size: 60, color: Colors.black) 
                            : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _profile?.studentId ?? '',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Avatar Selector
                      _buildAvatarSelector(),
                      const SizedBox(height: 24),

                      // Name Field
                      _buildNeuTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 24),

                      // Language Field
                      _buildNeuTextField(
                        controller: _languageController,
                        label: 'Preferred Language',
                        icon: Icons.language,
                      ),
                      const SizedBox(height: 24),
                      
                      // Read-only Email
                       _buildNeuTextField(
                        controller: TextEditingController(text: _profile?.email),
                        label: 'Email',
                        icon: Icons.email_outlined,
                        readOnly: true,
                      ),
                      const SizedBox(height: 40),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _updateProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(color: Colors.black, width: 2),
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text(
                                  'Save Changes',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Logout Button
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () async {
                            await AuthService.logout();
                            if (mounted) {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (context) => const LoginPage()),
                                (route) => false,
                              );
                            }
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Log Out',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildAvatarSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose Avatar',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ..._avatarOptions.entries.expand((entry) {
                return entry.value.map((url) => GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedAvatarUrl = url;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selectedAvatarUrl == url ? Colors.black : Colors.transparent, 
                        width: 3
                      ),
                    ),
                    padding: const EdgeInsets.all(4), // Padding for border
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[200],
                      backgroundImage: NetworkImage(url),
                    ),
                  ),
                ));
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNeuTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: readOnly ? Colors.grey[200] : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black, width: 2),
            boxShadow: readOnly
                ? []
                : const [
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(4, 4),
                      blurRadius: 0,
                    ),
                  ],
          ),
          child: TextFormField(
            controller: controller,
            readOnly: readOnly,
            validator: (value) {
              if (!readOnly && (value == null || value.isEmpty)) {
                return 'Please enter $label';
              }
              return null;
            },
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.black),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
