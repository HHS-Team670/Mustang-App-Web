import 'package:flutter/material.dart';
import 'package:mustang_app/counter.dart';

import 'endgamescouting.dart';
import 'header.dart';
import 'scoutingoperations.dart';

class TeleopScouter extends StatefulWidget {
  static const String route = '/TeleopScouter';
  String _teamNumber, _matchNumber;

  TeleopScouter(teamNumber, matchNumber) {
    _teamNumber = teamNumber;
    _matchNumber = matchNumber;
  }

  @override
  State<StatefulWidget> createState() {
    return new _TeleopScouterState(_teamNumber, _matchNumber);
  }
}

class _TeleopScouterState extends State<TeleopScouter> {
  String _teamNumber;
  String _matchNumber;
  ScoutingOperations db = new ScoutingOperations();
  Counter _bottomPort = Counter('Bottom Port');
  Counter _outerPort = Counter('Outer Port');
  Counter _innerPort = Counter('Inner Port');
  Counter _bottomPortMissed = Counter('Bottom Port Missed');
  Counter _outerPortMissed = Counter('Outer Port Missed');
  Counter _innerPortMissed = Counter('Inner Port Missed');

  bool _rotationControl = false;
  bool _positionControl = false;

  _TeleopScouterState(teamNumber, matchNumber) {
    _teamNumber = teamNumber;
    _matchNumber = matchNumber;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: Header(
          context,
          'Teleop',
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
              padding: EdgeInsets.all(15),
              child: SwitchListTile(
                title: Text(
                  'Completed rotation control?',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                value: _rotationControl,
                onChanged: (bool value) {
                  setState(() {
                    _rotationControl = value;
                  });
                },
              ),
            ),
            Container(
              padding: EdgeInsets.all(15),
              child: SwitchListTile(
                title: Text(
                  'Completed position control?',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                value: _positionControl,
                onChanged: (bool value) {
                  setState(() {
                    _positionControl = value;
                    if (_positionControl) _rotationControl = true;
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
                  db.updateMatchDataTeleop(_teamNumber, _matchNumber,
                      innerPort: _innerPort.count,
                      innerPortMissed: _innerPortMissed.count,
                      outerPort: _outerPort.count,
                      outerPortMissed: _outerPortMissed.count,
                      bottomPort: _bottomPort.count,
                      bottomPortMissed: _bottomPortMissed.count,
                      positionControl: _positionControl,
                      rotationControl: _rotationControl);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              EndgameScouter(_teamNumber, _matchNumber)));
                  // Navigator.pushNamed(context, EndgameScouter.route);
                },
                padding: EdgeInsets.all(15),
                child: Text(
                  'Next',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
