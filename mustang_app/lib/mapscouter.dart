import 'package:flutter/material.dart';
import 'header.dart';
import 'bottomnavbar.dart';
import 'analyzer.dart';
import 'symbolplotter.dart';
import 'teamdataanalyzer.dart';
import 'mapscouterkey.dart';

class MapScouter extends StatefulWidget {
  static const String route = '/MapScouter';
  String _teamNumber = '';
  MapScouter({String teamNumber}) {
    _teamNumber = teamNumber;
  }
  @override
  State<StatefulWidget> createState() {
    return new _MapScouterState(_teamNumber);
  }
}

class _MapScouterState extends State<MapScouter> {
  Analyzer myAnalyzer;
  String _teamNumber;
  SymbolPlotter plotter;

  _MapScouterState(String teamNumber) {
    myAnalyzer = new Analyzer(teamNumber);
    _teamNumber = teamNumber;
    plotter = new SymbolPlotter(_getPoints());
  }

  List<PlotPoint> _getPoints() {
    List<PlotPoint> points = new List<PlotPoint>();
    if (TeamDataAnalyzer.teamAverages[_teamNumber] != null &&
        TeamDataAnalyzer.getTeamDoc(_teamNumber).data['hasAnalysis']) {
      TeamDataAnalyzer.teamAverages[_teamNumber].forEach((key, value) {
        String val = value.toString();
        val = val.substring(0, 3);
        double x = 0, y = 0, shift = 0, textSize = 15;
        Color fillColor = Colors.black;
        bool isPoint = true;
        if (key.contains("autoBalls")) {
          fillColor = MapScouterKey.autoBalls;
        } else if (key.contains("teleBalls")) {
          fillColor = MapScouterKey.teleBalls;
          shift = -0.0495;
        } else if (key.contains("startingLocation")) {
          return; // Feature to be implemented in coming versions
        } else if (key.contains("autoEndLocation")) {
          return; // Feature to be implemented in coming versions
        } else {
          return;
        }
        if (key.contains("Balls")) {
          String zone = key.substring(key.indexOf("s") + 1).trim();
          // width: 800, height: 500
          switch (zone) {
            case "Low":
              x = 0.95625;
              y = 0.6649;
              textSize = 10;
              val = "Lo:" + val;
              break;
            case "1":
              x = 0.93125;
              y = 366 / 376;
              break;
            case "23":
              x = 640 / 807;
              y = 325 / 376;
              break;
            case "4":
              x = 500 / 807;
              y = 410 / 376;
              break;
            case "5":
              x = 260 / 807;
              y = 410 / 376;
              break;
            case "6":
              x = 200 / 807;
              y = 175 / 376;
              break;
            default:
              isPoint = false;
              break;
          }
        }
        if (isPoint) {
          points.add(new PlotPoint((x) + shift, (y), fillColor, val, textSize));
        }
      });
    }
    return points;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(context, 'Map'),
      body: Container(
        height: 0.61 * MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset('assets/map.png', fit: BoxFit.contain),
                myAnalyzer,
                plotter,
                MapScouterKey()
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(context),
    );
  }
}

class PlotPoint {
  double _x;
  double _y;
  String _avgScore;
  Color _fillColor;

  double radius = 20;
  double fontSize = 15;
  PlotPoint(this._x, this._y, this._fillColor, this._avgScore, this.fontSize);
  double get x => _x;
  double get y => _y;
  Color get fillColor => _fillColor;
  String get avgScore => _avgScore;
}
