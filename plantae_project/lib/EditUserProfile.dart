import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:plantae_project/parts/locationInputField.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plantae_project/util/permission_handler.dart';
import 'dart:convert';

class EditUserProfile extends StatefulWidget {
  const EditUserProfile({super.key});

  @override
  State<EditUserProfile> createState() => _EditUserProfileState();
}

class _EditUserProfileState extends State<EditUserProfile> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _profilePicUrlController = TextEditingController();
  Position? _userLocation;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  static const String defaultProfilePic = "https://img.freepik.com/premium-vector/vector-flat-illustration-grayscale-avatar-user-profile-person-icon-gender-neutral-silhouette-profile-picture-suitable-social-media-profiles-icons-screensavers-as-templatex9xa_719432-2210.jpg";

  @override
  void initState() {
    super.initState();
    _loadCurrentUserData();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _aboutController.dispose();
    _profilePicUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      // Check camera permission if using camera
      if (source == ImageSource.camera) {
        bool hasPermission = await PermissionManager.handleCameraPermission();
        if (!hasPermission) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Camera permission is required to take photos'),
                duration: Duration(seconds: 3),
              ),
            );
          }
          return;
        }
      }

      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 150,
        maxHeight: 150,
        imageQuality: 25,
      );
      
      if (image != null) {
        setState(() => _isLoading = true);

        final bytes = await image.readAsBytes();
        final base64String = base64Encode(bytes);
        final imageUrl = 'data:image/jpeg;base64,$base64String';

        setState(() {
          _profilePicUrlController.text = imageUrl;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to process image. Please try again')),
      );
    }
  }

  Future<void> _loadCurrentUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userData = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .get();

        if (!mounted) return;

        if (userData.exists) {
          final data = userData.data()!;
          final profilePicUrl = data['profile_pic_url'];
          
          setState(() {
            _usernameController.text = data['username'] ?? '';
            _aboutController.text = data['about'] ?? '';
            _profilePicUrlController.text = (profilePicUrl != null && profilePicUrl.toString().trim().isNotEmpty) 
                ? profilePicUrl 
                : defaultProfilePic;
          });
        } else {
          setState(() {
            _profilePicUrlController.text = defaultProfilePic;
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error loading profile data')),
      );
    }
  }

  void _setLocation(Position pos) {
    setState(() {
      _userLocation = pos;
    });
  }

  Future<void> _updateProfile() async {
    if (_usernameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a username')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      final updates = {
        'username': _usernameController.text.trim(),
        'about': _aboutController.text.trim(),
        'profile_pic_url': _profilePicUrlController.text,
        'last_updated': FieldValue.serverTimestamp(),
      };

      if (_userLocation != null) {
        updates['location'] = GeoPoint(_userLocation!.latitude, _userLocation!.longitude);
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .update(updates);
      } else {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .set({
              ...updates,
              'email': user.email,
              'created_at': FieldValue.serverTimestamp(),
            });
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error updating profile')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showImageSourceDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Profile Picture'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text("Edit Profile", style: TextStyle(fontSize: 20)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 0.3),
                      ),
                      child: ClipOval(
                        child: _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color.fromARGB(255, 21, 91, 24),
                                  ),
                                ),
                              )
                            : _profilePicUrlController.text.startsWith('data:image')
                                ? Image.memory(
                                    base64Decode(_profilePicUrlController.text.split(',')[1]),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      print('Error loading base64 profile image: $error');
                                      return const Icon(Icons.person, size: 50, color: Colors.grey);
                                    },
                                  )
                                : Image.network(
                                    _profilePicUrlController.text,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.person, size: 50, color: Colors.grey);
                                    },
                                  ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _showImageSourceDialog,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 21, 91, 24),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.person, color: Color.fromARGB(255, 21, 91, 24)),
                  labelText: "Username",
                  hintText: "Enter username",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(20),
                  FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9_]")),
                ],
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _aboutController,
                maxLines: 3,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.info_outline, color: Color.fromARGB(255, 21, 91, 24)),
                  labelText: "About",
                  hintText: "Tell us about yourself...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(150),
                ],
              ),
              const SizedBox(height: 16),

              LocationInputField(onLocationSelected: _setLocation),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 21, 91, 24),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          "Update Profile",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
