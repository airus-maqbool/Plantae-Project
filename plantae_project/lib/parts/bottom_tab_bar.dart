import 'package:flutter/material.dart';
import 'package:plantae_project/util/AppRoutes.dart';

class BottomTabBar extends StatelessWidget {
  const BottomTabBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _getCurrentIndex(context),
        onTap: (index) => _onItemTapped(index, context),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color.fromARGB(255, 21, 91, 24),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            activeIcon: Icon(Icons.add_box),
            label: 'Add Post',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  int _getCurrentIndex(BuildContext context) {
    final String currentRoute = ModalRoute.of(context)?.settings.name ?? '';
    print('Current route: $currentRoute'); // Debug print
    
    if (currentRoute == AppRoutes.HOME_PAGE || currentRoute == '/') {
      return 0;
    } else if (currentRoute == AppRoutes.ADD_POST) {
      return 1;
    } else if (currentRoute == AppRoutes.USER_PROFILE) {
      return 2;
    }
    
    // If we can't determine the route, check the current page widget
    final currentWidget = ModalRoute.of(context)?.settings.arguments;
    if (currentWidget != null) {
      if (currentWidget.toString().contains('MainPage')) {
        return 0;
      } else if (currentWidget.toString().contains('AddPost')) {
        return 1;
      } else if (currentWidget.toString().contains('UserProfile')) {
        return 2;
      }
    }
    
    return 0; // Default to home
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.HOME_PAGE);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, AppRoutes.ADD_POST);
        break;
      case 2:
        Navigator.pushReplacementNamed(context, AppRoutes.USER_PROFILE);
        break;
    }
  }
}
