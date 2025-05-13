import 'package:flutter/material.dart';
import 'package:iomoupsc/custom_color.dart';
import 'package:iomoupsc/login.dart';
import 'package:iomoupsc/onemainpage.dart';
import 'package:iomoupsc/onemainpage2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

void main() {
  runApp(const Searchotherimo(
    userId: '',
  ));
}

class Searchotherimo extends StatefulWidget {
  final String userId;

  const Searchotherimo({super.key, required this.userId});
  @override
  _SearchotherimoState createState() => _SearchotherimoState();
}

class _SearchotherimoState extends State<Searchotherimo> {
  final TextEditingController _imoNumberController = TextEditingController();
  String _selectedMou = '00';
  bool isButtonDisabled = true;
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

  void _validateForm() {
    setState(() {
      isButtonDisabled =
          _imoNumberController.text.length != 7 || _selectedMou == '00';
    });
  }

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
        body: Stack(children: [
          Center(
            child: Container(
              width: 300,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/iomou_logo.png"),
                  opacity: 0.1,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  'Inspection Data Search in other MOUs',
                  style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Arial',
                      fontWeight: FontWeight.bold,
                      color: AppColors.themeblue),
                ),
                const SizedBox(height: 16.0),
                Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _imoNumberController,
                        decoration: const InputDecoration(
                          labelText: 'IMO No:',
                          hintText: 'Enter IMO No (7 digits)',
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 7,
                        onChanged: (value) =>
                            _validateForm(), // Validate on input change
                      ),
                      const SizedBox(height: 16.0),
                      DropdownButtonFormField<String>(
                        value: _selectedMou,
                        items: const [
                          DropdownMenuItem(
                              value: '00',
                              child: Text('- - - Select MOU - - -')),
                          DropdownMenuItem(value: '4', child: Text('BSMOU')),
                          DropdownMenuItem(value: '3', child: Text('CMOU')),
                          DropdownMenuItem(
                              value: '1', child: Text('TOKYO MOU')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedMou = value!;
                            _validateForm();
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Select MOU:',
                          hintText: 'Select MOU',
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF174282)),
                        onPressed:
                            isButtonDisabled ? null : handleFormSubmission,
                        child: const Text(
                          "Submit",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  void handleFormSubmission() {
    String imoNumber = _imoNumberController.text;

    if (imoNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an IMO number')),
      );
      return;
    }

    if (_selectedMou == '00') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an MOU')),
      );
      return;
    }

    String sLink = constructLink(_selectedMou, imoNumber);

    // Open the link in an external browser if it's available
    if (sLink != "No record available") {
      _launchURLBrowser(sLink);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No record available')),
      );
    }
  }

  Future<void> _launchURLBrowser(String urlString) async {
    try {
      final Uri url = Uri.parse(urlString);
      if (!await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      )) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $urlString')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error launching URL: $e')),
      );
    }
  }

  String constructLink(String selectedMou, String imoNumber) {
    String sLink = "";

    switch (selectedMou) {
      case '1': // apcis
        sLink =
            "https://apcis.tmou.org/isss/exchange_link.php?login=iomou&pwd=gF5Syw7&imonumber=$imoNumber";
        break;
      case '2': // equsis
        sLink = constructEqusisLink(imoNumber);
        break;
      case '3': // cmou
        sLink =
            "http://www.cmispsc.org/mou/cmouship.aspx?login=IOMOU&password=Acc\$io17&imonumber=$imoNumber";
        break;
      case '4': // bsmou
        sLink =
            "https://bsis.bsmou.org/exchange_link.php?action=searchByIMO&imonumber=$imoNumber&user=iomou_bsis&password=Zz741852IObs";
        break;
      default: // othersss
        sLink = "No record available";
    }
    print(sLink);
    return sLink;
  }

  String constructEqusisLink(String imoNumber) {
    if (!RegExp(r'^\d+$').hasMatch(imoNumber)) {
      return "No record available";
    }

    String strUser = "IOMOU";
    String strPwd = "iomou11";

    try {
      String strUserCrypt = strCryptage(strUser, imoNumber);
      String strPwdCrypt = strCryptage(strPwd, imoNumber);

      return "http://www.equasis.org/EquasisWeb/restricted/ShipInfo?P2=$strUserCrypt&P3=$strPwdCrypt&P1=$imoNumber&P4=018&P5=0290";
    } catch (e) {
      print("Error in constructEqusisLink: $e");
      return "No record available";
    }
  }

  String strCryptage(String input, String imoNumber) {
    var key =
        utf8.encode(imoNumber); // Assuming the IMO number is used as a key
    var bytes = utf8.encode(input);
    var hmacSha256 = Hmac(sha256, key);
    var digest = hmacSha256.convert(bytes);
    return base64Url.encode(digest.bytes); // Encoding similar to PHP
  }

  int sIndiceCarInArray(List<String> rgTableCrypt, String cCar) {
    for (int i = 0; i < rgTableCrypt.length; i++) {
      if (rgTableCrypt[i] == cCar) {
        return i;
      }
    }
    return -1; // Return -1 if character not found
  }
}
