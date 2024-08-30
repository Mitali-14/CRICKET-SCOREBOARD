import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScoreboardScreen extends StatefulWidget {
  final String matchKey;

  ScoreboardScreen({required this.matchKey});

  @override
  _ScoreboardScreenState createState() => _ScoreboardScreenState();
}

class _ScoreboardScreenState extends State<ScoreboardScreen> {
  late String _teamA;
  late String _teamB;
  List<Map<String, dynamic>> _teamAPlayers = [];
  List<Map<String, dynamic>> _teamBPlayers = [];
  int _teamATotal = 0;
  int _teamBTotal = 0;

  @override
  void initState() {
    super.initState();
    _loadMatchDetails();
  }

  Future<void> _loadMatchDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final matchData = prefs.getStringList(widget.matchKey);
      if (matchData == null || matchData.length < 2) {
        throw Exception("Match data is incomplete.");
      }
      _teamA = matchData[0];
      _teamB = matchData[1];

      final teamAScores = prefs.getStringList('${widget.matchKey}_teamA_scores') ?? [];
      final teamBScores = prefs.getStringList('${widget.matchKey}_teamB_scores') ?? [];

      setState(() {
        _teamAPlayers = teamAScores.map((score) {
          final parts = score.split(',');
          if (parts.length < 3) {
            return {'run': 0, 'ball': 0, 'out': false}; // Default values
          }
          int run = int.tryParse(parts[0]) ?? 0;
          int ball = int.tryParse(parts[1]) ?? 0;
          bool out = parts[2] == 'true';
          _teamATotal += run;
          return {'run': run, 'ball': ball, 'out': out};
        }).toList();

        _teamBPlayers = teamBScores.map((score) {
          final parts = score.split(',');
          if (parts.length < 3) {
            return {'run': 0, 'ball': 0, 'out': false}; // Default values
          }
          int run = int.tryParse(parts[0]) ?? 0;
          int ball = int.tryParse(parts[1]) ?? 0;
          bool out = parts[2] == 'true';
          _teamBTotal += run;
          return {'run': run, 'ball': ball, 'out': out};
        }).toList();
      });
    } catch (e) {
      print("Error loading match scores: $e");
      setState(() {
        _teamA = 'Unknown';
        _teamB = 'Unknown';
        _teamAPlayers = [];
        _teamBPlayers = [];
        _teamATotal = 0;
        _teamBTotal = 0;
      });
    }
  }

  Future<void> _saveScores() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('${widget.matchKey}_teamA_scores', _teamAPlayers.map((p) => '${p['run']},${p['ball']},${p['out']}').toList());
    prefs.setStringList('${widget.matchKey}_teamB_scores', _teamBPlayers.map((p) => '${p['run']},${p['ball']},${p['out']}').toList());
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Scores Saved!')));
  }

  Widget _buildPlayerScoreInput(int index, List<Map<String, dynamic>> players, String team) {
    if (index >= players.length) {

      return Container();
    }
    final player = players[index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Player ${index + 1} ($team)', style: TextStyle(fontWeight: FontWeight.bold)),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: player['run'].toString(),
                decoration: InputDecoration(labelText: 'Runs'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    player['run'] = int.tryParse(value) ?? 0;
                    _calculateTotals();
                  });
                },
              ),
            ),
            Expanded(
              child: TextFormField(
                initialValue: player['ball'].toString(),
                decoration: InputDecoration(labelText: 'Balls'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    player['ball'] = int.tryParse(value) ?? 0;
                    _calculateTotals();
                  });
                },
              ),
            ),
            Expanded(
              child: DropdownButtonFormField<bool>(
                decoration: InputDecoration(labelText: 'Out?'),
                value: player['out'],
                items: [
                  DropdownMenuItem(value: false, child: Text('Not Out')),
                  DropdownMenuItem(value: true, child: Text('Out')),
                ],
                onChanged: (value) {
                  setState(() {
                    player['out'] = value!;
                    _calculateTotals();
                  });
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
      ],
    );
  }

  void _calculateTotals() {
    _teamATotal = _teamAPlayers.fold<int>(0, (sum, player) => sum + (player['run'] as int));
    _teamBTotal = _teamBPlayers.fold<int>(0, (sum, player) => sum + (player['run'] as int));
  }

  Widget _buildPlayerScoreRow(Map<String, dynamic> player) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Runs: ${player['run']}'),
        Text('Balls: ${player['ball']}'),
        Text(player['out'] ? 'Out' : 'Not Out'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scoreboard')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Team A: $_teamA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ..._teamAPlayers.map((player) => _buildPlayerScoreRow(player)).toList(),
              SizedBox(height: 20),
              Text('Team B: $_teamB', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ..._teamBPlayers.map((player) => _buildPlayerScoreRow(player)).toList(),
              SizedBox(height: 20),
              Text('Result:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              if (_teamATotal > _teamBTotal)
                Text('$_teamA won by ${_teamATotal - _teamBTotal} runs', style: TextStyle(color: Colors.green, fontSize: 18)),
              if (_teamBTotal > _teamATotal)
                Text('$_teamB won by ${_teamBTotal - _teamATotal} runs', style: TextStyle(color: Colors.green, fontSize: 18)),
              if (_teamATotal == _teamBTotal)
                Text('MATCH TIED', style: TextStyle(color: Colors.orange, fontSize: 18)),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: _saveScores,
                child: Text('Save Scores'),
              ),
              SizedBox(height: 20),
              Text('Update Scores', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              SizedBox(height: 20),
              Text('Team A: $_teamA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ...List.generate(_teamAPlayers.length, (index) => _buildPlayerScoreInput(index, _teamAPlayers, _teamA)),
              SizedBox(height: 20),
              Text('Team B: $_teamB', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ...List.generate(_teamBPlayers.length, (index) => _buildPlayerScoreInput(index, _teamBPlayers, _teamB)),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
