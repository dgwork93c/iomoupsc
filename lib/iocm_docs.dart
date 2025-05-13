// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iomoupsc/custom_color.dart';
import 'package:iomoupsc/login.dart';
import 'package:iomoupsc/onemainpage.dart';
import 'package:iomoupsc/onemainpage2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path/path.dart' as path;

class IOCMDocs extends StatefulWidget {
  final String userId;

  const IOCMDocs({super.key, required this.userId});

  @override
  State<IOCMDocs> createState() => _IOCMDocsState();
}

class _IOCMDocsState extends State<IOCMDocs> {
  String? userType;
  Map<String, List<Map<String, dynamic>>> groupedDocuments = {};
  bool isLoading = true;
  bool isDownloading = true;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final String basePath = "https://iomou.azurewebsites.net/HOMEPAGE/";
  final String sign =
      "?sv=2022-11-02&ss=bfqt&srt=sco&sp=rwlacupitfx&se=2025-12-31T14:55:47Z&st=2025-01-08T06:55:47Z&spr=https&sig=SyrZoTJtgAcDqVfAW%2BN1%2FEu7UiUQ0ekhMERYfpXx8kI%3D";

  @override
  void initState() {
    super.initState();
    _loadUserType();
  }

  Future<void> _loadUserType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userType = prefs.getString('usertype');
    });
    if (userType != null) {
      _fetchDocuments();
    }
  }

  Future<void> _fetchDocuments() async {
    final String apiUrl =
        'https://iomou.azurewebsites.net/flutter_connect/iocm_docs_api.php?UserType=12';
    print(apiUrl);
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);

        if (responseBody.containsKey('data') && responseBody['data'] is List) {
          final List<dynamic> data = responseBody['data'];
          _groupDocuments(data);
        } else {
          _showError("Invalid response format");
        }
      } else {
        _showError("HTTP Error: ${response.statusCode}");
      }
    } catch (e) {
      _showError("Network Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _groupDocuments(List<dynamic> data) {
    Map<String, List<Map<String, dynamic>>> grouped = {};

    for (var item in data) {
      String meetingNo =
          item['meeting_no']?.toString() ?? 'Unknown'; // Use meeting_no as key
      if (!grouped.containsKey(meetingNo)) {
        grouped[meetingNo] = [];
      }
      grouped[meetingNo]!.add(item);
    }

    setState(() {
      groupedDocuments = grouped;
    });
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _handleFileClick(String fileName) async {
    // Extract clean file name
    String cleanedFileName = fileName.replaceAll(RegExp(r'\s+$'), '');
    String extractedFileName = path.basename(fileName);
    String filePath =
        "$basePath" + "pdf/Committee_Meetings/${cleanedFileName.trim()}";
    print(filePath);
    if (cleanedFileName.toLowerCase().endsWith('.pdf')) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFViewerScreen(
            fileUrl: filePath,
            userId: widget.userId,
          ),
        ),
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('cleanedFileName', extractedFileName);
    } else {
      await downloadFile(filePath, cleanedFileName);
    }
  }

  Future<void> downloadFile(String fileUrl, String fileName) async {
    setState(() {
      isDownloading = true;
    });
    String extractedFileName = path.basename(fileName);
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 10),
              Text(extractedFileName),
              const Text("Downloading..."),
            ],
          ),
        );
      },
    );

    // Define download path

    String downloadsPath = "/storage/emulated/0/IOMOU/$extractedFileName";
    print("Downloading from: $fileUrl");

    try {
      // Start downloading
      await Dio().download(
        fileUrl,
        downloadsPath,
        options: Options(
          headers: {"Accept": "application/octet-stream"},
        ),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            print("Progress: ${(received / total * 100).toStringAsFixed(0)}%");
          }
        },
      );

      print("File saved to: $downloadsPath");

      // Show a notification after download
      showDownloadNotification(extractedFileName, downloadsPath);
    } catch (e) {
      print("Download failed: $e");
    } finally {
      // Hide the loading dialog
      Navigator.pop(context);
      setState(() {
        isDownloading = false;
      });
    }
  }

  Future<void> showDownloadNotification(
      String fileName, String filePath) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'download_channel', // Channel ID
      'Downloads', // Channel Name
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'Download Complete',
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      'Download Complete',
      'File saved to: IOMOU/$fileName',
      platformChannelSpecifics,
      payload: filePath, // File path to open on tap
    );
  }

  void _openFile(String filePath) {
    OpenFile.open(filePath);
  }

  Icon _getFileIcon(String filePath) {
    String cleanedFileName = filePath.replaceAll(RegExp(r'\s+$'), '');

    if (cleanedFileName.endsWith('.pdf')) {
      return const Icon(Icons.picture_as_pdf, color: Colors.red);
    } else if (cleanedFileName.endsWith('.zip') ||
        cleanedFileName.endsWith('.rar')) {
      return const Icon(Icons.archive, color: Colors.blue);
    } else if (cleanedFileName.endsWith('.doc') ||
        cleanedFileName.endsWith('.docx')) {
      return const Icon(Icons.description, color: Colors.green);
    } else {
      return const Icon(Icons.insert_drive_file, color: Colors.grey);
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

  String? _expandedMeetingNo; // Track currently expanded meeting_no

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
            onPressed: () => Navigator.pop(context),
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => widget.userId == 'guest'
                          ? IconMain2(userId: widget.userId)
                          : IconMain(userId: widget.userId)),
                );
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
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      const Center(
                        child: Text(
                          'IOCM Documents',
                          style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Arial',
                              fontWeight: FontWeight.bold,
                              color: AppColors.themeblue),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      ExpansionPanelList(
                        expansionCallback: (index, isExpanded) {
                          String selectedMeetingNo =
                              groupedDocuments.keys.elementAt(index);
                          setState(() {
                            _expandedMeetingNo =
                                (_expandedMeetingNo == selectedMeetingNo)
                                    ? null // Collapse if already expanded
                                    : selectedMeetingNo; // Expand new one
                          });
                        },
                        children: groupedDocuments.entries.map((entry) {
                          String meetingNo = entry.key;
                          List<Map<String, dynamic>> documents = entry.value;

                          return ExpansionPanel(
                            headerBuilder: (context, isExpanded) {
                              return ListTile(
                                title: Text(
                                  "IOCM$meetingNo",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              );
                            },
                            body: Column(
                              children: documents.map((doc) {
                                String documentNo =
                                    doc['document_no'] ?? 'Unknown';
                                String agendaName =
                                    doc['agenda_name'] ?? 'No Agenda';
                                String fileName =
                                    "IOCM${doc['meeting_no'] ?? ''}/${doc['file_name'] ?? 'No File'}";
                                String submittedBy =
                                    doc['submitted_by'] ?? 'Unknown';

                                return ListTile(
                                  leading: _getFileIcon(fileName),
                                  title: Text("$documentNo - $agendaName"),
                                  subtitle: Text("Submitted by: $submittedBy"),
                                  onTap: () => _handleFileClick(fileName),
                                );
                              }).toList(),
                            ),
                            isExpanded: _expandedMeetingNo == meetingNo,
                          );
                        }).toList(),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                    ],
                  ),
                ),
        ]),
      ),
    );
  }
}

class PDFViewerScreen extends StatefulWidget {
  final String fileUrl;
  final String userId;
  const PDFViewerScreen(
      {super.key, required this.fileUrl, required this.userId});

  @override
  State<PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  String cleanedFileName = "PDF Viewer"; // Default title

  @override
  void initState() {
    super.initState();
    _loadFileName();
  }

  Future<void> _loadFileName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      cleanedFileName = prefs.getString('cleanedFileName') ??
          "PDF Viewer"; // Fallback if null
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
      ), // Removed `const`
      body: SfPdfViewer.network(widget.fileUrl),
    );
  }
}
