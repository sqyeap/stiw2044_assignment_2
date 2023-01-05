import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../../config.dart';
import '../../models/homestay.dart';
import '../../models/user.dart';
import '../shared/mainmenu.dart';
import 'ownerscreen.dart';
import 'profilescreen.dart';

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

    @override
    void initState() {
        super.initState();
        _loadHomestays();
        
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
        } return WillPopScope(
            onWillPop: () async => false,
            child: Scaffold(
                appBar: AppBar(
                    title: const Text(
                        "Homestay Raya"
                    )
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
                                    "Your current homestays: (${homestayList.length} found)",
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
                                        homestayList.length,
                                        (index) {
                                            return Card(
                                                elevation: 8,
                                                child: InkWell(
                                                    onTap: _showDetails,
                                                    child: Column(
                                                        children: [
                                                            const SizedBox(
                                                                height: 8,
                                                            ),
                                                            Flexible(
                                                                flex: 6,
                                                                child: CachedNetworkImage(
                                                                    width: resWidth / 2,
                                                                    fit: BoxFit.cover,
                                                                    imageUrl:
                                                                        "${Config.SERVER}/assets/homestayimages/${homestayList[index].homestayId}.png",                                                                    placeholder: (context, url) =>
                                                                        const LinearProgressIndicator(),
                                                                    errorWidget: (context, url, error) =>
                                                                        const Icon(Icons.error),
                                                                ),
                                                            ),
                                                            Flexible(
                                                                flex: 4,
                                                                child: Padding(
                                                                    padding: const EdgeInsets.all(8.0),
                                                                    child: Column(
                                                                        children: [
                                                                            Text(
                                                                                truncateString(
                                                                                    homestayList[index]
                                                                                    .homestayName
                                                                                    .toString(),
                                                                                    15
                                                                                ),
                                                                                style: const TextStyle(
                                                                                    fontSize: 16,
                                                                                    fontWeight: FontWeight.bold
                                                                                ),
                                                                            ),
                                                                            Text(
                                                                                "RM ${double.parse(homestayList[index].homestayPrice.toString()).toStringAsFixed(2)}"
                                                                            ),
                                                                            Text(
                                                                                df.format(
                                                                                    DateTime.parse(
                                                                                        homestayList[index]
                                                                                        .homestayDate
                                                                                        .toString()
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
                            )
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

    void _loadHomestays() {
        http.get(
            Uri.parse("${Config.SERVER}/php/loadallhomestays.php"),
        ).then((response) {
            print(response.body);
            if (response.statusCode == 200) {
                //decode response body to jsondata array
                var jsondata = jsonDecode(response.body);
                if (jsondata['status'] == 'success') {
                    var extractdata = jsondata['data']; //extract data from jsondata array
                    if (extractdata['homestays'] != null) {
                        homestayList = <Homestay>[]; //complete the array object definition
                        extractdata['homestays'].forEach(
                            (v) {
                                //traverse homestays array list and add to the list object array homestayList
                                homestayList.add(
                                    Homestay.fromJson(v)
                                ); //add each homestay array to the list object array homestayList
                            }
                        );
                        titlecenter = "Found";
                    } else {
                        titlecenter =
                            "No Homestay Available"; //if no data returned show title center
                        homestayList.clear();
                    }
                }
            } else {
                titlecenter = "No Homestay Available"; //status code other than 200
                homestayList.clear(); //clear homestayList array
            }
            setState(() {}); //refresh UI
        });
    }

    void _showDetails() {}
}