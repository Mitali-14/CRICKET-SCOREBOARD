import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  BottomNavBar({required this.selectedIndex, required this.onItemTapped});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.group_add, size: 30),
          label: 'Create Team',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.sports_cricket, size: 30),
          label: 'Create Match',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list, size: 30),
          label: 'Team List',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.score, size: 30),
          label: 'Match List',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.scoreboard, size: 30),
          label: 'Scoreboard',
        ),
      ],
      currentIndex: selectedIndex,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey[500],
      backgroundColor: Colors.blueAccent,
      elevation: 8,
      selectedFontSize: 14,
      unselectedFontSize: 12,
      showUnselectedLabels: true,
      onTap: onItemTapped,
    );
  }
}
