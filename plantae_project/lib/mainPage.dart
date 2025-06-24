import 'package:flutter/material.dart';
import 'package:plantae_project/parts/post_card.dart';
import 'package:plantae_project/parts/filter_buttons.dart';
import 'package:plantae_project/parts/bottom_tab_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MainPage extends StatefulWidget {
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final Set<String> _selectedFilters = {'See all'};
  List<Map<String, dynamic>> _posts = [];
  List<Map<String, dynamic>> _filteredPosts = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _mapFilterToActionType(String filter) {
    switch (filter) {
      case 'Sell': return 'Sell';
      case 'Give away': return 'Give Away';
      case 'Swap': return 'Swap';
      case 'Flowers': return 'Flower';
      default: return filter;
    }
  }

  void _filterPosts() {
    if (_posts.isEmpty) {
      _filteredPosts = [];
      return;
    }

    List<Map<String, dynamic>> result = List.from(_posts);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      result = result.where((post) {
        final title = post['title'].toString().toLowerCase();
        final type = post['action_type'].toString().toLowerCase();
        final searchLower = _searchQuery.toLowerCase();
        return title.contains(searchLower) || type.contains(searchLower);
      }).toList();
    }

    // Apply category filter
    if (!_selectedFilters.contains('See all')) {
      final actionTypes = _selectedFilters.map(_mapFilterToActionType).toList();
      result = result.where((post) => 
        actionTypes.contains(post['action_type'])
      ).toList();
    }

    setState(() {
      _filteredPosts = result;
    });
  }

  Future<void> _fetchPosts() async {
    setState(() => _isLoading = true);
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .orderBy('created_at', descending: true)
          .get();

      final posts = await Future.wait(querySnapshot.docs.map((doc) async {
        final data = doc.data();
        
        // Fetch user data
        final userData = await FirebaseFirestore.instance
            .collection('Users')
            .doc(data['user_id'])
            .get();
        
        return {
          'id': doc.id,
          'image_url': data['image_url'] ?? '',
          'title': data['title'] ?? '',
          'action_type': data['action_type'] ?? '',
          'description': data['description'] ?? '',
          'user_id': data['user_id'] ?? '',
          'username': userData['username'] ?? 'Anonymous',
          'user_profile_pic': userData['profile_pic_url'] ?? '',
          'location': data['location'] as GeoPoint,
          'created_at': (data['created_at'] as Timestamp).toDate(),
        };
      }).toList());

      setState(() {
        _posts = posts;
        _filterPosts();
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching posts: $e');
      setState(() {
        _isLoading = false;
        _posts = [];
        _filteredPosts = [];
      });
    }
  }

  void _toggleFilter(String filter) {
    setState(() {
      if (filter == 'See all') {
        if (_selectedFilters.contains('See all')) {
          return;
        } else {
          _selectedFilters.clear();
          _selectedFilters.add('See all');
        }
      } else {
        if (_selectedFilters.contains(filter)) {
          _selectedFilters.remove(filter);
          if (_selectedFilters.isEmpty) {
            _selectedFilters.add('See all');
          }
        } else {
          _selectedFilters.remove('See all');
          _selectedFilters.add(filter);
        }
      }
    });
    _filterPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        title: Row(
          children: [Image.asset('assets/logo.png', height: 90, width: 90)],
        ),
      ),
      bottomNavigationBar: BottomTabBar(),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by title or type...',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.grey[600]),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                              _filterPosts();
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                    _filterPosts();
                  },
                ),
              ),
            ),

            // Filter Buttons
            Container(
              padding: EdgeInsets.symmetric(vertical: 2),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FilterButton(
                    icon: Icons.all_inclusive,
                    filterName: 'See all',
                    isSelected: _selectedFilters.contains('See all'),
                    onPressed: () => _toggleFilter('See all'),
                  ),
                  FilterButton(
                    icon: Icons.local_florist,
                    filterName: 'Flowers',
                    isSelected: _selectedFilters.contains('Flowers'),
                    onPressed: () => _toggleFilter('Flowers'),
                  ),
                  FilterButton(
                    icon: Icons.shopping_cart,
                    filterName: 'Sell',
                    isSelected: _selectedFilters.contains('Sell'),
                    onPressed: () => _toggleFilter('Sell'),
                  ),
                  FilterButton(
                    icon: Icons.redeem,
                    filterName: 'Give away',
                    isSelected: _selectedFilters.contains('Give away'),
                    onPressed: () => _toggleFilter('Give away'),
                  ),
                  FilterButton(
                    icon: Icons.sync_alt,
                    filterName: 'Swap',
                    isSelected: _selectedFilters.contains('Swap'),
                    onPressed: () => _toggleFilter('Swap'),
                  ),
                ],
              ),
            ),

            // Posts Grid
            Expanded(
              child: _isLoading
                ? Center(child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 21, 91, 24)),
                  ))
                : _filteredPosts.isEmpty
                  ? Center(
                      child: Text(
                        _searchQuery.isNotEmpty
                            ? 'No posts found matching "${_searchQuery}"'
                            : 'No posts found',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      color: Color.fromARGB(255, 21, 91, 24),
                      onRefresh: _fetchPosts,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: GridView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 6,
                            mainAxisSpacing: 6,
                          ),
                          itemCount: _filteredPosts.length,
                          itemBuilder: (context, index) {
                            final post = _filteredPosts[index];
                            return PostCard(
                              postId: post['id'],
                              imageUrl: post['image_url'],
                              plantName: post['title'],
                              typePost: post['action_type'],
                              description: post['description'],
                              userName: post['username'],
                              userProfile: post['user_profile_pic'],
                              userId: post['user_id'],
                              location: post['location'],
                              createdAt: post['created_at'],
                            );
                          },
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// that occupy full width-> list
// in singlechild scroll view , add column and then add multiple widgets for vertical scroll, but we are not going to do like this
// listTile-> for a list item, leading : first box, trailing: lastbox
// grid view for row, column
// container takes that width that takes its child.
// for container full screen  width- width: double.infinity
