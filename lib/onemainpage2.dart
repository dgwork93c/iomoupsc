import 'dart:convert';

import 'package:iomoupsc/banned_ship.dart';
import 'package:iomoupsc/custom_color.dart';
import 'package:iomoupsc/defcon.dart';
import 'package:iomoupsc/inspdata.dart';
import 'package:iomoupsc/iocm_docs.dart';
import 'package:iomoupsc/loader.dart';
import 'package:iomoupsc/login.dart';
import 'package:iomoupsc/onemainpage.dart';
import 'package:iomoupsc/oustandingdef.dart';
import 'package:iomoupsc/psc_insp_codes.dart';
import 'package:iomoupsc/searchothermou.dart';
import 'package:iomoupsc/ship_without_rel_date.dart';
import 'package:iomoupsc/shipdefhist.dart';
import 'package:iomoupsc/shipdethist.dart';
import 'package:iomoupsc/srp.dart';
import 'package:iomoupsc/underpership.dart';
import 'package:iomoupsc/watchlist.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'about.dart';
import 'knowshipmain.dart';
import 'manualsearch.dart';
import 'package:http/http.dart' as http;
import 'shipdb.dart';

class IconMain2 extends StatefulWidget {
  final String userId;

  const IconMain2({super.key, required this.userId});

  @override
  State<IconMain2> createState() => _IconMain2State();
}

class _IconMain2State extends State<IconMain2> {
  final String serverPath =
      "https://iomou.azurewebsites.net/flutter_connect"; // Replace with your server path

  bool isLoading = false;
  bool _isLoading = true;
// Responsive text sizing - now more granular for better scaling
  TextStyle _getResponsiveTextStyle(BuildContext context,
      {bool isTitle = false, bool isHeader = false}) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;

    // Using both width and height for better responsiveness
    final size = (screenWidth + screenHeight) / 2;

