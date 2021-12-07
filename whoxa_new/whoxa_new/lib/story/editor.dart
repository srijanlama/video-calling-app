import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_editor_pro/modules/all_emojies.dart';
import 'package:image_editor_pro/modules/emoji.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:signature/signature.dart';

TextEditingController heightcontroler = TextEditingController();
TextEditingController widthcontroler = TextEditingController();
var width = 300;
var height = 300;

List fontsize = [];
var howmuchwidgetis = 0;
List multiwidget = [];
Color currentcolors = Colors.white;
var opicity = 0.0;
SignatureController _controller =
    SignatureController(penStrokeWidth: 5, penColor: Colors.green);

class ImageEditorPro extends StatefulWidget {
  final Color appBarColor;
  final Color bottomBarColor;
  final File image;
  ImageEditorPro({this.appBarColor, this.bottomBarColor, this.image});

  @override
  _ImageEditorProState createState() => _ImageEditorProState();
}

var slider = 0.0;

class _ImageEditorProState extends State<ImageEditorPro> {
  // create some values
  Color pickerColor = Color(0xff443a49);
  Color currentColor = Color(0xff443a49);

// ValueChanged<Color> callback
  void changeColor(Color color) {
    setState(() => pickerColor = color);
    var points = _controller.points;
    _controller =
        SignatureController(penStrokeWidth: 5, penColor: color, points: points);
  }

  final textController = TextEditingController();

  List<Offset> offsets = [];
  Offset offset1 = Offset.zero;
  Offset offset2 = Offset.zero;
  final scaf = GlobalKey<ScaffoldState>();
  var openbottomsheet = false;
  List<Offset> _points = <Offset>[];
  List type = [];
  List aligment = [];

  final GlobalKey container = GlobalKey();
  final GlobalKey globalKey = new GlobalKey();
  ScreenshotController screenshotController = ScreenshotController();
  Timer timeprediction;
  void timers() {
    Timer.periodic(Duration(milliseconds: 10), (tim) {
      setState(() {});
      timeprediction = tim;
    });
  }

  @override
  void dispose() {
    timeprediction.cancel();

    super.dispose();
  }

