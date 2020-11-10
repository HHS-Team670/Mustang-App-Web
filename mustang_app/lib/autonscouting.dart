import 'package:flutter/material.dart';
import 'package:mustang_app/counter.dart';

import './header.dart';
import './teleopscouting.dart';
import './databaseoperations.dart';

class AutonScouter extends StatefulWidget {
  static const String route = '/AutonScouter';
  String _teamNumber, _matchNumber;

  AutonScouter(String teamNumber, String matchNumber) {
    _teamNumber = teamNumber;
    _matchNumber = matchNumber;
  }
  @override
  State<StatefulWidget> createState() {
    return new _AutonScouterState(_teamNumber, _matchNumber);
  }
}

class _AutonScouterState extends State<AutonScouter> {
  String _teamNumber, _matchNumber;
  Counter _bottomPort = Counter('Bottom Port');
  Counter _outerPort = Counter('Outer Port');
  Counter _innerPort = Counter('Inner Port');
  Counter _bottomPortMissed = Counter('Bottom Port Missed');
  Counter _outerPortMissed = Counter('Outer Port Missed');
  Counter _innerPortMissed = Counter('Inner Port Missed');
  bool _crossedInitiationLine = false;
  DatabaseOperations db = new DatabaseOperations();

  _AutonScouterState(teamNumber, matchNumber) {
    _teamNumber = teamNumber;
    _matchNumber = matchNumber;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: Header(context, 'Auton'),
        body: Center(
          child: ListView(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(15),
                child: SwitchListTile(
                  title: Text(
                    'Crossed initiation line?',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  value: _crossedInitiationLine,
                  onChanged: (bool value) {
                    setState(() {
                      _crossedInitiationLine = value;
                    });
                  },
                ),
              ),
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
                    EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 15),
                child: RaisedButton(
                  onPressed: () {
                    db.updateMatchDataAuton(_teamNumber, _matchNumber,
                        innerPort: _innerPort.count,
                        innerPortMissed: _innerPortMissed.count,
                        outerPort: _outerPort.count,
                        outerPortMissed: _outerPortMissed.count,
                        bottomPort: _bottomPort.count,
                        bottomPortMissed: _bottomPortMissed.count,
                        crossedLine: _crossedInitiationLine);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                TeleopScouter(_teamNumber, _matchNumber)));
                    // Navigator.pushNamed(context, TeleopScouter.route);
                  },
                  child: Text(
                    'Next',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  color: Colors.green,
                  padding: EdgeInsets.all(15),
                ),
              ),
            ],
          ),
        ));
  }
}
