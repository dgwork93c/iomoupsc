import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iomoupsc/custom_color.dart';
import 'package:iomoupsc/login.dart';
import 'package:iomoupsc/onemainpage.dart';
import 'package:iomoupsc/onemainpage2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class AboutApp extends StatefulWidget {
  // const AboutApp({super.key});
  final String userId;

  const AboutApp({super.key, required this.userId});
  @override
  State<AboutApp> createState() => _AboutAppState();
}

class _AboutAppState extends State<AboutApp> {
  bool isLoading = false;
  Widget pdfWidget = Container(); // Widget to hold PDF content

  @override
  void initState() {
    super.initState();
    getResult();
  }

  void getResult() {
    const azurepath = 'https://iomou.azurewebsites.net/HomePAGE/pdf/';
    const sign =
        '?sv=2022-11-02&ss=bfqt&srt=sco&sp=rwlacupitfx&se=2025-12-31T14:55:47Z&st=2025-01-08T06:55:47Z&spr=https&sig=SyrZoTJtgAcDqVfAW%2BN1%2FEu7UiUQ0ekhMERYfpXx8kI%3D';
    const pdfUrlfinal = '$azurepath' + 'app_synopsis.pdf' + '$sign';

    const pdfUrl = pdfUrlfinal;
    print(pdfUrl);
    setState(() {
      isLoading = true;
    });

    Future.delayed(const Duration(seconds: 2), () async {
      setState(() {
        isLoading = false;
      });

      try {
        final response = await http.head(Uri.parse(pdfUrl));
        final contentType = response.headers['content-type'];

        if (contentType != null && contentType.contains('application/pdf')) {
          pdfWidget = SfPdfViewer.network(pdfUrl);
        } else {
          pdfWidget = const Text('File Not Found or Invalid PDF');
        }

        setState(() {}); // Refresh the UI to display the PDF content
      } catch (error) {
        pdfWidget = Text('Error loading PDF: $error');
        setState(() {}); // Refresh the UI to display the error message
      }
    });
  }

  void logout() async {
    await clearSessionData();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const Login(title: ''),
      ),
      (route) => false, // This predicate removes all the previous routes
    );
  }

  Future<void> clearSessionData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.remove('userId'); // Remove only the userId
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.themeblue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Use the current context directly
          },
          color: Colors.white,
          iconSize: 18.0,
        ),
        title: Text(
          'IOMOU - ${widget.userId}',
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Arial',
            color: Colors.white,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              if (widget.userId == 'guest') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => IconMain2(userId: widget.userId)),
                );
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => IconMain(userId: widget.userId)),
                );
              }
            },
            color: Colors.white,
            iconSize: 18.0,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
            color: Colors.white,
            iconSize: 18.0,
          ),
        ],
      ),
      body: Stack(children: [
        Center(
          child: Container(
            width: 300,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/iomou_logo.png"),
                opacity: 0.1,
              ),
            ),
          ),
        ),
        isLoading
            ? Center(child: const CircularProgressIndicator())
            : pdfWidget,
      ] // Display PDF content here
          ),
    );
  }
}
