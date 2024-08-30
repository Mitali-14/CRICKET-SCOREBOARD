import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TeamListScreen extends StatelessWidget {
  Future<List<String>> _loadTeams() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getKeys().where((key) => key.startsWith('team_')).map((key) => key.replaceFirst('team_', '')).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Team List')),
      body: FutureBuilder<List<String>>(
        future: _loadTeams(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No Teams Found'));
          } else {
            return ListView(
              children: snapshot.data!.map((team) => ListTile(title: Text(team))).toList(),
            );
          }
        },
      ),
    );
  }
}
