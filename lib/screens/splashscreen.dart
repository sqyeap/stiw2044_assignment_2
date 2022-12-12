import 'dart:async';

import 'package:flutter/material.dart';

import 'mainscreen.dart';
import '../models/user.dart';

class SplashScreen extends StatefulWidget {
    const SplashScreen({super.key});
    
    @override
    State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
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
                                        'assets/images/splashpic.jpg'
                                    ),
                                    fit: BoxFit.cover
                                )
                            ),
                        ),
                        Padding(
                            padding: const EdgeInsets.all(64.0),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: const [
                                    Text(
                                        "Homestay Raya",
                                        style: TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white
                                        ),
                                    ),
                                    CircularProgressIndicator(),
                                    Text(
                                        "Version 0.1b",
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white
                                        ),
                                    ),
                                ]
                            ),
                        )
                    ],
                ),
            ),
        );
    }

    @override
    void initState() {
        super.initState();
        User user = User(
            id: "0",
            email: "unregistered",
            name: "unregistered",
            address: "na",
            phone: "0123456789",
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