
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'dart:io';
import 'dart:async';
import 'dart:convert';

import './Landing.dart';
import 'util.dart' as util;

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  HttpClient _httpClient = new HttpClient();

  bool _loginSuccessful = false;
  bool _initialState = true;
  String _username;
  String _password;

  String _err = "";


  _LoginPageState() : super() {



    //Duration second = new Duration(seconds: 1);
    //sleep(second );

  }

  void checkUserId() async {
    final storage = new FlutterSecureStorage();
    Map<String, String> secureStore = await storage.readAll();

    if (secureStore.containsKey('username'))
      _username = secureStore['username'];

    if (secureStore.containsKey('password'))
      _password = secureStore['password'];

    if (_username != "" && _password != "")
      this._loginAttempt();
  }

  Future<HttpClientResponse> _doLogin() async {
    Map<String, String> jsonMap = {
      'username': _username,
      'password': _password
    };

    // https://dart.dev/guides/libraries/library-tour
    String sRequestData = json.encode(jsonMap);
    List<int> listBytes = utf8.encode(sRequestData);

    HttpClientRequest request = await _httpClient.post(
        util.host, util.port, "/mobile/user/login");

    request.headers.set('Content-Length', listBytes.length.toString());
    request.add(listBytes);

    return await request.close();
  }

  void _loginAttempt() async {
    HttpClientResponse response = await this._doLogin();
    String sResponse = await response.transform(utf8.decoder).join();
    Map mResponse = jsonDecode(sResponse) as Map;


    _loginSuccessful = mResponse["status"] == 0 ? false : true;
    if (_loginSuccessful) {
      setState(() {
        _err = "";
      });

      util.userId = mResponse["status"];

      // store key value to phone
      final prefs = await SharedPreferences.getInstance();
      prefs.setInt('userId', util.userId);

      final storage = new FlutterSecureStorage();

      await storage.write(key: 'username', value: _username);

      await storage.write(key: 'password', value: _password);

      Navigator.pushNamed(context, "/Landing");
//      Navigator.of(context).push(
//          new MaterialPageRoute(
//              builder: (context) => new Landing(
//
//              )));
    }
    else {
      setState(() {
        _err = mResponse["description"];

      });

    }
  }

  @override
  Widget build(BuildContext context) {

    if (this._initialState) {
      this.checkUserId();
      this._initialState = !this._initialState;
    }

    return
      WillPopScope(
        // ignore: missing_return
//        onWillPop: () {Navigator.of(context).pop();},
      child:
      new Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(8.0),
                child: new Container(
                  width: 300,
                  height: 80,
                  color: Colors.white,
                  child: TextFormField(
                    style: Theme.of(context).textTheme.display1,
                    onChanged: (text) {
                      _username = text;
                    },
                    decoration: InputDecoration(
                      //border: OutlineInputBorder(),
                      hintText: 'Username',
                    ),
                    autofocus: false,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: new Container(
                  width: 300,
                  height: 80,
                  color: Colors.white,
                  child: TextField(
                    style: Theme.of(context).textTheme.display1,
                    onChanged: (text) {
                      _password = text;
                    },
                    decoration: InputDecoration(
                      //border: OutlineInputBorder(),
                      hintText: 'Password',
                    ),
                    autofocus: false,
                    obscureText: true,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  _err,
                ),
              ),
            ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loginAttempt,
        tooltip: 'Login',
        child: Icon(Icons.attach_money),
      ),
    ),
    onWillPop: () { Navigator.of(context).pop();},
      );
  }
}
