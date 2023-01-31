import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../serverconfig.dart';
import '../screens/mainscreen.dart';
import '../screens/ownerscreen.dart';
import '../screens/profilescreen.dart';
import 'EnterExitRoute.dart';

class MainMenuWidget extends StatefulWidget {
    final User user;
    const MainMenuWidget({super.key, required this.user});

    @override
    State<MainMenuWidget> createState() => _MainMenuWidgetState();
}

class _MainMenuWidgetState extends State<MainMenuWidget> {
    var val = 50;

    @override
    Widget build(BuildContext context) {
        return Drawer(
            width: 250,
            elevation: 10,
            child: ListView(
                children: [
                    UserAccountsDrawerHeader(
                        accountEmail: Text(widget.user.email.toString()),
                        accountName: Text(widget.user.name.toString()),
                        currentAccountPicture: CircleAvatar(
                            radius: 30.0,
                            backgroundImage:
                                NetworkImage("${ServerConfig.SERVER}/assets/profileimages/${widget.user.id}.png?v=$val"),
                            backgroundColor: Colors.transparent,
                        ),
                    ),
                    ListTile(
                        title: const Text('Homestay'),
                        onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                                context,
                                EnterExitRoute(
                                    exitPage: MainScreen(user: widget.user),
                                    enterPage: MainScreen(user: widget.user)
                                )
                            );
                        },
                    ),
                    ListTile(
                        title: const Text('Owner'),
                        onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                                context,
                                EnterExitRoute(
                                    exitPage: MainScreen(user: widget.user),
                                    enterPage: OwnerScreen(user: widget.user)
                                )
                            );
                        },
                    ),
                    ListTile(
                        title: const Text('Profile'),
                        onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                                context,
                                EnterExitRoute(
                                    exitPage: MainScreen(user: widget.user),
                                    enterPage: ProfileScreen(
                                        user: widget.user,
                                    )
                                )
                            );
                        },
                    ),
                ],
            ),
        );
    }
}