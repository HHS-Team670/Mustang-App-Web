import 'package:flutter/material.dart';

import 'bottomnavbar.dart';

class MapScouterKey extends StatefulWidget {
  static const String route = '/Key';

  static const Color autoBalls = Colors.green;
  static const Color teleBalls = Colors.yellow;
  static const Color startPos = Colors.redAccent;
  static const Color autoStopPos = Colors.blueAccent;

  @override
  State<StatefulWidget> createState() {
    return new _MapScouterKeyState();
  }
}

class _MapScouterKeyState extends State<MapScouterKey> {
  double iconSize = 65;
  Color autoBalls = Colors.green;
  Color teleBalls = Colors.yellow;
  Color startPos = Colors.redAccent;
  Color autoStopPos = Colors.blueAccent;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
          child: Column(children: <Widget>[
        Container(
          margin: EdgeInsets.all(10),
          child: Table(
            // border: TableBorder.all(),
            //border: TableBorder.symmetric(outside: BorderSide(width: 1, color: Colors.grey)),
            // border: TableBorder.symmetric(outside: BorderSide(width: .50, color: Colors.grey),inside: BorderSide(width: .50, color: Colors.grey)),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(children: [
                Column(children: [
                  Icon(Icons.circle, size: iconSize, color: autoBalls),
                  Text('Auton Balls',
                      style: TextStyle(
                          color: Colors.grey[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 14))
                ]),
                Column(children: [
                  Icon(Icons.circle, size: iconSize, color: teleBalls),
                  Text('Teleop Balls',
                      style: TextStyle(
                          color: Colors.grey[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 14))
                ]),
              ]),
            ],
          ),
        ),
        const Divider(
          color: Colors.blueGrey,
          height: 25,
          thickness: 2,
          indent: 5,
          endIndent: 5,
        ),
        Container(
          margin: EdgeInsets.all(10),
          child: Table(
            //border:TableBorder.all(),
            // border: TableBorder.symmetric(outside: BorderSide(width: .50, color: Colors.grey),inside: BorderSide(width: .50, color: Colors.grey)),
            defaultVerticalAlignment: TableCellVerticalAlignment.top,
            children: [
              // TableRow(children: [ // Feature to be implemented in coming versions
              //   Column(children: [
              //     Icon(Icons.circle, size: iconSize, color: startPos),
              //     Text('Start Position',
              //         style: TextStyle(
              //             color: Colors.grey[800],
              //             fontWeight: FontWeight.bold,
              //             fontSize: 14))
              //   ]),
              //   Column(children: [
              //     Icon(Icons.circle, size: iconSize, color: autoStopPos),
              //     Text('Auton End Position',
              //         textAlign: TextAlign.center,
              //         style: TextStyle(
              //             color: Colors.grey[800],
              //             fontWeight: FontWeight.bold,
              //             fontSize: 14))
              //   ]),
              // ]),
            ],
          ),
        ),
      ])),
      bottomNavigationBar: BottomNavBar(context),
    );
  }
}
