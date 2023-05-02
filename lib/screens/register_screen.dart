import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  Map<String, String> regions = {};
  Map<String, String> provinces = {};
  bool isRegionsLoaded = false;
  bool isProvincesLoaded = false;
  TextEditingController _regionController = TextEditingController();
  TextEditingController _provinceController = TextEditingController();
  TextEditingController _userNameController = TextEditingController();

  void callAPI() async {
    //set url
    //var url = Uri.parse('https://psgc.gitlab.io/api/island-groups/');
    //https://psgc.gitlab.io/api/regions/
    var url = Uri.https('psgc.gitlab.io', 'api/regions');
    var response = await http.get(url);
    print(response.statusCode);
    print(response.body);
  }

  Future<void> loadRegions() async {
    //get regions
    var url = Uri.https('psgc.gitlab.io', 'api/regions');
    var response = await http.get(url);
    //decode json response
    List decodedResponse = jsonDecode(response.body);
    decodedResponse.forEach((element) {
      Map item = element;
      // print(item['regionName']);
      regions.addAll({item['code']: item['regionName']});
    });
    //Map <key, value> code: regionName
    print(regions);
    setState(() {
      isRegionsLoaded = true;
    });
  }

  Future<void> loadProvinces(String regionCode) async {
    var url = Uri.https('psgc.gitlab.io', 'api/regions/$regionCode/provinces');
    var response = await http.get(url);
    List decodedResponse = jsonDecode(response.body);
    provinces.clear();
    decodedResponse.forEach((element) {
      Map item = element;
      // print(item['regionName']);
      provinces.addAll({item['code']: item['name']});
    });
    print(provinces);
    setState(() {
      isProvincesLoaded = true;
    });
  }

  Future<void> register() async {
    var url = Uri.parse('http://132.168.13.238/flutter_3b_php/register.php');
    var response = await http.post(url, body: {
      'username': _userNameController.text,
      'province': _provinceController.text,
    });
    print(response.statusCode);
    print(response.body);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadRegions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!isRegionsLoaded)
              const Center(child: CircularProgressIndicator())
            else
              DropdownMenu(
                controller: _regionController,
                label: const Text('Region'),
                // enableFilter: true,
                enableSearch: true,
                dropdownMenuEntries: regions.entries.map((item) {
                  return DropdownMenuEntry(value: item.key, label: item.value);
                }).toList(),
                // initialSelection: 'B',
                onSelected: (value) async {
                  print(value);
                  setState(() {
                    isProvincesLoaded = false;
                  });
                  await loadProvinces(value!);
                },
              ),
            const SizedBox(
              height: 8,
            ),
            if (isProvincesLoaded)
              DropdownMenu(
                controller: _provinceController,
                label: const Text('Provinces'),
                // enableFilter: true,
                enableSearch: true,
                dropdownMenuEntries: provinces.entries.map((item) {
                  return DropdownMenuEntry(value: item.key, label: item.value);
                }).toList(),
                // initialSelection: 'B',
                onSelected: (value) {
                  print(value);
                },
              ),
            const SizedBox(
              height: 8,
            ),
            TextField(
              controller: _userNameController,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(),
              ),
            ),
            ElevatedButton(
              onPressed: register,
              child: const Text('Call'),
            ),
          ],
        ),
      ),
    );
  }
}
