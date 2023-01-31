import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ndialog/ndialog.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../serverconfig.dart';
import '../../models/user.dart';
import '../../models/homestay.dart';
import '../shared/mainmenu.dart';
import 'mainscreen.dart';
import 'profilescreen.dart';
import 'loginscreen.dart';
import 'registrationscreen.dart';
import 'addhomestayscreen.dart';
import 'detailscreen.dart';

class OwnerScreen extends StatefulWidget {
    final User user;
    const OwnerScreen({super.key, required this.user});

    @override
    State<OwnerScreen> createState() => _OwnerScreenState();
}

class _OwnerScreenState extends State<OwnerScreen> {
	var _lat, _lon;
	late Position _position;
	List<Homestay> homestayList = <Homestay>[];
	String titlecenter = "Loading...";
	var placemarks;
	final df = DateFormat('dd/MM/yyyy');
	late double screenHeight, screenWidth, resWidth;
	int rowcount = 2;

	@override
	void initState() {
		super.initState();
		_loadHomestays();
	}

	@override
	void dispose() {
		homestayList = [];
		print("dispose");
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
						"Owner"
					),
					actions: [
						// IconButton(
						// 	onPressed: _registrationForm,
						// 	icon: const Icon(
						// 		Icons.app_registration
						// 	)
						// ),
						// IconButton(
						// 	onPressed: _loginForm,
						// 	icon: const Icon(
						// 		Icons.login
						// 	)
						// ),
						PopupMenuButton(
							// add icon, by default "3 dot" icon
							// icon: Icon(Icons.book)
							itemBuilder: (context) {
								return [
									const PopupMenuItem<int>(
										value: 0,
										child: Text("New Homestay"),
									),
									const PopupMenuItem<int>(
										value: 1,
										child: Text("Register Account"),
									),
									const PopupMenuItem<int>(
										value: 2,
										child: Text("Login"),
									),
									const PopupMenuItem<int>(
										value: 3,
										child: Text("Logout"),
									)
								];
							},
							onSelected: (value) {
								if (value == 0) {
									_gotoNewHomestay();
									print("My account menu is selected.");
								} else if (value == 1) {
									_registrationForm();
									print("Registration menu is selected.");
								} else if (value == 2) {
									_loginForm();
									print("Login menu is selected.");
								} else if (value == 3) {
									_logoutDialog();
									print("Lougout dialog is selected.");
								}
							}
						),
					]
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
													onTap: () {
														_showDetails(index);
													},
													onLongPress: () {
														_deleteDialog(index);
													},
													child: Column(
														children: [
															const SizedBox(
																height: 8,
															),
															Flexible(
																flex: 5,
																child: CachedNetworkImage(
																	width: resWidth / 2,
																	fit: BoxFit.cover,
																	imageUrl:
																		"${ServerConfig.SERVER}/assets/homestayimages/${homestayList[index].homestayId}_1.png",
																	placeholder: (context, url) =>
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
				drawer: MainMenuWidget(
					user: widget.user
				)
			),
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

	void _registrationForm() {
		Navigator.push(
			context,
			MaterialPageRoute(
				builder: (content) => const RegistrationScreen()
			)
		);
	}

	void _loginForm() {
		Navigator.push(
			context,
			MaterialPageRoute(
				builder: (content) => const LoginScreen()
			)
		);
	}

	void _logoutDialog() {
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
                        "Logout?",
                        style: TextStyle(),
                    ),
                    content: const Text(
                        "Are your sure"
                    ),
                    actions: <Widget>[
                        TextButton(
                            child: const Text(
                                "Yes",
                                style: TextStyle(),
                            ),
                            onPressed: () async {
                                Navigator.of(context).pop();
                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                await prefs.setString('email', '');
                                await prefs.setString('pass', '');
                                await prefs.setBool('remember', false);
                                User user = User(
                                    id: "0",
                                    email: "unregistered",
                                    name: "unregistered",
                                    address: "na",
                                    phone: "na",
                                    regdate: "0",
                                    // credit: '0'
                                );
                                // ignore: use_build_context_synchronously
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (content) => MainScreen(user: user)
                                    )
                                );
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

	Future<void> _gotoNewHomestay() async {
		if (widget.user.id == "0") {
			Fluttertoast.showToast(
				msg: "Please login/register",
				toastLength: Toast.LENGTH_SHORT,
				gravity: ToastGravity.BOTTOM,
				timeInSecForIosWeb: 1,
				fontSize: 14.0
			);
			return;
		}

    	ProgressDialog progressDialog = ProgressDialog(
			context,
			blur: 10,
			message: const Text("Searching your current location"),
			title: null,
		);
    	progressDialog.show();

		if (await _checkPermissionGetLoc()) {
			progressDialog.dismiss();
			await Navigator.push(
				context,
				MaterialPageRoute(
					builder: (content) => AddHomestayScreen(
						position: _position,
						user: widget.user,
						placemarks: placemarks
					)
				)
			);
			_loadHomestays();
		} else {
			Fluttertoast.showToast(
				msg: "Please allow the app to access the location",
				toastLength: Toast.LENGTH_SHORT,
				gravity: ToastGravity.BOTTOM,
				timeInSecForIosWeb: 1,
				fontSize: 14.0
			);
		}
  	}

	//check permission, get location, get address return false if any problem.
	Future<bool> _checkPermissionGetLoc() async {
		bool serviceEnabled;
		LocationPermission permission;

		serviceEnabled = await Geolocator.isLocationServiceEnabled();
		if (!serviceEnabled) {
			return Future.error('Location services are disabled.');
		}

		permission = await Geolocator.checkPermission();
		if (permission == LocationPermission.denied) {
			permission = await Geolocator.requestPermission();
			if (permission == LocationPermission.denied) {
				Fluttertoast.showToast(
					msg: "Please allow the app to access the location",
					toastLength: Toast.LENGTH_SHORT,
					gravity: ToastGravity.BOTTOM,
					timeInSecForIosWeb: 1,
					fontSize: 14.0
				);
				Geolocator.openLocationSettings();
				return false;
			}
		}
		if (permission == LocationPermission.deniedForever) {
			Fluttertoast.showToast(
				msg: "Please allow the app to access the location",
				toastLength: Toast.LENGTH_SHORT,
				gravity: ToastGravity.BOTTOM,
				timeInSecForIosWeb: 1,
				fontSize: 14.0
			);
			Geolocator.openLocationSettings();
			return false;
		}

		_position = await Geolocator.getCurrentPosition(
			desiredAccuracy: LocationAccuracy.best
		);

		try {
			placemarks = await placemarkFromCoordinates(
				_position.latitude, _position.longitude
			);
		} catch (e) {
			Fluttertoast.showToast(
				msg: "Error in fixing your location. Make sure internet connection is available and try again.",
				toastLength: Toast.LENGTH_SHORT,
				gravity: ToastGravity.BOTTOM,
				timeInSecForIosWeb: 1,
				fontSize: 14.0
			);
			return false;
		}
		return true;
  	}

  	void _loadHomestays() {
		if (widget.user.id == "0") {
			Fluttertoast.showToast(
				msg: "Please register an account first",
				toastLength: Toast.LENGTH_SHORT,
				gravity: ToastGravity.BOTTOM,
				timeInSecForIosWeb: 1,
				fontSize: 14.0
			);
			return;
    	}

		http.get(
			Uri.parse(
				"${ServerConfig.SERVER}/php/load_owner_homestay.php?userid=${widget.user.id}"
			),
		).then((response) {
			print(response.body);
			if (response.statusCode == 200) {
				var jsondata = jsonDecode(response.body);
				if (jsondata['status'] == 'success') {
					var extractdata = jsondata['data'];
					if (extractdata['homestays'] != null) {
						homestayList = <Homestay>[];
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
						titlecenter = "No Homestay Available";
						homestayList.clear();
					}
				} else {
					titlecenter = "No Homestay Available";
				}
			} else {
				titlecenter = "No Homestay Available";
				homestayList.clear();
			}
			setState(() {});
		});
	}

  	Future<void> _showDetails(int index) async {
    	Homestay homestay = Homestay.fromJson(homestayList[index].toJson());

		await Navigator.push(
			context,
			MaterialPageRoute(
				builder: (content) => DetailsScreen(
					homestay: homestay,
					user: widget.user,
				)
			)
		);
    	_loadHomestays();
  	}

  	_deleteDialog(int index) {
		showDialog(
			context: context,
			builder: (BuildContext context) {
				return AlertDialog(
					shape: const RoundedRectangleBorder(
						borderRadius: BorderRadius.all(
							Radius.circular(20.0)
						)
					),
					title: Text(
						"Delete ${truncateString(homestayList[index].homestayName.toString(), 15)}",
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
							onPressed: () async {
								Navigator.of(context).pop();
								_deleteHomestay(index);
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

	void _deleteHomestay(index) {
		try {
			http.post(
				Uri.parse(
					"${ServerConfig.SERVER}/php/delete_homestay.php"
				),
				body: {
					"homestayid": homestayList[index].homestayId,
				}
			).then((response) {
				var data = jsonDecode(response.body);
				if (response.statusCode == 200 && data['status'] == "success") {
					Fluttertoast.showToast(
						msg: "Success",
						toastLength: Toast.LENGTH_SHORT,
						gravity: ToastGravity.BOTTOM,
						timeInSecForIosWeb: 1,
						fontSize: 14.0
					);
					_loadHomestays();
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
		} catch (e) {
			print(e.toString());
		}
	}
}