  @override
  void initState() {
    timers();
    _controller.clear();
    type.clear();
    fontsize.clear();
    offsets.clear();
    multiwidget.clear();
    howmuchwidgetis = 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        key: scaf,
        appBar: new AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
          ),
          actions: <Widget>[
            new IconButton(
                icon: Icon(
                  Icons.undo,
                  color: Colors.black,
                ),
                onPressed: () {
                  _controller.points.clear();
                  setState(() {});
                }),
            // ignore: deprecated_member_use
            new FlatButton(
                child: new Text("Done"),
                textColor: Colors.black,
                onPressed: () {
                  // ignore: unused_local_variable
                  File _imageFile;
                  _imageFile = null;
                  screenshotController
                      .capture(
                          delay: Duration(milliseconds: 500), pixelRatio: 1.5)
                      .then((File image) async {
                    //print("Capture Done");
                    setState(() {
                      _imageFile = image;
                    });
                    final paths = await getExternalStorageDirectory();
                    image.copy(paths.path +
                        '/' +
                        DateTime.now().millisecondsSinceEpoch.toString() +
                        '.png');
                    Navigator.pop(context, image);
                  }).catchError((onError) {
                    print(onError);
                  });
                }),
          ],
          backgroundColor: widget.appBarColor,
        ),
        body: Center(
          child: Screenshot(
            controller: screenshotController,
            child: Container(
              margin: EdgeInsets.all(0),
              color: Colors.white,
              width: double.infinity,
              height: double.infinity,
              child: RepaintBoundary(
                  key: globalKey,
                  child: Stack(
                    children: <Widget>[
                      widget.image != null
                          ? Image.file(
                              widget.image,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.contain,
                            )
                          : Container(),
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        child: GestureDetector(
                            onPanUpdate: (DragUpdateDetails details) {
                              setState(() {
                                RenderBox object = context.findRenderObject();
                                Offset _localPosition = object
                                    .globalToLocal(details.globalPosition);
                                _points = new List.from(_points)
                                  ..add(_localPosition);
                              });
                            },
                            onPanEnd: (DragEndDetails details) {
                              _points.add(null);
                            },
                            child: Signat()),
                      ),
                      Stack(
                        children: multiwidget.asMap().entries.map((f) {
                          return type[f.key] == 1
                              ? EmojiView(
                                  left: offsets[f.key].dx,
                                  top: offsets[f.key].dy,
                                  ontap: () {
                                    scaf.currentState
                                        .showBottomSheet((context) {
                                      return Sliders(
                                        size: f.key,
                                        sizevalue: fontsize[f.key].toDouble(),
                                      );
                                    });
                                  },
                                  onpanupdate: (details) {
                                    setState(() {
                                      offsets[f.key] = Offset(
                                          offsets[f.key].dx + details.delta.dx,
                                          offsets[f.key].dy + details.delta.dy);
                                    });
                                  },
                                  value: f.value.toString(),
                                  fontsize: fontsize[f.key].toDouble(),
                                  align: TextAlign.start,
                                )
                              : type[f.key] == 2
                                  ? TextView(
                                      left: offsets[f.key].dx,
                                      top: offsets[f.key].dy,
                                      textColor: pickerColor,
                                      ontap: () {
                                        scaf.currentState
                                            .showBottomSheet((context) {
                                          return Sliders(
                                            size: f.key,
                                            sizevalue:
                                                fontsize[f.key].toDouble(),
                                          );
                                        });
                                      },
                                      onpanupdate: (details) {
                                        setState(() {
                                          offsets[f.key] = Offset(
                                              offsets[f.key].dx +
                                                  details.delta.dx,
                                              offsets[f.key].dy +
                                                  details.delta.dy);
                                        });
                                      },
                                      value: f.value.toString(),
                                      fontsize: fontsize[f.key].toDouble(),
                                      align: TextAlign.start,
                                    )
                                  : new Container();
                        }).toList(),
                      )
                    ],
                  )),
            ),
          ),
        ),
        bottomNavigationBar: openbottomsheet
            ? new Container()
            : Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(blurRadius: 10.9)]),
                height: 70,
                child: Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: new Row(
                    //scrollDirection: Axis.horizontal,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      IconButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Pick a color!'),
                                  content: SingleChildScrollView(
                                    child: ColorPicker(
                                      pickerColor: pickerColor,
                                      onColorChanged: changeColor,
                                      showLabel: true,
                                      pickerAreaHeightPercent: 0.8,
                                    ),
                                  ),
                                  actions: <Widget>[
                                    // ignore: deprecated_member_use
                                    FlatButton(
                                      child: const Text('Got it'),
                                      onPressed: () {
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop('dialog');
                                        setState(
                                            () => currentColor = pickerColor);
                                      },
                                    ),
                                  ],
                                );
                              });

                          // showDialog(
                          //     context: context,
                          //     child: AlertDialog(
                          //       title: const Text('Pick a color!'),
                          //       content: SingleChildScrollView(
                          //         child: ColorPicker(
                          //           pickerColor: pickerColor,
                          //           onColorChanged: changeColor,
                          //           showLabel: true,
                          //           pickerAreaHeightPercent: 0.8,
                          //         ),
                          //       ),
                          //       actions: <Widget>[
                          //         FlatButton(
                          //           child: const Text('Got it'),
                          //           onPressed: () {
                          //             Navigator.of(context, rootNavigator: true)
                          //                 .pop('dialog');
                          //             setState(
                          //                 () => currentColor = pickerColor);
                          //           },
                          //         ),
                          //       ],
                          //     ));
                        },
                        icon: Icon(
                          Icons.color_lens,
                          size: 30,
                          color: Colors.black,
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return StatefulBuilder(builder:
                                    (BuildContext context,
                                        StateSetter setState1) {
                                  return SimpleDialog(
                                    children: <Widget>[
                                      Form(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Container(
                                              height: 10,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 20),
                                              child: Text('Insert your message',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black54)),
                                            ),
                                            Container(
                                              height: 10,
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 15,
                                                      vertical: 5),
                                              child: new TextFormField(
                                                controller: textController,
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .hintColor),
                                                keyboardType:
                                                    TextInputType.text,
                                                maxLines: 5,
                                                decoration: InputDecoration(
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  contentPadding:
                                                      const EdgeInsets
                                                              .symmetric(
                                                          vertical: 14.0,
                                                          horizontal: 14),
                                                  errorStyle: TextStyle(
                                                      color: Colors.white),
                                                  focusedErrorBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.black45),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  labelStyle: TextStyle(
                                                      color: Colors.black45),
                                                  hintStyle: TextStyle(
                                                      color: Colors.black45),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.black54,
                                                        width: 1.8),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.black54,
                                                        width: 1.8),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  hintText: '',
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: <Widget>[
                                          MaterialButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text(
                                              'Cancel',
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .hintColor),
                                            ),
                                          ),
                                          MaterialButton(
                                            onPressed: () {
                                              Navigator.pop(context);

                                              type.add(2);
                                              fontsize.add(20);
                                              offsets.add(Offset.zero);
                                              multiwidget
                                                  .add(textController.text);
                                              howmuchwidgetis++;
                                            },
                                            child: Text(
                                              'Next',
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ),
                                        ],
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                      ),
                                    ],
                                  );
                                });
                              });

                          // final value = await Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) => TextEditor()));
                          // if (value.toString().isEmpty) {
                          //   print("true");
                          // } else {
                          //   type.add(2);
                          //   fontsize.add(20);
                          //   offsets.add(Offset.zero);
                          //   multiwidget.add(value);
                          //   howmuchwidgetis++;
                          // }
                        },
                        icon: Icon(
                          Icons.text_fields,
                          size: 30,
                          color: Colors.black,
                        ),
                      ),
                      IconButton(
                          onPressed: () async {
                            _controller.clear();
                            type.clear();
                            fontsize.clear();
                            offsets.clear();
                            multiwidget.clear();
                            howmuchwidgetis = 0;
                          },
                          icon: Image.asset("assets/images/eraser.png",
                              height: 28)),
                      IconButton(
                        onPressed: () async {
                          Future getemojis = showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context) {
                                return Emojies();
                              });
                          getemojis.then((value) {
                            if (value != null) {
                              type.add(1);
                              fontsize.add(20);
                              offsets.add(Offset.zero);
                              multiwidget.add(value);
                              howmuchwidgetis++;
                            }
                          });
                        },
                        icon: Icon(
                          Icons.emoji_emotions,
                          color: Colors.black,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),
              ));
  }
}

