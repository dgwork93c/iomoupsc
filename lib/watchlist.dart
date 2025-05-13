import 'package:iomoupsc/custom_color.dart';
import 'package:iomoupsc/loader.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:iomoupsc/login.dart';
import 'package:iomoupsc/onemainpage.dart';
import 'package:iomoupsc/onemainpage2.dart';
import 'package:shared_preferences/shared_preferences.dart';

class watch extends StatefulWidget {
  // const watch({super.key});
  final String userId;

  const watch({super.key, required this.userId});

  @override
  State<watch> createState() => _watchState();
}

class _watchState extends State<watch> {
  final String serverPath =
      "https://iomou.azurewebsites.net/flutter_connect"; // Replace with your server path

  List<Category> allDeficiencies = [];
  List<Category> filteredDeficiencies = [];
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
  bool _isLoading = true;
  List<Category> categoriesList = [];
  Category selectedCategory = Category(imo: '', name: '', insp: '');

  List<Category> categoriesList1 = [];
  Category selectedCategory1 = Category(imo: '', name: '', insp: '');

  @override
  void initState() {
    super.initState();
    fetchDeficiencies();
    fetchDeficiencies1();
    fetchDeficiencies2();
    hideCard = true;
    _isLoading = true;
  }

  Future<void> fetchDeficiencies() async {
    try {
      final response = await http.get(
          Uri.parse('$serverPath/get_imo_name_watchlist.php?identity=all'));

      if (response.statusCode == 200) {
        print(response.body);
        _isLoading = false;

        setState(() {});
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

  Future<void> fetchDeficiencies1() async {
    _isLoading = true;
    try {
      final response = await http.get(
          Uri.parse('$serverPath/get_imo_name_watchlist.php?identity=active'));

      if (response.statusCode == 200) {
        _isLoading = false;
        final data = jsonDecode(response.body);
        print(response.body);
        setState(() {
          if (data['result'] != null && data['result'] is List) {
            categoriesList = (data['result'] as List).map<Category>((item) {
              return Category(
                imo: item['imo'] ?? '',
                name: item['name'] ?? '',
                insp: item['insp'] ?? '',
              );
            }).toList();
            selectedCategory = categoriesList.isNotEmpty
                ? categoriesList.first
                : Category(imo: '', name: '', insp: '');
          } else {
            print('Result is null or not a List.');
            // Handle this case as needed, e.g., show an error message or set default values.
          }
        });
      } else {
        print('Failed to fetch data: ${response.statusCode}');
        // Handle the error here, e.g., show an error message.
      }
    } catch (error) {
      print('Error fetching data: $error');
      // Handle the error here, e.g., show an error message.
    }
  }

  Future<void> fetchDeficiencies2() async {
    _isLoading = true;
    try {
      final response = await http.get(Uri.parse(
          '$serverPath/get_imo_name_watchlist.php?identity=inactive'));

      if (response.statusCode == 200) {
        _isLoading = false;
        final data = jsonDecode(response.body);
        print(response.body);
        setState(() {
          if (data['result'] != null && data['result'] is List) {
            categoriesList1 = (data['result'] as List).map<Category>((item) {
              return Category(
                imo: item['imo'] ?? '',
                name: item['name'] ?? '',
                insp: item['insp'] ?? '',
              );
            }).toList();
            selectedCategory1 = categoriesList1.isNotEmpty
                ? categoriesList1.first
                : Category(imo: '', name: '', insp: '');
          } else {
            print('Result is null or not a List.');
            // Handle this case as needed, e.g., show an error message or set default values.
          }
        });
      } else {
        print('Failed to fetch data: ${response.statusCode}');
        // Handle the error here, e.g., show an error message.
      }
    } catch (error) {
      print('Error fetching data: $error');
      // Handle the error here, e.g., show an error message.
    }
  }

  Future<void> fetchdata(String insp) async {
    _isLoading = true;

    try {
      final response = await http.get(
          Uri.parse('$serverPath/get_watchlist_details.php?insp_no=$insp'));
      print(Uri.parse('$serverPath/get_watchlist_details.php?insp_no=$insp'));
      if (response.statusCode == 200) {
        _isLoading = false;
        print(response.body);
        final jsonData = jsonDecode(response.body);

        setState(() {
          shipData =
              jsonData['info']?.isNotEmpty == true ? jsonData['info'][0] : null;
          subInspHistData = jsonData['alert_hist'] ?? [];
          peoples1 = jsonData['sub_insp_hist'] ?? [];
          subInspHistData1 = jsonData['sub_insp_histF'] ?? [];
          print(subInspHistData1);
          v1 = jsonData['sub_insp_hist']?.isEmpty == true ? 1 : 0;
          inspHistInitData = jsonData['insp_hist_init'] ?? [];
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Text(
                          'Ship On-Watch List/Alert',
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Arial',
                            fontWeight: FontWeight.bold,
                            color: AppColors.themeblue,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                    height: 10,
                  ),

                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: double
                            .infinity, // Ensures both containers take the full available width
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Ship On-Watch List/Alert:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                                textAlign: TextAlign.left,
                              ),
                              DropdownButton<Category>(
                                value: selectedCategory,
                                menuMaxHeight: 300,
                                iconEnabledColor: Color(0xFFFCB131),
                                onChanged: (Category? newValue) {
                                  setState(() {
                                    selectedCategory = newValue!;
                                    fetchdata(newValue.insp);
                                  });
                                },
                                underline: Container(
                                  height: 2,
                                  color: Colors.orange,
                                ),
                                items: categoriesList.map((Category category) {
                                  return DropdownMenuItem<Category>(
                                    value: category,
                                    child: Text(
                                      '(${category.imo})${category.name}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double
                            .infinity, // Ensures both containers take the full available width
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.green, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Ship removed from Watch List/Alert (Last 2 Years):',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                                textAlign: TextAlign.left,
                              ),
                              DropdownButton<Category>(
                                menuMaxHeight: 300,
                                iconEnabledColor: Color(0xFFFCB131),
                                value: selectedCategory1,
                                onChanged: (Category? newValue) {
                                  setState(() {
                                    selectedCategory1 = newValue!;
                                    fetchdata(newValue.insp);
                                  });
                                },
                                underline: Container(
                                  height: 2,
                                  color: Colors.orange,
                                ),
                                items: categoriesList1.map((Category category) {
                                  return DropdownMenuItem<Category>(
                                    value: category,
                                    child: Text(
                                      '(${category.imo})${category.name}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
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
                          if (shipData != null) _buildShipDetailsCard(),
                          if (shipData != null) _buildInspectionCards1(),
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

  Widget _buildShipDetailsCard() {
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDetailTitle('Ship Details'),
              ],
            ),
            const SizedBox(height: 10),
            Column(
              children: [
                _buildDetailTile('Ship Name', shipData?['ship_name'] ?? ''),
                _buildDetailTile('IMO Number', shipData?['imo_no'] ?? ''),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Card _buildInspectionCards1() {
    List<Widget> cards = [];

    for (int i = 0; i < subInspHistData.length; i++) {
      cards.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Alert:${i + 1}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
              fontSize: 14,
              fontFamily: 'Arial',
            ),
          ),
        ),
      );

      cards.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              children: [
                const TextSpan(
                  text: 'Alert Date: ',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontFamily: 'Arial',
                  ),
                ),
                TextSpan(
                  text: '${subInspHistData[i]['date_alert']}',
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
      );

      cards.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              children: [
                const TextSpan(
                  text: 'Alerting Organization: ',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontFamily: 'Arial',
                  ),
                ),
                TextSpan(
                  text: '${subInspHistData[i]['alert_st_org']}',
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
      );
      cards.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              children: [
                const TextSpan(
                  text: 'Alerting Reason: ',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontFamily: 'Arial',
                  ),
                ),
                TextSpan(
                  text: '${subInspHistData[i]['alert_reason']}',
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
      );
      cards.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              children: [
                const TextSpan(
                  text: 'IOMOU Ref. No.: ',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontFamily: 'Arial',
                  ),
                ),
                TextSpan(
                  text: ' ${subInspHistData[i]['iomou_ref_no']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 12,
                    fontFamily: 'Arial',
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      cards.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              children: [
                const TextSpan(
                  text: 'Alerting Cancelled Date: ',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontFamily: 'Arial',
                  ),
                ),
                TextSpan(
                  text: ' ${subInspHistData[i]['edate']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 12,
                    fontFamily: 'Arial',
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      cards.add(const Divider(
        color: Colors.orange,
        height: 1.0,
        thickness: 2.0,
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
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Alert Details',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 14,
                fontFamily: 'Arial',
              ),
              textAlign: TextAlign.left,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: cards,
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
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 14),
        ),
        Text(
          value ?? '',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
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
              fontSize: 12, fontFamily: 'Arial', color: Colors.red),
        ),
        Text(
          value ?? '',
          style: const TextStyle(
            fontSize: 12,
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
          style: const TextStyle(fontSize: 12),
        ),
        Text(
          value.toString(), // Convert the int to a String
          style: TextStyle(
            fontSize: 12,
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
              fontSize: 12,
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
            color: Colors.black,
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
