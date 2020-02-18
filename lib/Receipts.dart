import 'dart:ffi';

import 'package:flutter/material.dart';

import 'dart:io';
import 'dart:async';
import 'dart:convert';

class Receipts extends StatelessWidget {
  final int userId;

  Receipts({Key key, this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Receipts',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.green,
      ),
      home: ReceiptsPage(
        userId: this.userId,
      ),
    );
  }
}

class ReceiptsPage extends StatefulWidget {
  ReceiptsPage({this.userId}) : super();

  final int userId;


  final String _host = "192.168.1.221";
  //final String _host = "web.pi";
  final int _port = 8000;

  @override
  _ReceiptsPageState createState() => _ReceiptsPageState();
}

class _ReceiptsPageState extends State<ReceiptsPage> {
  // variables for new receipt
  double amount;
  int receiptTypeID = 1; // 1 is standard bill
  DateTime purchaseDate = DateTime.now();
  String sPurchaseDate = DateTime.now().toString();
  String createdDate = DateTime.now().toString();
  String updatedDate = DateTime.now().toString();
  String description;

  HttpClient _httpClient = new HttpClient();
  String _err = "";
  String _usersDisplay = "";
  String _userOwnerDisplay = "";

  Map<int, String> usersToPopulate = new Map<int, String>();

  List<int> usersForReceiptsUsers = new List<int>();
  int userPaying;

  final StreamController<int> _streamController = StreamController<int>();

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: purchaseDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != purchaseDate)
      setState(() {
        purchaseDate = picked;
        sPurchaseDate = purchaseDate.toString();
      });
  }

  Future<HttpClientResponse> _doSubmit(BuildContext context) async {
    // Error handling first
    if (usersForReceiptsUsers == null || usersForReceiptsUsers.length == 0) {
      _err = "No users set";
    }

    //print(usersForReceiptsUsers);

    Map<String, dynamic> jsonMap = {
      'OwnerUserID': userPaying,
      'Amount': amount,
      'ReceiptTypeID': receiptTypeID,
      'PurchaseDate': sPurchaseDate,
      'CreatedBy': widget.userId,
      'CreatedDate': createdDate,
      'UpdatedBy': widget.userId,
      'UpdatedDate': updatedDate,
      'Description': description,
      'UserIdsCommaSeparated': _getUserIdsCommaSeparatedList()
    };

    // https://dart.dev/guides/libraries/library-tour
    String sRequestData = json.encode(jsonMap);
    List<int> listBytes = utf8.encode(sRequestData);

    HttpClientRequest request = await _httpClient.post(
        widget._host, widget._port, "/mobile/receipts/create");

    request.headers.set('Content-Length', listBytes.length.toString());
    request.add(listBytes);

    return await request.close();
  }

  void _submitAttempt() async {
    setState(() {
      _err = "Submitting...";
    });

    HttpClientResponse response = await this._doSubmit(context);
    String sResponse = await response.transform(utf8.decoder).join();
    Map mResponse = jsonDecode(sResponse) as Map;

    bool insertSuccessful = mResponse["status"] == 1 ? true : false;
    if (insertSuccessful) {
      setState(() {
        _err = mResponse["description"];
      });
    } else {
      setState(() {
        _err = mResponse["description"];
      });
    }
  }

  String _getUserIdsCommaSeparatedList() {
    String sUserIds = "";
    int userId;

    if (usersForReceiptsUsers.length >= 1) {
      for (int i = 0; i < usersForReceiptsUsers.length; i++) {
        userId = usersForReceiptsUsers[i];
        sUserIds += i == 0 ? userId.toString() : "," + userId.toString();
      }

      return sUserIds;
    }

    return "";
  }

  void _fillUserDisplay() {
    _usersDisplay = "Users to pay: ";
    String name;
    for (int i = 0; i < usersForReceiptsUsers.length; i++) {
      int userId = usersForReceiptsUsers[i];
      name = usersToPopulate[userId];
      setState(() {
        _usersDisplay += i == 0 ? name : ", " + name;
      });
    }
  }

  void _fillUserOwnerDisplay() {
    setState(() {
      _userOwnerDisplay = "Purchaser: " + usersToPopulate[userPaying];
    });
  }


  @override
  Widget build(BuildContext context) {
    usersToPopulate = {
      8: "alex",
      9: "connor",
      10: "sac"
    }; // sets values to default us

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
            Text(
              _userOwnerDisplay,
              style: Theme.of(context).textTheme.display2,
              textScaleFactor: 0.3333,
            ),
            Text(
              _usersDisplay,
              style: Theme.of(context).textTheme.display2,
              textScaleFactor: 0.3333,
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: new Container(
                  width: 300,
                  child: new DropdownButton<int>(
                    hint: Text("Who purchased this? "),
                    items: usersToPopulate.keys.map((int key) {
                      return new DropdownMenuItem<int>(
                        value: key,
                        child: new Text(usersToPopulate[key].toString()),
                      );
                    }).toList(),
                    onChanged: (var item) {
                      userPaying = item;
                      _fillUserOwnerDisplay();
                    },
                  )),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: new Container(
                  width: 300,
                  child: new DropdownButton<int>(
                    hint: Text("Who is paying?"),
                    items: usersToPopulate.keys.map((int key) {
                      return new DropdownMenuItem<int>(
                        value: key,
                        child: new Text(usersToPopulate[key].toString()),
                      );
                    }).toList(),
                    onChanged: (var item) {
                      usersForReceiptsUsers.add(item);
                      _fillUserDisplay();
                    },
                  )),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: new Container(
                width: 300,
                height: 50,
                child: TextFormField(
                  style: Theme.of(context).textTheme.display1,
                  decoration: InputDecoration(
                    hintText: "Description",
                  ),
                  onChanged: (text) {
                    setState(() {
                      description = text;
                      if (description == "") {
                        _err = "Please set a description";
                      } else {
                        _err = "";
                      }
                    });
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: new Container(
                width: 300,
                height: 50,
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  style: Theme.of(context).textTheme.display1,
                  decoration: InputDecoration(
                    hintText: "Amount",
                  ),
                  onChanged: (text) {
                    amount = double.tryParse(text);
                    if (amount == null) {
                      setState(() {
                        _err = "Invalid Amount set";
                      });
                    } else {
                      if (_err == "Invalid Amount set") {
                        setState(() {
                          _err = "";
                        });
                      }
                    }
                  },
                ),
              ),
            ),
            Text(
              "${purchaseDate.toString().substring(0, 10)}",
              style: Theme.of(context).textTheme.display1,
            ),
            Row(
                //children<Widget>[]: [
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: new Container(
                        width: 125,
                        height: 50,
                        child: RaisedButton(
                          onPressed: () => _selectDate(context),
                          child: Text('Select date'),
                        )),
                  ),
                ]
                //  ],
                ),
            Text(
              _err,
              style: Theme.of(context).textTheme.display1,
            ),
          ])),
      floatingActionButton: FloatingActionButton(
        onPressed: _submitAttempt,
        tooltip: 'Submit',
        child: Icon(Icons.add),
      ),
    );
  }
}
