import 'package:iomoupsc/custom_color.dart';
import 'package:iomoupsc/loader.dart';
import 'package:flutter/material.dart';
import 'package:iomoupsc/onemainpage.dart';
import 'package:iomoupsc/onemainpage2.dart';
import 'package:iomoupsc/reusablecards.dart';
import 'knowshipmain.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class shipwithoutreldate extends StatefulWidget {
  // const shipwithoutreldate({super.key, required userId});
  final String userId;

  const shipwithoutreldate({super.key, required this.userId});

  @override
  State<shipwithoutreldate> createState() => _shipwithoutreldateState();
}

class _shipwithoutreldateState extends State<shipwithoutreldate> {
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
  List<Category> _kOptions = [];
  Category? _selectedCategory;

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
          await http.get(Uri.parse('$serverPath/ship_without_rel_date.php'));

      if (response.statusCode == 200) {
        print(response.body);
        final parsedData = jsonDecode(response.body);
        final List result = parsedData['result'];

        final List<Category> categories = result
            .map((item) => Category.fromJson(item as Map<String, dynamic>))
            .toList();

        setState(() {
          _kOptions = categories;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch data')),
        );
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });

      print('Error fetching data: $error');
    }
  }

  Future<void> fetchShipDetails(String inspNo) async {
    _isLoading = true;
    try {
      final response = await http.get(Uri.parse(
          '$serverPath/ship_without_rel_date_details.php?insp_no=$inspNo'));

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

  void showCustomDialog(BuildContext context, List<dynamic> defHist) {
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
        width: MediaQuery.of(context).size.width * 0.9, // 90% of screen width
        height: 350, // Fixed height
        child: Column(
          children: [
            // Title
            const Padding(
              padding: EdgeInsets.only(bottom: 2),
              child: Text(
                'Deficiency',
                style: TextStyle(
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
                      scrollDirection: Axis.vertical,
                      child: Table(
                        columnWidths: const {
                          0: FixedColumnWidth(55), // Width for 'Code' column
                          1: FlexColumnWidth(), // Flexible width for 'Deficiencies'
                          2: FixedColumnWidth(
                              75), // Width for 'Rectified' column
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
                                padding: EdgeInsets.all(5.0),
                                child: Text(
                                  'Code',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Deficiencies',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(5.0),
                                child: Text(
                                  'Rectified',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          // Table rows
                          ...defHist.map((defEntry) {
                            final String defCode = defEntry[0];
                            final String defName = defEntry[1];
                            final String rectified = defEntry[2];

                            return TableRow(
                              children: [
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

  void showCustomDialogdet(BuildContext context, List<dynamic> defHist2) {
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
        width:
            MediaQuery.of(context).size.width * 0.9, // Match showCustomDialog
        height: 350, // Fixed height
        child: Column(
          children: [
            // Title
            const Padding(
              padding: EdgeInsets.only(bottom: 2),
              child: Text(
                'Detainable Deficiencies',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Arial',
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
            Expanded(
              child: defHist2.isEmpty
                  ? const Center(
                      child: Text('No deficiency history available.'),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Table(
                        columnWidths: const {
                          0: FixedColumnWidth(55), // Width for 'Code' column
                          1: FlexColumnWidth(), // Flexible width for 'Deficiencies'
                          2: FixedColumnWidth(
                              75), // Width for 'Rectified' column
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
                                padding: EdgeInsets.all(5.0),
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
                                padding: EdgeInsets.all(5.0),
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
                          // Table rows
                          ...defHist2.map((defEntry) {
                            final String defCode = defEntry[0];
                            final String defName = defEntry[1];
                            final String rectified = defEntry[2];

                            return TableRow(
                              children: [
                                SizedBox(
                                  width: 55,
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Text(
                                      defCode,
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      defName,
                                      style: const TextStyle(color: Colors.red),
                                    ),
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
                    const Center(
                      child: Text(
                        'Detained Ships Without Release Date',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Arial',
                          color: AppColors.themeblue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    DropdownButtonFormField<Category>(
                      decoration: const InputDecoration(
                        labelText: 'Select Ship',
                        border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xFFFCB131), width: 2.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xFFFCB131), width: 2.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xFFFCB131), width: 2.0),
                        ),
                      ),
                      value: _selectedCategory,
                      hint: const Text('Select Ship'),
                      isExpanded: true,
                      menuMaxHeight: 300,
                      items: _kOptions.map((Category category) {
                        return DropdownMenuItem<Category>(
                          value: category,
                          child: Text('${category.name} (${category.imo})'),
                        );
                      }).toList(),
                      onChanged: (Category? newValue) {
                        setState(() {
                          _selectedCategory = newValue;
                        });
                        if (newValue != null) {
                          debugPrint('You just selected ${newValue.name}');
                          fetchShipDetails(newValue.insp);
                        }
                      },
                    ),
                    const SizedBox(height: 16.0),

                    // Wrap SingleChildScrollView with Expanded
                    if (_isLoading)
                      Container(
                        color: Colors.black.withOpacity(0.5),
                        child: const Center(
                          child: HMLoader(),
                        ),
                      ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            if (shipData != null)
                              ShipDetailsCard(shipData: shipData),
                            if (shipData != null) _buildShipDetailsCard2(),
                            if (shipData != null) _buildShipDetailsCard3(),
                            if (subInspHistData5.isNotEmpty)
                              _buildShipDetailsCard5(),
                            if (subInspHistData4.isNotEmpty)
                              _buildShipDetailsCard6(),
                          ],
                        ),
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
                const SizedBox(height: 10),
                _buildDetailTileonpagenew(
                  'Ship Detained',
                  shipData?['detained_yn'] ?? '',
                  (shipData?['detained_yn'] == 'Yes')
                      ? Colors.red
                      : Colors.green,
                ),
                if (shipData?['detained_yn'] == 'Yes') ...[
                  const SizedBox(height: 10),
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
                      _buildDetailTileonpage(
                          'RO Responsible', shipData?['ro_resresult'] ?? ''),
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
        GestureDetector(
          onTap: () {
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
