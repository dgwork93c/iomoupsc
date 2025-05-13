import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:iomoupsc/custom_color.dart';
import 'package:iomoupsc/login.dart';
import 'package:iomoupsc/onemainpage.dart';
import 'package:iomoupsc/onemainpage2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'reusablecards.dart';

class underpership extends StatefulWidget {
  final String userId;

  const underpership({super.key, required this.userId});

  @override
  State<underpership> createState() => _underpershipState();
}

class _underpershipState extends State<underpership> {
  final String serverPath = "https://iomou.azurewebsites.net/flutter_connect/";
  List<Map<String, String>> _dropdownItems = [];
  String? _selectedItem;
  String? _selectedInsp;

  bool isLoading = false;
  Map<String, dynamic>? shipData;
  List<dynamic> subInspHistData = [];
  List<dynamic> peoples1 = [];
  List<dynamic> subInspHistData1 = [];
  List<dynamic> inspHistInitData = [];
  List<dynamic> defHist = [];
  List<dynamic> defHist1 = [];
  bool hideCard = true;
  var v1;

  @override
  void initState() {
    super.initState();
    getUnderperformingShipList();
  }

  void logout() async {
    await clearSessionData();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const Login(title: ''),
      ),
      (route) => false,
    );
  }

  Future<void> clearSessionData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  void getUnderperformingShipList() async {
    final response = await http.get(
      Uri.parse(
          'https://iomou.azurewebsites.net/flutter_connect/get_imo_name_up.php'),
    );

    if (response.statusCode == 200) {
      final List<Map<String, String>> apiResponse =
          parseResponse(response.body);
      setState(() {
        _dropdownItems = apiResponse;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch keyword list')),
      );
    }
  }

  List<Map<String, String>> parseResponse(String responseBody) {
    final decodedData = json.decode(responseBody) as Map<String, dynamic>;
    final results = decodedData['result'] as List<dynamic>;

    return results.map((item) {
      return {
        'imo': item['imo'].toString(),
        'name': item['name'].toString(),
        'insp': item['insp'].toString(),
      };
    }).toList();
  }

  Future<void> fetchdata(String insp) async {
    try {
      final response = await http.get(Uri.parse(
          'https://iomou.azurewebsites.net/flutter_connect/get_underperform_details.php?insp_no=$insp'));

      if (response.statusCode == 200) {
        print(response.body);

        final jsonData = jsonDecode(response.body);

        if (mounted) {
          setState(() {
            // Extract the first element of the 'info' array or set to null if empty
            shipData = jsonData['info'] != null && jsonData['info'].isNotEmpty
                ? jsonData['info'][0]
                : null;

            // Extract the 'det_hist' array or set to an empty list
            subInspHistData1 = jsonData['det_hist'] ?? [];

            // Extract 'Def_Codes_List' from 'det_hist' and flatten the list
            defHist =
                (jsonData['det_hist'] as List<dynamic>).expand((historyItem) {
              var defCodesList = historyItem['Def_Codes_List'] ?? [];
              return defCodesList;
            }).toList();

            hideCard = false;
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch data')),
        );
      }
    } catch (error) {
      print('Error fetching data: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }

  void showDeficiencyPopup(BuildContext context, List<dynamic> defCodesList) {
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
                'Detainable Deficiency',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Arial',
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            Expanded(
              child: defCodesList.isEmpty
                  ? const Center(
                      child: Text('No deficiencies available.'),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Table(
                        columnWidths: const {
                          0: FixedColumnWidth(100), // Deficiency Code
                          1: FlexColumnWidth(), // Flexible width for Name
                        },
                        border: TableBorder.all(
                          color: Color(0xFFFCB131), // Yellow border color
                          width: 2,
                        ),
                        children: [
                          // Table Header
                          const TableRow(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(5.0),
                                child: Center(
                                  child: Text(
                                    'Deficiency Code',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(5.0),
                                child: Center(
                                  child: Text(
                                    'Deficiency Name',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Table rows
                          ...defCodesList.map((defEntry) {
                            final String defCode = defEntry['def_code'];
                            final String defName = defEntry['def_name'];

                            return TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Center(child: Text(defCode)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Center(child: Text(defName)),
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

  void showROPopup(BuildContext context, List<dynamic> rohistvar) {
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
                'RO Responsible',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Arial',
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            Expanded(
              child: rohistvar.isEmpty
                  ? const Center(
                      child: Text('No RO Responsible available.'),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Table(
                        columnWidths: const {
                          0: FixedColumnWidth(100), // RO Code
                          1: FlexColumnWidth(), // Flexible width for Name
                        },
                        border: TableBorder.all(
                          color: Color(0xFFFCB131), // Yellow border color
                          width: 2,
                        ),
                        children: [
                          // Table Header
                          const TableRow(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(5.0),
                                child: Center(
                                  child: Text(
                                    'RO Code',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(5.0),
                                child: Center(
                                  child: Text(
                                    'RO Name',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Table rows
                          ...rohistvar.map((defEntry) {
                            final String defCode = defEntry['ro_soc_code'];
                            final String defName = defEntry['ro_soc_name'];

                            return TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Center(child: Text(defCode)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Center(child: Text(defName)),
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
            // Main r
            Container(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const Text(
                      "Underperforming Ships",
                      style: TextStyle(
                          color: AppColors.themeblue,
                          fontSize: 14,
                          fontFamily: 'Arial',
                          fontWeight: FontWeight.bold),
                    ),
                    const Center(
                      child: Text(
                        "[Criteria: No. of Detentions >= 3 during last 24 months]",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                          fontFamily: 'Arial',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      children: [
                        if (_dropdownItems.isNotEmpty)
                          const Text(
                            "Select Ship: ",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              fontFamily: 'Arial',
                            ),
                          ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: _dropdownItems.isEmpty
                              ? const Center(
                                  child: Text(
                                    "No Under Performing Ships Found",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 14,
                                      fontFamily: 'Arial',
                                    ),
                                  ),
                                )
                              : DropdownButton<String>(
                                  isExpanded: true,
                                  value: _selectedItem,
                                  hint: const Text('Select ship'),
                                  items: _dropdownItems.map((item) {
                                    return DropdownMenuItem<String>(
                                      value: item['imo'],
                                      child: Text(
                                          '(${item['imo']}) ${item['name']}'),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedItem = newValue;
                                      _selectedInsp = _dropdownItems.firstWhere(
                                          (item) =>
                                              item['imo'] == newValue)['insp'];
                                      fetchdata(_selectedInsp!);
                                    });
                                  },
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    // Scrollable section
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            if (shipData != null)
                              ShipDetailsCard(shipData: shipData),
                            _buildInspectionCards(),
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

  Widget _buildInspectionCards() {
    if (subInspHistData1.isEmpty) return const SizedBox.shrink();
    int i = 1; // Initialize the counter

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
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: subInspHistData1.map<Widget>((data) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Add row number
                      _buildDetailTileRiskDetail('Detention', (i++).toString()),
                      _buildDetailTiledet('Date of Inspection/Detention',
                          data['det_date'] ?? 'N/A'),
                      _buildDetailTiledet(
                          'Date of Release', data['rel_date'] ?? 'N/A'),
                      _buildDetailTiledet(
                          'Place of Inspection', data['place'] ?? 'N/A'),
                      _buildDetailTiledet(
                          'IMO Company',
                          '(' +
                              data['comp_no'] +
                              ')' +
                              (data['ship_owner'] ?? 'N/A')),
                      _buildDetailTiledet('RO', data['RO'] ?? 'N/A'),

                      // Display Def_Codes (clickable)
                      GestureDetector(
                        onTap: () {
                          // Show the custom dialog with the filtered Def_Codes_List
                          final peoplesDefCodesList = data['Def_Codes_List'];
                          if (peoplesDefCodesList != null &&
                              peoplesDefCodesList.isNotEmpty) {
                            showDeficiencyPopup(context, peoplesDefCodesList);
                          }
                        },
                        child: _buildDetailTiledefcodes(
                            'Deficiency Codes', data['Def_Codes'] ?? 'N/A'),
                      ),

                      GestureDetector(
                        onTap: () {
                          // Show the custom dialog with the filtered RO history
                          final rohistvar = data['ro_hist'];
                          if (rohistvar != null && rohistvar.isNotEmpty) {
                            showROPopup(context, rohistvar);
                          }
                        },
                        child: _buildDetailTiledetro(
                          'RO Responsible',
                          data['ro_resresult'] ?? 'N/A', // First parameter
                          (data['get_ro_string'] != null &&
                                  data['get_ro_string']!.isNotEmpty)
                              ? '; ' +
                                  data[
                                      'get_ro_string']! // Second parameter: Add `;` and value if `get_ro_string` is not null
                              : '',
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(
                  color: Color(0xFFFCB131),
                  height: 2,
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDetailTiledetro(String label, String value, String condition) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 12),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text.rich(
            TextSpan(
              children: [
                if (value.isNotEmpty)
                  TextSpan(
                    text: '$value',
                    style: TextStyle(
                      fontSize: 12, fontFamily: 'Arial',
                      fontWeight: FontWeight.bold,
                      color: value.toLowerCase() == 'yes'
                          ? Colors.red // Red for "yes"
                          : (value.toLowerCase() == 'no'
                              ? Colors.green // Green for "no"
                              : Colors
                                  .black), // Default to black for any other value
                    ),
                  ),

                // Show `condition` only if it has a value
                TextSpan(
                  text: ' $condition',
                  style: TextStyle(
                    fontSize: 14, fontFamily: 'Arial',
                    fontWeight: FontWeight.bold,
                    // Default to black
                  ),
                ),
              ],
            ),
            softWrap: true,
            overflow: TextOverflow.clip,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailTiledet(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 12),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'Arial',
              fontWeight: FontWeight.bold,
              color: value.toLowerCase() == 'yes'
                  ? Colors.red
                  : (value.toLowerCase() == 'no' ? Colors.green : Colors.black),
            ),
            softWrap: true,
            overflow: TextOverflow.clip,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailTiledefcodes(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 12),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
                fontSize: 12,
                fontFamily: 'Arial',
                fontWeight: FontWeight.bold,
                color: Colors.red),
            softWrap: true,
            overflow: TextOverflow.clip,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailTileRiskDetail(String label, String? value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
              fontSize: 12,
              fontFamily: 'Arial',
              color: Colors.red,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            value ?? '',
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'Arial',
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
            softWrap: true,
            overflow: TextOverflow.clip,
          ),
        ),
      ],
    );
  }
}
