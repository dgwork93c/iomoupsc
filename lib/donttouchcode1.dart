import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class InspectionScreen extends StatefulWidget {
  final String inspNo;

  InspectionScreen({required this.inspNo});

  @override
  _InspectionScreenState createState() => _InspectionScreenState();
}

class _InspectionScreenState extends State<InspectionScreen> {
  bool _isLoading = false;
  List<dynamic> subInspHistData = [];

  @override
  void initState() {
    super.initState();
    fetchdata(widget.inspNo);
  }

  Future<void> fetchdata(String insp) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(
          'https://iomou.azurewebsites.net/flutter_connect/get_know_ship.php?insp_no=$insp'));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        setState(() {
          subInspHistData = jsonData['sub_insp_hist'] ?? [];
          _isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch data')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      print('Error fetching data: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void showDeficiencyDetails(BuildContext context, List<dynamic> defHist) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Deficiency Details"),
          content: SingleChildScrollView(
            child: Column(
              children: defHist.map((def) {
                return ListTile(
                  title: Text(def['def_name'] ?? 'Unknown'),
                  subtitle: Text("Code: ${def['def_code']}"),
                  trailing: Icon(
                    def['rectified'] == "YES"
                        ? Icons.check_circle
                        : Icons.error,
                    color:
                        def['rectified'] == "YES" ? Colors.green : Colors.red,
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Inspection Data")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: subInspHistData.length,
              itemBuilder: (context, index) {
                final insp = subInspHistData[index];
                final followups = insp['sub_insp_histF'] ?? [];

                return Card(
                  margin: EdgeInsets.all(8),
                  child: ExpansionTile(
                    title: Text(
                      "Inspection: ${insp['insp_no']} (${insp['date_inspection']})",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "Deficiencies: ${insp['NumDef']} | Rectified: ${insp['RectifyNum']} | Unrectified: ${insp['unRect']}",
                    ),
                    children: [
                      ListTile(
                        title: Text("Initial Inspection"),
                        onTap: () =>
                            showDeficiencyDetails(context, insp['def_hist']),
                      ),
                      if (followups.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: followups.map<Widget>((followup) {
                              return ListTile(
                                title: Text(
                                  "Follow-up: ${followup['insp_no']} (${followup['date_inspection']})",
                                  style: TextStyle(color: Colors.blue),
                                ),
                                subtitle: Text(
                                  "Deficiencies: ${followup['NumDef']} | Rectified: ${followup['RectifyNum']} | Unrectified: ${followup['unRect']}",
                                ),
                                onTap: () => showDeficiencyDetails(
                                    context, followup['def_hist']),
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
