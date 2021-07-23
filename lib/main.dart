import 'dart:async';

import 'package:flutter/material.dart';

void main() => runApp(BlobApp());

class BlobApp extends StatefulWidget {

  @override
  _BlobAppState createState() => _BlobAppState();

}

class _BlobAppState extends State<BlobApp> {

  int counter = 0;
  double cps = 0;

  static const int expiryTime = 5;

  late ExpiringPool clicksPool;

  @override
  void initState() {
    super.initState();

    clicksPool = ExpiringPool(
      expiryTime: expiryTime,
      onRemove: () {}
    );

    Timer.periodic(
      Duration(milliseconds: 10), 
      (timer) => setCPS()
    );
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: Scaffold(

        body: Container(
          child: Material(
            child: InkWell(
              child: Container(
                child: Text(
                  counter.toString(),
                  style: TextStyle(fontSize: 100),
                ),
                alignment: Alignment.center,
              ),
              onTap: incrementCounter,
              onLongPress: resetCounter,
            ),
            color: Colors.transparent,
          ),
          color: Colors.blue[200],
        ),

        floatingActionButton: Text(
          cps.toString() + " CPS",
          style: TextStyle(fontSize: 30),
        ),

      ),
    );

  }

  void incrementCounter() {
    setState(() {
      counter++;
      clicksPool.addItem();
    });
  }

  void resetCounter() {
    setState(() {
      counter = 0;
      clicksPool.reset();
    });
  }

  void setCPS() {
    setState(() {
      cps = clicksPool.count/expiryTime;
    });
  }

}

class ExpiringPool {

  static const sec = Duration(seconds: 1);

  final int expiryTime;
  final VoidCallback onRemove;

  ExpiringPool({
    required this.expiryTime,
    required this.onRemove
  });

  int count = 0;
  List<Timer> _timers = [];

  void addItem() {
    count++;
    Timer destroyTimer = Timer(sec*expiryTime, 
      () {
        count--;
        onRemove();
      }
    );

    _timers.add(destroyTimer);
  }

  void reset() {
    for (Timer timer in _timers) {
      timer.cancel();
    }
    _timers = <Timer>[];
    count = 0;
  }

}