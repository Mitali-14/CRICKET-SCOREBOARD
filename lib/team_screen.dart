import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TeamScreen extends StatefulWidget {
  @override
  _TeamScreenState createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  final _teamNameController = TextEditingController();
  final _playerNameController = TextEditingController();
  final _playerUsernameController = TextEditingController();
  final _playerAgeController = TextEditingController();
  final _playerHeightController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<Map<String, String>> players = [];
  List<String> existingPlayerNames = [];
  List<String> existingUsernames = [];

  @override
  void initState() {
    super.initState();
    _loadExistingPlayersAndUsernames();
  }

  Future<void> _loadExistingPlayersAndUsernames() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    for (String key in keys) {
      if (key.startsWith('team_')) {
        List<String> teamPlayers = prefs.getStringList(key)!;
        for (String player in teamPlayers) {
          List<String> details = player.split(',');
          existingPlayerNames.add(details[0]);
          existingUsernames.add(details[1]);
        }
      }
    }
  }

  Future<void> _saveTeam() async {
    if (_formKey.currentState!.validate() && players.length == 11) {
      final prefs = await SharedPreferences.getInstance();
      String teamName = _teamNameController.text;

      // Save team data
      List<String> playerDetails = players.map((player) {
        return '${player['name']},${player['username']},${player['age']},${player['height']}';
      }).toList();
      prefs.setStringList('team_$teamName', playerDetails);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Team $teamName saved!')),
      );

      _teamNameController.clear();
      _playerNameController.clear();
      _playerUsernameController.clear();
      _playerAgeController.clear();
      _playerHeightController.clear();

      setState(() {
        players.clear();
      });
    } else if (players.length < 11) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Each team must have 11 players')),
      );
    }
  }

  void _addPlayer() {
    if (_playerNameController.text.isNotEmpty &&
        _playerUsernameController.text.isNotEmpty &&
        _playerAgeController.text.isNotEmpty &&
        _playerHeightController.text.isNotEmpty) {
      if (!existingPlayerNames.contains(_playerNameController.text) &&
          !existingUsernames.contains(_playerUsernameController.text)) {
        setState(() {
          players.add({
            'name': _playerNameController.text,
            'username': _playerUsernameController.text,
            'age': _playerAgeController.text,
            'height': _playerHeightController.text,
          });

          existingPlayerNames.add(_playerNameController.text);
          existingUsernames.add(_playerUsernameController.text);

          _playerNameController.clear();
          _playerUsernameController.clear();
          _playerAgeController.clear();
          _playerHeightController.clear();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Player name or username must be unique')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Team')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _teamNameController,
                decoration: InputDecoration(labelText: 'Team Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a team name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _playerNameController,
                decoration: InputDecoration(labelText: 'Player Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a player name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _playerUsernameController,
                decoration: InputDecoration(labelText: 'Player Username'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a player username';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _playerAgeController,
                decoration: InputDecoration(labelText: 'Player Age'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter player age';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _playerHeightController,
                decoration: InputDecoration(labelText: 'Player Height'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter player height';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: _addPlayer,
                child: Text('Add Player'),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: players.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(players[index]['name']!),
                      subtitle: Text('Username: ${players[index]['username']}, Age: ${players[index]['age']}, Height: ${players[index]['height']}'),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: _saveTeam,
                child: Text('Save Team'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
