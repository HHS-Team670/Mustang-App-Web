import 'package:flutter/material.dart';

import './bottomnavbar.dart';

class HomePage extends StatefulWidget {
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
        child: Text('Welcome!', style: TextStyle(color: Colors.green, fontSize: 30, fontWeight: FontWeight.bold,)),
      ),
      bottomNavigationBar: BottomNavBar(context),
    );
  }
}