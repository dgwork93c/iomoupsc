// ignore_for_file: library_private_types_in_public_api, prefer_typing_uninitialized_variables, unused_element, use_build_context_synchronously, non_constant_identifier_names, duplicate_ignore, avoid_print, unused_local_variable
import 'dart:convert';
import 'dart:typed_data';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iomoupsc/custom_color.dart';
import 'package:iomoupsc/login.dart';
import 'package:iomoupsc/onemainpage.dart';
import 'package:iomoupsc/onemainpage2.dart';
import 'package:iomoupsc/reusablecards.dart';
import 'package:iomoupsc/shipdb.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:iomoupsc/loader.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(const KnowShip(
    userId: '',
  ));
}

class KnowShip extends StatefulWidget {
  // const KnowShip({super.key});
  final String userId;

  const KnowShip({super.key, required this.userId});
  @override
  _KnowShipState createState() => _KnowShipState();
}

class _KnowShipState extends State<KnowShip> {
  final String serverPath =
      "https://iomou.azurewebsites.net/flutter_connect"; // Replace with your server path

  List<Category> allDeficiencies = [];
  List<Category> filteredDeficiencies = [];
  bool isLoading = false;
  bool _isLoading = true;
  Map<String, dynamic>? shipData;
  List<dynamic> subInspHistData = [];
  List<dynamic> peoples1 = [];
  List<dynamic> subInspHistData1 = [];
  List<dynamic> inspHistInitData = [];
  List<dynamic> subInspHistData3 = [];
  List<dynamic> defHist = [];
  List<dynamic> defHist1 = [];
  List<dynamic> defHist2 = [];
  bool hideCard = true;
  var v1;
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
      // Fetch data from SQLite database
      final shipDatabase = ShipDatabase();
      final List<Map<String, dynamic>> shipsData =
          await shipDatabase.getShips();
      final int localRowCount = await shipDatabase.getRowCount();
      print('Local row count: $localRowCount');
      // Check if we have data from the database
      if (shipsData.isNotEmpty) {
        // Map the result into your Category model (adjust if needed)
        final List<Category> categories = shipsData
            .map((item) => Category.fromJson({
                  'imo': item['imo'],
                  'name': item['name'],
                  'insp': item['insp'],
                }))
            .toList();

        setState(() {
          _kOptions = categories; // Set the state with the fetched data
          _isLoading = false; // Hide loading
        });
      } else {
        setState(() {
          _isLoading = false; // Hide loading
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No data found')),
        );
      }
    } catch (error) {
      print('Error fetching data: $error');
      setState(() {
        _isLoading = false; // Hide loading
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching data')),
      );
    }
  }

  void filterByKeyword(String keyword) {
    setState(() {
      final keywordLower = keyword.toLowerCase();

      filteredDeficiencies = allDeficiencies
          .where(
              (category) => category.imo.toLowerCase().startsWith(keywordLower))
          .toList();

      filteredDeficiencies.sort((a, b) {
        int compareStrings(String aText, String bText, String keyword) {
          // Directly compare based on the starting characters
          if (aText.startsWith(keyword) && !bText.startsWith(keyword)) {
            return -1;
          } else if (!aText.startsWith(keyword) && bText.startsWith(keyword)) {
            return 1;
          } else {
            return 0;
          }
        }

        final aImo = a.imo.toLowerCase();
        final bImo = b.imo.toLowerCase();

        return compareStrings(aImo, bImo, keywordLower);
      });
    });
  }

