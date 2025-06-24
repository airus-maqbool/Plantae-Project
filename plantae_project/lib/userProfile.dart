import 'package:flutter/material.dart';
import 'package:plantae_project/LogOutDialogBox.dart';
import 'package:plantae_project/parts/bottom_tab_bar.dart';
import 'package:plantae_project/util/AppRoutes.dart';
import 'package:plantae_project/util/user_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:plantae_project/util/permission_handler.dart';

class UserProfile extends StatefulWidget {
  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> with SingleTickerProviderStateMixin {
  List<String> userPosts = [];
  bool isLoading = true;
  String? username;
  String locationText = 'Location not set';
  GeoPoint? userGeoPoint;
  late TabController _tabController;
  
  // Updated default profile image URL to match EditUserProfile
  static const String DEFAULT_PROFILE_PIC = "https://img.freepik.com/premium-vector/vector-flat-illustration-grayscale-avatar-user-profile-person-icon-gender-neutral-silhouette-profile-picture-suitable-social-media-profiles-icons-screensavers-as-templatex9xa_719432-2210.jpg";
  final String defaultAboutText = "Tell us about yourself by editing your profile...";
  
  String profilePicUrl = "";  // Will be set in initState
  String aboutText = "";      // Will be set in initState
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Initialize with defaults
    profilePicUrl = DEFAULT_PROFILE_PIC;
    aboutText = defaultAboutText;
    _loadUserData();
    _loadUserPosts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<String> _getLocationString(GeoPoint location) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return '${place.locality}, ${place.country}';
      }
    } catch (e) {
      print('Error getting location string: $e');
    }
    return 'Location set';
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        print('Loading data for user ID: ${user.uid}');

        final userData = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .get();
        
        print('User data exists: ${userData.exists}');
        if (userData.exists) {
          final data = userData.data()!;
          print('Full user data: $data');

          final fetchedUsername = data['username'];
          final location = data['location'];
          final fetchedProfilePicUrl = data['profile_pic_url'];
          final fetchedAbout = data['about'];
          
          print('Fetched profile picture URL: $fetchedProfilePicUrl');
          
          print('Raw location data: $location');
          String locationString = 'Location not set';
          
          if (location != null) {
            if (location is GeoPoint) {
              print('Location coordinates: ${location.latitude}, ${location.longitude}');
              locationString = await _getLocationString(location);
              setState(() {
                userGeoPoint = location;
              });
            } else {
              print('Location is not a GeoPoint, it is: ${location.runtimeType}');
            }
          } else {
            print('Location is null in Firestore');
          }

          setState(() {
            username = fetchedUsername ?? 'User';
            locationText = locationString;
            // Only update if the fetched values are not null or empty
            if (fetchedProfilePicUrl != null && fetchedProfilePicUrl.isNotEmpty) {
              profilePicUrl = fetchedProfilePicUrl;
            }
            if (fetchedAbout != null && fetchedAbout.isNotEmpty) {
              aboutText = fetchedAbout;
            }
          });
        }
      }
    } catch (e, stackTrace) {
      print('Error loading user data: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        username = 'User';
        locationText = 'Location not set';
        // Reset to defaults on error
        profilePicUrl = DEFAULT_PROFILE_PIC;
        aboutText = defaultAboutText;
      });
    }
  }

  Future<void> _loadUserPosts() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        print('Loading posts for user ID: ${user.uid}'); // Debug print

        // Get posts from 'posts' collection where user_id matches
        final QuerySnapshot postsSnapshot = await FirebaseFirestore.instance
            .collection('posts')
            .where('user_id', isEqualTo: user.uid)
            .get();

        print('Found ${postsSnapshot.docs.length} posts'); // Debug print

        // Extract image URLs from posts
        List<String> imageUrls = [];
        for (var doc in postsSnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final imageUrl = data['image_url'] as String?;
          print('Post data: $data'); // Debug print
          if (imageUrl != null && imageUrl.isNotEmpty) {
            imageUrls.add(imageUrl);
          }
        }

        print('Extracted ${imageUrls.length} valid image URLs'); // Debug print

        setState(() {
          userPosts = imageUrls;
          isLoading = false;
        });
      } else {
        print('No user logged in');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading posts: $e');
      setState(() {
        isLoading = false;
      });
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
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 70,
      );
      
      if (image != null) {
        await _uploadProfilePicture(File(image.path));
      }
    } catch (e) {
      print('Error picking image: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: ${e.toString()}')),
      );
    }
  }

  Future<void> _uploadProfilePicture(File imageFile) async {
    try {
      setState(() => isLoading = true);
      
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Convert image to base64
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      
      // Add data:image/jpeg;base64, prefix for proper image display
      String imageUrl = 'data:image/jpeg;base64,$base64Image';
      
      // Update Firestore with base64 image string
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .update({'profile_pic_url': imageUrl});
      
      // Update local state
      setState(() {
        profilePicUrl = imageUrl;
        isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile picture updated successfully')),
      );
    } catch (e) {
      print('Error uploading profile picture: $e');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile picture')),
      );
    }
  }

  Widget _buildLocationView() {
    if (userGeoPoint == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, color: Colors.grey[400], size: 50),
            SizedBox(height: 16),
            Text(
              'Location not set',
              style: TextStyle(color: Colors.grey[600], fontSize: 18),
            ),
          ],
        ),
      );
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(userGeoPoint!.latitude, userGeoPoint!.longitude),
        zoom: 12,
      ),
      markers: {
        Marker(
          markerId: MarkerId('userLocation'),
          position: LatLng(userGeoPoint!.latitude, userGeoPoint!.longitude),
          infoWindow: InfoWindow(title: locationText),
        ),
      },
      zoomControlsEnabled: true,
      mapToolbarEnabled: true,
      myLocationButtonEnabled: true,
      rotateGesturesEnabled: true,
      scrollGesturesEnabled: true,
      tiltGesturesEnabled: true,
      zoomGesturesEnabled: true,
      mapType: MapType.normal,
    );
  }
 
  Widget _buildPostsView() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            Color.fromARGB(255, 21, 91, 24),
          ),
        ),
      );
    }

    if (userPosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library, color: Colors.grey[400], size: 50),
            SizedBox(height: 16),
            Text(
              'No posts yet',
              style: TextStyle(color: Colors.grey[600], fontSize: 18),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
      ),
      itemCount: userPosts.length,
      itemBuilder: (context, index) {
        final imageUrl = userPosts[index];
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey, width: 0.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageUrl.startsWith('data:image')
                ? Image.memory(
                    base64Decode(imageUrl.split(',')[1]),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print('Error loading base64 image: $error');
                      return Container(
                        color: Colors.grey[200],
                        child: Icon(Icons.error),
                      );
                    },
                  )
                : Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: Icon(Icons.error),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text("Profile", style: TextStyle(fontSize: 20)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,

        // for 3 dot menu
        actions: [
          PopupMenuButton(
            onSelected: (value) async {
              if (value == 1) {
                await Navigator.of(context).pushNamed("/edit_user_profile").then((_) {
                  // Reload user data when returning from edit profile
                  _loadUserData();
                });
              } else if (value == 2) {
                await UserAuth.logout();
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (route) => false);
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Log out successfully")));
              }
            },
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                    value: 1,
                    child: Text(
                      "Edit Profile",
                      style: TextStyle(
                          fontWeight: FontWeight.normal, color: Colors.black),
                    )),
                const PopupMenuItem(
                    value: 2,
                    child: Text(
                      "Log Out",
                      style: TextStyle(
                          fontWeight: FontWeight.normal, color: Colors.black),
                    )),
              ];
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomTabBar(),
      body: Column(
        children: [
          // Profile Section
          Container(
            margin: const EdgeInsets.all(3.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Picture without Edit Icon
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 0.6),
                  ),
                  child: ClipOval(
                    child: profilePicUrl.startsWith('data:image')
                        ? Image.memory(
                            base64Decode(profilePicUrl.split(',')[1]),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              print('Error loading base64 profile image: $error');
                              return Container(
                                color: Colors.grey[200],
                                child: Icon(Icons.person, size: 40),
                              );
                            },
                          )
                        : Image.network(
                            profilePicUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: Icon(Icons.person, size: 40),
                              );
                            },
                          ),
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  username ?? 'Loading...',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 5),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed("/edit_user_profile").then((_) {
                      // Reload user data when returning from edit profile
                      _loadUserData();
                    });
                  },
                  child: Text(
                    aboutText,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                SizedBox(height: 25),
              ],
            ),
          ),

          // Tab Bar
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  icon: Icon(Icons.grid_on),
                  text: 'Posts',
                ),
                Tab(
                  icon: Icon(Icons.location_on),
                  text: 'Location',
                ),
              ],
              labelColor: Color.fromARGB(255, 21, 91, 24),
              unselectedLabelColor: Colors.grey,
              indicatorColor: Color.fromARGB(255, 21, 91, 24),
            ),
          ),

          // Tab Bar View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPostsView(),
                _buildLocationView(),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }
}
