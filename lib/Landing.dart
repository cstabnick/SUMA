import 'package:flutter/material.dart';
import 'util.dart' as util;
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import './Receipts.dart';

class Landing extends StatelessWidget {
  final int userId;

  Landing({Key key, this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          Navigator.of(context).pop(false);
          return new Future(() => false);

        },
        child: MaterialApp(
          title: 'Landing',
          routes: {
            '/Receipts': (context) => Receipts(),
          },
          theme: ThemeData(
            primarySwatch: Colors.green,
          ),
          home: LandingPage(),
        ));
  }
}

class LandingPage extends StatelessWidget {
  LandingPage() : super();

//  @override
//  _LandingPageState createState() => _LandingPageState();
//  new MaterialPageRoute(
//  builder: (context) => new Landing(
//  userId: util.userId,
//  )));
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(
        child: new Scaffold(

          backgroundColor: Colors.white,
          body: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                RaisedButton(child: Text("Receipts"), onPressed: () {
                  Navigator.pushNamed(context, '/Receipts');
                })
              ])),

        ),
        onWillPop: () {
          Navigator.of(context).pop(false);
          return new Future(() => false);
        });
  }
}
//
//class _LandingPageState extends State<LandingPage> {
//  final StreamController<int> _streamController = StreamController<int>();
//
//  @override
//  void dispose() {
//    _streamController.close();
//    super.dispose();
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return WillPopScope(
//
//        // ignore: missing_return
//        onWillPop: () {Navigator.of(context).pop();},
//    child: new Scaffold(
//        backgroundColor: Colors.white,
//        body: Center(
//            child: Column(
//                mainAxisAlignment: MainAxisAlignment.center,
//                children: <Widget>[
//
//                  MaterialButton(onPressed: () {
//
//                  {Navigator.of(context).pop();},
//
//
//
//                  }, color: Colors.cyan,)
//
//
//                ]))));
//  }
//}