  Future<void> fetchdata(String insp) async {
    _isLoading = true;
    try {
      final response = await http
          .get(Uri.parse('$serverPath/get_know_ship.php?insp_no=$insp'));

      print('$serverPath/get_know_ship.php?insp_no=$insp');

      if (response.statusCode == 200) {
        _isLoading = false;
        print(response.body);
        final jsonData = jsonDecode(response.body);

        setState(() {
          shipData =
              jsonData['info']?.isNotEmpty == true ? jsonData['info'][0] : null;

          // Extracting sub_insp_hist
          subInspHistData = jsonData['sub_insp_hist'] ?? [];
          peoples1 = jsonData['sub_insp_hist'] ?? [];

          // Extracting nested sub_insp_histF (inside each sub_insp_hist item)
          subInspHistData1 =
              subInspHistData.expand((e) => e['sub_insp_histF'] ?? []).toList();

          // Extracting nested def_det_hist (inside each sub_insp_hist item)
          subInspHistData3 =
              subInspHistData.expand((e) => e['def_det_hist'] ?? []).toList();

          // Extracting insp_hist_init
          inspHistInitData = jsonData['insp_hist_init'] ?? [];

          // Handling visibility
          v1 = subInspHistData.isEmpty ? 1 : 0;
          hideCard = false;
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

  void showCustomDialog(
      BuildContext context, String title, List<dynamic> defHist) {
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
      body: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: 350,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                title, // Dynamic title (Initial or Follow-up)
                style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Arial',
                    fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: defHist.isEmpty
                  ? const Center(
                      child: Text('No deficiency history available.'),
                    )
                  : SingleChildScrollView(
                      child: Table(
                        columnWidths: const {
                          0: IntrinsicColumnWidth(),
                          1: FlexColumnWidth(2),
                          2: IntrinsicColumnWidth(),
                        },
                        border:
                            TableBorder.all(color: Color(0xFFFCB131), width: 2),
                        children: [
                          const TableRow(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Code',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Deficiencies',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Rectified',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          ...defHist.map((defEntry) {
                            return TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(defEntry['def_code']),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(defEntry['def_name']),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: defEntry['rectified'] == 'YES'
                                      ? const Icon(Icons.check,
                                          color: Colors.green)
                                      : const Icon(Icons.clear,
                                          color: Colors.red),
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

  void showCustomDialog1(BuildContext context, List<dynamic> defHist1) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 30),
                    const Text('Deficiencies History',
                        style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Arial',
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 300,
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: defHist1.isEmpty
                          ? const Center(
                              child: Text('No deficiency history available.'))
                          : SingleChildScrollView(
                              child: Table(
                                columnWidths: const {
                                  0: IntrinsicColumnWidth(),
                                  1: FlexColumnWidth(2),
                                  2: IntrinsicColumnWidth(),
                                },
                                border: TableBorder.all(
                                    color: Color(0xFFFCB131), width: 2),
                                children: [
                                  const TableRow(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text('Code',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text('Deficiencies',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text('Rectified',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                  ...defHist1.map((defEntry) {
                                    return TableRow(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(defEntry['def_code']),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(defEntry['def_name']),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: defEntry['rectified'] == 'YES'
                                              ? const Icon(Icons.check,
                                                  color: Colors.green)
                                              : const Icon(Icons.clear,
                                                  color: Colors.red),
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
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: const Icon(Icons.close, size: 24, color: Colors.black),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void showCustomDialogdet(BuildContext context, List<dynamic> defHist2) {
    AwesomeDialog(
      context: context,
      headerAnimationLoop: false,
      dialogType: DialogType.noHeader,
      showCloseIcon: true,
      closeIcon: const Icon(
        Icons.close,
        size: 24,
        color: Colors.black,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width * 0.9, // 90% of screen width
        height: 350, // Fixed height
        child: Column(
          children: [
            // Title
            const Padding(
              padding: EdgeInsets.only(bottom: 2),
              child: Text(
                'Detainable Deficiencies',
                style: TextStyle(
                  fontSize: 14, fontFamily: 'Arial',
                  fontWeight: FontWeight.bold,
                  color: Colors.red, // Red title color
                ),
              ),
            ),
            Expanded(
              child: defHist2.isEmpty
                  ? const Center(
                      child: Text(
                        'No deficiency history available.',
                        style: TextStyle(color: Colors.red),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Table(
                        border: TableBorder.all(
                          color: const Color(0xFFFCB131), // Yellow border color
                          width: 2,
                        ),
                        children: [
                          // Table Header
                          const TableRow(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Code',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Deficiencies',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Rectified',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Table Rows
                          ...defHist2.map((defEntry) {
                            final String defCode = defEntry['def_code'];
                            final String defName = defEntry['def_name'];
                            final String rectified = defEntry['rectified'];

                            return TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    defCode,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    defName,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: rectified == 'YES'
                                      ? const Icon(Icons.check,
                                          color: Colors.green)
                                      : const Icon(Icons.clear,
                                          color: Colors.red),
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

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 14.0,
    );
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
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Know Your Ship',
                      style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Arial',
                          fontWeight: FontWeight.bold,
                          color: AppColors.themeblue),
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
                        fetchdata(selection.insp);
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
                                    icon: const Icon(Icons.clear),
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

                    // Wrap SingleChildScrollView with Expanded
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            if (shipData != null)
                              ShipDetailsCard(shipData: shipData),
                            Center(
                              child: hideCard ? null : _buildInspectionCards(),
                            ),
                            if (shipData != null) _buildInspHistInitCard(),
                            SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (_isLoading)
                      Container(
                        color: Colors.black.withOpacity(0.5), // Dim background
                        child: const Center(
                          child:
                              HMLoader(), // Replace this with your loader widget
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Column _buildInspectionCards() {
    List<Widget> cards = [];

    for (int i = 0; i < peoples1.length; i++) {
      var c = peoples1[i];
      var peoples1FF = c['sub_insp_histF'];
      var defHist = c['def_hist'];
      var peoples31 = c['def_det_hist'] ?? [];

      var inspectionDetails = Padding(
        padding: const EdgeInsets.only(left: 5),
        child: Text(
          "( I-${i + 1} ) ${c['date_inspection']} (${c['insp_type']}) - ${c['port_name']}",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF0807bb),
            fontSize: 12,
            fontFamily: 'Arial',
          ),
        ),
      );

      var deficiencies = GestureDetector(
        onTap: () {
          if (c['NumDef'] > 0) {
            showCustomDialog(context, "Deficiencies", defHist);
          }
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Deficiencies(${c['NumDef']}): ',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontFamily: 'Arial',
                  ),
                ),
                TextSpan(
                  text: 'Rectified(${c['RectifyNum']}), ',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 12,
                    fontFamily: 'Arial',
                  ),
                ),
                TextSpan(
                  text: 'Outstanding(${c['unRect']})',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    fontFamily: 'Arial',
                    color: c['unRect'] != '0' ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      var detainableDeficiency = GestureDetector(
        onTap: () {
          if (peoples31.isNotEmpty) {
            showCustomDialogdet(context, peoples31);
          }
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: RichText(
            text: TextSpan(
              children: [
                const TextSpan(
                  text: "Detainable Deficiencies: ",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontFamily: 'Arial',
                  ),
                ),
                TextSpan(
                  text: "(${peoples31.length})",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: c['detained_count_colour'] == 'NO'
                        ? Colors.red
                        : Colors.green,
                    fontSize: 12,
                    fontFamily: 'Arial',
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      var dodDor = Padding(
        padding: const EdgeInsets.only(left: 8),
        child: RichText(
          text: TextSpan(
            children: [
              const TextSpan(
                text: "DOD: ",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontFamily: 'Arial',
                ),
              ),
              TextSpan(
                text: "${c['date_inspection']}, ",
                style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'Arial',
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
              const TextSpan(
                text: "DOR: ",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontFamily: 'Arial',
                ),
              ),
              TextSpan(
                text: "${c['date_release']}",
                style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'Arial',
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );

      var roResponsible = Padding(
        padding: const EdgeInsets.only(left: 8),
        child: RichText(
          text: TextSpan(
            children: [
              const TextSpan(
                text: "RO Responsible: ",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontFamily: 'Arial',
                ),
              ),
              TextSpan(
                text: "${c['ro_resresult']}",
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Arial',
                  color: c['ro_resresult'] == "NO" ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );

      var forms = Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Row(
          children: [
            const Text("Forms: ",
                style: TextStyle(color: Colors.black, fontSize: 14)),
            TextButton(
              onPressed: () {
                showToast("Opening Form A...");
                makeAnotherAPICall(context, c['insp_no']);
              },
              child: const Text('Form A',
                  style: TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                      fontFamily: 'Arial',
                      fontWeight: FontWeight.bold)),
            ),
            if (c['NumDef'] != '0')
              TextButton(
                onPressed: () {
                  showToast("Opening Form B...");
                  makeAnotherAPICall1(context, c['insp_no']);
                },
                child: const Text('Form B',
                    style: TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                        fontFamily: 'Arial',
                        fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      );

      List<Widget> subInspectionWidgets = [];
      for (int iFF = 0; iFF < peoples1FF.length; iFF++) {
        var FF = peoples1FF[iFF];
        var defHistFF = FF['def_hist'];

        subInspectionWidgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "( F-${iFF + 1} ) ${FF['date_inspection']} (${FF['insp_type']}) - ${FF['port_name']}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    fontSize: 12,
                    fontFamily: 'Arial',
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (FF['NumDef'] > 0) {
                      showCustomDialog(context, "Deficiencies", defHistFF);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Deficiencies(${FF['NumDef']}): ',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontFamily: 'Arial',
                            ),
                          ),
                          TextSpan(
                            text: 'Rectified(${FF['RectifyNum']}), ',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                              fontSize: 12,
                              fontFamily: 'Arial',
                            ),
                          ),
                          TextSpan(
                            text: 'Outstanding(${FF['unRect']})',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              fontFamily: 'Arial',
                              color: FF['unRect'] != '0'
                                  ? Colors.red
                                  : Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: "DOR: ",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontFamily: 'Arial',
                          ),
                        ),
                        TextSpan(
                          text: "${FF['date_release']}",
                          style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'Arial',
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                forms = Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Row(
                    children: [
                      const Text("Forms: ",
                          style: TextStyle(color: Colors.black, fontSize: 14)),
                      TextButton(
                        onPressed: () {
                          showToast("Opening Form A...");
                          makeAnotherAPICall(context, FF['insp_no']);
                        },
                        child: const Text('Form A',
                            style: TextStyle(
                                color: Colors.blue,
                                fontSize: 12,
                                fontFamily: 'Arial',
                                fontWeight: FontWeight.bold)),
                      ),
                      if (c['NumDef'] != '0')
                        TextButton(
                          onPressed: () {
                            showToast("Opening Form B...");
                            makeAnotherAPICall1(context, FF['insp_no']);
                          },
                          child: const Text('Form B',
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 12,
                                  fontFamily: 'Arial',
                                  fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }

      cards.add(
        Card(
          // margin: EdgeInsets.all(8.0),
          margin: EdgeInsets.only(bottom: 0, left: 4, right: 4),
          elevation: 0,
          color: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
            side: const BorderSide(
              color: Color(0xFFFCB131),
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                inspectionDetails,
                deficiencies,
                SizedBox(
                  height: 4,
                ),
                detainableDeficiency,
                dodDor,
                roResponsible,
                forms,
                ...subInspectionWidgets,
              ],
            ),
          ),
        ),
      );
    }

    return Column(children: cards);
  }

  Widget _buildInspHistInitCard() {
    if (inspHistInitData.isEmpty) {
      return Card(
        elevation: 0,
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(1),
          side: const BorderSide(
            color: Color(0xFFFCB131),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: double.infinity,
              color: const Color(0xFFFCB131),
              padding:
                  const EdgeInsets.symmetric(vertical: 1), // Better spacing
              child: const Text(
                'Next Possible Action',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  fontFamily: 'Arial',
                ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  'Initial',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    fontFamily: 'Arial',
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Assuming inspHistInitData is a List<Map<String, dynamic>>
      // Modify the following code accordingly if the data structure is different
      final inspectionData = inspHistInitData.last;
      final String inspCan =
          inspectionData["insp_can"] == "F" ? "Follow-Up" : "Initial";
      final String datesInsp = "${inspectionData["insp_date"]}(I)";

      return Card(
        elevation: 0,
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(1),
          side: const BorderSide(
            color: Color(0xFFFCB131),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: double.infinity,
                color: const Color(0xFFFCB131),
                padding:
                    const EdgeInsets.symmetric(vertical: 1), // Better spacing
                child: const Text(
                  'Next Possible Action',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    fontFamily: 'Arial',
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "$inspCan [ $datesInsp ]",
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    fontFamily: 'Arial',
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildDetailTile(String label, String? value,
      {bool isRed = false, bool isGreen = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label:',
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontFamily: 'Arial', fontSize: 12),
        ),
        Text(
          value ?? '',
          style: TextStyle(
            fontSize: 12,
            fontFamily: 'Arial',
            color: isRed ? Colors.red : (isGreen ? Colors.green : Colors.black),
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

  getResources() {}

  void _showDefHistPopup(BuildContext context, List<dynamic> defHist) {
    // Implement the popup window showing the Deficiency History
  }

  void _showDetainableDefHistPopup(
      BuildContext context, List<dynamic> defDetHist) {
    // Implement the popup window showing the Detainable Deficiency History
  }

  void _showROHistPopup(BuildContext context, List<dynamic> roHist) {
    // Implement the popup window showing the RO History
  }

  Widget createFormsTextView(String inspNo, String count) {
    // Replace this with your implementation of creating a TextView for Forms
    return Text('INSP_NO: $inspNo, Count: $count');
  }

  void showToastMessage(String s) {}

  void _initiatePopupWindow(BuildContext context, c) {}

  void _initiatePopupWindowD(BuildContext context, peoples31) {}

  _initiatePopupWindow2(BuildContext context, c) {}
}

class PDFScreen extends StatefulWidget {
  final String pdfUrl;

  const PDFScreen({super.key, required this.pdfUrl});

  @override
  _PDFScreenState createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> {
  bool _isLoading = true;
  late Uint8List _pdfData;

  @override
  void initState() {
    super.initState();
    loadPdf();
  }

  Future<void> loadPdf() async {
    try {
      final response = await http.get(Uri.parse(widget.pdfUrl));
      final contentType = response.headers['content-type'];
      print('Response Status Code: ${response.statusCode}');
      print('Response Content-Type: ${response.headers['content-type']}');

      if (contentType != null && contentType.contains('application/pdf')) {
        if (response.statusCode == 200) {
          setState(() {
            _pdfData = response.bodyBytes;
            _isLoading = false;
          });
        } else {
          showErrorDialog('Failed to load PDF.');
        }
      } else {
        showErrorDialog('The selected file is not a valid PDF.');
      }
    } catch (error) {
      showErrorDialog('An error occurred while loading the PDF: $error');
    }
  }

  void showErrorDialog(String errorMessage) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('IOMOU')),
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

Future<void> makeAnotherAPICall(BuildContext context, String inspNo) async {
  try {
    final response = await http.get(Uri.parse(
        'https://iomou.azurewebsites.net/IOCIS2O2O/ADMINISTRATOR/flutter_11_FormA_Rpt.php?inspNo=$inspNo'));

    print(response.body);
    if (response.statusCode == 200) {
      // ignore: use_build_context_synchronously
      _openPDFScreen(context, inspNo);
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch data')),
      );
    }
  } catch (error) {
    print('Error fetching data: $error');
  }
}

Future<void> makeAnotherAPICall1(BuildContext context, String inspNo) async {
  try {
    final response = await http.get(Uri.parse(
        'https://iomou.azurewebsites.net/IOCIS2O2O/ADMINISTRATOR/flutter_11_FormB_Rpt.php?inspNo=$inspNo'));

    if (response.statusCode == 200) {
      _openPDFScreen(context, inspNo);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch data')),
      );
    }
  } catch (error) {
    print('Error fetching data: $error');
  }
}

void _openPDFScreen(BuildContext context, String inspNo) {
  String pdfUrl =
      'https://iomou.azurewebsites.net/flutter_connect/app_pdf/forms.pdf';

  Navigator.of(context).push(MaterialPageRoute(
    builder: (BuildContext context) => PDFScreen(pdfUrl: pdfUrl),
  ));
}

class Category {
  String imo;
  String name;
  String insp;

  Category({required this.imo, required this.name, required this.insp});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      imo: json['imo'] ?? '',
      name: json['name'] ?? '',
      insp: json['insp'] ?? '',
    );
  }
}
