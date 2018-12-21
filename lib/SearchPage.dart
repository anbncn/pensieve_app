import 'package:flutter/material.dart';

import "Pensieve.dart";

class SearchPage extends StatefulWidget {
  final Pensieve pensieve;

  SearchPage({Key key, this.pensieve}) : super(key: key);

  @override
  SearchPageState createState() {
    return SearchPageState();
  }
}

class SearchPageState extends State<SearchPage> {
  final controller = TextEditingController();
  String input = "";

  List<Widget> _buildSearch() {
    List<Message> messages = widget.pensieve.find(null, input.split(" "));

    List<Widget> searchResults = [];
    for (final msg in messages) {
      searchResults.add(ListTile(
        title: Text(msg.text),
        onTap: () { /*open a new page to edit/delete*/ },
      ));
    }

    if (searchResults.length == 0) {
      searchResults.add(ListTile(
        title: Text(""),
      ));
    }

    return searchResults;
  }

  Widget _buildInput() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(hintText: "Search your thoughts here"),
        controller: controller,
        onChanged: (text) {
          setState(() {
            input = text;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // otherwise the textfield resizes to accommodate the keyboard
        resizeToAvoidBottomPadding: false,
        body: ListView(
          children: <Widget>[
            _buildInput(),
            Column(children: _buildSearch()),
          ],
        ));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
