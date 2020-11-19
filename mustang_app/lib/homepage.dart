import 'package:flutter/material.dart';
import './bottomnavbar.dart';
import 'package:flutter/services.dart';
import 'teamdataanalyzer.dart';

class HomePage extends StatefulWidget {
  HomePage() {
    if (!TeamDataAnalyzer.initialized) {
      TeamDataAnalyzer.init();
    }
  }
  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      // body: Column(
      //   children: [
      //     Text('Welcome!',
      //         style: TextStyle(
      //           color: Colors.green,
      //           fontSize: 30,
      //           fontWeight: FontWeight.bold,
      //         )),
      //     RaisedButton(onPressed: () async {}, child: Text('Update DB'))
      //   ],
      // ),
      body: Center(
        child: Text('Welcome!',
            style: TextStyle(
              color: Colors.green,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            )),
      ),
      bottomNavigationBar: BottomNavBar(context),
    );
  }
}
