import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import '../../serverconfig.dart';
import '../../models/homestay.dart';
import '../../models/user.dart';

class DetailsScreen extends StatefulWidget {
    final Homestay homestay;
    final User user;
    const DetailsScreen({
        Key? key,
        required this.homestay,
        required this.user,
    }) : super(key: key);

    @override
    State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
    var pathAsset = "assets/images/uploadpic.png";
    bool _isChecked = false;
    final TextEditingController _hsnameEditingController = TextEditingController();
    final TextEditingController _hsdescEditingController = TextEditingController();
    final TextEditingController _hspriceEditingController = TextEditingController();
    final TextEditingController _hsstateEditingController = TextEditingController();
    final TextEditingController _hslocalEditingController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    File? _image;
    late double screenHeight, screenWidth, resWidth;
    int rowcount = 2;

    @override
    void initState() {
        super.initState();
        _hsnameEditingController.text = widget.homestay.homestayName.toString();
        _hsdescEditingController.text = widget.homestay.homestayDesc.toString();
        _hspriceEditingController.text = widget.homestay.homestayPrice.toString();
        _hsstateEditingController.text = widget.homestay.homestayState.toString();
        _hslocalEditingController.text = widget.homestay.homestayLocal.toString();
    }

    @override
    Widget build(BuildContext context) {
        screenHeight = MediaQuery.of(context).size.height;
        screenWidth = MediaQuery.of(context).size.width;

        if (screenWidth <= 600) {
            resWidth = screenWidth;
        } else {
            resWidth = screenWidth * 0.75;
        }

        return Scaffold(
            appBar: AppBar(
                title: const Text(
                    "Edit Details"
                )
            ),
            body: SingleChildScrollView(
                child: Column(
                    children: [
                        Card(
                            elevation: 8,
                            // replaced Container
                            child: Container(
                                height: screenHeight / 3,
                                width: resWidth,
                                child: CachedNetworkImage(
                                    width: resWidth,
                                    fit: BoxFit.cover,
                                    imageUrl:
                                        "${ServerConfig.SERVER}/assets/homestayimages/${widget.homestay.homestayId}_1.png",
                                    placeholder: (context, url) =>
                                        const LinearProgressIndicator(),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                )
                            ),
                        ),
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Form(
                                key: _formKey,
                                child: Column(
                                    children: [
                                        const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                                "Homestay details",
                                                style: TextStyle(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.w600
                                                ),
                                            ),
                                        ),
                                        TextFormField(
                                            textInputAction: TextInputAction.next,
                                            controller: _hsnameEditingController,
                                            validator: (val) => val!.isEmpty || (val.length < 3)
                                                ? "Homestay name must be longer than 3"
                                                : null,
                                            keyboardType: TextInputType.text,
                                            decoration: const InputDecoration(
                                                labelText: 'Homestay Name',
                                                labelStyle: TextStyle(),
                                                icon: Icon(Icons.person),
                                                focusedBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        width: 2.0
                                                    ),
                                                )
                                            )
                                        ),
                                        TextFormField(
                                            textInputAction: TextInputAction.next,
                                            controller: _hsdescEditingController,
                                            validator: (val) => val!.isEmpty || (val.length < 10)
                                                ? "Homestay description must be longer than 10"
                                                : null,
                                            maxLines: 4,
                                            keyboardType: TextInputType.text,
                                            decoration: const InputDecoration(
                                                labelText: 'Homestay Description',
                                                alignLabelWithHint: true,
                                                labelStyle: TextStyle(),
                                                icon: Icon(Icons.person),
                                                focusedBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        width: 2.0
                                                    ),
                                                )
                                            )
                                        ),
                                        Row(
                                            children: [
                                                Flexible(
                                                    flex: 5,
                                                    child: TextFormField(
                                                        textInputAction: TextInputAction.next,
                                                        controller: _hspriceEditingController,
                                                        validator: (val) => val!.isEmpty
                                                            ? "Homestay price must contain value"
                                                            : null,
                                                        keyboardType: TextInputType.number,
                                                        decoration: const InputDecoration(
                                                            labelText: 'Homestay Price per Night',
                                                            labelStyle: TextStyle(),
                                                            icon: Icon(Icons.money),
                                                            focusedBorder: OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    width: 2.0
                                                                ),
                                                            )
                                                        )
                                                    ),
                                                ),
                                            ],
                                        ),
                                        Row(
                                            children: [
                                                Flexible(
                                                    flex: 5,
                                                    child: TextFormField(
                                                        textInputAction: TextInputAction.next,
                                                        validator: (val) =>
                                                            val!.isEmpty || (val.length < 3)
                                                                ? "Current State"
                                                                : null,
                                                        enabled: false,
                                                        controller: _hsstateEditingController,
                                                        keyboardType: TextInputType.text,
                                                        decoration: const InputDecoration(
                                                            labelText: 'Current States',
                                                            labelStyle: TextStyle(),
                                                            icon: Icon(Icons.flag),
                                                            focusedBorder: OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    width: 2.0
                                                                ),
                                                            )
                                                        )
                                                    )
                                                ),
                                                Flexible(
                                                    flex: 5,
                                                    child: TextFormField(
                                                        textInputAction: TextInputAction.next,
                                                        enabled: false,
                                                        validator: (val) => val!.isEmpty || (val.length < 3)
                                                            ? "Current Locality"
                                                            : null,
                                                        controller: _hslocalEditingController,
                                                        keyboardType: TextInputType.text,
                                                        decoration: const InputDecoration(
                                                            labelText: 'Current Locality',
                                                            labelStyle: TextStyle(),
                                                            icon: Icon(Icons.map),
                                                            focusedBorder: OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    width: 2.0
                                                                ),
                                                            )
                                                        )
                                                    ),
                                                )
                                            ],
                                        ),
                                        SizedBox(
                                            width: 200,
                                            child: ElevatedButton(
                                                child: const Text('Update Homestay'),
                                                onPressed: () => {_updateHomestayDialog()},
                                            ),
                                        ),
                                    ]
                                ),
                            ),
                        )
                    ]
                ),
            )
        );
    }

    _updateHomestayDialog() {
        if (!_formKey.currentState!.validate()) {
            Fluttertoast.showToast(
                msg: "Please complete the form first",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                fontSize: 14.0
            );
            return;
        }

        showDialog(
            context: context,
            builder: (BuildContext context) {
                return AlertDialog(
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                            Radius.circular(20.0)
                        )
                    ),
                    title: const Text(
                        "Update this homestay?",
                        style: TextStyle(),
                    ),
                    content: const Text(
                        "Are you sure?",
                        style: TextStyle()
                    ),
                    actions: <Widget>[
                        TextButton(
                            child: const Text(
                                "Yes",
                                style: TextStyle(),
                            ),
                            onPressed: () {
                                Navigator.of(context).pop();
                                _updateHomestay();
                            },
                        ),
                        TextButton(
                            child: const Text(
                                "No",
                                style: TextStyle(),
                            ),
                            onPressed: () {
                                Navigator.of(context).pop();
                            },
                        ),
                    ],
                );
            },
        );
    }

    void _updateHomestay() {
        String hsname = _hsnameEditingController.text;
        String hsdesc = _hsdescEditingController.text;
        String hsprice = _hspriceEditingController.text;
        
        http.post(Uri.parse("${ServerConfig.SERVER}/php/update_homestay.php"),
        body: {
            "homestayid": widget.homestay.homestayId,
            "userid": widget.user.id,
            "hsname": hsname,
            "hsdesc": hsdesc,
            "hsprice": hsprice,
        }).then((response) {
            var data = jsonDecode(response.body);
            if (response.statusCode == 200 && data['status'] == "success") {
                Fluttertoast.showToast(
                    msg: "Success",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    fontSize: 14.0
                );
                Navigator.of(context).pop();
                return;
            } else {
                Fluttertoast.showToast(
                    msg: "Failed",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    fontSize: 14.0
                );
                return;
            }
        });
    }
}