import 'package:flutter/material.dart';
import 'package:mustang_app/counter.dart';

import 'matchendscouting.dart';
import 'scoutingoperations.dart';
import 'header.dart';

class EndgameScouter extends StatefulWidget {
  static const String route = '/EndgameScouter';
  String _teamNumber, _matchNumber;

  EndgameScouter(teamNumber, matchNumber) {
    _teamNumber = teamNumber;
    _matchNumber = matchNumber;
  }
  @override
  _EndgameScouterState createState() =>
      _EndgameScouterState(_teamNumber, _matchNumber);
}

class _EndgameScouterState extends State<EndgameScouter> {
  String _teamNumber;
  String _matchNumber;
  Counter _bottomPort = Counter('Bottom Port');
  Counter _outerPort = Counter('Outer Port');
  Counter _innerPort = Counter('Inner Port');
  Counter _bottomPortMissed = Counter('Bottom Port Missed');
  Counter _outerPortMissed = Counter('Outer Port Missed');
  Counter _innerPortMissed = Counter('Inner Port Missed');
  Counter _stagesCompletedController = new Counter('Stages Completed');
  String _endingState;
  ScoutingOperations db = new ScoutingOperations();

  _EndgameScouterState(teamNumber, matchNumber) {
    _teamNumber = teamNumber;
    _matchNumber = matchNumber;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: Header(
          context,
          'Endgame',
        ),
        body: ListView(
          children: <Widget>[
            Container(
              padding:
                  EdgeInsets.only(left: 30, right: 30, top: 15, bottom: 15),
              child: _bottomPort,
            ),
            Container(
              padding:
                  EdgeInsets.only(left: 30, right: 30, top: 15, bottom: 15),
              child: _bottomPortMissed,
            ),
            Container(
              padding:
                  EdgeInsets.only(left: 30, right: 30, top: 15, bottom: 15),
              child: _outerPort,
            ),
            Container(
              padding:
                  EdgeInsets.only(left: 30, right: 30, top: 15, bottom: 15),
              child: _outerPortMissed,
            ),
            Container(
              padding:
                  EdgeInsets.only(left: 30, right: 30, top: 15, bottom: 15),
              child: _innerPort,
            ),
            Container(
              padding:
                  EdgeInsets.only(left: 30, right: 30, top: 15, bottom: 15),
              child: _innerPortMissed,
            ),
            Container(
              padding:
                  EdgeInsets.only(left: 30, right: 30, top: 15, bottom: 30),
              child: _stagesCompletedController,
            ),
            Container(
              padding:
                  EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 15),
              child: DropdownButton<String>(
                value: _endingState,
                hint: Text('Choose Ending State',
                    style: TextStyle(color: Colors.black, fontSize: 20)),
                items: <String>['None', 'Parked', 'Hanging']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _endingState = value;
                  });
                },
              ),
            ),
            Container(
              padding:
                  EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 15),
              child: RaisedButton(
                  color: Colors.green,
                  onPressed: () {
                    db.updateMatchDataEndgame(_teamNumber, _matchNumber,
                        innerPort: _innerPort.count,
                        innerPortMissed: _innerPortMissed.count,
                        outerPort: _outerPort.count,
                        outerPortMissed: _outerPortMissed.count,
                        bottomPort: _bottomPort.count,
                        bottomPortMissed: _bottomPortMissed.count,
                        stagesCompleted: _stagesCompletedController.count,
                        endState: _endingState);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                MatchEndScouter(_teamNumber, _matchNumber)));
                    // Navigator.pushNamed(context, MatchEndScouter.route);
                  },
                  padding: EdgeInsets.all(15),
                  child: Text(
                    'Next',
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
