import 'package:flutter/material.dart';
import 'package:mustang_app/counter.dart';

import 'scoutingoperations.dart';
import 'header.dart';
import 'postscouter.dart';

class MatchEndScouter extends StatefulWidget {
  static const String route = '/MatchEndScouter';
  String _teamNumber, _matchNumber;

  MatchEndScouter({String teamNumber, String matchNumber}) {
    _teamNumber = teamNumber;
    _matchNumber = matchNumber;
  }

  @override
  _MatchEndScouterState createState() =>
      _MatchEndScouterState(_teamNumber, _matchNumber);
}

class _MatchEndScouterState extends State<MatchEndScouter> {
  String _teamNumber;
  String _matchNumber;
  TextEditingController _finalCommentsController = TextEditingController();
  Counter _fouls = Counter('Fouls');
  String _matchResult;
  ScoutingOperations db = new ScoutingOperations();

  _MatchEndScouterState(teamNumber, matchNumber) {
    _teamNumber = teamNumber;
    _matchNumber = matchNumber;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: Header(
          context,
          'Match End',
        ),
        body: ListView(
          children: <Widget>[
            Container(
              padding:
                  EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 15),
              child: DropdownButton<String>(
                value: _matchResult,
                hint: Text('Choose Match Result',
                    style: TextStyle(color: Colors.black, fontSize: 20)),
                items: <String>['Win', 'Lose', 'Tie']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _matchResult = value;
                  });
                },
              ),
            ),
            Container(
              padding:
                  EdgeInsets.only(left: 30, right: 30, top: 15, bottom: 30),
              child: _fouls,
            ),
            Container(
              padding:
                  EdgeInsets.only(left: 30, right: 30, top: 15, bottom: 30),
              child: TextField(
                controller: _finalCommentsController,
                decoration: InputDecoration(
                  labelText: 'Final Comments',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Container(
              padding:
                  EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 15),
              child: RaisedButton(
                  color: Colors.green,
                  onPressed: () {
                    db.updateMatchDataEnd(_teamNumber, _matchNumber,
                        fouls: _fouls.count,
                        finalComments: _finalCommentsController.text,
                        matchResult: _matchResult);
                    Navigator.pushNamed(context, PostScouter.route);
                  },
                  padding: EdgeInsets.all(15),
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  )),
            )
          ],
        ));
  }
}
