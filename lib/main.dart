import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(GetMaterialApp(
    home: Search(),
    debugShowCheckedModeBanner: false,
  ));
}

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);
  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  List<String> allCharacters = [];
  List<String> matchs = [];
  RxMap dattaCaracters = <String, dynamic>{}.obs;

  TextEditingController searchController = TextEditingController();
  Key autocompleteKey = UniqueKey();

  Future<void> fetchRick(String searchTerm) async {
    final connect =
        await http.get(Uri.parse("https://rickandmortyapi.com/api/character"));

    if (connect.statusCode == 200) {
      var alldata = json.decode(connect.body);
      var data = alldata['results'];
      allCharacters.clear();

      for (var i = 0; i < data.length; i++) {
        var search = data[i]['name'];
        allCharacters.add(search);
        if (search.toLowerCase() == searchTerm.toLowerCase()) {
          var id = data[i]['id'] - 1;
          dattaCaracters.addAll(data[id]);
        }
      }

      var regex = RegExp(searchTerm, caseSensitive: false);
      matchs = allCharacters.where((name) => regex.hasMatch(name)).toList();
    }
  }

  Future<void> _refresh() {
    return Future.delayed(Duration(seconds: 1));
  }

  @override
  void initState() {
    super.initState();
    fetchRick('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image.asset(
            'assets/images/logo.png',
            width: 40,
          ),
          Text('Rick et Morty Wiki')
        ]),
        backgroundColor: Colors.green[500],
      ),
      body: ListView(
        children: [
          Row(
            children: [
              SizedBox(height: 20),
              Expanded(
                child: Autocomplete<String>(
                  key: autocompleteKey,
                  optionsBuilder: (textEditingValue) async {
                    await fetchRick(textEditingValue.text);
                    return matchs;
                  },
                  onSelected: (value) {
                    searchController.text = value;
                  },
                ),
              ),
              IconButton(
                onPressed: () {
                  searchController.clear();

                  setState(() {
                    autocompleteKey = UniqueKey();
                  });
                  dattaCaracters.clear();
                },
                icon: Icon(Icons.clear),
              ),
            ],
          ),
          SizedBox(height: 20),
          Obx(() {
            if (dattaCaracters['name'] != null) {
              return Column(
                children: [
                  Text(
                    dattaCaracters['name'],
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Image.network(dattaCaracters['image']),
                  SizedBox(height: 20),
                  Text("Status : " + dattaCaracters['status']),
                  Text("Espèce : " + dattaCaracters['species']),
                  Text("Genre : " + dattaCaracters['gender']),
                  Text("Origine : " + dattaCaracters['origin']['name']),
                  Text("Localisation : " + dattaCaracters['location']['name']),
                  SizedBox(height: 20),
                  for (int i = 0; i < dattaCaracters['episode'].length; i++)
                    InkWell(
                        onTap: () async {
                          await launch(dattaCaracters['episode'][i]);
                        },
                        child: Text(
                          dattaCaracters['episode'][i],
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: Colors.blue),
                        ))
                ],
              );
            } else {
              return Text('');
            }
          })
        ],
      ),
    );
  }
}
