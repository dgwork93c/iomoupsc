// ignore_for_file: unused_import, unused_field

import 'package:iomoupsc/custom_color.dart';
import 'package:iomoupsc/loader.dart';
import 'package:flutter/material.dart';
import 'package:iomoupsc/login.dart';
import 'package:iomoupsc/onemainpage.dart';
import 'package:iomoupsc/onemainpage2.dart';
import 'package:iomoupsc/reusablecards.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'knowshipmain.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class shipdefhist extends StatefulWidget {
  // const shipdefhist({super.key});
  final String userId;

  const shipdefhist({super.key, required this.userId});

  @override
  State<shipdefhist> createState() => _shipdefhistState();
}

class _shipdefhistState extends State<shipdefhist> {
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
          .get(Uri.parse('$serverPath/get_imo_name_def.php?identity=false'));

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

  Future<void> fetchShipDetails(String inspNo) async {
    _isLoading = true;
    try {
      final response = await http
          .get(Uri.parse('$serverPath/get_def_details.php?insp_no=$inspNo'));

      if (response.statusCode == 200) {
        _isLoading = false;
        final jsonData = jsonDecode(response.body);
        print(response.body);
        setState(() {
          shipData =
              jsonData['info']?.isNotEmpty == true ? jsonData['info'][0] : null;
          subInspHistData = jsonData['det_hist'] ?? [];
          subInspHistData1 = jsonData['def_hist'] ?? [];
          subInspHistData3 = jsonData['def_det_hist'] ?? [];
          subInspHistData4 = jsonData['insp_hist'] ?? [];
          subInspHistData5 = jsonData['def_hist'] ?? [];
          subInspHistData6 = jsonData['cert_hist'] ?? [];
        });
      } else {
        throw Exception('Failed to load ship details');
      }
    } catch (e) {
      print('Exception: $e');
    }
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
        body: Stack(
          children: [
            // Background container with watermark
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
            Container(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        "Ship Deficiency History",
                        style: TextStyle(
                            color: AppColors.themeblue,
                            fontSize: 14,
                            fontFamily: 'Arial',
                            fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        "(Deficiencies Recorded in Last 2 Years)",
                        style:
                            TextStyle(color: AppColors.themeblue, fontSize: 12),
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
                                option.imo
                                    .toLowerCase()
                                    .contains(lowerCaseInput);
                          });
                        },
                        onSelected: (Category selection) {
                          debugPrint('You just selected ${selection.name}');
                          fetchShipDetails(selection.insp);
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
                              suffixIcon:
                                  _autocompleteController.text.isNotEmpty
                                      ? IconButton(
                                          icon: Icon(Icons.clear),
                                          onPressed: () {
                                            _autocompleteController.clear();
                                          },
                                        )
                                      : null,
                            ),
                            onFieldSubmitted: (String value) {
                              onFieldSubmitted();
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 16.0),
                      // Scrollable section
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              if (shipData != null)
                                ShipDetailsCard(shipData: shipData),
                              if (shipData != null) _buildShipDetailsCard2(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShipDetailsCard2() {
    return Card(
      elevation: 0,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(1),
        side: BorderSide(
          color: Color(0xFFFCB131),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildDetailTile1(
                  'Deficiency Details (',
                  '${shipData?['period_from'] ?? ''} - ${shipData?['period_to'] ?? ''})',
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildDetailTile2('No. of Initial Inspections',
                    shipData?['countInitInsp'] ?? ''),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildDetailTile2(
                    'No. of Initial Inspections with Deficiencies',
                    shipData?['countInitInspDef'] ?? ''),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildDetailTile2(
                    'No. of Detentions', shipData?['countDetInsp'] ?? ''),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildDetailTile2('No. of RO Responsible Detentions',
                    shipData?['countInitInspRoDet'] ?? ''),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildDetailTile2('Total Number of Deficiencies',
                    shipData?['countDef'] ?? ''),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildDetailTile3('Total Number of Detainable Deficiencies',
                    shipData?['countInitInspTotalDet'] ?? ''),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDetailTitle('Deficiency History'),
              ],
            ),
            const SizedBox(height: 10),
            Table(
              border: TableBorder.all(
                color: Colors.orange,
              ),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: const {
                0: FixedColumnWidth(100), // Width of the first column
                1: IntrinsicColumnWidth(), // Width of the middle column (adjust as needed)
                2: FixedColumnWidth(100), // Width of the last column
              },
              children: [
                // Create rows
                const TableRow(
                  children: [
                    TableCell(
                        child: Center(
                            child: Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text(
                        'Deficiency Code',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'Arial',
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                    ))),
                    TableCell(
                      child: Center(
                          child: Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Text(
                          'Deficiency Description',
                          style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      )),
                    ),
                    TableCell(
                        child: Center(
                            child: Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text(
                        'Reported Occurrence',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'Arial',
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                    ))),
                  ],
                ),
                for (final detentionData in subInspHistData1)
                  TableRow(
                    children: [
                      TableCell(
                        child: Center(
                            child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            detentionData['def_code'],
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 12,
                            ),
                          ),
                        )),
                      ),
                      TableCell(
                        child: Center(
                            child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            detentionData['def_name'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 12,
                            ),
                          ),
                        )),
                      ),
                      TableCell(
                        child: Center(
                            child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            detentionData['count'],
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 12,
                            ),
                          ),
                        )),
                      ),
                    ],
                  ),
              ],
            )
          ],
        ),
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
              fontSize: 14, fontFamily: 'Arial', color: Colors.red),
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
          style: const TextStyle(fontSize: 14),
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
          style: const TextStyle(fontSize: 14),
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
}
