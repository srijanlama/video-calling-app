import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutterwhatsappclone/constatnt/global.dart';

// ignore: must_be_immutable
class ViewImages extends StatefulWidget {
  List<dynamic> images;
  int number;
  ViewImages({this.images, this.number});
  @override
  State<StatefulWidget> createState() {
    return _ViewImagesState();
  }
}

class _ViewImagesState extends State<ViewImages> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appColorWhite,
        title: Text(
          "",
          style: TextStyle(
              fontFamily: "MontserratBold", fontSize: 17, color: appColorBlack),
        ),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: appColorBlue,
            )),
      ),
      body: Stack(
        children: [
          CarouselSlider(
            options: CarouselOptions(
                initialPage: widget.number,
                height: height,
                viewportFraction: 1.0,
                enlargeCenterPage: false,
                onPageChanged: (index, reason) {
                  setState(() {
                    _current = index;
                  });
                }
                // autoPlay: false,
                ),
            items: widget.images
                .map((item) => Container(
                      color: appColorWhite,
                      child: CachedNetworkImage(
                        placeholder: (context, url) => Center(
                            child: Container(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator())),
                        imageUrl: item,
                        fit: BoxFit.contain,
                      ),
                    ))
                .toList(),
          ),
          widget.images.length > 1
              ? Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: widget.images.map((url) {
                      int index = widget.images.indexOf(url);
                      return Container(
                        width: 15.0,
                        height: 15.0,
                        margin: EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 4.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _current == index
                              ? Colors.grey[700]
                              : Colors.white,
                        ),
                      );
                    }).toList(),
                  ),
                )
              : Container(),
          // Padding(
          //   padding: const EdgeInsets.only(top: 50, right: 20),
          //   child: Align(
          //     alignment: Alignment.topRight,
          //     child: IconButton(
          //       padding: new EdgeInsets.all(2.0),
          //       onPressed: () {
          //         Navigator.pop(context);
          //       },
          //       icon: Image.asset(
          //         'assets/images/crosswhite.png',
          //         height: 60,
          //         width: 60,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
