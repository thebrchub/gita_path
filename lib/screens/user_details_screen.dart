import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import '../theme/colors.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/google_auth_service.dart';
import 'homescreen.dart';

class UserDetailsScreen extends StatefulWidget {
  const UserDetailsScreen({super.key});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _aboutController = TextEditingController();
  
  DateTime? _selectedDate;
  File? _profileImage;
  String? _profileImageBase64;
  String? _profileImageUrl;
  bool _isSubmitting = false;
  
  late AnimationController _headerAnimController;
  late AnimationController _formAnimController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    
    _headerAnimController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _formAnimController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _formAnimController, curve: Curves.easeIn),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _formAnimController,
      curve: Curves.easeOutCubic,
    ));
    
    _headerAnimController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _formAnimController.forward();
    });
    _loadInitialProfile();
  }

  Future<void> _loadInitialProfile() async {
    try {
      // 1. Try SharedPreferences (persisted Google/backend profile)
      final prefs = await SharedPreferences.getInstance();
      final storedName = prefs.getString('user_name') ?? '';
      final storedAbout = prefs.getString('user_about') ?? '';
      final storedDob = prefs.getString('user_dob') ?? '';
      final storedPhoto = prefs.getString('user_photo') ?? '';

      if (storedName.isNotEmpty && mounted) {
        setState(() {
          _nameController.text = storedName;
        });
      }

      if (storedAbout.isNotEmpty && mounted) {
        setState(() {
          _aboutController.text = storedAbout;
        });
      }

      if (storedDob.isNotEmpty) {
        try {
          final dt = DateTime.tryParse(storedDob);
          if (dt != null && mounted) {
            setState(() => _selectedDate = dt);
          }
        } catch (_) {}
      }

      if (storedPhoto.isNotEmpty && mounted) {
        setState(() => _profileImageUrl = storedPhoto);
      }

      // 2. If still missing, try JWT claims
      if ((_nameController.text.isEmpty || _profileImageUrl == null) && await GoogleAuthService.getAuthToken() != null) {
        final claims = await GoogleAuthService.getUserFromAuthToken();
        if (claims != null && mounted) {
          if ((_nameController.text.isEmpty) && (claims['name'] ?? '').toString().isNotEmpty) {
            setState(() {
              _nameController.text = claims['name'];
            });
          }
          if (_profileImageUrl == null && (claims['picture'] ?? '').toString().isNotEmpty) {
            setState(() => _profileImageUrl = claims['picture']);
          }
          if ((_aboutController.text.isEmpty) && (claims['about'] ?? '').toString().isNotEmpty) {
            setState(() => _aboutController.text = claims['about'] ?? '');
          }
          if (_selectedDate == null && (claims['dob'] ?? '').toString().isNotEmpty) {
            final dt = DateTime.tryParse(claims['dob']);
            if (dt != null) setState(() => _selectedDate = dt);
          }
        }
      }

      // 3. Optionally try backend if still missing (non-blocking)
      if ((_nameController.text.isEmpty || _profileImageUrl == null) ) {
        try {
          final profile = await ApiService.getUserProfile();
          if (profile.isNotEmpty && mounted) {
            if ((_nameController.text.isEmpty) && (profile['name'] ?? '').toString().isNotEmpty) {
              setState(() => _nameController.text = profile['name']);
            }
            if (_profileImageUrl == null && (profile['profilePicture'] ?? '').toString().isNotEmpty) {
              setState(() => _profileImageUrl = profile['profilePicture']);
            }
            if ((_aboutController.text.isEmpty) && (profile['about'] ?? '').toString().isNotEmpty) {
              setState(() => _aboutController.text = profile['about']);
            }
            if (_selectedDate == null && (profile['dob'] ?? '').toString().isNotEmpty) {
              final dt = DateTime.tryParse(profile['dob']);
              if (dt != null) setState(() => _selectedDate = dt);
            }
          }
        } catch (_) {
          // ignore backend failures
        }
      }
    } catch (e) {
      // ignore any errors while pre-filling
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aboutController.dispose();
    _headerAnimController.dispose();
    _formAnimController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        final File imageFile = File(image.path);
        final bytes = await imageFile.readAsBytes();
        
        if (bytes.lengthInBytes > 5 * 1024 * 1024) {
          if (mounted) {
            _showError('Image size should be less than 5MB');
          }
          return;
        }

        setState(() {
          _profileImage = imageFile;
          _profileImageBase64 = base64Encode(bytes);
        });
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final age = DateTime.now().year - picked.year;
      if (age < 13) {
        _showError('You must be at least 13 years old');
        return;
      }
      
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _submitProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null) {
      _showError('Please select your date of birth');
      return;
    }

    setState(() => _isSubmitting = true);

    final profileData = {
      'name': _nameController.text.trim(),
      'dob': _formatDate(_selectedDate!),
      'about': _aboutController.text.trim().isNotEmpty
          ? _aboutController.text.trim()
          : null,
      'profilePicture': _profileImageBase64 ?? _profileImageUrl ?? '',
    };

    try {
      try {
        await ApiService.updateUserProfile(profileData);

        // persist locally as well
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', profileData['name'] ?? '');
        await prefs.setString('user_dob', profileData['dob'] ?? '');
        await prefs.setString('user_about', profileData['about'] ?? '');
        if ((_profileImageBase64 ?? '').isNotEmpty) {
          await prefs.setString('user_photo_base64', _profileImageBase64!);
        } else if ((_profileImageUrl ?? '').isNotEmpty) {
          await prefs.setString('user_photo', _profileImageUrl!);
        }
      } catch (e) {
        final err = e.toString();
        if (err.contains('405')) {
          // Backend doesn't allow update — save locally and proceed
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_name', profileData['name'] ?? '');
          await prefs.setString('user_dob', profileData['dob'] ?? '');
          await prefs.setString('user_about', profileData['about'] ?? '');
          if ((_profileImageBase64 ?? '').isNotEmpty) {
            await prefs.setString('user_photo_base64', _profileImageBase64!);
          } else if ((_profileImageUrl ?? '').isNotEmpty) {
            await prefs.setString('user_photo', _profileImageUrl!);
          }

          if (mounted) {
            _showSuccess('Profile saved locally. Proceeding to Home.');
            await Future.delayed(const Duration(milliseconds: 800));
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            }
            return;
          }
        }

        // rethrow other errors to be handled by outer catch
        rethrow;
      }

      if (mounted) {
        _showSuccess('Profile created successfully! 🎉');
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      }
    } catch (e) {
      if (mounted) _showError('Failed to create profile. Please try again.\n${e.toString()}');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFFF8E1),
              const Color(0xFFFFFBF0),
              const Color(0xFFFFE4CC),
              const Color(0xFFE3F2FD),
            ],
            stops: const [0.0, 0.3, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildAnimatedHeader(),
                  const SizedBox(height: 40),
                  
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          _buildProfilePicture(),
                          const SizedBox(height: 36),
                          _buildTextField(
                            controller: _nameController,
                            label: 'Full Name',
                            
                            icon: Icons.person_outline,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Name is required';
                              }
                              if (value.trim().length < 2) {
                                return 'Name must be at least 2 characters';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 20),
                          _buildDateField(),
                          const SizedBox(height: 20),
                          _buildAboutField(),
                          const SizedBox(height: 32),
                          _buildSubmitButton(),
                          const SizedBox(height: 20),
                          Text(
                            '* Required fields  •  Profile picture and about are optional',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedHeader() {
    return FadeTransition(
      opacity: _headerAnimController,
      child: Column(
        children: [
          const SizedBox(height: 20),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Join us on a journey of wisdom and enlightenment',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.brown.shade600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePicture() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.shade100,
                    Colors.orange.shade50,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.shade300.withOpacity(0.4),
                    blurRadius: 25,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: ClipOval(
                child: _profileImage != null
                    ? Image.file(
                        _profileImage!,
                        fit: BoxFit.cover,
                      )
                    : (_profileImageUrl != null && _profileImageUrl!.isNotEmpty)
                        ? Image.network(
                            _profileImageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.orange.shade100,
                                      Colors.orange.shade50,
                                    ],
                                  ),
                                ),
                                child: Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.orange.shade300,
                                ),
                              );
                            },
                          )
                        : Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.orange.shade100,
                                  Colors.orange.shade50,
                                ],
                              ),
                            ),
                            child: Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.orange.shade300,
                            ),
                          ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.deepOrange.shade400,
                        Colors.orange.shade500,
                      ],
                    ),
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.shade400.withOpacity(0.5),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          _profileImage != null ? 'Tap to change photo' : 'Add a profile picture',
          style: TextStyle(
            fontSize: 13,
            color: Colors.brown.shade600,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Icon(icon, size: 18, color: Colors.brown.shade700),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.brown.shade800,
                ),
              ),
              const Text(
                ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.shade100.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            style: TextStyle(
              fontSize: 16,
              color: Colors.brown.shade900,
            ),
            decoration: InputDecoration(
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 15,
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.orange.shade100, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: const Color.fromARGB(255, 255, 180, 99), width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Icon(Icons.calendar_today, size: 18, color: Colors.brown.shade700),
              const SizedBox(width: 8),
              Text(
                'Date of Birth',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.brown.shade800,
                ),
              ),
              const Text(
                ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: _selectDate,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _selectedDate != null 
                    ? AppColors.primary 
                    : Colors.orange.shade100,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.shade100.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.event,
                  color: _selectedDate != null 
                      ? const Color.fromARGB(255, 255, 180, 99) 
                      : Colors.grey.shade400,
                  size: 22,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    _selectedDate != null
                        ? _formatDate(_selectedDate!)
                        : 'Select your date of birth',
                    style: TextStyle(
                      fontSize: 12,
                      color: _selectedDate != null
                          ? Colors.brown.shade900
                          : Colors.grey.shade400,
                      fontWeight: _selectedDate != null 
                          ? FontWeight.w500 
                          : FontWeight.normal,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAboutField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
  padding: const EdgeInsets.only(left: 4, bottom: 8),
  child: Row(
    children: [
      Icon(Icons.edit_note, size: 18, color: Colors.brown.shade700),
      const SizedBox(width: 8),
      Text(
        'About You',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.brown.shade800,
        ),
      ),
      const SizedBox(width: 4),
      Text(
        '(Optional)',
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade500,
          fontStyle: FontStyle.italic,
        ),
      ),
    ],
  ),
),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.shade100.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: _aboutController,
            maxLines: 5,
            maxLength: 500,
            style: TextStyle(
              fontSize: 15,
              color: Colors.brown.shade900,
              height: 1.5,
            ),
            validator: (value) {
              // Only validate if user entered something
              if (value != null && value.trim().isNotEmpty && value.trim().length < 20) {
                return 'Please write at least 20 characters';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: 'Share your spiritual journey or what brings you to the Gita... (Optional)',
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 12,
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.orange.shade100, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: const Color.fromARGB(255, 255, 180, 99), width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              contentPadding: const EdgeInsets.all(18),
              counterStyle: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: _isSubmitting
              ? [Colors.grey.shade400, Colors.grey.shade500]
              : [
                  Colors.deepOrange.shade400,
                  Colors.orange.shade500,
                ],
        ),
        boxShadow: _isSubmitting
            ? []
            : [
                BoxShadow(
                  color: Colors.orange.shade400.withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isSubmitting
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Creating your profile...',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Complete Profile',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 22),
                ],
              ),
      ),
    );
  }
}