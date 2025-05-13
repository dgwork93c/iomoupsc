import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iomoupsc/custom_color.dart';
import 'package:iomoupsc/login.dart';
import 'package:iomoupsc/onemainpage.dart';
import 'package:iomoupsc/onemainpage2.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

class BannedShipsPDF extends StatefulWidget {
  final String userId;

  const BannedShipsPDF({super.key, required this.userId});
  @override
  _BannedShipsPDFState createState() => _BannedShipsPDFState();
}

class _BannedShipsPDFState extends State<BannedShipsPDF> {
  bool isLoading = false;
  List<Map<String, String>> bannedShips = [];
  String? pdfPath;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await fetchBannedShips();
      await generateAndSavePdf(); // Generate & save PDF automatically
    });
  }

  Future<void> fetchBannedShips() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(
          'https://iomou.azurewebsites.net/flutter_connect/banned_ship_api.php'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData =
            jsonDecode(response.body)['banned_ships'];

        setState(() {
          bannedShips =
              jsonData.map((e) => Map<String, String>.from(e)).toList();
        });

        print("Banned Ships Data: $bannedShips"); // Debugging log
      } else {
        print("Failed to fetch data. Status code: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to fetch ship data")),
        );
      }
    } catch (e) {
      print("Error fetching data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> generateAndSavePdf() async {
    final pdf = pw.Document();

    // Grouping by banned source
    final groupedBySource = <String, List<Map<String, String>>>{};
    for (var ship in bannedShips) {
      final source = ship['banned_source'] ?? 'Unknown';
      if (!groupedBySource.containsKey(source)) {
        groupedBySource[source] = [];
      }
      groupedBySource[source]!.add(ship);
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          List<pw.Widget> content = [];

          // Table headers added only once before groups
          content.add(
            pw.Table.fromTextArray(
              headers: [
                'Sr.No.',
                'Ship Name',
                'IMO No.',
                'Period of Ban',
                'Reason',
              ],
              data: [],
              columnWidths: {
                0: pw.FixedColumnWidth(70), // Sr. No.
                1: pw.FixedColumnWidth(120), // Ship Name
                2: pw.FixedColumnWidth(80), // IMO No.
                3: pw.FixedColumnWidth(100), // Period of Ban
                4: pw.FixedColumnWidth(200), // Reason
              },
              border: pw.TableBorder.all(width: 1, color: PdfColors.black),
              cellAlignment: pw.Alignment.centerLeft,
              headerStyle:
                  pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
              headerDecoration: pw.BoxDecoration(
                color: PdfColor.fromInt(
                    0xFFFCB131), // Custom yellow background color
              ),
              rowDecoration: pw.BoxDecoration(
                color: PdfColors.white, // White background color for data rows
              ),
            ),
          );

          groupedBySource.forEach((source, ships) {
            // Add source as a row spanning all columns
            content.add(
              pw.Table(
                border: pw.TableBorder.all(width: 1, color: PdfColors.black),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.only(
                            left: 8), // Add right margin of 3
                        child: pw.Expanded(
                          child: pw.Text(
                            source, // Banned Source Title
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 14,
                            ),
                            textAlign: pw.TextAlign.left,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );

            // Add table rows for ship data under the source group
            int index = 1;
            for (var ship in ships) {
              String periodOfBan =
                  ship["banned_date"] != null && ship["banned_end_date"] != null
                      ? '${ship["banned_date"]} to ${ship["banned_end_date"]}'
                      : 'N/A';

              content.add(
                pw.Table.fromTextArray(
                  headers: [],
                  data: [
                    [
                      (index++).toString(),
                      ship["ship_name"] ?? 'N/A',
                      ship["imo_no"] ?? 'N/A',
                      periodOfBan,
                      ship["banned_reason"] ?? 'N/A',
                    ]
                  ],
                  columnWidths: {
                    0: pw.FixedColumnWidth(70), // Sr. No.
                    1: pw.FixedColumnWidth(120), // Ship Name
                    2: pw.FixedColumnWidth(80), // IMO No.
                    3: pw.FixedColumnWidth(100), // Period of Ban
                    4: pw.FixedColumnWidth(200), // Reason
                  },
                  border: pw.TableBorder.all(width: 1, color: PdfColors.black),
                  cellAlignment: pw.Alignment.centerLeft,
                ),
              );
            }
          });
          return content;
        },
      ),
    );

    // Save PDF to file
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/banned_ships_report.pdf");
    await file.writeAsBytes(await pdf.save());

    setState(() {
      pdfPath = file.path;
    });

    print("PDF saved at: $pdfPath"); // Debugging
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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : pdfPath == null
              ? Center(child: Text("Loading PDF..."))
              : Column(
                  children: [
                    Expanded(
                      child: PDFView(
                        filePath: pdfPath,
                        enableSwipe: true,
                        swipeHorizontal: false,
                        autoSpacing: false, // Try setting this to false
                        pageFling: false,
                        fitEachPage: true,
                        onRender: (pages) {
                          print("PDF Rendered: $pages pages");
                        },
                        onError: (error) {
                          print("PDF Error: $error");
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error opening PDF")),
                          );
                        },
                        onPageError: (page, error) {
                          print("Error on page $page: $error");
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: BannedShipsPDF(
      userId: '',
    ),
  ));
}
