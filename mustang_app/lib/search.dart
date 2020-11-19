import 'package:flutter/material.dart';
import 'package:mustang_app/header.dart';
import 'mapscouter.dart';
import 'bottomnavbar.dart';
import 'teaminfodisplay.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'teamdataanalyzer.dart';

class SearchPage extends StatefulWidget {
  static const String route = './Search';

  @override
  _SearchPageState createState() => new _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<String> teams = [];
  List<String> tempSearchStore = [];
  TextEditingController _queryController = new TextEditingController();

  _SearchPageState() {
    initAllTeams().then((value) {
      setState(() {});
    });
  }

  Future<void> initAllTeams() async {
    List<String> allTeams = await TeamDataAnalyzer.getTeamNumbers();
    setState(() {
      teams = allTeams;
      tempSearchStore = allTeams;
    });
  }

  initiateSearch(value) async {
    if (value.length == 0) {
      setState(() {
        tempSearchStore = teams;
      });
      return;
    }

    List<String> temp = [];
    teams.forEach((element) {
      if (element.startsWith(value)) {
        temp.add(element);
      }
    });
    setState(() {
      tempSearchStore = temp;
    });
  }

  showAlertDialog(BuildContext context, String teamNumber) {
    FlatButton cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    FlatButton goToAnalysis = FlatButton(
      child: Text("Analysis"),
      onPressed: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MapScouter(
              teamNumber: teamNumber,
            ),
          ),
        );
      },
    );
    FlatButton goToData = FlatButton(
      child: Text("Data"),
      onPressed: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TeamInfoDisplay(
              teamNumber,
            ),
          ),
        );
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Data View"),
      content: Text("Would you like to see defense analysis or data?"),
      actions: [cancelButton, goToAnalysis, goToData],
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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    return new Scaffold(
      appBar: new Header(
        context,
        'Search Data',
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10.0),
            child: TextField(
              controller: _queryController,
              onChanged: (val) {
                initiateSearch(val);
              },
              decoration: InputDecoration(
                  prefixIcon: IconButton(
                    color: Colors.black,
                    icon: Icon(Icons.arrow_back),
                    iconSize: 20.0,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  contentPadding: EdgeInsets.only(left: 25.0),
                  hintText: 'Search by name',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0))),
            ),
          ),
          // SizedBox(height: 10.0),
          Container(
            height: 500,
            child: (ListView.builder(
              itemCount: tempSearchStore.length,
              itemBuilder: (context, index) => ListTile(
                onTap: () {
                  showAlertDialog(context, tempSearchStore[index]);
                },
                leading: Icon(Icons.people),
                title: RichText(
                  text: TextSpan(
                    text: tempSearchStore[index]
                        .substring(0, _queryController.text.length),
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: tempSearchStore[index]
                            .substring(_queryController.text.length),
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(context),
    );
  }
}
