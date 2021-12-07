import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterwhatsappclone/constatnt/global.dart';
import 'package:flutterwhatsappclone/storyPlugin/story_view.dart';

// ignore: must_be_immutable
class StoryPageView extends StatelessWidget {
  BuildContext context;
  List<dynamic> images;
  String peerId;
  String userId;
  StoryPageView(BuildContext context, {this.images, this.peerId, this.userId});

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

    return Material(
      child: Column(
        children: <Widget>[
          Expanded(
            child: StoryView(
                onStoryShow: (s) {
                  print(peerId);
                  print(userID);
                  print(s.time.toString());
                  if (peerId != userId) {
                    userViewStory(s.time.toString());
                  }
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
        ],
      ),
    );
  }

  userViewStory(time) async {
    var check = [];
    var document1 = Firestore.instance.collection("storyViews").document(time);

    document1.get().then((value) async {
      if (value.exists) {
        for (var i = 0; i < value["views"].length; i++) {
          check.add(value["views"][i]["userId"]);
        }
      }
    }).then((value) {
      if (check.contains(userID)) {
      } else {
        Firestore.instance.collection('storyViews').document(time).setData({
          "views": FieldValue.arrayUnion([
            {
              "name": globalName,
              "image": globalImage,
              "userId": userID,
              "timestamp": DateTime.now().millisecondsSinceEpoch.toString(),
            }
          ])
        }, merge: true).then((value) async {});
      }
    });
  }
}
