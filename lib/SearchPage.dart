import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import "Pensieve.dart";

class TextPage extends StatelessWidget {
  final Message message;

  TextPage({Key key, this.message}) : super(key: key);

  Widget _time(BuildContext context, DateTime time) {
    final formatter = new DateFormat.yMMMd().add_jm();
    final dateStr = formatter.format(time);
    return Text.rich(TextSpan(text: dateStr, style: TextStyle(fontWeight: FontWeight.bold)),);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Message'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(flex: 1, child: Container()),
            Expanded(flex: 1, child: _time(context, message.time),),
            Expanded(flex: 1, child: Text(message.text)),
            Expanded(flex: 10, child: Container()),
          ],
        ),
      ),
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

  Widget _time(BuildContext context, DateTime time) {
    final formatter = new DateFormat.yMMMd().add_jm();
    final dateStr = formatter.format(time);
    return Text.rich(
      TextSpan(text: dateStr,
          style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 0.75)
      ),
    );
  }

  List<Widget> _buildSearch(BuildContext context) {
    List<Message> messages = widget.pensieve.find(null, input.split(" "));

    List<Widget> searchResults = [];
    for (final msg in messages) {
      searchResults.add(InkWell(
        // can use Card instead of ListTile as well
        // ListTile looks a bit better
        child: ListTile(title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _time(context, msg.time),
            Text(msg.text, maxLines: 2, overflow: TextOverflow.ellipsis)
          ],
        )),
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
