import 'package:flutter/material.dart';
import 'package:mustang_app/header.dart';
import 'datareader.dart';
import 'mapscouter.dart';
import 'bottomnavbar.dart';
import 'teaminfodisplay.dart';

class SearchPage extends StatefulWidget {
  static const String route = './Search';

  @override
  _SearchPageState createState() => new _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<String> teams = [];
  var tempSearchStore = [];
  TextEditingController _queryController = new TextEditingController();

  _SearchPageState() {
    teams = DataReader.teams;
    tempSearchStore = DataReader.teams;
  }

  initiateSearch(value) async {
    if (value.length == 0) {
      setState(() {
        tempSearchStore = teams;
      });
      return;
    }

    var temp = [];
    teams.forEach((element) {
      if (element.startsWith(value)) {
        temp.add(element);
      }
    });
    setState(() {
      tempSearchStore = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          TeamInfoDisplay(tempSearchStore[index]),
                    ),
                  );
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
          // GridView.count(
          //     padding: EdgeInsets.only(left: 10.0, right: 10.0),
          //     crossAxisCount: 2,
          //     crossAxisSpacing: 4.0,
          //     mainAxisSpacing: 4.0,
          //     primary: false,
          //     shrinkWrap: true,
          //     children: tempSearchStore.map((element) {
          //       return buildResultCard(element);
          //     }).toList())
        ],
      ),
      bottomNavigationBar: BottomNavBar(context),
    );
  }
}

Widget buildResultCard(data) {
  return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 2.0,
      child: Container(
          child: Center(
              child: Text(
        data['businessName'],
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.black,
          fontSize: 20.0,
        ),
      ))));
}
