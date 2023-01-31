import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:ndialog/ndialog.dart';

import '../../serverconfig.dart';
import '../../models/homestay.dart';
import '../../models/user.dart';
import '../shared/mainmenu.dart';
import 'homestayscreen.dart';

class MainScreen extends StatefulWidget {
    final User user;
    const MainScreen({super.key, required this.user});

    @override
    State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
    List<Homestay> homestayList = <Homestay>[];
    String titlecenter = "Loading...";
    final df = DateFormat('dd/MM/yyyy hh:mm a');
    late double screenHeight, screenWidth, resWidth;
    int rowcount = 2;
    TextEditingController searchController = TextEditingController();
    var owner;
    String search = "all";
    // for pagination
    var color;
    var numofpage, currentpage = 1;
    int numofresult = 0;

    @override
    void initState() {
        super.initState();
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            _loadHomestays("all", 1);
        });
    }

    @override
    void dispose() {
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        screenHeight = MediaQuery.of(context).size.height;
        screenWidth = MediaQuery.of(context).size.width;

        if (screenWidth <= 600) {
            resWidth = screenWidth;
            rowcount = 2;
        } else {
            resWidth = screenWidth * 0.75;
            rowcount = 3;
        }

        return WillPopScope(
            onWillPop: () async => false,
            child: Scaffold(
                appBar: AppBar(
                    title: const Text(
                        "Homestay Raya"
                    ),
                    actions: [
                        IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () {
                                _loadSearchDialog();
                            }
                        )
                    ],
                ),
                body: homestayList.isEmpty
                    ? Center(
                        child: Text(
                            titlecenter,
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold
                            )
                        )
                    )
                    : Column(
                        children: [
                            Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                    "Total Homestays ($numofresult found)",
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold
                                    ),
                                ),
                            ),
                            const SizedBox(
                                height: 4,
                            ),
                            Expanded(
                                child: GridView.count(
                                    crossAxisCount: rowcount,
                                    children: List.generate(
                                        homestayList.length, (index) {
                                            return Card(
                                                elevation: 8,
                                                child: InkWell(
                                                    onTap: () {
                                                        _showDetails(index);
                                                    },
                                                    child: Column(
                                                        children: [
                                                            const SizedBox(
                                                                height: 6,
                                                            ),
                                                            Flexible(
                                                                flex: 15,
                                                                child: CachedNetworkImage(
                                                                    width: resWidth / 1.5,
                                                                    fit: BoxFit.cover,
                                                                    imageUrl:
                                                                        "${ServerConfig.SERVER}/assets/homestayimages/${homestayList[index].homestayId}_1.png",
                                                                    placeholder: (context, url) => const LinearProgressIndicator(),
                                                                    errorWidget: (context, url, error) => const Icon(Icons.error),
                                                                ),
                                                            ),
                                                            Flexible(
                                                                flex: 15,
                                                                child: Padding(
                                                                    padding: const EdgeInsets.all(2.0),
                                                                    child: Column(
                                                                        children: [
                                                                            Text(
                                                                                truncateString(
                                                                                    homestayList[index].homestayName.toString(),
                                                                                    15
                                                                                ),
                                                                                style: const TextStyle(
                                                                                    fontSize: 14,
                                                                                    fontWeight: FontWeight.bold
                                                                                ),
                                                                            ),
                                                                            Text(
                                                                                "RM ${double.parse(homestayList[index].homestayPrice.toString()).toStringAsFixed(2)}"
                                                                            ),
                                                                            Text(
                                                                                df.format(
                                                                                    DateTime.parse(
                                                                                        homestayList[index].homestayDate.toString()
                                                                                    )
                                                                                )
                                                                            ),
                                                                        ],
                                                                    ),
                                                                )
                                                            )
                                                        ]
                                                    ),
                                                ),
                                            );
                                        }
                                    ),
                                ),
                            ),
                            // pagination widget
                            SizedBox(
                                height: 50,
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: numofpage,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, index) {
                                        //build the list for textbutton with scroll
                                        if ((currentpage - 1) == index) {
                                            // current page active
                                            color = Colors.teal;
                                        } else {
                                            color = Colors.black;
                                        }
                                        return TextButton(
                                            onPressed: () => {
                                                _loadHomestays(search, index + 1)
                                            },
                                            child: Text(
                                                (index + 1).toString(),
                                                style: TextStyle(
                                                    color: color,
                                                    fontSize: 18
                                                ),
                                            )
                                        );
                                    },
                                ),
                            ),
                        ],
                    ),
                drawer: MainMenuWidget(user: widget.user),
            )
        );
    }

    String truncateString(String str, int size) {
        if (str.length > size) {
            str = str.substring(0, size);
            return "$str...";
        } else {
            return str;
        }
    }

    void _loadHomestays(String search, int pageno) {
        currentpage = pageno; //init current page
        numofpage ?? 1; //get total num of pages if not by default set to only 1

        http.get(
            Uri.parse(
                "${ServerConfig.SERVER}/php/loadallhomestays.php?search=$search&pageno=$pageno"
            ),
        ).then((response) {
            ProgressDialog progressDialog = ProgressDialog(
                context,
                blur: 5,
                message: const Text("Loading..."),
                title: null,
            );
            progressDialog.show();
            print(response.body);
            // wait for response from the request
            if (response.statusCode == 200) {
                // if statuscode OK, decode response body to jsondata array
                var jsondata = jsonDecode(response.body);
                if (jsondata['status'] == 'success') {
                    // if status data array success, extract data from jsondata array
                    var extractdata = jsondata['data'];
                    if (extractdata['homestays'] != null) {
                        numofpage = int.parse(jsondata['numofpage']); //get number of pages
                        numofresult = int.parse(jsondata['numberofresult']); //get total number of result returned
                        // check if  array object is not null
                        homestayList = <Homestay>[]; // complete the array object definition
                        extractdata['homestays'].forEach((v) {
                            //traverse homestays array list and add to the list object array homestayList
                            homestayList.add(
                                Homestay.fromJson(v)
                            ); //add each homestay array to the list object array homestayList
                        });
                        titlecenter = "Found";
                    } else {
                        titlecenter = "No Homestay Available"; //if no data returned show title center
                        homestayList.clear();
                    }
                }
            } else {
                titlecenter = "No Homestay Available"; //status code other than 200
                homestayList.clear(); //clear homestayList array
            }

            setState(() {}); //refresh UI
            progressDialog.dismiss();
        });
    }

    _showDetails(int index) async {
        
        // unregistered user cannot view details
        // if (widget.user.id == "0") {
        //     Fluttertoast.showToast(
        //         msg: "Please login/register an account",
        //         toastLength: Toast.LENGTH_SHORT,
        //         gravity: ToastGravity.BOTTOM,
        //         timeInSecForIosWeb: 1,
        //         fontSize: 14.0
        //     );
        //     return;
        // }

        Homestay homestay = Homestay.fromJson(homestayList[index].toJson());
        loadSingleOwner(index);
        ProgressDialog progressDialog = ProgressDialog(
            context,
            blur: 5,
            message: const Text("Loading..."),
            title: null,
        );
        progressDialog.show();

        Timer(
            const Duration(seconds: 1), () {
                if (owner != null) {
                    progressDialog.dismiss();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (content) => HomestayScreen(
                                user: widget.user,
                                homestay: homestay,
                                owner: owner,
                            )
                        )
                    );
                }
                progressDialog.dismiss();
            }
        );
    }

    void _loadSearchDialog() {
        searchController.text = "";
        showDialog(
            context: context,
            builder: (BuildContext context) {
                return StatefulBuilder(
                    builder: (context, StateSetter setState) {
                        return AlertDialog(
                            title: const Text(
                                "Search Homestay",
                            ),
                            content: SizedBox(
                                // height: screenHeight / 4,
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                        TextField(
                                            controller: searchController,
                                            decoration: InputDecoration(
                                                labelText: 'Homestay Name',
                                                border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(5.0)
                                                )
                                            ),
                                        ),
                                        const SizedBox(
                                            height: 5
                                        ),
                                    ],
                                ),
                            ),
                            actions: [
                                ElevatedButton(
                                    onPressed: () {
                                        search = searchController.text;
                                        Navigator.of(context).pop();
                                        _loadHomestays(search, 1);
                                    },
                                    child: const Text(
                                        "Search"
                                    ),
                                )
                            ],
                        );
                    },
                );
            }
        );
    }

    loadSingleOwner(int index) {
        http.post(
            Uri.parse(
                "${ServerConfig.SERVER}/php/load_owner.php"
            ),
            body: {
                "ownerid": homestayList[index].userId
            }
        ).then((response) {
            print(response.body);
            var jsonResponse = json.decode(response.body);
            if (response.statusCode == 200 && jsonResponse['status'] == "success") {
                owner = User.fromJson(jsonResponse['data']);
            }
        });
    }
}