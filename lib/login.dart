import 'package:flutter/material.dart';

import 'dart:io';
import 'dart:async';
import 'dart:convert';

import './Receipts.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  //final String _host = "http://web.pi";

  final String _host = "192.168.1.221";
  final int _port = 8000;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  HttpClient _httpClient = new HttpClient();

  bool _loginSuccessful = false;
  String _username;
  String _password;

  String _err = "";

  Future<HttpClientResponse> _doLogin() async {
    Map<String, String> jsonMap = {
      'username': _username,
      'password': _password
    };

    // https://dart.dev/guides/libraries/library-tour
    String sRequestData = json.encode(jsonMap);
    List<int> listBytes = utf8.encode(sRequestData);

    HttpClientRequest request = await _httpClient.post(
        widget._host, widget._port, "/mobile/user/login");

    request.headers.set('Content-Length', listBytes.length.toString());
    request.add(listBytes);

    return await request.close();
  }

  void _loginAttempt() async {
    HttpClientResponse response = await this._doLogin();
    String sResponse = await response.transform(utf8.decoder).join();
    Map mResponse = jsonDecode(sResponse) as Map;

    int userId;
    _loginSuccessful = mResponse["status"] == 0 ? false : true;
    if (_loginSuccessful) {
      setState(() {
        _err = "";
      });
      userId = mResponse["status"];
      Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (context) => new Receipts(
                    userId: userId,
                  )));
    }
    else {
      setState(() {
        _err = mResponse["description"];

      });

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}
