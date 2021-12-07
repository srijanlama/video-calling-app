import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterwhatsappclone/constatnt/global.dart';
import 'package:flutterwhatsappclone/helper/sizeconfig.dart';

import 'package:toast/toast.dart';

// ignore: must_be_immutable
class SaveContact extends StatefulWidget {
  String name;
  String phone;
  String peerId;
  SaveContact({this.name, this.phone, this.peerId});
  @override
  _NewContactState createState() => _NewContactState();
}

class _NewContactState extends State<SaveContact> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  Contact contact = Contact();
  PostalAddress address = PostalAddress(label: "Home");
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    nameController.text = widget.name;
    phoneController.text = widget.phone;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Form(
      key: _formKey,
      child: Container(
        child: Scaffold(
            backgroundColor: Colors.white,
            body: LayoutBuilder(builder: (context, constraint) {
              return Padding(
                padding: const EdgeInsets.only(top: 70),
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraint.maxHeight),
                    child: Material(
                      elevation: 10,
                      color: Colors.white,
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, top: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: appColorBlue,
                                    ),
                                  ),
                                ),
                                Text(
                                  'New Contact',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: "MontserratBold",
                                    color: appColorBlack,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    _formKey.currentState.save();
                                    contact.postalAddresses = [address];
                                    ContactsService.addContact(contact);
                                    Toast.show(
                                        "Contact saved successfully", context,
                                        duration: Toast.LENGTH_SHORT,
                                        gravity: Toast.BOTTOM);
                                    setState(() {
                                      savedContactUserId.add(widget.peerId);
                                    });
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    'Save',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: appColorBlue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 10, left: 15, right: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Text(
                                      'Name',
                                      style: TextStyle(
                                          fontSize:
                                              SizeConfig.blockSizeHorizontal *
                                                  4.2,
                                          fontFamily: "MontserratBold"),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    children: <Widget>[
                                      TextFormField(
                                        controller: nameController,
                                        onSaved: (v) => contact.givenName = v,
                                        decoration: InputDecoration(
                                            hintText: 'First Name',
                                            hintStyle: TextStyle(fontSize: 14)),
                                      ),
                                      TextFormField(
                                        onSaved: (v) => contact.familyName = v,
                                        decoration: InputDecoration(
                                            hintText: 'Last Name',
                                            hintStyle: TextStyle(fontSize: 14)),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: SizeConfig.safeBlockVertical * 5,
                          ),
                          Divider(
                            thickness: 1,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 20, left: 15, right: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'Country',
                                          style: TextStyle(
                                              fontSize: SizeConfig
                                                      .blockSizeHorizontal *
                                                  4.1,
                                              fontFamily: "MontserratBold"),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 20),
                                          child: Text(
                                            'Mobile',
                                            style: TextStyle(
                                                fontSize: SizeConfig
                                                        .blockSizeHorizontal *
                                                    4.2,
                                                fontFamily: "MontserratBold"),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(width: 10),
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    children: <Widget>[
                                      TextFormField(
                                        onSaved: (v) => address.country = v,
                                        decoration: InputDecoration(
                                          hintText: 'Country Name',
                                          hintStyle: TextStyle(fontSize: 14),
                                        ),
                                      ),
                                      TextFormField(
                                        controller: phoneController,
                                        onSaved: (v) => contact.phones = [
                                          Item(label: "mobile", value: v)
                                        ],
                                        keyboardType: TextInputType.phone,
                                        decoration: InputDecoration(
                                            hintText: 'Phone number',
                                            hintStyle: TextStyle(fontSize: 14)),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: SizeConfig.safeBlockVertical * 5,
                          ),
                          Divider(
                            thickness: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            })),
      ),
    );
  }
}
