import 'package:flutter/material.dart';

import "Pensieve.dart";

class TextPage extends StatelessWidget {
  final Message message;

  TextPage({Key key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Message'),
      ),
      body: Text(message.text),
    );
  }
}

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

  void _navigateToTextScreen(BuildContext context, Message message) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TextPage(
                  message: message,
                )));
  }

  List<Widget> _buildSearch(BuildContext context) {
    List<Message> messages = widget.pensieve.find(null, input.split(" "));

    List<Widget> searchResults = [];
    for (final msg in messages) {
      searchResults.add(ListTile(
        title: Text(msg.text, maxLines: 2, overflow: TextOverflow.ellipsis),
        onTap: () {
          _navigateToTextScreen(context, msg);
        },
      ));
    }

    if (searchResults.length == 0) {
      searchResults.add(ListTile(
        title: Text(""),
      ));
    }

    return searchResults;
  }

  Widget _buildInput(BuildContext context) {
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
      body: Column(
        children: <Widget>[
          _buildInput(context),
          Expanded(child: ListView(children: _buildSearch(context))),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
