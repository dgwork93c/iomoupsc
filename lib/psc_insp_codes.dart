// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:iomoupsc/custom_color.dart';
import 'package:iomoupsc/loader.dart';
import 'package:iomoupsc/login.dart';
import 'package:iomoupsc/onemainpage.dart';
import 'package:iomoupsc/onemainpage2.dart';
import 'package:shared_preferences/shared_preferences.dart';

class pscinspcodes extends StatefulWidget {
  final String userId;

  const pscinspcodes({super.key, required this.userId});

  @override
  State<pscinspcodes> createState() => _pscinspcodesState();
}

class _pscinspcodesState extends State<pscinspcodes>
    with AutomaticKeepAliveClientMixin {
  var val1 = 11;
  final _formKey = GlobalKey<FormState>();
  final List<ListItem> _dropdownItems1 = [
    const ListItem(0, "Flag"),
    const ListItem(1, "Ship type"),
    const ListItem(2, "Recognized Organization"),
    const ListItem(3, "IMO Company"),
    const ListItem(4, "Certificate"),
    const ListItem(5, "Deficiency"),
    const ListItem(6, "Deficiency action"),
    const ListItem(7, "Port"),
    const ListItem(8, "PSC Action"),
  ];
  final List<ListItem> _dropdownItems2 = [
    const ListItem(0, "IMO No."),
    const ListItem(1, "Call Sign"),
    const ListItem(2, "MMSI No."),
  ];
  List<DropdownMenuItem<ListItem>> _dropdownMenuItems1 = [];
  List<DropdownMenuItem<ListItem>> _dropdownMenuItems2 = [];
  ListItem? _selectedItem1;
  ListItem? _selectedItem2;
  final TextEditingController _textFieldController = TextEditingController();
  final List<String> _autocompleteSuggestions = [];
  List<String> _filteredAutocompleteSuggestions = [];
  List<Map<String, String>> shipData = [];
  String labelText = "";
  String shipName = "";
  String imoNo = "";
  String mmsiNo = "";
  String callSign = "";
  String flagCode = "";
  String _placeholderText = 'Enter Identity';
  bool _isLoading = false;

  double _getFontSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 320) {
      return 10;
    } else if (screenWidth >= 320 && screenWidth < 400) {
      return 12;
    } else {
      return 14;
    }
  }

  @override
  bool get wantKeepAlive => true;
  void initState() {
    super.initState();
    _dropdownMenuItems1 = buildDropDownMenuItems(_dropdownItems1);
    _dropdownMenuItems2 = buildDropDownMenuItems(_dropdownItems2);
  }

  List<DropdownMenuItem<ListItem>> buildDropDownMenuItems(
      List<ListItem> listItems) {
    return listItems.map((listItem) {
      return DropdownMenuItem(
        value: listItem,
        child: Text(listItem.name),
      );
    }).toList();
  }

  void _search() async {
    setState(() {
      _isLoading = true; // Show loading indicator while inserting data
    });
    if (_formKey.currentState!.validate()) {
      String searchText = _textFieldController.text;

      String apiUrl =
          'https://iomou.azurewebsites.net/flutter_connect/chk_validate.php?position=${_selectedItem2?.value}&idname=$searchText';
      print(apiUrl);
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          _isLoading = false; // Show loading indicator while inserting data
        });
        print(response.body);
        String jsonString = response.body;

        if (response.body == '1') {
          Fluttertoast.showToast(
            msg: "Invalid IMO number.",
            toastLength: Toast.LENGTH_SHORT, // or Toast.LENGTH_LONG
            gravity: ToastGravity.CENTER, // Position (TOP, CENTER, BOTTOM)
            backgroundColor: Colors.black54,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        } else if (response.body == '2') {
          Fluttertoast.showToast(
            msg: "Invalid Call Sign.",
            toastLength: Toast.LENGTH_SHORT, // or Toast.LENGTH_LONG
            gravity: ToastGravity.CENTER, // Position (TOP, CENTER, BOTTOM)
            backgroundColor: Colors.black54,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        } else if (response.body == '3') {
          Fluttertoast.showToast(
            msg: "Invalid MMSI number.",
            toastLength: Toast.LENGTH_SHORT, // or Toast.LENGTH_LONG
            gravity: ToastGravity.CENTER, // Position (TOP, CENTER, BOTTOM)
            backgroundColor: Colors.black54,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }

        final Map<String, dynamic> data =
            json.decode(response.body); // Parse JSON
        if (data["result"] is List && data["result"].isEmpty) {
          Fluttertoast.showToast(
            msg: "No Data Found.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.black54,
            textColor: Colors.red,
            fontSize: 16.0,
          );
          imoNo = '';
        }

        try {
          final parsedResponse = jsonDecode(jsonString);

          setState(() {
            shipName = parsedResponse['result'][0]['ship_name'];
            imoNo = parsedResponse['result'][0]['imo_no'];
            mmsiNo = parsedResponse['result'][0]['mmsi_no'];
            callSign = parsedResponse['result'][0]['call_sign'];
            flagCode = parsedResponse['result'][0]['flag_code'];
          });
          // ignore: empty_catches
        } catch (error) {}
      } else {}
    }
  }

  Widget _buildDetailTile(String label, String? value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 14),
        ),
        // const SizedBox(width: 4),
        Flexible(
          child: Text(
            value ?? '',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Arial',
              fontWeight: FontWeight.bold,
              color: value?.toLowerCase() == 'yes'
                  ? Colors.red
                  : (value?.toLowerCase() == 'no'
                      ? Colors.green
                      : Colors.black),
            ),
            softWrap: true,
            overflow: TextOverflow.clip,
          ),
        ),
      ],
    );
  }

  void _sendValueToAPI(ListItem? selectedItem) async {
    if (selectedItem != null) {
      _autocompleteSuggestions.clear();
      _textFieldController.clear();
      final apiUrl =
          'https://iomou.azurewebsites.net/flutter_connect/get_identity.php?identity=${selectedItem.value}';
      print(apiUrl);

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        List<String> apiResponse = _parseResponse(response.body);
        setState(() {
          _autocompleteSuggestions.addAll(apiResponse);
        });
      } else {}
    } else {}
  }

  List<String> _parseResponse(String responseBody) {
    try {
      final parsedData = jsonDecode(responseBody);
      final List<dynamic> result = parsedData['result'];

      return result.map((item) => '${item['name']}(${item['id']})').toList();
    } catch (error) {
      print('Error parsing response: $error');
    }

    return [];
  }

  void _reset() {
    _formKey.currentState!.reset();
    _textFieldController.clear();
    labelText = '';
    setState(() {
      _selectedItem1 = null;
      _selectedItem2 = null;
      labelText = "";
      shipName = "";
      imoNo = "";
      mmsiNo = "";
      callSign = "";
      flagCode = "";
    });
  }

  void _filterAutocompleteSuggestions(String value) {
    setState(() {
      _filteredAutocompleteSuggestions = _autocompleteSuggestions
          .where((suggestion) =>
              suggestion.toLowerCase().contains(value.toLowerCase()))
          .toList();
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
  void dispose() {
    _textFieldController.dispose();
    super.dispose();
  }

  bool _isValidateEnabled = false; // Track button enabled state

  void _validateInput(String value) {
    setState(() {
      final selectedValue = _selectedItem2?.value;

      if (selectedValue == 0) {
        // IMO Number: Only numbers, exactly 7 digits
        _isValidateEnabled = RegExp(r'^\d{7}$').hasMatch(value);
      } else if (selectedValue == 1) {
        // Call Sign: 4 to 7 alphanumeric characters
        _isValidateEnabled = RegExp(r'^[a-zA-Z0-9]{4,7}$').hasMatch(value);
      } else if (selectedValue == 2) {
        // MMSI Number: Only numbers, exactly 9 digits
        _isValidateEnabled = RegExp(r'^\d{9}$').hasMatch(value);
      } else {
        _isValidateEnabled = false; // Default case: Disable button
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double fontSize = _getFontSize(context);
    super.build(context);
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
              // Ensure scrolling works
              child: Column(
                children: [
                  Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'PSC Inspection Codes',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Arial',
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.themeblue),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(1),
                        child: Row(
                          children: [
                            Expanded(
                              child: Center(
                                child: ToggleButtons(
                                  isSelected: [val1 == 11, val1 == 22],
                                  onPressed: (index) {
                                    setState(() {
                                      val1 = index == 0 ? 11 : 22;
                                      _textFieldController.clear();

                                      if (val1 == 11) {
                                        labelText = '';
                                        _dropdownMenuItems2.clear();
                                        _dropdownMenuItems2 =
                                            buildDropDownMenuItems(
                                                _dropdownItems2);
                                        _selectedItem2 =
                                            _dropdownMenuItems2.isNotEmpty
                                                ? _dropdownMenuItems2[0].value
                                                : null; // Reset to default
                                        _placeholderText = '';
                                        imoNo = "";
                                      } else {
                                        _dropdownMenuItems1.clear();
                                        _dropdownMenuItems1 =
                                            buildDropDownMenuItems(
                                                _dropdownItems1);
                                        _selectedItem1 =
                                            _dropdownMenuItems1.isNotEmpty
                                                ? _dropdownMenuItems1[0].value
                                                : null; // Reset to default
                                        _placeholderText = '';
                                        imoNo = "";
                                      }
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(15),
                                  selectedColor: Colors.white,
                                  fillColor: AppColors.themeorange,
                                  color: AppColors.themeblue,
                                  borderColor: AppColors.themeblue,
                                  borderWidth: 1,
                                  selectedBorderColor: AppColors.themeblue,
                                  children: [
                                    Container(
                                      width: 170, // Set the width of the button
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        child: Text(
                                          'PSC Code/Description',
                                          style: TextStyle(
                                              fontSize: fontSize,
                                              fontFamily: 'Arial',
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 170, // Set the width of the button
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        child: Text(
                                          'Validate Identity',
                                          style: TextStyle(
                                              fontSize: fontSize,
                                              fontFamily: 'Arial',
                                              fontWeight: FontWeight.bold),
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
                      const SizedBox(height: 16.0),
                      Visibility(
                        visible: val1 == 11,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                DropdownButtonFormField<ListItem>(
                                  value: _selectedItem1,
                                  items: _dropdownMenuItems1,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedItem1 = value;
                                      _filteredAutocompleteSuggestions.clear();
                                      _textFieldController.clear();
                                      labelText = '';

                                      if ([0, 6, 8]
                                          .contains(_selectedItem1?.value)) {
                                        _textFieldController.text = '';
                                        _placeholderText =
                                            'Enter minimum 2 characters.';
                                      } else if ([1, 2, 3, 4, 5, 7]
                                          .contains(_selectedItem1?.value)) {
                                        _textFieldController.text = '';
                                        _placeholderText =
                                            'Enter minimum 3 characters.';
                                      }
                                    });
                                    _sendValueToAPI(_selectedItem1);
                                  },
                                  decoration: const InputDecoration(
                                    labelText: 'Identity',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Please select an option';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16.0),
                                TextFormField(
                                  controller: _textFieldController,
                                  onChanged: (value) {
                                    if (value.length >= 2) {
                                      _filterAutocompleteSuggestions(value);
                                    }
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Value',
                                    hintText: _placeholderText,
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please enter search text';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16.0),
                                Visibility(
                                  visible: _filteredAutocompleteSuggestions
                                      .isNotEmpty,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: LimitedBox(
                                      maxHeight: 200,
                                      child: ListView.builder(
                                        padding: EdgeInsets.zero,
                                        shrinkWrap: true,
                                        itemCount:
                                            _filteredAutocompleteSuggestions
                                                .length,
                                        itemBuilder: (context, index) {
                                          final suggestion =
                                              _filteredAutocompleteSuggestions[
                                                  index];
                                          return ListTile(
                                            title: Text(suggestion),
                                            onTap: () {
                                              setState(() {
                                                _textFieldController.text =
                                                    suggestion;
                                                _filteredAutocompleteSuggestions
                                                    .clear();
                                              });
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      onPressed: _reset,
                                      style: const ButtonStyle(
                                          backgroundColor:
                                              MaterialStatePropertyAll(
                                                  AppColors.themeblue)),
                                      child: const Text(
                                        'RESET',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontFamily: 'Arial',
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: val1 == 22,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                DropdownButtonFormField<ListItem>(
                                  value: _selectedItem2,
                                  items: _dropdownMenuItems2,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedItem2 = value;

                                      if (_selectedItem2?.value == 0) {
                                        _textFieldController.text = '';
                                        imoNo = "";
                                        _placeholderText = 'Enter IMO number.';
                                      } else if (_selectedItem2?.value == 1) {
                                        _textFieldController.text = '';
                                        imoNo = "";
                                        _placeholderText = 'Enter CallSign.';
                                      } else if (_selectedItem2?.value == 2) {
                                        _textFieldController.text = '';
                                        imoNo = "";
                                        _placeholderText = 'Enter MMSI number.';
                                      }
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    labelText: 'Identity',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Please select an option';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16.0),
                                TextFormField(
                                  controller: _textFieldController,
                                  onChanged:
                                      _validateInput, // Validate input dynamically
                                  decoration: InputDecoration(
                                    labelText: 'Value',
                                    hintText: _placeholderText,
                                    border: OutlineInputBorder(),
                                  ),
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(
                                      _selectedItem2?.value == 0
                                          ? 7 // IMO Number (Max 7 digits)
                                          : _selectedItem2?.value == 1
                                              ? 7 // Call Sign (Max 7 characters)
                                              : 9, // MMSI Number (Max 9 digits)
                                    ),
                                    FilteringTextInputFormatter.allow(
                                      _selectedItem2?.value == 1
                                          ? RegExp(
                                              r'[a-zA-Z0-9]') // Call Sign: Allow alphanumeric
                                          : RegExp(
                                              r'[0-9]'), // IMO & MMSI: Allow only numbers
                                    ),
                                  ],
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Value cannot be empty';
                                    }

                                    final selectedValue = _selectedItem2?.value;

                                    if (selectedValue == 0) {
                                      if (!RegExp(r'^\d{7}$').hasMatch(value)) {
                                        return 'IMO Number must be exactly 7 digits.';
                                      }
                                    } else if (selectedValue == 1) {
                                      if (!RegExp(r'^[a-zA-Z0-9]{4,7}$')
                                          .hasMatch(value)) {
                                        return 'Call Sign must be 4 to 7 alphanumeric characters.';
                                      }
                                    } else if (selectedValue == 2) {
                                      if (!RegExp(r'^\d{9}$').hasMatch(value)) {
                                        return 'MMSI Number must be exactly 9 digits.';
                                      }
                                    }

                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      onPressed: _isValidateEnabled
                                          ? _search
                                          : null, // Disable when invalid
                                      style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty
                                            .resolveWith<Color>(
                                          (Set<MaterialState> states) {
                                            if (states.contains(
                                                MaterialState.disabled)) {
                                              return Colors
                                                  .grey; // Disabled button color
                                            }
                                            return AppColors
                                                .themeblue; // Enabled button color
                                          },
                                        ),
                                      ),
                                      child: const Text(
                                        'VALIDATE',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontFamily: 'Arial',
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 16.0),
                                    ElevatedButton(
                                      onPressed: _reset,
                                      style: const ButtonStyle(
                                        backgroundColor:
                                            MaterialStatePropertyAll(
                                                AppColors.themeblue),
                                      ),
                                      child: const Text(
                                        'RESET',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontFamily: 'Arial',
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Visibility(
                    visible: imoNo.isNotEmpty,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: Text(
                              'Latest record details in IOCIS database',
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Arial',
                                fontWeight: FontWeight.bold,
                                color: AppColors.themeblue,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildDetailRow('IMO No.:', imoNo),
                          _buildDetailRow('Ship Name:', shipName),
                          _buildDetailRow('Flag Name:', flagCode),
                          _buildDetailRow('Call Sign:', callSign),
                          _buildDetailRow('MMSI No.:', mmsiNo),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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
      ),
    );
  }
}

/// Helper function to build rows
Widget _buildDetailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      mainAxisSize: MainAxisSize.min, // Prevents infinite width
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: 14, fontFamily: 'Arial', fontWeight: FontWeight.normal),
        ),
        SizedBox(width: 5),
        Text(
          value,
          style: TextStyle(
              fontSize: 14, fontFamily: 'Arial', fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}

class ListItem {
  final int value;
  final String name;

  const ListItem(this.value, this.name);
}

void main() {
  runApp(const MaterialApp(
    home: pscinspcodes(
      userId: '',
    ),
  ));
}
