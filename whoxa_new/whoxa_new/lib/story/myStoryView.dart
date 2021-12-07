import 'package:flutter/material.dart';
import 'package:flutterwhatsappclone/Screens/widgets/customBottomSheet.dart';
import 'package:flutterwhatsappclone/storyPlugin/story_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swipedetector/swipedetector.dart';
import 'package:flutterwhatsappclone/helper/sizeconfig.dart';
import 'package:timeago/timeago.dart';

// ignore: must_be_immutable
class MyStoryPageView extends StatelessWidget {
  BuildContext context;
  List<dynamic> images;
  String time;
  MyStoryPageView(BuildContext context, {this.images, this.time});

  @override
  Widget build(BuildContext context) {
    final controller = StoryController();

    List<StoryItem> storyItems = [];

    for (var value in images) {
      if (value["type"] == "image") {
        storyItems.add(
          StoryItem.pageImage(
              controller: controller,
              url: value["image"],
              duration: Duration(seconds: 5),
              shown: true,
              caption: value["text"],
              time: value["time"]),
        );
      } else {
        storyItems.add(StoryItem.pageVideo(value["image"],
            controller: controller,
            shown: true,
            caption: value["text"],
            time: value["time"]));
      }
    }

    return SwipeDetector(
      onSwipeUp: () {
        controller.pause();
        // _handleFABPressed(context);
      },
      child: Material(
        child: Column(
          children: <Widget>[
            Expanded(
              child: StoryView(
                  onStoryShow: (s) {
                    print(s.time.toString());
                  },
                  progressPosition: ProgressPosition.top,
                  storyItems: storyItems,
                  controller: controller,
                  inline: false,
                  repeat: true,
                  onComplete: () {
                    controller.pause();
                    Navigator.pop(context);
                  },
                  onVerticalSwipeComplete: (direction) {
                    if (direction == Direction.down) {
                      controller.pause();
                      Navigator.pop(context);
                    }
                  }),
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     Expanded(
            //       child: Container(
            //         color: Colors.black,
            //         child: RotationTransition(
            //           turns: new AlwaysStoppedAnimation(90 / 360),
            //           child: IconButton(
            //             onPressed: () {
            //               controller.pause();
            //               _handleFABPressed(context);
            //             },
            //             icon: Icon(
            //               Icons.arrow_back_ios,
            //               color: Colors.white,
            //             ),
            //           ),
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }

  // ignore: unused_element
  void _handleFABPressed(BuildContext contaxt1) {
    showModalBottomSheet<int>(
      backgroundColor: Colors.transparent,
      context: contaxt1,
      builder: (context) {
        return Popover(child: myStatusWidget());
      },
    );
  }

  Widget myStatusWidget() {
    return StreamBuilder(
      stream: Firestore.instance
          .collection("storyViews")
          .where(FieldPath.documentId, isEqualTo: time)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        return snapshot.hasData && snapshot.data.documents.length > 0
            ? ListView.builder(
                padding: const EdgeInsets.all(0),
                itemCount: snapshot.data.documents[0]["views"].length,
                shrinkWrap: true,
                itemBuilder: (context, int index) {
                  return Container(
                    color: Colors.grey[100],
                    height: SizeConfig.blockSizeVertical * 10,
                    child: Center(
                      child: Row(
                        children: [
                          Expanded(
                            child: ListTile(
                              onTap: () {},
                              leading: Container(
                                height: 60,
                                width: 60,
                                child: new Stack(
                                  children: <Widget>[
                                    snapshot
                                                .data
                                                .documents[0]["views"][index]
                                                    ["image"]
                                                .length >
                                            0
                                        ? CircleAvatar(
                                            radius: 30,
                                            backgroundImage: NetworkImage(
                                              snapshot.data.documents[0]
                                                  ["views"][index]["image"],
                                            ),
                                          )
                                        : Image.asset(
                                            "assets/images/person.png"),
                                  ],
                                ),
                              ),
                              title: new Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  new Text(
                                    snapshot.data.documents[0]["views"][index]
                                        ["name"],
                                    style: new TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              subtitle: new Container(
                                padding: const EdgeInsets.only(top: 5.0),
                                child: new Text(
                                  format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        int.parse(
                                      snapshot.data.documents[0]["views"][index]
                                          ["timestamp"],
                                    )),
                                  ),
                                  style: new TextStyle(
                                      color: Colors.grey, fontSize: 14.0),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
            : Container();
      },
    );
  }
}
