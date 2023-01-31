import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../serverconfig.dart';
import '../../models/user.dart';

import 'mainscreen.dart';

class SplashScreen extends StatefulWidget {
    const SplashScreen({super.key});

    @override
    State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
    @override
    void initState() {
        super.initState();
        autoLogin();
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            body: Center(
                child: Stack(
                    children: <Widget>[
                        Container(
                            decoration: const BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(
                                        'assets/images/splashpic.png'
                                    ),
                                    fit: BoxFit.cover
                                )
                            ),
                        ),
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: const [
                                        SizedBox(
                                            height: 8,
                                        ),
                                        Text(
                                            "Homestay Raya",
                                            style: TextStyle(
                                                fontSize: 40,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white
                                            ),
                                        ),
                                        CircularProgressIndicator(),
                                        SizedBox(
                                            height: 32,
                                        ),
                                        Text(
                                            "Version 0.2b",
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black45
                                            ),
                                        ),
                                    ]
                                ),
                            )
                        )
                    ],
                ),
            ),
        );
    }

    Future<void> autoLogin() async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String email = (prefs.getString('email')) ?? '';
        String pass = (prefs.getString('pass')) ?? '';
        
        if (email.isNotEmpty) {
            http.post(Uri.parse("${ServerConfig.SERVER}/php/login_user.php"),
            body: {"email": email, "password": pass}).then((response) {
                print(response.body);
                var jsonResponse = json.decode(response.body);
                if (response.statusCode == 200 && jsonResponse['status'] == "success") {
                    User user = User.fromJson(jsonResponse['data']);
                    Timer(
                        const Duration(seconds: 3),
                        () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (content) => MainScreen(user: user)
                            )
                        )
                    );
                } else {
                    User user = User(
                        id: "0",
                        email: "unregistered",
                        name: "unregistered",
                        address: "na",
                        phone: "na",
                        regdate: "0"
                    );
                    Timer(
                        const Duration(seconds: 3),
                        () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (content) => MainScreen(user: user)
                            )
                        )
                    );
                }
            });
        } else {
            User user = User(
                id: "0",
                email: "unregistered",
                name: "unregistered",
                address: "na",
                phone: "na",
                regdate: "0"
            );
            Timer(
                const Duration(seconds: 3),
                () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (content) => MainScreen(user: user)
                    )
                )
            );
        }
    }
}