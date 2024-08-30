import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MatchScreen extends StatefulWidget {
  @override
  _MatchScreenState createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _matchPlaceController = TextEditingController();
  final _totalOversController = TextEditingController();
  String? _selectedTeamA;
  String? _selectedTeamB;
  DateTime _selectedDate = DateTime.now();

  List<String> _teams = [];

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _teams = prefs.getKeys().where((key) => key.startsWith('team_')).map((key) => key.replaceFirst('team_', '')).toList();
    });
  }

  Future<void> _saveMatch() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      String matchKey = 'match_${_selectedDate.toIso8601String()}';
      prefs.setStringList(matchKey, [
        _selectedTeamA!,
        _selectedTeamB!,
        _matchPlaceController.text,
        _totalOversController.text
      ]);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Match saved!')),
      );
      _formKey.currentState!.reset();
      setState(() {
        _selectedTeamA = null;
        _selectedTeamB = null;
        _selectedDate = DateTime.now();
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Match')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              ListTile(
                title: Text("${_selectedDate.toLocal()}".split(' ')[0]),
                trailing: Icon(Icons.keyboard_arrow_down),
                onTap: () => _selectDate(context),
              ),
              DropdownButtonFormField<String>(
                value: _selectedTeamA,
                hint: Text('Select Team A'),
                items: _teams.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedTeamA = newValue;
                    if (_selectedTeamB == newValue) {
                      _selectedTeamB = null;
                    }
                  });
                },
                validator: (value) => value == null ? 'Please select Team A' : null,
              ),
              DropdownButtonFormField<String>(
                value: _selectedTeamB,
                hint: Text('Select Team B'),
                items: _teams.where((team) => team != _selectedTeamA).map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedTeamB = newValue;
                  });
                },
                validator: (value) => value == null ? 'Please select Team B' : null,
              ),
              TextFormField(
                controller: _matchPlaceController,
                decoration: InputDecoration(labelText: 'Match Place'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a match place';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _totalOversController,
                decoration: InputDecoration(labelText: 'Total Overs'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter total overs';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveMatch,
                child: Text('Save Match'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
