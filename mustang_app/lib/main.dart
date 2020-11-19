import 'package:flutter/material.dart';
import 'package:mustang_app/teamdataanalyzer.dart';
import 'mapscouter.dart';
import 'mapscouterkey.dart';
import './calendar.dart';
import './scouter.dart';
import './search.dart';
import './homepage.dart';
import './sketcher.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  MyApp() {
    // TeamDataAnalyzer.init();
  }
  // This widget is the root of your application.
  static final Map<String, WidgetBuilder> routes = {
    Calendar.route: (BuildContext context) => new Calendar(),
    Scouter.route: (BuildContext context) => new Scouter(),
    // AutonScouter.route: (BuildContext context) => new AutonScouter(),
    // TeleopScouter.route: (BuildContext context) => new TeleopScouter(),
    // EndgameScouter.route: (BuildContext context) => new EndgameScouter(),
    // MatchEndScouter.route: (BuildContext context) => new MatchEndScouter(),
    // PostScouter.route: (BuildContext context) => new PostScouter(),
    SearchPage.route: (BuildContext context) => new SearchPage(),
    MapScouter.route: (BuildContext context) => new MapScouter(),
    MapScouterKey.route: (BuildContext context) => new MapScouterKey(),
    SketchPage.route: (BuildContext context) => new SketchPage(),
  };
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mustang App',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: HomePage(),
      routes: routes,
    );
  }
}
