import 'package:cricket_scoreboard/bottom_nav_bar.dart';
import 'package:cricket_scoreboard/scoreboard_screen.dart';
import 'package:cricket_scoreboard/team_list_screen.dart';
import 'package:cricket_scoreboard/team_screen.dart';
import 'package:flutter/material.dart';

import 'match_list_screen.dart';
import 'match_screen.dart';

void main() {
  runApp(CricketScoreApp());
}

class CricketScoreApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cricket Scoreboard',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(),
      routes: {
        '/team': (context) => TeamScreen(),
        '/match': (context) => MatchScreen(),
        '/teams': (context) => TeamListScreen(),
        '/matches': (context) => MatchListScreen(),
        '/match-scoreboard': (context) => ScoreboardScreen(matchKey: '',),
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  static List<Widget> _screens = <Widget>[
    TeamScreen(),
    MatchScreen(),
    TeamListScreen(),
    MatchListScreen(),
    ScoreboardScreen(matchKey: '',),

  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
