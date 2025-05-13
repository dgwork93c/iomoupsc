import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AutocompleteExampleApp extends StatefulWidget {
  @override
  _AutocompleteExampleAppState createState() => _AutocompleteExampleAppState();
}

class _AutocompleteExampleAppState extends State<AutocompleteExampleApp> {
  final String serverPath = "http://10.153.8.98/livesite_0823/flutter_connect";

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
  var showme;
  List<Category> _kOptions = <Category>[];

  @override
  void initState() {
    super.initState();
    fetchDeficiencies();
  }

  Future<void> fetchDeficiencies() async {
    try {
      final response =
          await http.get(Uri.parse('$serverPath/unrectdefs.php?identity=true'));

      if (response.statusCode == 200) {
        print(response.body);
        final parsedData = jsonDecode(response.body);
        final List<dynamic> result = parsedData['result'];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Autocomplete<Category>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text == '') {
                  return const Iterable<Category>.empty();
                }
                return _kOptions.where((Category option) {
                  final String lowerCaseInput =
                      textEditingValue.text.toLowerCase();
                  return option.name.toLowerCase().contains(lowerCaseInput) ||
                      option.imo.toLowerCase().contains(lowerCaseInput);
                });
              },
              onSelected: (Category selection) {
                debugPrint('You just selected ${selection.name}');
              },
              displayStringForOption: (Category option) =>
                  option.name + '(' + option.imo + ')',
            ),
            const Text("data"),
            // Add more widgets as needed
          ],
        ),
      ),
    );
  }
}

class Category {
  final String name;
  final String imo;

  Category({required this.name, required this.imo});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      name: json['name'] as String,
      imo: json['imo'] as String,
    );
  }
}
