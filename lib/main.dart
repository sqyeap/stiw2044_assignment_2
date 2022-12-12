import 'package:flutter/material.dart';
import 'screens/splashscreen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
    const MyApp({super.key});

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title: 'Homestay Raya',
            theme: ThemeData(
				primarySwatch: Colors.teal,
				brightness: Brightness.light
			),
			home: const SplashScreen(),
        );
    }
}