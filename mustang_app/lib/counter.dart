import 'package:flutter/material.dart';

class Counter extends StatefulWidget {
  _CounterState lol;
  String _text;
  Counter(String text) {
    _text = text;
    lol = new _CounterState(_text);
  }

  int get count {
    return lol.count;
  }

  @override
  _CounterState createState() {
    lol = new _CounterState(_text);
    return lol;
  }
}

class _CounterState extends State<Counter> {
  int _count = 0;
  String _text;

  _CounterState(String text) {
    _text = text;
  }

  int get count {
    return _count;
  }

  void add() {
    setState(() {
      _count++;
    });
  }

  void minus() {
    setState(() {
      if (_count != 0) _count--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new Center(
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(right: 30),
              child: new Text(
                _text,
                style: new TextStyle(fontSize: 20.0),
              ),
            ),
            Row(
              children: <Widget>[
                IconButton(
                  color: Colors.green,
                  onPressed: minus,
                  icon: new Icon(
                    Icons.remove_circle,
                    size: 25,
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 10),
                  child: new Text(
                    '$_count',
                    style: new TextStyle(fontSize: 20.0),
                  ),
                ),
                IconButton(
                  onPressed: add,
                  color: Colors.green,
                  icon: new Icon(
                    Icons.add_circle,
                    size: 25,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
