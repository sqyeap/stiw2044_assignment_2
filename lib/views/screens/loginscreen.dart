import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'mainscreen.dart';
import 'registrationscreen.dart';
import '../../models/user.dart';
import '../../serverconfig.dart';

class LoginScreen extends StatefulWidget {
    const LoginScreen({super.key});
    
      @override
      State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
    final TextEditingController _emailEditingController = TextEditingController();
    final TextEditingController _passEditingController = TextEditingController();

    final _formKey = GlobalKey<FormState>();
    bool _isChecked = false;
    var screenHeight, screenWidth, cardWidth;

    @override
    void initState() {
        super.initState();
        loadPref();
    }

    @override
    Widget build(BuildContext context) {
        screenHeight = MediaQuery.of(context).size.height;
        screenWidth = MediaQuery.of(context).size.width;
        
        if (screenWidth <= 600) {
            cardWidth = screenWidth;
        } else {
            cardWidth = 400.00;
        }

        return Scaffold(
            appBar: AppBar(
                title: const Text("Login"),
            ),
            body: Center(
                child: SingleChildScrollView(
                    child: SizedBox(
                        width: cardWidth,
                        child: Column(
                            children: [
                                Card(
                                    elevation: 8,
                                    margin: const EdgeInsets.all(8),
                                    child: Container(
                                        padding: const EdgeInsets.all(16),
                                        child: Form(
                                            key: _formKey,
                                            child: Column(
                                                children: [
                                                    TextFormField(
                                                        controller: _emailEditingController,
                                                        keyboardType: TextInputType.emailAddress,
                                                        validator: (val) => val!.isEmpty
                                                        || !val.contains("@")
                                                        || !val.contains(".")
                                                        ? "Please enter a valid email"
                                                        : null,
                                                        decoration: const InputDecoration(
                                                            labelText: 'Email',
                                                            labelStyle: TextStyle(),
                                                            icon: Icon(Icons.email),
                                                            focusedBorder: OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    width: 1.0
                                                                )
                                                            )
                                                        ),
                                                    ),
                                                    TextFormField(
                                                        controller: _passEditingController,
                                                        keyboardType: TextInputType.visiblePassword,
                                                        obscureText: true,
                                                        decoration: const InputDecoration(
                                                            labelText: 'Password',
                                                            labelStyle: TextStyle(),
                                                            icon: Icon(Icons.password),
                                                            focusedBorder: OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    width: 1.0
                                                                )
                                                            )
                                                        ),
                                                    ),
                                                    const SizedBox(
                                                        height: 8,
                                                    ),
                                                    Row(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        children: [
                                                            Checkbox(
                                                                value: _isChecked, 
                                                                onChanged: (bool? value) {
                                                                    setState(() {
                                                                        _isChecked = value!;
                                                                        saveremovepref(value);
                                                                    },);
                                                                }
                                                            ),
                                                            Flexible(
                                                                child: GestureDetector(
                                                                    onTap: () {
                                                                        setState(() {
                                                                            _isChecked = _isChecked ? false : true;
                                                                            saveremovepref(_isChecked);
                                                                        });
                                                                    },
                                                                    child: const Text(
                                                                        'Remember Me',
                                                                        style: TextStyle(
                                                                            fontSize: 16,
                                                                            fontWeight: FontWeight.bold,
                                                                        )
                                                                    )
                                                                )
                                                            )
                                                        ]
                                                    ),
                                                    MaterialButton(
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(5.0)
                                                        ),
                                                        minWidth: 115,
                                                        height: 50,
                                                        elevation: 10,
                                                        onPressed: _loginUser,
                                                        color: Theme.of(context).colorScheme.primary,
                                                        child: const Text(
                                                            'Login',
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight: FontWeight.bold,
                                                                color: Colors.white
                                                            ),
                                                        ),
                                                    ),
                                                    const SizedBox(
                                                        height: 8,
                                                    )
                                                ]
                                            ),
                                        ),
                                    ),
                                ),
                                GestureDetector(
                                    onTap: _goLogin,
                                    child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: const [
                                            Text(
                                                "No Account Yet? ",
                                                style: TextStyle(
                                                    fontSize: 18
                                                ),
                                            ),
                                            Text(
                                                "Create for Free",
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.teal
                                                ),
                                            )
                                        ],
                                    ),
                                ),
                                const SizedBox(
                                    height: 8,
                                ),
                                GestureDetector(
                                    onTap: _goHome,
                                    child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: const [
                                            Text(
                                                "Back to",
                                                style: TextStyle(
                                                    fontSize: 18
                                                ),
                                            ),
                                            Text(
                                                " Home",
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.teal
                                                ),
                                            )
                                        ],
                                    )
                                )
                            ]
                        ),
                    ),
                )
            ),
        );
    }

    void _loginUser() {
        if (!_formKey.currentState!.validate()) {
            Fluttertoast.showToast(
                msg: "Please fill in the login credentials",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                fontSize: 14.0
            );
            return;
        }

        String _email = _emailEditingController.text;
        String _pass = _passEditingController.text;
        http.post(
            Uri.parse("${ServerConfig.SERVER}/php/login_user.php"),
            body: {"email": _email, "password": _pass}
        ).then(
            (response) {
                print(response.body);
                if (response.statusCode == 200) {
                    var jsonResponse = json.decode(response.body);
                    if (jsonResponse['data'] == null) {
                        Fluttertoast.showToast(
                            msg: "Login Failed",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            fontSize: 14.0
                        );
                        return;
                    }
                    User user = User.fromJson(jsonResponse['data']);
                    //User user = User(id: jsonResponse['data']['name'],email: jsonResponse['email'],name: "",phone: "",address: "",regdate: "");
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (content) => MainScreen(user: user)
                        )
                    );
                }
            }
        );
    }

    void _goHome() {
        User user = User(
            id: "0",
            email: "unregistered",
            name: "unregistered",
            address: "na",
            phone: "na",
            regdate: "0"
        );
        Navigator.pop(
            context,
            MaterialPageRoute(
                builder: (content) => MainScreen(
                    user: user,
                )
            )
        );
    }

    void _goLogin() {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (content) => const RegistrationScreen()
            )
        );
    }

    void saveremovepref(bool value) async {
        String email = _emailEditingController.text;
        String password = _passEditingController.text;
        SharedPreferences prefs = await SharedPreferences.getInstance();
        
        if (value) {
            if (!_formKey.currentState!.validate()) {
                Fluttertoast.showToast(
                    msg: "Please fill in the login credentials",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    fontSize: 14.0);
                _isChecked = false;
                return;
            }
            await prefs.setString('email', email);
            await prefs.setString('pass', password);
            Fluttertoast.showToast(
                msg: "Preference Stored",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                fontSize: 14.0
            );
        } else {
            //delete preference
            await prefs.setString('email', '');
            await prefs.setString('pass', '');
            setState(() {
                _emailEditingController.text = '';
                _passEditingController.text = '';
                _isChecked = false;
            });
            Fluttertoast.showToast(
                msg: "Preference Removed",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                fontSize: 14.0
            );
        }
    }

    Future<void> loadPref() async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String email = (prefs.getString('email')) ?? '';
        String password = (prefs.getString('pass')) ?? '';
        if (email.isNotEmpty) {
            setState(() {
                _emailEditingController.text = email;
                _passEditingController.text = password;
                _isChecked = true;
            });
        }
    }
}