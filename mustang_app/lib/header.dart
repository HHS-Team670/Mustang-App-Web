import 'package:flutter/material.dart';

class Header extends AppBar {
  Header(BuildContext context, String text)
      : super(
          title: Text(text),
          actions: <Widget>[
            Container(
              margin: EdgeInsets.only(
                right: 10,
              ),
              child: IconButton(
                icon: Icon(Icons.home),
                onPressed: () {
                  Navigator.pushNamed(context, '/');
                },
              ),
            )
          ],
        );
}
