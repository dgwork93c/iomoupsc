import 'package:flutter/material.dart';

class ShipDetailsCard extends StatelessWidget {
  final Map<String, dynamic>? shipData;

  const ShipDetailsCard({Key? key, required this.shipData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildShipDetailsCard(), // Main details card
        const SizedBox(height: 5),
        _buildShipDetailsCard1(), // Risk details card
      ],
    );
  }

  Widget _buildShipDetailsCard() {
    return Card(
      elevation: 0,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(
          color: Color(0xFFFCB131),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Container
          Container(
            width: double.infinity,
            color: const Color(0xFFFCB131),
            padding: const EdgeInsets.symmetric(vertical: 1), // Better spacing
            child: const Text(
              'Ship Details',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                fontFamily: 'Arial',
              ),
            ),
          ),

          // Ship Details Content
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // First Row
                // Second Row (Single Column)
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailTile(
                              'Ship Name', shipData?['ship_name'] ?? ''),
                        ],
                      ),
                    ),
                  ],
                ),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // First Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailTile(
                              'IMO Number', shipData?['imo_no'] ?? ''),
                          const SizedBox(height: 15),
                          _buildDetailTile(
                              'Flag', shipData?['flag_code'] ?? ''),
                          const SizedBox(height: 18),
                          _buildDetailTile(
                              'MMSI No.', shipData?['mmsi_no'] ?? ''),
                          _buildDetailTile(
                              'GT', shipData?['gross_tonnage'] ?? ''),
                        ],
                      ),
                    ),
                    // Second Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailTile(
                              'Call Sign', shipData?['call_sign'] ?? ''),
                          _buildFlagImage(shipData?['flag_image']),
                          _buildDetailTile(
                              'Date KL', shipData?['date_keel_laid'] ?? ''),
                          _buildDetailTile(
                              'DWT', shipData?['dead_weight'] ?? ''),
                        ],
                      ),
                    ),
                  ],
                ),

                // Second Row (Single Column)
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailTile('RO', shipData?['soc_code'] ?? ''),
                          _buildDetailTile(
                              'Type', shipData?['ship_type_code'] ?? ''),
                          _buildDetailTile(
                            'IMO Company',
                            '(${shipData?['imo_comp_no']}) ${shipData?['ship_owner'] ?? ''}',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShipDetailsCard1() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Container
          Container(
            width: double.infinity,
            color: const Color(0xFFFCB131),
            padding: const EdgeInsets.symmetric(vertical: 1), // Better spacing
            child: Text(
              'Risk Details (as on ${shipData?['period_fromSRP'] ?? 'N/A'})',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                fontFamily: 'Arial',
              ),
            ),
          ),
          Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailTile(
                    'Ship On-Watch List/Alert?',
                    shipData?['watch_list'] == 'YES' ? 'Yes' : 'No',
                  ),
                  _buildDetailTile(
                    'Banned Ship?',
                    shipData?['alert_master'] == 'YES' ? 'Yes' : 'No',
                  ),
                  _buildDetailTile(
                    'Underperforming Ship?',
                    shipData?['under_perform'] == 'YES' ? 'Yes' : 'No',
                  ),
                  _buildShipRiskProfileend(shipData),
                ],
              ),
            ),
          )

          // Detail Tiles
        ],
      ),
    );
  }

  Widget _buildShipDetailsCarddetentions() {
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
            const Text(
              'Ship Details',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                fontFamily: 'Arial',
              ),
            ),
            _buildDetailTile(
              'Ship On-Watch List/Alert?',
              shipData?['watch_list'] == 'YES' ? 'Yes' : 'No',
            ),
            _buildDetailTile(
              'Underperforming Ship?',
              shipData?['under_perform'] == 'YES' ? 'Yes' : 'No',
            ),
            _buildDetailTile(
              'Banned Ship?',
              shipData?['alert_master'] == 'YES' ? 'Yes' : 'No',
            ),
            _buildDetailTile(
              'Ship Risk Profile?',
              _getShipRiskProfileText(
                shipData?['srp_value'] ?? '',
                shipData?['srp_priority'] ?? '',
                shipData?['srp_insp_cat'] ?? '',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile(String label, String? value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 12),
        ),
        // const SizedBox(width: 4),
        Flexible(
          child: Text(
            value ?? '',
            style: TextStyle(
              fontSize: 12,
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

  Widget _buildDetailTileRiskDetail(String label, String? value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label',
          style: const TextStyle(
              fontSize: 12,
              fontFamily: 'Arial',
              color: Colors.red,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            value ?? '',
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'Arial',
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
            softWrap: true,
            overflow: TextOverflow.clip,
          ),
        ),
      ],
    );
  }

  Widget _buildFlagImage(String? imageName) {
    if (imageName == null || imageName.isEmpty) {
      return const Placeholder(); // Replace with your preferred placeholder widget.
    }

    return Image.asset(
      'assets/images/${imageName.toLowerCase()}',
      width: 50,
      height: 50,
    );
  }

  String _getShipRiskProfileText(
      String srpValue, String srpPriority, String srpInspCat) {
    if (srpValue == 'HRS' || srpValue == 'SRS' || srpValue == 'LRS') {
      return '$srpValue-$srpPriority-$srpInspCat Insp.';
    } else {
      return 'HRS-Priority I-Additional Insp.';
    }
  }

  Widget _buildShipRiskProfileend(Map<String, dynamic>? shipData) {
    final String srpValue = shipData?['srp_value'] ?? '';
    final String srpPriority = shipData?['srp_priority'] ?? '';
    final String srpInspCat = shipData?['srp_insp_cat'] ?? '';

    Color textColor;
    String riskProfileText;

    if (srpValue == 'HRS') {
      textColor = Colors.red;
      riskProfileText = '$srpValue-$srpPriority-$srpInspCat Insp.';
    } else if (srpValue == 'SRS') {
      textColor = Color(0xFF0807bb);
      riskProfileText = '$srpValue-$srpPriority-$srpInspCat Insp.';
    } else if (srpValue == 'LRS') {
      textColor = Colors.green;
      riskProfileText = '$srpValue-$srpPriority-$srpInspCat Insp.';
    } else {
      textColor = Colors.red;
      riskProfileText = 'HRS-Priority I-Additional Insp.';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Text(
          'Ship Risk Profile?: ',
          style: TextStyle(fontSize: 12),
        ),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: riskProfileText,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  fontFamily: 'Arial',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
