import 'package:flutter/material.dart';
import 'datareader.dart';
import './bottomnavbar.dart';

class HomePage extends StatefulWidget {
  HomePage() {
    DataReader.init().then((value) {
      DataReader.csvToFirestore().then((value) => print('Finished'));
    });
  }
  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
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
