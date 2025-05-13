// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:iomoupsc/custom_color.dart';
import 'package:iomoupsc/loader.dart';
import 'package:iomoupsc/login.dart';
import 'package:iomoupsc/onemainpage.dart';
import 'package:iomoupsc/onemainpage2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'knowshipmain.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(
    MaterialApp(
      navigatorKey: navigatorKey,
      home: const srppage(
        userId: '',
      ),
    ),
  );
}

class srppage extends StatefulWidget {
  // const srppage({super.key});
  final String userId;

  const srppage({super.key, required this.userId});

  @override
  State<srppage> createState() => _srppageState();
}

class _srppageState extends State<srppage> {
  final String serverPath = "https://iomou.azurewebsites.net/flutter_connect";
  List<Category> allDeficiencies = [];
  List<Category> filteredDeficiencies = [];
  bool isLoading = false;
  Map<String, dynamic>? shipData;
  List<dynamic> subInspHistData = [];
  List<dynamic> peoples = [];
  List<dynamic> subInspHistData1 = [];
  List<dynamic> subInspHistData3 = [];
  List<dynamic> subInspHistData4 = [];
  List<dynamic> subInspHistData5 = [];
  List<dynamic> subInspHistData6 = [];
  List<dynamic> inspHistInitData = [];
  List<dynamic> defHist = [];
  List<dynamic> defHist2 = [];
  List<dynamic> defHist1 = [];
  bool hideCard = true;
  var v1;
  bool _isLoading = true;
  List<Category> _kOptions = <Category>[];
  TextEditingController _autocompleteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchDeficiencies();
    hideCard = true;
    _isLoading = true;
  }

  Future<void> fetchDeficiencies() async {
    try {
      final response = await http
          .get(Uri.parse('$serverPath/get_imo_name_srp.php?identity=false'));

      if (response.statusCode == 200) {
        print(response.body);
        final parsedData = jsonDecode(response.body);
        final List<dynamic> result = parsedData['result'];
        _isLoading = false;

        final List<Category> categories = result
            .map((item) => Category.fromJson(item as Map<String, dynamic>))
            .toList();

        setState(() {
          _kOptions = categories;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch data')),
        );
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  void filterByKeyword(String keyword) {
    setState(() {
      filteredDeficiencies = allDeficiencies
          .where((category) =>
              category.name.toLowerCase().contains(keyword.toLowerCase()) ||
              category.imo.toLowerCase().contains(keyword.toLowerCase()))
          .toList();
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Arial'),
      home: Scaffold(
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
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    "Ship Risk Profile",
                    style: TextStyle(
                        color: AppColors.themeblue,
                        fontSize: 14,
                        fontFamily: 'Arial',
                        fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "(Based on 3 years inspection data)",
                    style: TextStyle(color: AppColors.themeblue, fontSize: 12),
                  ),
                  const SizedBox(height: 16.0),
                  Autocomplete<Category>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text == '') {
                        return const Iterable<Category>.empty();
                      }
                      return _kOptions.where((Category option) {
                        final String lowerCaseInput =
                            textEditingValue.text.toLowerCase();
                        return option.name
                                .toLowerCase()
                                .contains(lowerCaseInput) ||
                            option.imo.toLowerCase().contains(lowerCaseInput);
                      });
                    },
                    onSelected: (Category selection) {
                      debugPrint('You just selected ${selection.name}');
                      makeAnotherAPICallnew(context, selection.insp);
                    },
                    displayStringForOption: (Category option) =>
                        option.name + '(' + option.imo + ')',
                    fieldViewBuilder: (BuildContext context,
                        TextEditingController controller,
                        FocusNode focusNode,
                        VoidCallback onFieldSubmitted) {
                      _autocompleteController = controller;

                      return TextFormField(
                        controller: _autocompleteController,
                        focusNode: focusNode,
                        onTap: () {
                          if (_autocompleteController.text ==
                              'Enter IMO No. / Ship Name:') {
                            _autocompleteController.clear();
                          }
                        },
                        decoration: InputDecoration(
                            hintText: 'Enter IMO No. / Ship Name',
                            suffixIcon: IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                _autocompleteController.clear();
                              },
                            )),
                        onFieldSubmitted: (String value) {
                          onFieldSubmitted();
                        },
                      );
                    },
                  ),
                  if (_isLoading)
                    const Align(
                      alignment: Alignment.center,
                      child: HMLoader(),
                    )
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  String _getShipRiskProfileText(
      String srpValue, String srpPriority, String srpInspCat) {
    if (srpValue == 'HRS' || srpValue == 'SRS' || srpValue == 'LRS') {
      return '$srpValue-$srpPriority-$srpInspCat Insp.';
    } else {
      return 'N/A';
    }
  }

  Widget _buildDetailTile(String label, String? value,
      {bool isRed = false, bool isGreen = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label:',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        Text(
          value ?? '',
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Arial',
            color: isRed ? Colors.red : (isGreen ? Colors.green : Colors.black),
          ),
          textAlign: TextAlign.left, // Set text alignment to left
        ),
      ],
    );
  }

  Widget _buildDetailTile1(String label, String? value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              fontFamily: 'Arial',
              color: Colors.red),
        ),
        Text(
          value ?? '',
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Arial',
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
          textAlign: TextAlign.left, // Set text alignment to left
        ),
      ],
    );
  }

  Widget _buildDetailTile2(String label, int value,
      {bool isRed = false, bool isGreen = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        Text(
          value.toString(), // Convert the int to a String
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Arial',
            fontWeight: FontWeight.bold,
            color: isRed ? Colors.red : (isGreen ? Colors.green : Colors.black),
          ),
          textAlign: TextAlign.left,
        ),
      ],
    );
  }

  Widget _buildDetailTile3(String label, int value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        Text(
          value.toString(), // Convert the int to a String
          style: const TextStyle(
              fontSize: 14,
              fontFamily: 'Arial',
              fontWeight: FontWeight.bold,
              color: Colors.red),
          textAlign: TextAlign.left,
        ),
      ],
    );
  }

  Widget _buildDetailTitle(String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            fontFamily: 'Arial',
            color: Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildFlagImage(String? imageName) {
    if (imageName == null || imageName.isEmpty) {
      return const Placeholder(); // Replace with your preferred placeholder widget.
    }

    final lowercaseImageName = imageName.toLowerCase();
    print('Image Name: $lowercaseImageName');

    return Image.asset(
      'assets/images/$lowercaseImageName',
      width: 50,
      height: 50,
    );
  }

  void makeAnotherAPICallnew(BuildContext context, String inspNo) async {
    _isLoading = true;
    try {
      final response = await http.get(Uri.parse(
          'https://iomou.azurewebsites.net/IOCIS2O2O/ADMINISTRATOR/flutter_11_FormNIR_Rpt.php?inspNum=$inspNo'));

      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200) {
        _isLoading = false;
        print(response.statusCode);
        print(response.body);

        _openPDFScreennew(inspNo, widget.userId);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch data')),
        );
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  void _openPDFScreennew(String inspNo, String userId) {
    String pdfUrl =
        'https://iomou.azurewebsites.net/flutter_connect/app_pdf/srp.pdf';
    Navigator.of(context).push(MaterialPageRoute(
      builder: (BuildContext context) => PDFScreennew(
        pdfUrl: pdfUrl,
        userId: userId, inspNo: inspNo, // Pass the userId here
      ),
    ));
  }
}

class PDFScreennew extends StatefulWidget {
  final String userId;
  final String inspNo;
  // const srppage({super.key, required this.userId});
  final String pdfUrl;

  const PDFScreennew(
      {super.key,
      required this.pdfUrl,
      required this.userId,
      required this.inspNo});

  @override
  _PDFScreennewState createState() => _PDFScreennewState();
}

class _PDFScreennewState extends State<PDFScreennew> {
  bool _isLoading = true;
  late Uint8List _pdfData;
  late String _tempPDFFilePath;

  @override
  void initState() {
    super.initState();
    loadPdfnew();
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

  Future<void> loadPdfnew() async {
    try {
      final response = await http.get(Uri.parse(widget.pdfUrl));
      final contentType = response.headers['content-type'];
      print('Response Status Code: ${response.statusCode}');
      print('Response Content-Type: ${response.headers['content-type']}');
      print('3');
      if (contentType != null && contentType.contains('application/pdf')) {
        if (response.statusCode == 200) {
          setState(() {
            _pdfData = response.bodyBytes;
            _isLoading = false;
          });
        } else {
          showErrorDialognew('Failed to load PDF.');
        }
      } else {
        showErrorDialognew('The selected file is not a valid PDF.');
      }
    } catch (error) {
      showErrorDialognew('An error occurred while loading the PDF: $error');
    }
  }

  void showErrorDialognew(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> saveCurrentPDF() async {
    // Create a temporary directory
    Directory tempDir = await getTemporaryDirectory();
    // Generate a unique filename
    String tempFileName = '${widget.inspNo}.pdf';

    // Combine the temporary directory path and the filename
    _tempPDFFilePath = '${tempDir.path}/$tempFileName';

    // Write the PDF content to the temporary file
    await File(_tempPDFFilePath).writeAsBytes(_pdfData);
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SfPdfViewer.memory(
              _pdfData,

              // scroll to a specific page when opening the PDF
              // initialPage: 1,
            ),
    );
  }
}
