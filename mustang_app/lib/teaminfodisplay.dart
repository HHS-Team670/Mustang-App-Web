import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mustang_app/header.dart';

class TeamInfoDisplay extends StatefulWidget {
  String _team;

  TeamInfoDisplay(String team) {
    _team = team;
  }

  @override
  State<StatefulWidget> createState() {
    return _TeamInfoDisplayState(_team);
  }
}

class _TeamInfoDisplayState extends State<TeamInfoDisplay> {
  String _team;
  List<String> _matches = [];
  Map<dynamic, dynamic> _pitData = {};
  List<Map<dynamic, dynamic>> _matchData = [];

  _TeamInfoDisplayState(String team) {
    _team = team;
    getData().then((onValue) {
      setState(() {});
      print(_pitData);
      print('\n');
      print(_matchData);
    });
  }

  Future<void> getData() async {
    QuerySnapshot matchData = await Firestore.instance
        .collection('teams')
        .document(_team)
        .collection('Match Scouting')
        .getDocuments();

    matchData.documents.forEach((f) {
      _matches.add(f.documentID);
      _matchData.add(f.data);
    });

    var lol =
        await Firestore.instance.collection('teams').document(_team).get();
    _pitData = lol.data['Pit Scouting'];
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: Header(context, _team),
      body: ListView(
        children: <Widget>[
          (_matchData.isEmpty)
              ? (ListTile(
                  title: Text(
                    'No Matches Yet',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ))
              : (ExpansionTile(
                  title: Text("Match Data"),
                  children: <Widget>[
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: _matchData.length,
                      itemBuilder: (context, index) => ExpansionTile(
                        title: Text(_matches[index]),
                        children: <Widget>[
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: _matchData[index].length,
                            itemBuilder: (context, index2) => ExpansionTile(
                              title: Text(_matchData[index]
                                  .keys
                                  .toList()[index2]
                                  .toString()),
                              children: <Widget>[
                                ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: _matchData[index]
                                      .values
                                      .toList()[index2]
                                      .length,
                                  itemBuilder: (context, index3) => ListTile(
                                      title: Text(_matchData[index]
                                              .values
                                              .toList()[index2]
                                              .keys
                                              .toList()[index3]
                                              .toString() +
                                          ": " +
                                          _matchData[index]
                                              .values
                                              .toList()[index2]
                                              .values
                                              .toList()[index3]
                                              .toString())),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                )),
          (_pitData.isEmpty)
              ? (ListTile(
                  title: Text(
                    'No Pit Data Yet',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ))
              : (ExpansionTile(
                  title: Text("Pit Scouting"),
                  children: <Widget>[
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: _pitData.length,
                      itemBuilder: (context, index) => ListTile(
                        title: Text(
                          _pitData.keys.toList()[index].toString() +
                              ": " +
                              _pitData.values.toList()[index].toString(),
                        ),
                      ),
                    )
                  ],
                )),
        ],
      ),
    );
  }
}
