import 'package:flutter/material.dart';

class SearchListExample extends StatefulWidget {
  @override
  _SearchListExampleState createState() => _SearchListExampleState();
}

class _SearchListExampleState extends State<SearchListExample> {
  final List<String> items = [
    "Apple",
    "Banana",
    "Cherry",
    "Date",
    "Fig",
    "Grape"
  ];
  List<String> filteredItems = [];
  String query = "";

  @override
  void initState() {
    super.initState();
    filteredItems = items; // Initially show all items
  }

  void updateSearch(String searchText) {
    setState(() {
      query = searchText;
      filteredItems = items
          .where(
              (item) => item.toLowerCase().contains(searchText.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: const InputDecoration(hintText: "Search..."),
          onChanged: updateSearch,
        ),
      ),
      body: ListView.builder(
        itemCount: filteredItems.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(filteredItems[index]),
          );
        },
      ),
    );
  }
}

void main() => runApp(MaterialApp(home: SearchListExample()));
