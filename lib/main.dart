import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iomoupsc/login.dart';

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IOMOU',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Arial'),
      home: const FirstPage(),
    );
  }
}

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  String textheadBefore = '';
  String textheadAfter = '';

  @override
  void initState() {
    super.initState();
    headtext();
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const Login(title: '')),
      );
    });
  }

  void headtext() async {
    try {
      const apiUrl =
          'https://iomou.azurewebsites.net/flutter_connect/index1.php';
      final response = await http.post(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        List<String> parts = response.body.split('###');
        setState(() {
          textheadBefore = parts.isNotEmpty ? parts[0] : '';
          textheadAfter = parts.length > 1 ? parts[1] : '';
        });
      } else {
        setState(() {
          textheadBefore = '';
          textheadAfter = 'Error: Unable to fetch data';
        });
      }
    } catch (e) {
      setState(() {
        textheadBefore = '';
        textheadAfter = 'Error: Unable to fetch data';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            children: [
              // Top section with logo and slogan
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/iomou_logo.png'),
                          fit: BoxFit.contain,
                        ),
                      ),
                      width: 180,
                      height: 180,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Our ultimate goal is to identify and\neliminate substandard ships from the\nIndian Ocean region',
                      style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Arial',
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(73, 54, 116, 1)),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Bottom section with theme text and version
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Theme text
                    Text(
                      'Annual Theme $textheadBefore',
                      style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'Arial',
                          fontWeight: FontWeight.bold,
                          color: Colors.orange),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      textheadAfter,
                      style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'Arial',
                          fontWeight: FontWeight.bold,
                          color: Colors.orange),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Yellow divider
                    Center(
                      child: Container(
                        width: 200.0,
                        child: const Divider(
                          color: Colors.yellow,
                          thickness: 2.0,
                          height: 10.0,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // App version
                    const Text(
                      'App Version: 3.0.0',
                      style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Arial',
                          color: Color.fromRGBO(73, 54, 116, 1)),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
