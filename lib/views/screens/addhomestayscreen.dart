import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

import '../../serverconfig.dart';
import '../../models/user.dart';

class AddHomestayScreen extends StatefulWidget {
    final User user;
    final Position position;
    final List<Placemark> placemarks;
    const AddHomestayScreen({
        super.key,
        required this.user,
        required this.position,
        required this.placemarks
    });

    @override
    State<AddHomestayScreen> createState() => _AddHomestayScreenState();
}

class _AddHomestayScreenState extends State<AddHomestayScreen> {
    final TextEditingController _hsnameEditingController = TextEditingController();
    final TextEditingController _hsdescEditingController = TextEditingController();
    final TextEditingController _hspriceEditingController = TextEditingController();
    final TextEditingController _hsstateEditingController = TextEditingController();
    final TextEditingController _hslocalEditingController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    var _lat, _lon;
    int _index = 0;

    @override
    void initState() {
        super.initState();
        _lat = widget.position.latitude.toString();
        _lon = widget.position.longitude.toString();
        _hsstateEditingController.text = widget.placemarks[0].administrativeArea.toString();
        _hslocalEditingController.text = widget.placemarks[0].locality.toString();
    }

    File? _image;
    List<File> _imageList = [];
    var pathAsset = "assets/images/uploadpic.jpg";
    // bool _isChecked = false;

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: const Text(
                    "New Homestay"
                )
            ),
            body: SingleChildScrollView(
                child: Column(
                    children: [
                        const SizedBox(
                            height: 8,
                        ),
                        Center(
                            child: SizedBox(
                                height: 250,
                                child: PageView.builder(
                                    itemCount: 3,
                                    controller: PageController(viewportFraction: 0.7),
                                    onPageChanged: (int index) =>
                                        setState(() => _index = index),
                                    itemBuilder: (BuildContext context, int index) {
                                        if (index == 0) {
                                            return imageOne();
                                        } else if (index == 1) {
                                            return imageTwo();
                                        } else {
                                            return imageThree();
                                        }
                                    }
                                ),
                            ),
                        ),
                        Padding(
                            padding: const EdgeInsets.fromLTRB(8.0, 4.0, 16.0, 4.0),
                            child: Form(
                                key: _formKey,
                                child: Column(
                                    children: [
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
                                                            labelText: 'Price per Stay',
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
                                        const SizedBox(
                                            height: 16,
                                        ),
                                        SizedBox(
                                            width: 200,
                                            height: 50,
                                            child: ElevatedButton(
                                                child: const Text('Add Homestay'),
                                                onPressed: () => {
                                                    _addHomestayDialog(),
                                                },
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

    void _addHomestayDialog() {
        if (_imageList.length < 2) {
            Fluttertoast.showToast(
                msg: "Please take 3 pictures of your homestay",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                fontSize: 14.0
            );
            return;
        }
        
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
                        "Insert this homestay?",
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
                                _insertHomestay();
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

    void _selectImageDialog() {
        showDialog(
            context: context,
            builder: (BuildContext context) {
                return AlertDialog(
                    title: const Text(
                        "Select picture from:",
                        style: TextStyle(),
                    ),
                    content: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                            IconButton(
                                iconSize: 64,
                                onPressed: _onCamera,
                                icon: const Icon(Icons.camera)
                            ),
                            IconButton(
                                iconSize: 64,
                                onPressed: _onGallery,
                                icon: const Icon(Icons.browse_gallery)
                            ),
                        ],
                    )
                );
            },
        );
    }

    Future<void> _onCamera() async {
        Navigator.pop(context);
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(
            source: ImageSource.camera,
            maxHeight: 800,
            maxWidth: 800,
        );
        
        if (pickedFile != null) {
            _image = File(pickedFile.path);
            cropImage();
        } else {
            print('No image selected.');
        }
    }

    Future<void> _onGallery() async {
        Navigator.pop(context);
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(
            source: ImageSource.gallery,
            maxHeight: 800,
            maxWidth: 800,
        );

        if (pickedFile != null) {
            _image = File(pickedFile.path);
            cropImage();
        } else {
            print('No image selected.');
        }
    }

    Future<void> cropImage() async {
        CroppedFile? croppedFile = await ImageCropper().cropImage(
            sourcePath: _image!.path,
            aspectRatioPresets: [
                CropAspectRatioPreset.square,
            ],
            uiSettings: [
                AndroidUiSettings(
                    toolbarTitle: 'Image Cropper',
                    toolbarColor: Colors.teal,
                    toolbarWidgetColor: Colors.white,
                    initAspectRatio: CropAspectRatioPreset.original,
                    lockAspectRatio: false
                ),
                IOSUiSettings(
                    title: 'Image Cropper',
                ),
            ],
        );

        if (croppedFile != null) {
            File imageFile = File(croppedFile.path);
            _image = imageFile;
            _imageList.add(_image!);
            setState(() {});
        }
    }

    void _insertHomestay() {
        String hsname = _hsnameEditingController.text;
        String hsdesc = _hsdescEditingController.text;
        String hsprice = _hspriceEditingController.text;
        String state = _hsstateEditingController.text;
        String local = _hslocalEditingController.text;
        String base64Image1 = base64Encode(_imageList[0].readAsBytesSync());
        String base64Image2 = base64Encode(_imageList[1].readAsBytesSync());
        String base64Image3 = base64Encode(_imageList[2].readAsBytesSync());

        http.post(Uri.parse("${ServerConfig.SERVER}/php/insert_homestay.php"),
        body: {
            "userid": widget.user.id,
            "hsname": hsname,
            "hsdesc": hsdesc,
            "hsprice": hsprice,
            "state": state,
            "local": local,
            "lat": _lat,
            "lon": _lon,
            "image1": base64Image1,
            "image2": base64Image2,
            "image3": base64Image3,
            "registerhomestay": "registerhomestay"
        }).then((response) {
            var data = jsonDecode(response.body);
            print(response.body);
            print(data);
            if (response.statusCode == 200 && data['status'] == 'success') {
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

    Widget imageOne() {
        return Transform.scale(
            scale: 1,
            child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)
                ),
                child: GestureDetector(
                    onTap: _selectImageDialog,
                    child: Container(
                        height: 200,
                        width: 200,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: _imageList.length > 0
                                    ? FileImage(_imageList[0]) as ImageProvider
                                    : AssetImage(pathAsset),
                                fit: BoxFit.cover,
                            )
                        ),
                    ),
                )
            ),
        );
    }

    Widget imageTwo() {
        return Transform.scale(
            scale: 1,
            child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)
                ),
                child: GestureDetector(
                    onTap: _selectImageDialog,
                    child: Container(
                        height: 200,
                        width: 200,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: _imageList.length > 1
                                    ? FileImage(_imageList[1]) as ImageProvider
                                    : AssetImage(pathAsset),
                                fit: BoxFit.cover,
                            )
                        ),
                    ),
                )
            ),
        );
    }

    Widget imageThree() {
        return Transform.scale(
            scale: 1,
            child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)
                ),
                child: GestureDetector(
                    onTap: _selectImageDialog,
                    child: Container(
                        height: 200,
                        width: 200,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: _imageList.length > 2
                                    ? FileImage(_imageList[2]) as ImageProvider
                                    : AssetImage(pathAsset),
                                fit: BoxFit.cover,
                            )
                        ),
                    ),
                )
            ),
        );
    }
}