import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:iomoupsc/custom_color.dart';
import 'package:iomoupsc/loader.dart';
import 'package:flutter/material.dart';
import 'package:iomoupsc/onemainpage.dart';
import 'package:iomoupsc/onemainpage2.dart';
import 'package:iomoupsc/reusablecards.dart';
import 'package:iomoupsc/shipdb.dart';
import 'knowshipmain.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';

class inspdatalive extends StatefulWidget {
  // const inspdatalive({super.key, required userId});
  final String userId;

  const inspdatalive({super.key, required this.userId});

  @override
  State<inspdatalive> createState() => _inspdataliveState();
}

class _inspdataliveState extends State<inspdatalive> {
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
      // Fetch data from SQLite database
      final shipDatabase = ShipDatabase();
      final List<Map<String, dynamic>> shipsData =
          await shipDatabase.getShips();
      print(shipsData);
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

  Future<void> fetchShipDetails(String inspNo) async {
    _isLoading = true;
    try {
      final response = await http
          .get(Uri.parse('$serverPath/get_ship_details.php?insp_no=$inspNo'));
      print('$serverPath/get_ship_details.php?insp_no=$inspNo');
      if (response.statusCode == 200) {
        _isLoading = false;
        final jsonData = jsonDecode(response.body);
        print(response.body);
        setState(
          () {
            shipData = jsonData['info']?.isNotEmpty == true
                ? jsonData['info'][0]
                : null;
            subInspHistData = jsonData['det_hist'] ?? [];
            subInspHistData1 = jsonData['def_hist'] ?? [];
            subInspHistData3 = jsonData['def_det_hist'] ?? [];
            subInspHistData4 = jsonData['insp_hist'] ?? [];
            subInspHistData5 = jsonData['def_hist'] ?? [];
            subInspHistData6 = jsonData['cert_hist'] ?? [];
          },
        );
      } else {
        throw Exception('Failed to load ship details');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  void showCustomDialog(BuildContext context, List<dynamic> defHist) {
    AwesomeDialog(
      context: context,
      headerAnimationLoop: false,
      dialogType: DialogType.noHeader,
      showCloseIcon: true,
      closeIcon: const Icon(Icons.close, size: 20, color: Colors.black),
      body: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: 350,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 2),
              child: Text(
                'Deficiency',
                style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Arial',
                    fontWeight: FontWeight.bold,
                    color: Colors.red),
              ),
            ),
            Expanded(
              child: defHist.isEmpty
                  ? const Center(
                      child: Text('No deficiency history available.'))
                  : SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Table(
                        columnWidths: const {
                          0: FixedColumnWidth(55),
                          1: FlexColumnWidth(),
                          2: FixedColumnWidth(70),
                        },
                        border:
                            TableBorder.all(color: Color(0xFFFCB131), width: 2),
                        children: [
                          const TableRow(children: [
                            Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Center(
                                  child: Text('Code',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red))),
                            ),
                            Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Center(
                                  child: Text('Deficiencies',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red))),
                            ),
                            Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Center(
                                  child: Text('Rectified',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red))),
                            ),
                          ]),
                          ...defHist.map((entry) => TableRow(children: [
                                Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Center(child: Text(entry[0]))),
                                Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Center(child: Text(entry[1]))),
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Center(
                                    child: entry[2] == 'YES'
                                        ? const Icon(Icons.check,
                                            color: Colors.green)
                                        : const Icon(Icons.clear,
                                            color: Colors.red),
                                  ),
                                ),
                              ])),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    ).show();
  }

  void showCustomDialogdet(BuildContext context, List<dynamic> defHist2) {
    AwesomeDialog(
      context: context,
      headerAnimationLoop: false,
      dialogType: DialogType.noHeader,
      showCloseIcon: true,
      closeIcon: const Icon(Icons.close, size: 20, color: Colors.black),
      body: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: 350,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 2),
              child: Text(
                'Detainable Deficiencies',
                style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Arial',
                    fontWeight: FontWeight.bold,
                    color: Colors.red),
              ),
            ),
            Expanded(
              child: defHist2.isEmpty
                  ? const Center(
                      child: Text('No deficiency history available.'))
                  : SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Table(
                        columnWidths: const {
                          0: FixedColumnWidth(55),
                          1: FlexColumnWidth(),
                          2: FixedColumnWidth(70),
                        },
                        border:
                            TableBorder.all(color: Color(0xFFFCB131), width: 2),
                        children: [
                          const TableRow(children: [
                            Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Center(
                                  child: Text('Code',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red))),
                            ),
                            Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Center(
                                  child: Text('Deficiencies',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red))),
                            ),
                            Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Center(
                                  child: Text('Rectified',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red))),
                            ),
                          ]),
                          ...defHist2.map((entry) => TableRow(children: [
                                Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Center(child: Text(entry[0]))),
                                Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Center(child: Text(entry[1]))),
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Center(
                                    child: entry[2] == 'YES'
                                        ? const Icon(Icons.check,
                                            color: Colors.green)
                                        : const Icon(Icons.clear,
                                            color: Colors.red),
                                  ),
                                ),
                              ])),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    ).show();
  }

  void showCustomDialogcert(BuildContext context, List<dynamic> defHist1) {
    AwesomeDialog(
      context: context,
      headerAnimationLoop: false,
      dialogType: DialogType.noHeader,
      showCloseIcon: true,
      closeIcon: const Icon(Icons.close, size: 20, color: Colors.black),
      body: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: 350,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 2),
              child: Text(
                'Certificates',
                style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Arial',
                    fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: defHist1.isEmpty
                  ? const Center(child: Text('No Certificates available.'))
                  : SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Table(
                        columnWidths: const {
                          0: FixedColumnWidth(120),
                          1: FlexColumnWidth(),
                        },
                        border:
                            TableBorder.all(color: Color(0xFFFCB131), width: 2),
                        children: [
                          const TableRow(children: [
                            Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Center(
                                  child: Text('Certificate Code',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red))),
                            ),
                            Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Center(
                                  child: Text('Certificate Name',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red))),
                            ),
                          ]),
                          ...defHist1.map((entry) => TableRow(children: [
                                Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Center(child: Text(entry[0]))),
                                Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Center(child: Text(entry[1]))),
                              ])),
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
                      'Ship Inspection Search',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Arial',
                        color: AppColors.themeblue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
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
                    const SizedBox(height: 16.0),

                    // Wrap SingleChildScrollView with Expanded
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            if (shipData != null)
                              ShipDetailsCard(shipData: shipData),
                            if (shipData != null) _buildShipDetailsCard2(),
                            if (shipData != null) _buildShipDetailsCard3(),
                            if (subInspHistData6.isNotEmpty)
                              _buildShipDetailsCard4(),
                            if (subInspHistData5.isNotEmpty)
                              _buildShipDetailsCard5(),
                            if (subInspHistData4.isNotEmpty)
                              _buildShipDetailsCard6(),
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

  Widget _buildShipDetailsCard2() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            color: const Color(0xFFFCB131),
            padding: const EdgeInsets.symmetric(vertical: 1), // Better spacing
            child: const Text(
              'Inspection Details',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                fontFamily: 'Arial',
              ),
            ),
          ),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailTileonpage(
                          'Authority', shipData?['psco_flag_code'] ?? ''),
                      _buildFlagImage(shipData?['psco_flag_image']),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailTileonpage2(
                          'Place', shipData?['port_code'] ?? ''),
                      _buildDetailTileonpage(
                          'Date', shipData?['date_inspection'] ?? ''),
                      _buildDetailTileonpage(
                          'Type', shipData?['insp_type'] ?? ''),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShipDetailsCard3() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            color: const Color(0xFFFCB131),
            padding: const EdgeInsets.symmetric(vertical: 1), // Better spacing
            child: const Text(
              'Detention Details',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                fontFamily: 'Arial',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailTileonpagenew(
                  'Ship Detained',
                  shipData?['detained_yn'] ?? '',
                  (shipData?['detained_yn'] == 'Yes')
                      ? Colors.red
                      : Colors.green,
                ),
                if (shipData?['detained_yn'] == 'Yes') ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildDetailTileonpage(
                          'DOD', shipData?['date_inspection'] ?? ''),
                      _buildDetailTileonpage(
                          'DOR', shipData?['date_release'] ?? ''),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildDetailTileonpagenew(
                        'RO Responsible',
                        shipData?['ro_resresult'] ?? '',
                        (shipData?['ro_resresult'] == 'YES')
                            ? Colors.red
                            : Colors.green,
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 10),
                if (subInspHistData.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    color: const Color(0xFFFCB131),
                    padding: const EdgeInsets.symmetric(
                        vertical: 1), // Better spacing
                    child: const Text(
                      'Detention History',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        fontFamily: 'Arial',
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  Table(
                    border: TableBorder.all(color: Colors.orange),
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      const TableRow(
                        children: [
                          TableCell(
                            child: Center(
                              child: Text(
                                'Detention Date',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'Arial',
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          TableCell(
                            child: Center(
                              child: Text(
                                'Release Date',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'Arial',
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          TableCell(
                            child: Center(
                              child: Text(
                                'RO Responsible',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'Arial',
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                      for (final detentionData in subInspHistData)
                        TableRow(
                          children: [
                            TableCell(
                              child: Center(
                                child: Text(
                                  detentionData['det_date'],
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'Arial',
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Center(
                                child: Text(
                                  detentionData['rel_date'],
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'Arial',
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Center(
                                child: GestureDetector(
                                  child: Text(
                                    detentionData['ro_resresult'] == 'YES'
                                        ? 'Yes'
                                        : 'No',
                                    style: TextStyle(
                                      color:
                                          detentionData['ro_resresult'] == 'YES'
                                              ? Colors.red
                                              : Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      fontFamily: 'Arial',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShipDetailsCard4() {
    var defHistList11 = [];

    for (var subInspEntry1 in subInspHistData6) {
      if (subInspEntry1 is Map) {
        // Convert the JSON object to a list (assuming a specific order of values)
        List<dynamic> entryList1 = [
          subInspEntry1['cert_code'],
          subInspEntry1['cert_name'],
        ];
        defHistList11.add(entryList1);
      }
    }
    defHist1 = defHistList11;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Yellow Background Strip for "Certificate Details"
          Container(
            width: double.infinity,
            color: const Color(0xFFFCB131),
            padding: const EdgeInsets.symmetric(vertical: 1),
            child: const Text(
              'Certificate Details',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                fontFamily: 'Arial',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                if (subInspHistData6.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      showCustomDialogcert(context, defHist1);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (shipData != null)
                          _buildDetailTileonpage('No. of Certificates',
                              shipData?['cert_count'].toString() ?? ''),
                      ],
                    ),
                  ),
                if (subInspHistData6.isEmpty)
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Text("No Certificates available")],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Card _buildShipDetailsCard5() {
    List<Widget> cards = [];

    // Null safety handling
    final int defCount = (shipData?['def_count'] ?? 0) as int;
    final int outsDef = (shipData?['outs_def'] ?? 0) as int;
    final int rectifiedDef = defCount - outsDef;

    var defHistList1 = [];

    for (var subInspEntry in subInspHistData5) {
      if (subInspEntry is Map) {
        defHistList1.add([
          subInspEntry['def_code'],
          subInspEntry['def_name'],
          subInspEntry['rectified'],
          subInspEntry['detColour']
        ]);
      }
    }
    defHist = defHistList1;

    // Section: Deficiency Details Title

    // Section: Deficiencies Count & Rectified/Outstanding Deficiencies
    if (subInspHistData5.isNotEmpty) {
      cards.add(
        InkWell(
          onTap: () {
            print("Card tapped");

            showCustomDialog(context, defHist);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Deficiencies(${defCount.toString()}): ',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontFamily: 'Arial',
                      ),
                    ),
                    TextSpan(
                      text: 'Rectified(${rectifiedDef.toString()})',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontSize: 12,
                        fontFamily: 'Arial',
                      ),
                    ),
                    TextSpan(
                      text: ', Outstanding(${outsDef.toString()})',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        fontSize: 12,
                        fontFamily: 'Arial',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      cards.add(const Text("No Deficiencies available"));
    }

    // Section: Detainable Deficiencies
    var defHistList2 = [];

    for (var subInspEntry2 in subInspHistData3) {
      if (subInspEntry2 is Map) {
        defHistList2.add([
          subInspEntry2['def_code'],
          subInspEntry2['def_name'],
          subInspEntry2['rectified'],
          subInspEntry2['detColour']
        ]);
      }
    }
    defHist2 = defHistList2;

    if (subInspHistData3.isNotEmpty) {
      cards.add(
        GestureDetector(
          onTap: () {
            showCustomDialogdet(context, defHist2);
          },
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: 'Detainable Deficiencies: ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontFamily: 'Arial',
                    ),
                  ),
                  TextSpan(
                    text: '(${subInspHistData3.length.toString()})',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      fontFamily: 'Arial',
                      color:
                          subInspHistData3.isEmpty ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

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
          // Header outside padding
          Container(
            width: double.infinity,
            color: const Color(0xFFFCB131),
            padding: const EdgeInsets.symmetric(vertical: 1),
            child: const Text(
              'Deficiency Details',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                fontFamily: 'Arial',
              ),
            ),
          ),
          // Content inside padding
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: cards,
            ),
          ),
        ],
      ),
    );
  }

  Card _buildShipDetailsCard6() {
    List<Widget> rows = [];
    List<Widget> currentRow = [];
    List<Widget> cards = [];

    cards.add(
      Container(
        width: double.infinity,
        color: const Color(0xFFFCB131),
        padding: const EdgeInsets.symmetric(vertical: 1),
        child: const Text(
          'Other Inspections',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            fontFamily: 'Arial',
          ),
        ),
      ),
    );
    for (var d in subInspHistData4) {
      currentRow.add(Flexible(
        child: GestureDetector(
            onTap: () {
              fetchShipDetails('${d['insp_no']}');
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '${d['insp_date']} (${d['insp_type']})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                  fontSize: 12,
                  fontFamily: 'Arial',
                ),
              ),
            )),
      ));

      // Check if three records have been added to the current row
      if (currentRow.length == 3) {
        rows.add(Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: currentRow,
        ));
        currentRow = [];
      }
    }

    // If there are any remaining records, add them to the last row
    if (currentRow.isNotEmpty) {
      rows.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: currentRow,
      ));
    }

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
      child: Column(
        children: [
          ...cards,
          ...rows
        ], // Combine cards and rows in a single Column
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

  Widget _buildDetailTileonpage(String label, String? value,
      {bool isRed = false, bool isGreen = false}) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 12),
        ),
        Text(
          value ?? '',
          style: TextStyle(
            fontSize: 12,
            fontFamily: 'Arial',
            fontWeight: FontWeight.bold,
            color: isRed ? Colors.red : (isGreen ? Colors.green : Colors.black),
          ),
          textAlign: TextAlign.left, // Set text alignment to left
        ),
      ],
    );
  }

  Widget _buildDetailTileonpagenew(String title, String value, Color color) {
    return Row(
      children: [
        Text(
          title + ': ',
          style: const TextStyle(fontSize: 12),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
            fontFamily: 'Arial',
          ),
        ),
      ],
    );
  }

  Widget _buildDetailTileonpage2(String label, String? value,
      {bool isRed = false, bool isGreen = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 12),
        ),
        Flexible(
          child: Text(
            value ?? '',
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'Arial',
              fontWeight: FontWeight.bold,
              color:
                  isRed ? Colors.red : (isGreen ? Colors.green : Colors.black),
            ),
            textAlign: TextAlign.left, // Set text alignment to left
            overflow: TextOverflow.visible, // Ensure text wraps
          ),
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
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailTitlered(String label) {
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
