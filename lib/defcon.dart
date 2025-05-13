import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iomoupsc/custom_color.dart';
import 'package:iomoupsc/login.dart';
import 'package:iomoupsc/onemainpage.dart';
import 'package:iomoupsc/onemainpage2.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeficiencyConvention extends StatefulWidget {
  // const DeficiencyConvention({super.key});
  final String userId;

  const DeficiencyConvention({super.key, required this.userId});

  @override
  State<DeficiencyConvention> createState() => _DeficiencyConventionState();
}

class Category {
  late String id;
  late String name;
  late String defType;
  late String defNature;
  late String defConvention;
  late String defConventionAbbr;
  late String defActionCode1;
  late String defActionCode1Name;

  Category({
    required this.id,
    required this.name,
    this.defType = '',
    this.defNature = '',
    this.defConvention = '',
    this.defConventionAbbr = '',
    this.defActionCode1 = '',
    this.defActionCode1Name = '',
  });
}

class _DeficiencyConventionState extends State<DeficiencyConvention> {
  List<Category> categoriesList = [];
  Category selectedCategory = Category(id: '', name: '');

  List<Category> categoriesList1 = [];
  Category selectedCategory1 = Category(id: '', name: '');

  final TextEditingController _textFieldController = TextEditingController();

  final TextEditingController _textFieldController1 = TextEditingController();

  List<Category> categoriesList3 = [];
  Category selectedCategory3 = Category(id: '', name: '');

  final TextEditingController _textFieldController2 = TextEditingController();

  List<Category> categoriesList5 = [];
  Category selectedCategory5 = Category(id: '', name: '');

  List<Category> categoriesList6 = [];
  Category selectedCategory6 = Category(id: '', name: '');

  List<Category> categoriesList7 = [];
  Category selectedCategory7 = Category(id: '', name: '');

