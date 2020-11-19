import 'package:flutter/material.dart';
import 'package:mustang_app/pitscouting.dart';

import './header.dart';
import './autonscouting.dart';
import './bottomnavbar.dart';
import './scoutingoperations.dart';

class Scouter extends StatefulWidget {
  static const String route = '/Scouter';

  @override
  State<StatefulWidget> createState() {
    return new _ScouterState();
  }
}

class _ScouterState extends State<Scouter> {
  TextEditingController _teamNumberController = TextEditingController();
  TextEditingController _matchNumberController = TextEditingController();
  TextEditingController _namesController = new TextEditingController();
  bool _showError = false;
  ScoutingOperations db = new ScoutingOperations();

  showAlertDialog(BuildContext context, bool pit) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Override"),
      onPressed: () {
        Navigator.pop(context);
        if (pit) {
          db.startPitScouting(
              _teamNumberController.text, _namesController.text);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PitScouter(
                _teamNumberController.text,
              ),
            ),
          );
        } else {
          db.startNewMatch(_teamNumberController.text,
              _matchNumberController.text, _namesController.text);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AutonScouter(
                _teamNumberController.text,
                _matchNumberController.text,
              ),
            ),
          );
        }
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Overwrite Data"),
      content: Text(pit
          ? "Pit data for this team already.\nAre you sure you want to overwrite it?"
          : "Match data for this team and match number already.\nAre you sure you want to overwrite it?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(
        context,
        'Pre Scouting Info',
      ),
      body: ListView(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left: 20, right: 20, top: 30, bottom: 15),
            child: TextField(
              controller: _teamNumberController,
              decoration: InputDecoration(
                labelText: 'Team Number',
                errorText: _showError ? 'Team number is required' : null,
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 15),
            child: TextField(
              controller: _matchNumberController,
              decoration: InputDecoration(
                labelText: 'Match Number',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 15),
            child: TextField(
              controller: _namesController,
              decoration: InputDecoration(
                labelText: 'Names',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 15),
            child: new Builder(
              builder: (BuildContext buildContext) => RaisedButton(
                color: Colors.green,
                onPressed: () {
                  setState(() {
                    if (_teamNumberController.text.isEmpty) {
                      Scaffold.of(buildContext).showSnackBar(SnackBar(
                        content: Text("Enter a team number"),
                      ));
                      return;
                    } else if (_namesController.text.isEmpty) {
                      Scaffold.of(buildContext).showSnackBar(SnackBar(
                        content: Text("Enter a name"),
                      ));
                      return;
                    }
                    db
                        .doesPitDataExist(_teamNumberController.text)
                        .then((onValue) {
                      if (onValue) {
                        showAlertDialog(context, true);
                      } else {
                        db.startPitScouting(
                            _teamNumberController.text, _namesController.text);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PitScouter(
                              _teamNumberController.text,
                            ),
                          ),
                        );
                      }
                    });
                  });
                },
                padding: EdgeInsets.all(15),
                child: Text(
                  'Pit Scouting',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 15),
            child: new Builder(
              builder: (BuildContext buildContext) => new RaisedButton(
                color: Colors.green,
                onPressed: () {
                  setState(() {
                    if (_teamNumberController.text.isEmpty) {
                      Scaffold.of(buildContext).showSnackBar(SnackBar(
                        content: Text("Enter a team number"),
                      ));
                      return;
                    } else if (_matchNumberController.text.isEmpty) {
                      Scaffold.of(buildContext).showSnackBar(SnackBar(
                        content: Text("Enter a match number"),
                      ));
                      return;
                    } else if (_namesController.text.isEmpty) {
                      Scaffold.of(buildContext).showSnackBar(SnackBar(
                        content: Text("Enter a name"),
                      ));
                      return;
                    }
                    db
                        .doesMatchDataExist(_teamNumberController.text,
                            _matchNumberController.text)
                        .then((onValue) {
                      if (onValue) {
                        showAlertDialog(context, false);
                      } else {
                        db.startNewMatch(_teamNumberController.text,
                            _matchNumberController.text, _namesController.text);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AutonScouter(
                              _teamNumberController.text,
                              _matchNumberController.text,
                            ),
                          ),
                        );
                      }
                    });
                    // Navigator.pushNamed(context, AutonScouter.route);
                  });
                },
                padding: EdgeInsets.all(15),
                child: Text(
                  'Match Scouting',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(context),
    );
  }
}
