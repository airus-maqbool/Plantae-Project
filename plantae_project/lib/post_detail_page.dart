import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:plantae_project/models/comment.dart';
import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostDetailPage extends StatefulWidget {
  final String postId;
  final String imageUrl;
  final String plantName;
  final String typePost;
  final String description;
  final String userName;
  final String userProfile;
  final String userId;
  final GeoPoint location;
  final DateTime createdAt;

  const PostDetailPage({
    super.key,
    required this.postId,
    required this.imageUrl,
    required this.plantName,
    required this.typePost,
    required this.description,
    required this.userName,
    required this.userProfile,
    required this.userId,
    required this.location,
    required this.createdAt,
  });

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final TextEditingController commentController = TextEditingController();
  bool isLoading = false;
  String locationString = '';
  bool liked = false;
  int likesCount = 0;
  Stream<QuerySnapshot>? commentsStream;

  @override
  void initState() {
    super.initState();
    _loadLocationString();
    _setupCommentsStream();
    _checkIfLiked();
    _getLikesCount();
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  Future<void> _loadLocationString() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        widget.location.latitude,
        widget.location.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          locationString = '${place.locality}, ${place.country}';
        });
      }
    } catch (e) {
      print('Error getting location string: $e');
      setState(() {
        locationString = 'Location not available';
      });
    }
  }

  void _setupCommentsStream() {
    commentsStream = FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .orderBy('created_at', descending: true)
        .snapshots();
  }

  Future<void> _checkIfLiked() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final likeDoc = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('likes')
          .doc(user.uid)
          .get();
      
      if (mounted) {
        setState(() {
          liked = likeDoc.exists;
        });
      }
    }
  }

  Future<void> _getLikesCount() async {
    final likesSnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('likes')
        .count()
        .get();
    
    if (mounted) {
      setState(() {
        likesCount = likesSnapshot.count ?? 0;
      });
    }
  }

  Future<void> _toggleLike() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to like posts')),
      );
      return;
    }

    final likeRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('likes')
        .doc(user.uid);

    if (liked) {
      await likeRef.delete();
      setState(() {
        liked = false;
        likesCount--;
      });
    } else {
      await likeRef.set({
        'created_at': FieldValue.serverTimestamp(),
      });
      setState(() {
        liked = true;
        likesCount++;
      });
    }
  }

  Future<void> _addComment(String text) async {
    if (text.trim().isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to comment')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final comment = Comment(
        id: '', // Will be set by Firestore
        userId: user.uid,
        text: text.trim(),
        createdAt: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .add(comment.toMap());

      if (mounted) {
        commentController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add comment')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Widget _buildCommentItem(Comment comment) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('Users')
          .doc(comment.userId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                CircleAvatar(radius: 16),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 100,
                        height: 12,
                        child: LinearProgressIndicator(),
                      ),
                      SizedBox(height: 4),
                      SizedBox(
                        width: double.infinity,
                        height: 12,
                        child: LinearProgressIndicator(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        final userData = snapshot.data?.data() as Map<String, dynamic>?;
        final username = userData?['username'] ?? 'Deleted User';
        final userProfilePic = userData?['profile_pic_url'] ?? '';

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundImage: userProfilePic.startsWith('data:image')
                    ? MemoryImage(base64Decode(userProfilePic.split(',')[1]))
                    : userProfilePic.isNotEmpty
                        ? NetworkImage(userProfilePic) as ImageProvider
                        : const AssetImage('assets/default_avatar.png'),
                radius: 16,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          username,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          timeago.format(comment.createdAt),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(comment.text),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Post Detail"),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
              children: [
                // Image
                widget.imageUrl.startsWith('data:image')
                    ? Image.memory(
                        base64Decode(widget.imageUrl.split(',')[1]),
                        height: 450,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print('Error loading base64 image: $error');
                          return Container(
                            height: 450,
                            color: Colors.grey[200],
                            child: Icon(Icons.error, color: Colors.grey[400]),
                          );
                        },
                      )
                    : Image.network(
                        widget.imageUrl,
                        height: 450,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 450,
                            color: Colors.grey[200],
                            child: Icon(Icons.error, color: Colors.grey[400]),
                          );
                        },
                      ),

                const SizedBox(height: 16),

                // User Info and Post Details
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User Info
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: widget.userProfile.startsWith('data:image')
                                ? MemoryImage(base64Decode(widget.userProfile.split(',')[1]))
                                : NetworkImage(widget.userProfile) as ImageProvider,
                            radius: 20,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.userName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                timeago.format(widget.createdAt),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Title and Type
                      Text(
                        widget.plantName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 238, 255, 240),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color.fromARGB(255, 21, 91, 24),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          widget.typePost,
                          style: const TextStyle(
                            color: Color.fromARGB(255, 21, 91, 24),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Description
                      Text(
                        widget.description,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Location
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Color.fromARGB(255, 21, 91, 24),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            locationString,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Likes
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              liked ? Icons.favorite : Icons.favorite_border,
                              color: liked ? Colors.red : Colors.grey,
                            ),
                            onPressed: _toggleLike,
                          ),
                          Text(
                            '$likesCount likes',
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),

                      const Divider(),

                      // Comments Section
                      const Text(
                        "Comments",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      StreamBuilder<QuerySnapshot>(
                        stream: commentsStream,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const Text('Something went wrong');
                          }

                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Text('No comments yet'),
                            );
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              final comment = Comment.fromFirestore(
                                snapshot.data!.docs[index],
                              );
                              return _buildCommentItem(comment);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Comment input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      decoration: InputDecoration(
                        hintText: "Write a comment...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: Colors.grey[300]!,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: Colors.grey[300]!,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 21, 91, 24),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: isLoading
                        ? null
                        : () => _addComment(commentController.text),
                    icon: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.send,
                            color: Color.fromARGB(255, 21, 91, 24),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