    double fontSize;
    if (isTitle) {
      fontSize = size < 600
          ? 13
          : size < 900
              ? 16
              : 20;
    } else if (isHeader) {
      fontSize = size < 600
          ? 14
          : size < 900
              ? 16
              : 18;
    } else {
      // Normal text (for icons)
      fontSize = size < 600
          ? 8
          : size < 900
              ? 10
              : 12;
    }
    print(size);
    return TextStyle(
      fontSize: fontSize,
      fontFamily: 'Arial',
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );
  }

  double _getIconSize(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;

    // Calculate size based on both dimensions for better adaptability
    return (screenWidth + screenHeight) / 70;
  }

  @override
  void initState() {
    super.initState();
    insertData();
    _isLoading = true;
  }

  void showLoginErrorPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        // Show the error message dialog
        AlertDialog errorDialog = const AlertDialog(
          content: Text('Access Restricted.'),
        );

        // Dismiss the dialog after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.of(context).pop();
        });

        return errorDialog;
      },
    );
  }

  Future<void> insertData() async {
    setState(() {
      _isLoading = true; // Show loading indicator while inserting data
    });

    try {
      // Step 1: Fetch SQLite row count
      final shipDatabase = ShipDatabase();
      final int localRowCount = await shipDatabase.getRowCount();
      print('Local row count: $localRowCount');

      // Step 2: Fetch data from the server
      final response = await http.get(
        Uri.parse('$serverPath/get_imo_name.php?identity=true'),
      );

      if (response.statusCode == 200) {
        print('Response Body: ${response.body}');
        final Map<String, dynamic> parsedData = jsonDecode(response.body);

        if (parsedData.containsKey('result')) {
          final List<dynamic> ships = parsedData['result'];
          final int serverRowCount = ships.length;
          print('Server row count: $serverRowCount');

          // Step 3: Compare row counts
          if (localRowCount == serverRowCount) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Data is already up to date')),
            );
            return; // Skip further processing
          }

          // Step 4: Clear existing data in SQLite
          await shipDatabase.clearAllData();

          // Step 5: Insert new data
          for (var shipData in ships) {
            Map<String, dynamic> ship = {
              'imo': shipData['imo'], // Ensure correct key mapping
              'name': shipData['name'],
              'insp': shipData['insp'],
            };
            await shipDatabase.insertShip(ship);
          }

          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data inserted successfully')),
          );
        } else {
          // Handle case where 'result' key is missing
          _handleError('No ships data available');
        }
      } else {
        // Handle non-200 status codes
        _handleError('Failed to fetch data');
      }
    } catch (error) {
      // Handle exceptions
      _handleError('Error fetching data: $error');
    }
  }

  /// Handles errors by updating the UI and showing a SnackBar
  void _handleError(String message) {
    setState(() {
      _isLoading = false;
    });
    print(message);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
    // Get device dimensions for responsive sizing
    final double iconSize = _getIconSize(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.themeblue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.white,
          iconSize: iconSize,
        ),
        title: Text(
          'IOMOU - ${widget.userId}',
          style: _getResponsiveTextStyle(context, isTitle: true),
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
            iconSize: iconSize,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
            color: Colors.white,
            iconSize: iconSize,
          ),
        ],
      ),
      backgroundColor: const Color(0xFF174282),
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              // Calculate responsive padding
              final double horizontalPadding = constraints.maxWidth * 0.03;
              final double verticalPadding = constraints.maxHeight * 0.02;

              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Column(
                    children: [
                      // Logo - adaptive sizing
                      Padding(
                        padding: EdgeInsets.only(top: verticalPadding),
                        child: Center(
                          child: Image.asset(
                            'assets/images/iomou_log.png',
                            width: constraints.maxWidth * 0.3,
                            height: constraints.maxWidth * 0.3,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      // Title
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: verticalPadding),
                        child: Text(
                          'INDIAN OCEAN \n MEMORANDUM OF UNDERSTANDING',
                          style:
                              _getResponsiveTextStyle(context, isTitle: true),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      // Grid of icon groups with responsive spacing
                      _buildResponsiveIconGrid(context, constraints),
                    ],
                  ),
                ),
              );
            },
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: HMLoader(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResponsiveIconGrid(
      BuildContext context, BoxConstraints constraints) {
    // Calculate spacing based on available space
    final double verticalSpacing = constraints.maxHeight * 0.012;

    // Create all icon data
    final List<List<_IconData>> iconRows = [
      // Second row
      [
        _IconData(
          image: 'assets/images/image1.jpg',
          label: 'Ship Inspection\nSearch',
          onTap: inspd,
        ),
        _IconData(
          image: 'assets/images/image2.jpg',
          label: 'Ship Deficiency\nHistory',
          onTap: shipdefh,
        ),
        _IconData(
          image: 'assets/images/image3.jpg',
          label: 'Ship Detention\nHistory',
          onTap: shipdeth,
        ),
        _IconData(
          image: 'assets/images/image4.jpg',
          label: 'Under Performing\nShip',
          onTap: underpship,
        ),
      ],

      // Third row
      [
        _IconData(
          image: 'assets/images/image5.JPG',
          label: 'Ship On-Watch\nList',
          onTap: watchl,
        ),
        _IconData(
          image: 'assets/images/image6.JPG',
          label: 'Banned Vessels\nby Authorities',
          onTap: bannedshipcall,
        ),
        _IconData(
          image: 'assets/images/image7.jpg',
          label: 'Search in Other\nMOU',
          onTap: inspdatasearch,
        ),
        _IconData(
          image: 'assets/images/image8.jpg',
          label: 'IOMOU App',
          onTap: loader,
        ),
      ],
    ];

    // Build the grid
    return Column(
      children: iconRows.asMap().entries.map((entry) {
        // Add spacing between rows
        return Padding(
          padding: EdgeInsets.only(
              bottom: entry.key < iconRows.length - 1 ? verticalSpacing : 0),
          child: _buildIconRow(entry.value, context, constraints),
        );
      }).toList(),
    );
  }

  // Helper method to build a row of icons with responsive sizing
  Widget _buildIconRow(
      List<_IconData> icons, BuildContext context, BoxConstraints constraints) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: icons
          .map((iconData) => _buildIconItem(iconData, context, constraints))
          .toList(),
    );
  }

  // Helper method to build a single icon item with a circular UI
  Widget _buildIconItem(
      _IconData iconData, BuildContext context, BoxConstraints constraints) {
    // Calculate spacing
    final double horizontalPadding = constraints.maxWidth * 0.01;

    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: GestureDetector(
          onTap: iconData.onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Circular icon container
              ClipOval(
                child: Container(
                  width: constraints.maxWidth * 0.18, // Adjust size dynamically
                  height: constraints.maxWidth * 0.18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // border: Border.all(
                    //     color: Colors.white, width: 2), // Optional border
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.blueAccent, // Background color
                    backgroundImage: AssetImage(iconData.image),
                  ),
                ),
              ),
              // Reduced spacing between icon and label
              const SizedBox(height: 2),
              // Responsive text size
              Text(
                iconData.label,
                textAlign: TextAlign.center,
                style: _getResponsiveTextStyle(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void pscinspcode1() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => pscinspcodes(userId: widget.userId)),
    );
  }

  void knowship() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => KnowShip(userId: widget.userId)),
    );
  }

  void inspd() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => inspdatalive(userId: widget.userId)),
    );
  }

  void shipdefh() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => shipdefhist(userId: widget.userId)),
    );
  }

  void shipdeth() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => shipdethist(userId: widget.userId)),
    );
  }

  void underpship() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => underpership(userId: widget.userId)),
    );
  }

  void srp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => srppage(userId: widget.userId)),
    );
  }

  void watchl() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => watch(userId: widget.userId)),
    );
  }

  void mansearch() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => PscManualApp(userId: widget.userId)),
    );
  }

  void defcon() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => DeficiencyConvention(userId: widget.userId)),
    );
  }

  void loader() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AboutApp(userId: widget.userId)),
    );
  }

  void inspdatasearch() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => Searchotherimo(userId: widget.userId)),
    );
  }

  void outdef() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => OustandingDef(userId: widget.userId)),
    );
  }

  void bannedshipcall() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => BannedShipsPDF(
                userId: widget.userId,
              )),
    );
  }

  void shipwithoutreldatecall() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => shipwithoutreldate(userId: widget.userId)),
    );
  }

  void IOCMDOCS() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => IOCMDocs(userId: widget.userId)),
    );
  }
}

// Helper class to store icon data
class _IconData {
  final String image;
  final String label;
  final VoidCallback onTap;

  _IconData({required this.image, required this.label, required this.onTap});
}
