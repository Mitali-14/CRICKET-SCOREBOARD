import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MatchListScreen extends StatelessWidget {
  Future<List<Map<String, String>>> _loadMatches() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getKeys()
        .where((key) => key.startsWith('match_'))
        .map((key) {
      List<String> matchData = prefs.getStringList(key)!;
      return {
        'date': key.replaceFirst('match_', ''),
        'teamA': matchData[0],
        'teamB': matchData[1],
        'place': matchData[2],
        'overs': matchData[3],
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Match List')),
      body: FutureBuilder<List<Map<String, String>>>(
        future: _loadMatches(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No Matches Found'));
          } else {
            return ListView(
              children: snapshot.data!.map((match) {
                return ListTile(
                  title: Text('${match['teamA']} vs ${match['teamB']}'),
                  subtitle: Text('Date: ${match['date']}, Place: ${match['place']}'),
                );
              }).toList(),
            );
          }
        },
      ),
    );
  }
}
