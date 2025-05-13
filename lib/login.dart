// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:math';
import 'package:iomoupsc/onemainpage2.dart';
import 'package:iomoupsc/toast.dart';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'onemainpage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key, required String title});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController txtuser = TextEditingController();
  TextEditingController txtpass = TextEditingController();

  bool isGuestLogin = false;
  var msg = '';
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  void _loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedUsername = prefs.getString('username');

    if (savedUsername != null && savedUsername.isNotEmpty) {
      setState(() {
        txtuser.text = savedUsername; // Keep username in the text field
      });
    }
  }

  void _saveUsername(String user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', user); // Save username for persistence
  }

  void _clearUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('username'); // Clear only username
    setState(() {
      txtuser.clear(); // Reset text field
    });
  }

  void saveLoginStatus(String userId, String usertype) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', true);
    prefs.setString('userId', userId);
    await prefs.setString('usertype', usertype);
  }

  void log() async {
    setState(() {
      _isLoading = true; // Trigger UI update when loading starts
    });
    String txtuser1 = txtuser.text;
    String txtpass1 = txtpass.text;
    print('$txtuser1 + $txtpass1');

    if (txtuser1 == 'guest') {
      setState(() {
        _isLoading = false; // Trigger UI update when loading starts
      });
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const IconMain2(userId: 'guest')),
      );
    } else {
      String generateSalt(int length) {
        var random = Random.secure();
        var values = List<int>.generate(length, (i) => random.nextInt(256));
        return base64Url.encode(values);
      }

      var sha256pwd1 = sha256.convert(utf8.encode(txtpass1)).toString();
      print(sha256pwd1);
      final apiUrl =
          'https://iomou.azurewebsites.net/flutter_connect/mlogin.php?txtmLoginName=$txtuser1&txtmPassword=$sha256pwd1';
      final response = await http.post(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        String responseBody = response.body;
        setState(() {
          _isLoading = false; // Trigger UI update when loading starts
        });
        if (responseBody.startsWith('mLogin_success')) {
          // Extract usertype
          List<String> parts = responseBody.split('|');
          String usertype = parts.length > 1 ? parts[1] : '';

          saveLoginStatus(txtuser1, usertype);
          _saveUsername(txtuser1);
          // Default navigation
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => IconMain(userId: txtuser1)),
          );
        } else if (responseBody == 'mLogin_error') {
          ToastUtil.showCustomToast(
              context, 'Wrong password. Please try again.');
        } else if (responseBody == 'mLogin_lock') {
          ToastUtil.showCustomToast(context, 'Your account has been locked.');
        } else if (responseBody == 'mLogin_errorid') {
          ToastUtil.showCustomToast(
              context, 'Wrong Username. Please try again.');
        } else if (responseBody == 'mLogin_erroridinact') {
          ToastUtil.showCustomToast(context, 'Username Not Found.');
        }
      } else {}
    }
  }

  void dataempty() {
    txtuser.clear();
    txtpass.clear();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 400;

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text(
              'IOMOU',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: const Color(0xFF174282),
          ),
          backgroundColor: const Color(0xFF174282),
          body: Container(
            color: const Color(0xFF174282),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Container(
                  margin: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      // Logo
                      Padding(
                        padding: EdgeInsets.only(top: isSmallScreen ? 15 : 30),
                        child: Image.asset(
                          'assets/images/iomou_log.png',
                          width: isSmallScreen ? 100 : 120,
                          height: isSmallScreen ? 100 : 120,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: isSmallScreen ? 10 : 20),
                        child: Text(
                          'INDIAN OCEAN \n MEMORANDUM OF UNDERSTANDING',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      // Toggle Buttons
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final toggleButtonWidth =
                              constraints.maxWidth * 0.45 > 175
                                  ? 175.0
                                  : constraints.maxWidth * 0.45;

                          return Row(
                            children: [
                              Expanded(
                                child: Center(
                                  child: ToggleButtons(
                                    isSelected: [!isGuestLogin, isGuestLogin],
                                    onPressed: (index) {
                                      setState(() {
                                        isGuestLogin = index == 1;
                                        if (isGuestLogin) {
                                          txtuser.text = 'guest';
                                          txtpass.text = 'guest1';
                                        } else {
                                          txtuser.clear();
                                          _loadUsername();
                                          txtpass.clear();
                                        }
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(15),
                                    selectedColor: const Color(0xFF174282),
                                    fillColor: Colors.white,
                                    color: Colors.white,
                                    borderColor: Colors.white,
                                    borderWidth: 1,
                                    selectedBorderColor: Colors.white,
                                    children: [
                                      Container(
                                        width: toggleButtonWidth,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: isSmallScreen ? 8 : 16,
                                            vertical: 8,
                                          ),
                                          child: Text(
                                            'Member Login',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: isSmallScreen ? 14 : 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: toggleButtonWidth,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: isSmallScreen ? 8 : 16,
                                            vertical: 8,
                                          ),
                                          child: Text(
                                            'Guest Login',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: isSmallScreen ? 14 : 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      // Login Form
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final formWidth = constraints.maxWidth > 350
                              ? 350.0
                              : constraints.maxWidth * 0.95;

                          return Container(
                            width: formWidth,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Color(0xFFFCB131),
                                width: 2,
                              ),
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFFFCB131).withOpacity(0.5),
                                  offset: const Offset(5, 5),
                                  blurRadius: 5,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            padding: EdgeInsets.all(isSmallScreen ? 15 : 20),
                            child: Column(
                              children: [
                                Text(
                                  isGuestLogin ? 'Guest Login' : 'Member Login',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 14 : 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF174282),
                                  ),
                                ),
                                SizedBox(height: isSmallScreen ? 8 : 10),
                                TextFormField(
                                  controller: txtuser,
                                  readOnly: isGuestLogin,
                                  decoration: const InputDecoration(
                                    labelText: 'Username',
                                    hintText: 'Please enter username',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                SizedBox(height: isSmallScreen ? 8 : 10),
                                TextFormField(
                                  controller: txtpass,
                                  readOnly: isGuestLogin,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Password',
                                    hintText: 'Please enter Username',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                SizedBox(height: isSmallScreen ? 8 : 10),
                                Padding(
                                  padding:
                                      EdgeInsets.all(isSmallScreen ? 0 : 1),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF174282),
                                          ),
                                          onPressed: log,
                                          child: const Text(
                                            "Login",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (!isGuestLogin) ...[
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFF174282),
                                            ),
                                            onPressed: dataempty,
                                            child: const Text(
                                              "Reset",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.white,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Loading Please Wait...',
                      textAlign: TextAlign.center, // Add this if needed
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        decoration: TextDecoration
                            .none, // Ensures no underline or decoration
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
