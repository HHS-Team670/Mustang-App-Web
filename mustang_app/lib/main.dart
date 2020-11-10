import 'package:flutter/material.dart';
import 'package:mustang_app/endgamescouting.dart';
import 'package:mustang_app/teaminfodisplay.dart';

import './calendar.dart';
import './scouter.dart';
import './autonscouting.dart';
import './teleopscouting.dart';
import './postscouter.dart';
import './search.dart';
import './homepage.dart';
import './matchendscouting.dart';
import './sketcher.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  static final Map<String, WidgetBuilder> routes = {
    Calendar.route: (BuildContext context) => new Calendar(),
    Scouter.route: (BuildContext context) => new Scouter(),
    // AutonScouter.route: (BuildContext context) => new AutonScouter(),
    // TeleopScouter.route: (BuildContext context) => new TeleopScouter(),
    // EndgameScouter.route: (BuildContext context) => new EndgameScouter(),
    // MatchEndScouter.route: (BuildContext context) => new MatchEndScouter(),
    PostScouter.route: (BuildContext context) => new PostScouter(),
    SearchPage.route: (BuildContext context) => new SearchPage(),
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
