// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iomoupsc/custom_color.dart';
import 'package:iomoupsc/login.dart';
import 'package:iomoupsc/onemainpage.dart';
import 'package:iomoupsc/onemainpage2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

void main() {
  runApp(const PscManualApp(
    userId: '',
  ));
}

class PscManualApp extends StatefulWidget {
  // const PscManualApp({super.key});
  final String userId;

  const PscManualApp({super.key, required this.userId});

  @override
  _PscManualAppState createState() => _PscManualAppState();
}

class _PscManualAppState extends State<PscManualApp> {
  final List<String> _autocompleteSuggestions = [];

  TextEditingController _autocompleteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    makeKeywordList();
  }

  List<String> _parseResponse(String responseBody) {
    try {
      final parsedData = jsonDecode(responseBody);
      final List<dynamic> result = parsedData['result'];

      // ignore: unnecessary_null_comparison
      if (result != null) {
        final List<String> concatenatedItems = [];

        for (int i = 0; i < result.length; i++) {
          final String keywords = result[i]['keywords'] as String;
          final String filenames = result[i]['filename'] as String;

          final List<String> separatedKeywords = keywords.split('@@');
          final List<String> separatedFilenames = filenames.split('@@');

          for (int j = 0; j < separatedKeywords.length; j++) {
            final String keyword = separatedKeywords[j];
            final String filename = separatedFilenames[j];

            final List<String> subKeywords = keyword.split('||');
            for (int k = 0; k < subKeywords.length; k++) {
              final String subKeyword = subKeywords[k];
              final String concatenatedItem = '$subKeyword ($filename)';
              concatenatedItems.add(concatenatedItem);
            }
          }
        }

        return concatenatedItems.toSet().toList();
      } else {
        print('Response does not contain a valid result.');
      }
    } catch (error) {
      print('Error parsing response: $error');
    }

    return [];
  }

  void makeKeywordList() async {
    final response = await http.get(Uri.parse(
        'https://iomou.azurewebsites.net/flutter_connect/get_pscKeywords.php'));

    if (response.statusCode == 200) {
      final List<String> apiResponse = _parseResponse(response.body);
      setState(() {
        _autocompleteSuggestions.addAll(apiResponse);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch keyword list')),
      );
    }
  }

  void getResult(String selectedFileName) {
    const baseUrl =
        'https://iomou.azurewebsites.net/HomePAGE/pdf/PSC_Manual_Search/';
    const sign =
        '?sv=2022-11-02&ss=bfqt&srt=sco&sp=rwlacupitfx&se=2025-12-31T14:55:47Z&st=2025-01-08T06:55:47Z&spr=https&sig=SyrZoTJtgAcDqVfAW%2BN1%2FEu7UiUQ0ekhMERYfpXx8kI%3D';
    final pdfUrl = '$baseUrl$selectedFileName$sign';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16.0),
                Text('Loading PDF...'),
              ],
            ),
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 2), () async {
      Navigator.of(context).pop(); // Close the loader dialog

      try {
        final response = await http.head(Uri.parse(pdfUrl));
        final contentType = response.headers['content-type'];

        if (contentType != null && contentType.contains('application/pdf')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(
                  title: Text(selectedFileName),
                ),
                body: SfPdfViewer.network(pdfUrl),
              ),
            ),
          );
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('File Not Found'),
                content: const Text(
                    'The selected file could not be found or is not a valid PDF.'),
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
      } catch (error) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('An error occurred while loading the PDF: $error'),
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
            SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "PSC Manual Search",
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Arial',
                        color: AppColors.themeblue,
                        fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text == '') {
                          return const Iterable<String>.empty();
                        }
                        return _autocompleteSuggestions
                            .where((String suggestion) {
                          final String lowerCaseInput =
                              textEditingValue.text.toLowerCase();
                          return suggestion
                              .toLowerCase()
                              .contains(lowerCaseInput);
                        });
                      },
                      onSelected: (String selection) {
                        debugPrint('You just selected $selection');
                        // Extract filename from the selected suggestion
                        final String selectedFileName = selection.substring(
                            selection.lastIndexOf('(') + 1,
                            selection.lastIndexOf(')'));
                        getResult(selectedFileName);
                      },
                      displayStringForOption: (String option) => option,
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
                                'Enter Keyword') {
                              _autocompleteController.clear();
                            }
                          },
                          decoration: InputDecoration(
                              hintText: 'Enter Keyword',
                              suffixIcon: IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                  _autocompleteController.clear();
                                },
                              )),
                          onFieldSubmitted: (String value) {
                            onFieldSubmitted();
                          },
                        );
                      },
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
}
