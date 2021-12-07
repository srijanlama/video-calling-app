import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterwhatsappclone/Screens/groupChat/groupinfo.dart';
import 'package:flutterwhatsappclone/Screens/widgets/chat_bubble.dart';
import 'package:flutterwhatsappclone/helper/sizeconfig.dart';
import 'package:flutterwhatsappclone/models/message.dart';

class ChatDetail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;

   

    final userName = Text(
      'Kristen Johnson',
      style: TextStyle(
          fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.black),
    );

   

    final messageList = ListView.builder(
      scrollDirection: Axis.vertical,
      itemCount: messages.length,
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          onLongPress: () {
            _bubblelongpressBottomSheet(context);
          },
          child: ChatBubble(
            message: messages[index],
          ),
        );
      },
    );

 

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, 100),
        child: Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                    color: Colors.grey[200], spreadRadius: 5, blurRadius: 2)
              ]),
              width: MediaQuery.of(context).size.width,
              height: SizeConfig.blockSizeVertical * 12,
              child: Container(
                child: Container(
                  margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => GroupInfo()),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios),
                          color: Colors.black,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                         Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(100.0),
        child: Container(
          height: SizeConfig.blockSizeVertical * 7,
          width: SizeConfig.blockSizeHorizontal * 13,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100.0),
            image: DecorationImage(
              image: AssetImage('assets/images/man1.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
                        Padding(
                          padding: const EdgeInsets.only(right: 50),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              userName,
                              Text(
                                'Online',
                                style: TextStyle(color: Colors.green),
                              ),
                            ],
                          ),
                        ),
                        Image.asset(
                          'assets/images/Video_Call.png',
                          height: SizeConfig.safeBlockVertical * 3,
                        ),
                        Image.asset(
                          'assets/images/Call.png',
                          height: SizeConfig.safeBlockVertical * 3,
                        ),
                        // Image.asset(name),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            height: deviceHeight,
            width: deviceWidth,
            child: Column(
              children: <Widget>[
                // appBar,

                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 0, right: 0, top: 10, bottom: 60),
                    child: Material(
                      elevation: 5.0,
                      shadowColor: Colors.white,
                      child: Container(
                          width: SizeConfig.screenWidth,
                          decoration: BoxDecoration(
                            color: Colors.white,
                          ),
                          child: messageList),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.only(left: 0, right: 0),
        child: Container(
          height: 60.0,
          width: deviceHeight,
          decoration: BoxDecoration(color: Colors.white),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: InkWell(
                    onTap: () {
                      _settingModalBottomSheet(context);
                    },
                    child: Image.asset('assets/images/Group_33.png')),
              ),
             Container(
      padding: EdgeInsets.only(
        left: 20.0,
      ),
      height: 47.0,
      width: deviceWidth * 0.6,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.grey[300],
      ),
      child: TextField(
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Type a message...',
          hintStyle: TextStyle(
            color: Colors.grey.withOpacity(0.6),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.camera_alt,
                  color: Colors.black,
                ),
                iconSize: 32.0,
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.mic,
                  color: Colors.black,
                ),
                iconSize: 30.0,
              ),
            ],
          ),
        ),
      ),
    )
        ],
      ),
    );
  }

  void _settingModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                    leading: new Icon(Icons.music_video),
                    title: new Text('Photo & video library'),
                    onTap: () => {}),
                new ListTile(
                  leading: new Icon(Icons.attach_file),
                  title: new Text('Documents'),
                  onTap: () => {},
                ),
                new ListTile(
                  leading: new Icon(Icons.location_on),
                  title: new Text('Location'),
                  onTap: () => {},
                ),
                new ListTile(
                  leading: new Icon(Icons.contacts),
                  title: new Text('Contacts'),
                  onTap: () => {},
                ),
              ],
            ),
          );
        });
  }

  void _bubblelongpressBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: new Wrap(
              children: <Widget>[
                Center(
                    child: new ListTile(
                        title: Center(child: new Text('Star')),
                        onTap: () => {})),
                new ListTile(
                  title: Center(child: new Text('Reply')),
                  onTap: () => {},
                ),
                new ListTile(
                  title: Center(child: new Text('Forward')),
                  onTap: () => {},
                ),
                new ListTile(
                  title: Center(child: new Text('Copy')),
                  onTap: () => {},
                ),
                new ListTile(
                  title: Center(
                    child: new Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  onTap: () => {},
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: new RawMaterialButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      elevation: 2.0,
                      fillColor: Colors.grey[300],
                      child: Icon(
                        Icons.close,
                        size: 20.0,
                      ),
                      padding: EdgeInsets.all(15.0),
                      shape: CircleBorder(),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }
}
