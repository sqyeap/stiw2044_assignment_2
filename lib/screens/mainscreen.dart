import 'package:flutter/material.dart';

import 'loginscreen.dart';
import '../models/user.dart';

class MainScreen extends StatefulWidget {
    final User user;
    const MainScreen({super.key, required this.user});
    
    @override
    State<StatefulWidget> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
    @override
    Widget build(BuildContext context) {
        String username = widget.user.name.toString();
        
        return Scaffold(
            appBar: AppBar(
                title: const Text("Homestay Raya"),
                actions: <Widget>[
                    IconButton(
                        icon: const Icon(
                            Icons.login,
                            color: Colors.white,
                        ),
                        onPressed: () => _Login(),
                    )
                ],
            ),
            body: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        Text(
                            "You are $username",
                            style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey
                            ),
                        )
                    ],
                ),
            ),
        );
    }
    
    _Login() async {
        Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => const LoginScreen()
            )
        );
    }
}