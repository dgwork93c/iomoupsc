import 'package:flutter/material.dart';

void main() {
  runApp(const ml());
}

class ml extends StatelessWidget {
  const ml({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Know Your Ship'),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF32cafe), Color(0xFF9f78ff)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Side Menu - You can include the side menu here.
                // For simplicity, I'm excluding the side menu in this example.

                // Content section
                const Text(
                  'Know Your Ship Before Inspection',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Arial',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile(
                        value: 'imo_no',
                        groupValue: 'selectedRadio',
                        onChanged: (value) {},
                        title: const Text('IMO No./Ship Name'),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile(
                        value: 'call_sign',
                        groupValue: 'selectedRadio',
                        onChanged: (value) {},
                        title: const Text('Call Sign'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const TextField(
                  decoration: InputDecoration(
                    hintText: 'Input at least 3 digits or characters',
                  ),
                  // Add your event handlers for input validation and search here.
                ),
                const SizedBox(height: 20),
                // View result in table section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'IOCIS PSC Inspection Details for IMO No. ........... (01.01.2017 - till date)',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Arial',
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        backgroundColor: Color(0xFF77b9e5),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Table content here...
                    DataTable(
                      columns: const [
                        DataColumn(label: Text('Column 1')),
                        DataColumn(label: Text('Column 2')),
                        DataColumn(label: Text('Column 3')),
                        DataColumn(label: Text('Column 4')),
                        DataColumn(label: Text('Column 5')),
                        DataColumn(label: Text('Column 6')),
                      ],
                      rows: const [
                        DataRow(cells: [
                          DataCell(Text('Data 1')),
                          DataCell(Text('Data 2')),
                          DataCell(Text('Data 3')),
                          DataCell(Text('Data 4')),
                          DataCell(Text('Data 5')),
                          DataCell(Text('Data 6')),
                        ]),
                        // Add more data rows as needed.
                      ],
                    ),
                  ],
                ),
                // Tabs section
                DefaultTabController(
                  length: 5,
                  initialIndex: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        child: const TabBar(
                          isScrollable: true,
                          labelColor: Colors.black,
                          indicatorColor: Colors.white,
                          tabs: [
                            Tab(text: 'Latest Ship Particulars'),
                            Tab(text: 'Recorded Certificates'),
                            Tab(text: 'Recorded Deficiencies'),
                            Tab(text: 'Recorded Detentions'),
                            Tab(text: 'Search Inspection in Other MOUs'),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        height: 200.0, // Adjust height based on content
                        child: const TabBarView(
                          children: [
                            // Content for each tab here...
                            Center(child: Text('Tab 1 Content')),
                            Center(child: Text('Tab 2 Content')),
                            Center(child: Text('Tab 3 Content')),
                            Center(child: Text('Tab 4 Content')),
                            Center(child: Text('Tab 5 Content')),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
