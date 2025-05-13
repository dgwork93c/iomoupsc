// ignore_for_file: prefer_const_constructors

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:iomoupsc/custom_color.dart';
import 'package:iomoupsc/loader.dart';
import 'package:iomoupsc/login.dart';
import 'package:iomoupsc/onemainpage.dart';
import 'package:iomoupsc/onemainpage2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OustandingDef extends StatefulWidget {
  final String userId;

  const OustandingDef({Key? key, required this.userId}) : super(key: key);

  @override
  State<OustandingDef> createState() => _OustandingDefState();
}

class _OustandingDefState extends State<OustandingDef> {
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
  List<dynamic> subInspHistData8 = [];
  List<dynamic> subInspHistData6 = [];
  List<dynamic> inspHistInitData = [];
  List<dynamic> defHist = [];
  List<dynamic> defHist2 = [];
  List<dynamic> defHist1 = [];
  bool hideCard = true;
  var v1;
  bool _isLoading = true;
  var showme;
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
      final response =
          await http.get(Uri.parse('$serverPath/unrectdefs.php?identity=true'));

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
          .get(Uri.parse('$serverPath/unrectifieddefs.php?imo_no=$inspNo'));
      print('$serverPath/unrectifieddefs.php?imo_no=$inspNo');
      if (response.statusCode == 200) {
        _isLoading = false;
        final jsonData = jsonDecode(response.body);
        print(response.body);
        // showme = '0';

        print(showme);
        setState(() {
          subInspHistData = jsonData['result'] ?? [];
          if (subInspHistData.isNotEmpty) {
            showme = '2';
          } else if (subInspHistData.isEmpty) {
            showme = '1';
          }
          print(subInspHistData);
        });
      } else {
        throw Exception('Failed to load ship details');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  viewdef(insp) async {
    _isLoading = true;
    try {
      final response =
          await http.get(Uri.parse('$serverPath/defs_api.php?insp_no=$insp'));
      print('$serverPath/defs_api.php?insp_no=$insp');
      if (response.statusCode == 200) {
        _isLoading = false;
        final jsonData = jsonDecode(response.body);
        print(response.body);
        setState(() {
          subInspHistData8 = jsonData['def_hist'] ?? [];
          var defHistList1 = [];

          int srNo = 1; // Initialize the serial number counter
          for (var subInspEntry in subInspHistData8) {
            if (subInspEntry is Map) {
              List<dynamic> entryList = [
                srNo, // Add the serial number to the list
                subInspEntry['def_code'],
                subInspEntry['def_name'],
                subInspEntry['rectified'],
                subInspEntry['detColour']
              ];
              defHistList1.add(entryList);
              srNo++; // Increment the serial number for the next record
            }
          }

          defHist = defHistList1;
          showCustomDialog9(context, defHist);
        });
      } else {
        throw Exception('Failed to load ship details');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  viewdef1(insp) async {
    _isLoading = true;
    try {
      final response = await http
          .get(Uri.parse('$serverPath/defs_apioustanding.php?insp_no=$insp'));
      print('$serverPath/defs_apioustanding.php?insp_no=$insp');
      if (response.statusCode == 200) {
        _isLoading = false;
        final jsonData = jsonDecode(response.body);
        print(response.body);
        setState(() {
          subInspHistData8 = jsonData['def_hist'] ?? [];
          var defHistList1 = [];

          int srNo = 1; // Initialize the serial number counter
          for (var subInspEntry in subInspHistData8) {
            if (subInspEntry is Map) {
              List<dynamic> entryList = [
                srNo,
                subInspEntry['def_code'],
                subInspEntry['def_name'],
                subInspEntry['rectified'],
                subInspEntry['detColour']
              ];
              defHistList1.add(entryList);
              srNo++;
            }
          }
          defHist = defHistList1;
          showCustomDialog9(context, defHist);
        });
      } else {
        throw Exception('Failed to load ship details');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  void showCustomDialog9(BuildContext context, List<dynamic> defHist) {
    AwesomeDialog(
      context: context,
      headerAnimationLoop: false,
      dialogType: DialogType.noHeader,
      showCloseIcon: true,
      closeIcon: const Icon(
        Icons.close,
        size: 20,
        color: Colors.black,
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9, // Consistent width
        height: 350, // Fixed height
        child: Column(
          children: [
            // Title
            const Padding(
              padding: EdgeInsets.only(bottom: 2),
              child: Text(
                'Deficiencies History',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Arial',
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            Expanded(
              child: defHist.isEmpty
                  ? const Center(
                      child: Text('No deficiency history available.'),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Table(
                        columnWidths: const {
                          0: FixedColumnWidth(50), // Width for 'Sr.No.'
                          1: FixedColumnWidth(55), // Width for 'Code'
                          2: FlexColumnWidth(), // Flexible width for 'Deficiencies'
                          3: FixedColumnWidth(75), // Width for 'Rectified'
                        },
                        border: TableBorder.all(
                          color: const Color(0xFFFCB131), // Yellow border color
                          width: 2,
                        ),
                        children: [
                          // Table Header
                          const TableRow(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(3.0),
                                child: Text(
                                  'Sr.No.',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(3.0),
                                child: Text(
                                  'Code',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(3.0),
                                child: Text(
                                  'Deficiencies',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(3.0),
                                child: Text(
                                  'Rectified',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Table rows
                          ...defHist.map((defEntry) {
                            final int srNo = defEntry[0]; // Sr.No.
                            final String defCode = defEntry[1];
                            final String defName = defEntry[2];
                            final String rectified = defEntry[3];

                            return TableRow(
                              children: [
                                SizedBox(
                                  width: 50,
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Center(child: Text(srNo.toString())),
                                  ),
                                ),
                                SizedBox(
                                  width: 55,
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Text(defCode),
                                  ),
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(defName),
                                  ),
                                ),
                                SizedBox(
                                  width: 75,
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: rectified == 'YES'
                                        ? const Icon(Icons.check,
                                            color: Colors.green)
                                        : const Icon(Icons.clear,
                                            color: Colors.red),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    ).show();
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
      theme: ThemeData(
        fontFamily: 'Arial',
      ),
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Center(
                    child: Text(
                      'Outstanding Deficiencies after Rectification Period',
                      style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Arial',
                          fontWeight: FontWeight.bold,
                          color: AppColors.themeblue),
                    ),
                  ),
                  Center(
                    child: Text(
                      '(24 Months Rectification Period)',
                      style: TextStyle(
                          fontSize: 10,
                          fontFamily: 'Arial',
                          fontWeight: FontWeight.bold,
                          color: AppColors.themeblue),
                    ),
                  ),
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
                      fetchShipDetails(selection.imo);
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
                          suffixIcon: _autocompleteController.text.isNotEmpty
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
                  SingleChildScrollView(
                    child: Center(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          if (subInspHistData.isNotEmpty)
                            _buildShipDetailsCard2(),
                          if (showme == '1') _builderrorcard(),
                          if (_isLoading)
                            const Align(
                              alignment: Alignment.center,
                              child: HMLoader(),
                            )
                        ],
                      ),
                    ),
                  ),
                ],
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
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(
          color: Color(0xFFFCB131),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Table(
              border: TableBorder.all(
                color: Colors.orange,
              ),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                // Create rows
                const TableRow(
                  children: [
                    TableCell(
                        child: Center(
                            child: Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text('IMO No.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 10,
                              fontFamily: 'Arial',
                              fontWeight: FontWeight.bold)),
                    ))),
                    TableCell(
                        child: Center(
                            child: Padding(
                      padding: EdgeInsets.all(2.0),
                      child: Text('Date of Inspection(I)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 10,
                              fontFamily: 'Arial',
                              fontWeight: FontWeight.bold)),
                    ))),
                    TableCell(
                        child: Center(
                            child: Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text('Total Deficiencies',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 10,
                              fontFamily: 'Arial',
                              fontWeight: FontWeight.bold)),
                    ))),
                    TableCell(
                        child: Center(
                            child: Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text('Outstanding Deficiencies',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 10,
                              fontFamily: 'Arial',
                              fontWeight: FontWeight.bold)),
                    ))),
                  ],
                ),
                for (final detentionData in subInspHistData)
                  TableRow(
                    children: [
                      TableCell(
                        child: Center(
                            child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(detentionData['imo'],
                              style: TextStyle(
                                  fontSize: 10,
                                  fontFamily: 'Arial',
                                  fontWeight: FontWeight.bold)),
                        )),
                      ),
                      TableCell(
                        child: Center(
                            child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(detentionData['insp_date'],
                              style: TextStyle(
                                  fontSize: 10,
                                  fontFamily: 'Arial',
                                  fontWeight: FontWeight.bold)),
                        )),
                      ),
                      TableCell(
                        child: Center(
                            child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: TextButton(
                            onPressed: () {
                              // if (detentionData['rect'] != '0') {
                              //   viewdef(detentionData['insp_no']);
                              // }
                            },
                            style: ButtonStyle(
                              padding:
                                  MaterialStateProperty.all(EdgeInsets.zero),
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.transparent),
                              overlayColor:
                                  MaterialStateProperty.all(Colors.transparent),
                            ),
                            child: Text(
                              (int.parse(detentionData['rect'] ?? '0') +
                                      int.parse(detentionData['unrect'] ?? '0'))
                                  .toString(),
                              style: TextStyle(
                                fontSize: 10,
                                fontFamily: 'Arial',
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )),
                      ),
                      TableCell(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: TextButton(
                              onPressed: () {
                                // Check if unrect is not equal to 0 before opening the dialogue box
                                if (detentionData['unrect'] != '0') {
                                  viewdef1(detentionData['insp_no']);
                                }
                              },
                              style: ButtonStyle(
                                padding:
                                    MaterialStateProperty.all(EdgeInsets.zero),
                                backgroundColor: MaterialStateProperty.all(
                                    Colors.transparent),
                                overlayColor: MaterialStateProperty.all(
                                    Colors.transparent),
                              ),
                              child: Text(
                                detentionData['unrect'],
                                style: TextStyle(
                                  fontSize: 10,
                                  fontFamily: 'Arial',
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
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
}

Widget _builderrorcard() {
  return Card(
    child: Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'No Deficiencies Found',
            style: TextStyle(color: Colors.red),
          )
        ],
      ),
    ),
  );
}

class Category {
  final String name;
  final String imo;

  Category({required this.name, required this.imo});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      name: json['name'] ?? '',
      imo: json['imo'] ?? '',
    );
  }
}
