import 'package:flutter/material.dart';

class MyBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  const MyBottomNavBar({Key? key, required this.selectedIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (int index) {
        if (index == selectedIndex) return;
        String route;
        switch (index) {
          case 0:
            route = '/';
            break;
          case 1:
            route = '/records';
            break;
          case 2:
            route = '/bills';
            break;
          case 3:
            route = '/profile';
            break;
          default:
            route = '/';
        }
        Navigator.pushReplacementNamed(context, route);
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.folder), label: 'Records'),
        NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Bills'),
        NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