class Signat extends StatefulWidget {
  @override
  _SignatState createState() => _SignatState();
}

class _SignatState extends State<Signat> {
  @override
  void initState() {
    super.initState();
    _controller.addListener(() => print("Value changed"));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Signature(controller: _controller, backgroundColor: Colors.transparent),
      ],
    );
  }
}

class Sliders extends StatefulWidget {
  final int size;
  final sizevalue;
  const Sliders({Key key, this.size, this.sizevalue}) : super(key: key);
  @override
  _SlidersState createState() => _SlidersState();
}

class _SlidersState extends State<Sliders> {
  @override
  void initState() {
    slider = widget.sizevalue;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 120,
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: IconButton(
                    padding: const EdgeInsets.all(0),
                    onPressed: () {
                      // Navigator.of(context, rootNavigator: true).pop('dialog');
                      Navigator.pop(context);
                    },
                    icon: Text("Done"),
                  ),
                ),
              ],
            ),
            Divider(
              height: 1,
            ),
            new Slider(
                value: slider,
                min: 0.0,
                max: 100.0,
                onChangeEnd: (v) {
                  setState(() {
                    fontsize[widget.size] = v.toInt();
                  });
                },
                onChanged: (v) {
                  setState(() {
                    slider = v;
                    print(v.toInt());
                    fontsize[widget.size] = v.toInt();
                  });
                }),
          ],
        ));
  }
}

class TextView extends StatefulWidget {
  final double left;
  final double top;
  final Function ontap;
  final Function(DragUpdateDetails) onpanupdate;
  final double fontsize;
  final String value;
  final TextAlign align;
  final Color textColor;
  const TextView(
      {Key key,
      this.left,
      this.top,
      this.ontap,
      this.onpanupdate,
      this.fontsize,
      this.value,
      this.align,
      this.textColor})
      : super(key: key);
  @override
  _TextViewState createState() => _TextViewState();
}

class _TextViewState extends State<TextView> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.left,
      top: widget.top,
      child: GestureDetector(
          onTap: widget.ontap,
          onPanUpdate: widget.onpanupdate,
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Container(
              width: 330,
              child: Text(widget.value,
                  textAlign: widget.align,
                  style: TextStyle(
                      fontSize: widget.fontsize, color: widget.textColor)),
            ),
          )),
    );
  }
}

class TextEditor extends StatefulWidget {
  @override
  _TextEditorState createState() => _TextEditorState();
}

class _TextEditorState extends State<TextEditor> {
  TextEditingController name = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // appBar: new AppBar(
      //   backgroundColor: Colors.black,
      //   actions: <Widget>[
      //     new IconButton(
      //         icon: Icon(FontAwesomeIcons.alignLeft), onPressed: () {}),
      //     new IconButton(
      //         icon: Icon(FontAwesomeIcons.alignCenter), onPressed: () {}),
      //     new IconButton(
      //         icon: Icon(FontAwesomeIcons.alignRight), onPressed: () {}),
      //   ],
      // ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: name,
                decoration: InputDecoration(
                  hintText: "Insert your message",
                  hintStyle: TextStyle(color: Colors.white),
                  alignLabelWithHint: true,
                ),
                scrollPadding: EdgeInsets.all(20.0),
                keyboardType: TextInputType.multiline,
                maxLines: 99999,
                style: TextStyle(
                  color: Colors.white,
                ),
                autofocus: true,
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: new Container(
        color: Colors.white,
        padding: EdgeInsets.all(10),
        // ignore: deprecated_member_use
        child: new FlatButton(
            onPressed: () {
              Navigator.pop(context, name.text);
            },
            color: Colors.black,
            padding: EdgeInsets.all(15),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: new Text(
              "Add Text",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.white),
            )),
      ),
    );
  }
}
