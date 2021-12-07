import 'package:custom_switch/custom_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutterwhatsappclone/Screens/newcontact.dart';
import 'package:flutterwhatsappclone/Screens/slectfontsize.dart';
import 'package:flutterwhatsappclone/helper/sizeconfig.dart';

class NotificationOptions extends StatefulWidget {
  @override
  NotificationOptionsState createState() {
    return new NotificationOptionsState();
  }
}

class NotificationOptionsState extends State<NotificationOptions> {
  bool status = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Column(
            children: <Widget>[
              Container(
                height: SizeConfig.blockSizeVertical * 15,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 0, right: 0, top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.arrow_back_ios),
                            color: Colors.black,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          Text(
                            'Notifications',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            'aaa',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.transparent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text("MESSAGE NOTIFICATION"),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 0),
                child: Container(
                  color: Colors.grey[200],
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: SizeConfig.blockSizeVertical * 5,
                        child: Center(
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => NewContact()),
                              );
                            },
                            child: ListTile(
                              title: new Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  new Text(
                                    'Show Notifications',
                                    style: new TextStyle(
                                        fontSize:
                                            SizeConfig.blockSizeHorizontal * 4,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                  Container(
                                    child: CustomSwitch(
                                      activeColor: Colors.green,
                                      value: status,
                                      onChanged: (value) {
                                        print("VALUE : $value");
                                        setState(() {
                                          status = value;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Divider(
                          thickness: 1,
                        ),
                      ),
                      Container(
                        height: SizeConfig.blockSizeVertical * 5,
                        child: Center(
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => FontSize()),
                              );
                            },
                            child: ListTile(
                              title: new Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  new Text(
                                    'Sound',
                                    style: new TextStyle(
                                        fontSize:
                                            SizeConfig.blockSizeHorizontal * 4,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Divider(
                          thickness: 1,
                        ),
                      ),
                      Container(
                        height: SizeConfig.blockSizeVertical * 7,
                        child: Center(
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => NewContact()),
                              );
                            },
                            child: ListTile(
                              title: new Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  new Text(
                                    'Vibration',
                                    style: new TextStyle(
                                        fontSize:
                                            SizeConfig.blockSizeHorizontal * 4,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                  Container(
                                    child: CustomSwitch(
                                      activeColor: Colors.green,
                                      value: status,
                                      onChanged: (value) {
                                        print("VALUE : $value");
                                        setState(() {
                                          status = value;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text("MESSAGE NOTIFICATION"),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 0),
                child: Container(
                  color: Colors.grey[200],
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: SizeConfig.blockSizeVertical * 5,
                        child: Center(
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => NewContact()),
                              );
                            },
                            child: ListTile(
                              title: new Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  new Text(
                                    'Show Notifications',
                                    style: new TextStyle(
                                        fontSize:
                                            SizeConfig.blockSizeHorizontal * 4,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                  Container(
                                    child: CustomSwitch(
                                      activeColor: Colors.green,
                                      value: status,
                                      onChanged: (value) {
                                        print("VALUE : $value");
                                        setState(() {
                                          status = value;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Divider(
                          thickness: 1,
                        ),
                      ),
                      Container(
                        height: SizeConfig.blockSizeVertical * 5,
                        child: Center(
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => FontSize()),
                              );
                            },
                            child: ListTile(
                              title: new Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  new Text(
                                    'Sound',
                                    style: new TextStyle(
                                        fontSize:
                                            SizeConfig.blockSizeHorizontal * 4,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Divider(
                          thickness: 1,
                        ),
                      ),
                      Container(
                        height: SizeConfig.blockSizeVertical * 7,
                        child: Center(
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => NewContact()),
                              );
                            },
                            child: ListTile(
                              title: new Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  new Text(
                                    'Vibration',
                                    style: new TextStyle(
                                        fontSize:
                                            SizeConfig.blockSizeHorizontal * 4,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                  Container(
                                    child: CustomSwitch(
                                      activeColor: Colors.green,
                                      value: status,
                                      onChanged: (value) {
                                        print("VALUE : $value");
                                        setState(() {
                                          status = value;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 50,
              )
            ],
          ),
        ),
      ),
    );
  }
}
