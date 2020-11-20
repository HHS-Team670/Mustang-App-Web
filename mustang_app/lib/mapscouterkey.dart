import 'package:flutter/material.dart';

class MapScouterKey extends StatefulWidget {
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
    return Container(
      margin: EdgeInsets.all(10),
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                margin: EdgeInsets.only(left: 20, right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.circle, size: iconSize, color: autoBalls),
                    Text('Auton Balls',
                        style: TextStyle(
                            color: Colors.grey[800],
                            fontWeight: FontWeight.bold,
                            fontSize: 14))
                  ],
                )),
            Container(
              margin: EdgeInsets.only(left: 20, right: 20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.circle, size: iconSize, color: teleBalls),
                    Text('Teleop Balls',
                        style: TextStyle(
                            color: Colors.grey[800],
                            fontWeight: FontWeight.bold,
                            fontSize: 14))
                  ]),
            )
          ]),
    );
  }
}