  final TextEditingController _textFieldController3 = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
    getDef('011');
    getaction2('15', 'NON-ISM');
    _textFieldController3.text = 'Not Available';
  }

  //================================================================================================================================================================================================
  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse(
          'https://iomou.azurewebsites.net/flutter_connect/get_def_group.php'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          categoriesList = List.from(data['result']).map<Category>((item) {
            return Category(id: item['id'], name: item['name']);
          }).toList();
          selectedCategory = categoriesList.isNotEmpty
              ? categoriesList.first
              : Category(id: '', name: '');
        });
      } else {
        print('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  //================================================================================================================================================================================================
  Future<void> getDef(String defGroupCode) async {
    try {
      final response = await http.get(Uri.parse(
          'https://iomou.azurewebsites.net/flutter_connect/get_def.php?def_group_code=$defGroupCode'));
      if (response.statusCode == 200) {
        print(response.body);
        final data = jsonDecode(response.body);

        setState(() {
          categoriesList1 = List.from(data['result']).map<Category>((item) {
            return Category(
              id: item['id'] ?? '',
              name: item['name'] ?? '',
              defType: item['defType'] ?? '',
              defNature: item['defNature'] ?? '',
              defConvention: item['defConvention'] ?? '',
              defConventionAbbr: item['defConventionName'] ?? '',
              defActionCode1: item['actCode1'] ?? '',
              defActionCode1Name: item['actCode1Name'] ?? '',
            );
          }).toList();
          selectedCategory1 = categoriesList1.isNotEmpty
              ? categoriesList1.first
              : Category(id: '', name: '');

          _textFieldController.text = selectedCategory1.defType;

          _textFieldController1.text =
              selectedCategory1.defNature.replaceAll('##', ',');

          final List<String> defConventionData =
              selectedCategory1.defConvention.split('##');
          categoriesList3 = defConventionData.map<Category>((item) {
            return Category(id: '', name: item);
          }).toList();
          selectedCategory3 = categoriesList3.isNotEmpty
              ? categoriesList3.first
              : Category(id: '', name: '');

          _textFieldController2.text =
              selectedCategory1.defConventionAbbr.split('##').first;

          final List<String> actCode1List =
              selectedCategory1.defActionCode1.split('##');
          final List<String> actCode1NameList =
              selectedCategory1.defActionCode1Name.split('##');

          if (actCode1List.length == actCode1NameList.length) {
            categoriesList5 = List.generate(actCode1List.length, (index) {
              return Category(
                id: actCode1List[index],
                name: actCode1NameList[index],
              );
            });
          }

          selectedCategory5 = categoriesList5.isNotEmpty
              ? categoriesList5.first
              : Category(id: '', name: '');
        });
      } else {
        print('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data1: $e');
    }
  }

  //================================================================================================================================================================================================
  Future<void> getaction2(String id, String textFieldController1) async {
    try {
      final response = await http.get(Uri.parse(
          'https://iomou.azurewebsites.net/flutter_connect/get_def_action2.php?def_action1=$id&def_type=$textFieldController1'));

      if (response.statusCode == 200) {
        print(response.body);
        final data = jsonDecode(response.body);

        setState(() {
          final List<String> actCode1List = data['result'][0]['id'].split('##');
          final List<String> actCode1NameList =
              data['result'][0]['name'].split('##');

          if (actCode1List.length == actCode1NameList.length) {
            categoriesList6 = List.generate(actCode1List.length, (index) {
              return Category(
                  id: actCode1List[index], name: actCode1NameList[index]);
            });
          }

          selectedCategory6 = categoriesList6.isNotEmpty
              ? categoriesList6.first
              : Category(id: '', name: '');
        });
      } else {
        print('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  //================================================================================================================================================================================================

  void getaction3(action2) {
    if (action2 == '10') {
      _textFieldController3.text = 'Not Available';
    } else {
      _textFieldController3.text = 'Deficiency Rectified.';
    }
  }

  //================================================================================================================================================================================================

  void updateDropdowns(Category category) {
    _textFieldController.text = category.defType;

    _textFieldController1.text = category.defNature.replaceAll('##', ',');

    final List<String> defConventionData = category.defConvention.split('##');
    categoriesList3 = defConventionData.map<Category>((item) {
      return Category(id: '', name: item);
    }).toList();
    selectedCategory3 = categoriesList3.isNotEmpty
        ? categoriesList3.first
        : Category(id: '', name: '');

    _textFieldController2.text = category.defConventionAbbr.split('##').first;

    final List<String> actCode1List = category.defActionCode1.split('##');
    final List<String> actCode1NameList =
        category.defActionCode1Name.split('##');

    if (actCode1List.length == actCode1NameList.length) {
      categoriesList5 = List.generate(actCode1List.length, (index) {
        return Category(id: actCode1List[index], name: actCode1NameList[index]);
      });
    }

    selectedCategory5 = categoriesList5.isNotEmpty
        ? categoriesList5.first
        : Category(id: '', name: '');
  }

  void updateconref(Category category) {
    final List<String> defConventionData =
        selectedCategory1.defConvention.split('##');
    final List<String> defConventionAbbrData =
        selectedCategory1.defConventionAbbr.split('##');

    final index = defConventionData.indexOf(category.name);
    if (index >= 0) {
      setState(() {
        _textFieldController2.text = defConventionAbbrData[index];
      });
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
    // Get screen dimensions
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 400;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.themeblue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
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
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'PSC Deficiency and Convention',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      fontFamily: 'Arial',
                      color: AppColors.themeblue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFormRow(
                    isSmallScreen,
                    'Deficiency\nGroup',
                    DropdownButton<Category>(
                      value: selectedCategory,
                      isExpanded: true,
                      menuMaxHeight: 400,
                      onChanged: (Category? newValue) {
                        setState(() {
                          selectedCategory = newValue!;
                        });
                        getDef(newValue!.id);
                      },
                      items: categoriesList.map<DropdownMenuItem<Category>>(
                        (Category value) {
                          return DropdownMenuItem<Category>(
                            value: value,
                            child: Text(
                              '(${value.id}) ${value.name}',
                              overflow: TextOverflow.visible,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 12 : 14,
                              ),
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 16),
                  _buildFormRow(
                    isSmallScreen,
                    'Deficiency',
                    DropdownButton<Category>(
                      value: selectedCategory1,
                      isExpanded: true,
                      menuMaxHeight: 400,
                      onChanged: (Category? newValue) {
                        setState(() {
                          selectedCategory1 = newValue!;
                          updateDropdowns(newValue);
                        });
                      },
                      items: categoriesList1.map<DropdownMenuItem<Category>>(
                        (Category value) {
                          return DropdownMenuItem<Category>(
                            value: value,
                            child: Text(
                              '(${value.id}) ${value.name}',
                              overflow: TextOverflow.visible,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 12 : 14,
                              ),
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 16),
                  _buildFormRow(
                    isSmallScreen,
                    'Deficiency\nType',
                    TextFormField(
                      controller: _textFieldController,
                      readOnly: true,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 14,
                      ),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 16),
                  _buildFormRow(
                    isSmallScreen,
                    'Standard\nDeficiency\nText',
                    TextFormField(
                      controller: _textFieldController1,
                      readOnly: true,
                      maxLines: null,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 14,
                      ),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 16),
                  _buildFormRow(
                    isSmallScreen,
                    'Convention\nReference',
                    DropdownButton<Category>(
                      value: selectedCategory3,
                      isExpanded: true,
                      menuMaxHeight: 400,
                      onChanged: (Category? newValue) {
                        setState(() {
                          selectedCategory3 = newValue!;
                          updateconref(newValue);
                        });
                      },
                      items: categoriesList3.map<DropdownMenuItem<Category>>(
                        (Category value) {
                          return DropdownMenuItem<Category>(
                            value: value,
                            child: Text(
                              value.name,
                              overflow: TextOverflow.visible,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 12 : 14,
                              ),
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 16),
                  _buildFormRow(
                    isSmallScreen,
                    'Convention\nDescription',
                    TextFormField(
                      controller: _textFieldController2,
                      readOnly: true,
                      maxLines: null,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 14,
                      ),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 16),
                  _buildFormRow(
                    isSmallScreen,
                    'Action\nCode 1',
                    DropdownButton<Category>(
                      value: selectedCategory5,
                      isExpanded: true,
                      menuMaxHeight: 400,
                      onChanged: (Category? newValue) {
                        setState(() {
                          selectedCategory5 = newValue!;
                        });
                        getaction2(newValue!.id, _textFieldController.text);
                      },
                      items: categoriesList5.map<DropdownMenuItem<Category>>(
                        (Category value) {
                          return DropdownMenuItem<Category>(
                            value: value,
                            child: Text(
                              '(${value.id}) ${value.name}',
                              overflow: TextOverflow.visible,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 12 : 14,
                              ),
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 16),
                  _buildFormRow(
                    isSmallScreen,
                    'Action\nCode 2',
                    DropdownButton<Category>(
                      value: selectedCategory6,
                      isExpanded: true,
                      menuMaxHeight: 400,
                      onChanged: (Category? newValue) {
                        setState(() {
                          selectedCategory6 = newValue!;
                        });
                        getaction3(newValue!.id);
                      },
                      items: categoriesList6.map<DropdownMenuItem<Category>>(
                        (Category value) {
                          return DropdownMenuItem<Category>(
                            value: value,
                            child: Text(
                              '(${value.id}) ${value.name}',
                              overflow: TextOverflow.visible,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 12 : 14,
                              ),
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 16),
                  _buildFormRow(
                    isSmallScreen,
                    'Action\nCode 3',
                    TextFormField(
                      controller: _textFieldController3,
                      readOnly: true,
                      maxLines: null,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 14,
                      ),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

// Helper method to build form rows based on screen size
  Widget _buildFormRow(bool isSmallScreen, String labelText, Widget formField) {
    if (isSmallScreen) {
      // For small screens, stack label and field vertically
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelText,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 12 : 14,
            ),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: formField,
          ),
        ],
      );
    } else {
      // For larger screens, keep the original side-by-side layout
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelText,
            style: const TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
          ),
          SizedBox(
            width: 300,
            child: formField,
          ),
        ],
      );
    }
  }
}
