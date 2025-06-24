import 'package:flutter/material.dart';
import 'package:plantae_project/post_detail_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class PostCard extends StatelessWidget {
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

  const PostCard({
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailPage(
              postId: postId,
              imageUrl: imageUrl,
              plantName: plantName,
              typePost: typePost,
              description: description,
              userName: userName,
              userProfile: userProfile,
              userId: userId,
              location: location,
              createdAt: createdAt,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 238, 255, 240),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color.fromARGB(255, 2, 90, 44),
            width: 1,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                // Image Container
                Container(
                  height: constraints.maxHeight * 0.7,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                    child: imageUrl.startsWith('data:image')
                        ? Image.memory(
                            base64Decode(imageUrl.split(',')[1]),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              print('Error loading base64 image: $error');
                              return Container(
                                color: Colors.grey[200],
                                child: Icon(Icons.error, color: Colors.grey[400]),
                              );
                            },
                          )
                        : Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: Icon(Icons.error, color: Colors.grey[400]),
                              );
                            },
                          ),
                  ),
                ),
                // Text Container
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          plantName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          typePost,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
