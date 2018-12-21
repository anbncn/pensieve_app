import 'package:flutter/material.dart';

import "Pensieve.dart";

// stateful text cell (to be used inside alert dialog)
class ClickableText extends StatefulWidget {
  final DateTime time;
  final String text;
  final Set<String> keys;
  final Pensieve pensieve;

  ClickableText({Key key, this.pensieve, this.time, this.text, this.keys})
      : super(key: key);

  @override
  ClickableTextState createState() {
    return ClickableTextState();
  }
}

class ClickableTextState extends State<ClickableText> {
  Widget _text(word) {
    TextStyle style = widget.pensieve.keysContain(word, widget.keys)
        ? TextStyle(fontWeight: FontWeight.bold)
        : null;
    return InkWell(
      onTap: () {
        setState(() {
          if (widget.keys.contains(word)) {
            widget.pensieve.keysRemove(word, widget.keys);
          } else {
            widget.pensieve.keysAdd(word, widget.keys);
          }
        });
      },
      child: Text(
        word,
        style: style,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> split = widget.text.split(" ");
    List<Widget> splitWords = [];
    final maxRowLen = 22;
    int currRowLen = 0;
    for (final word in split) {
      if (currRowLen + word.length >= maxRowLen) {
        splitWords.add(Text("*"));
        break;
      }
      splitWords.add(_text(word));
      splitWords.add(Text(" "));
      currRowLen += word.length;
    }

    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          Text(widget.time.toString() + "\n"),
          Row(children: splitWords),
        ],
      ),
    );
  }
}

class AddPage extends StatefulWidget {
  final Pensieve pensieve;

  AddPage({Key key, this.pensieve}) : super(key: key);

  @override
  AddPageState createState() {
    return AddPageState();
  }
}

class AddPageState extends State<AddPage> {
  final controller = TextEditingController();

  void _showDialog(BuildContext context, time, text, keys) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // content
          // pass by reference, so if keys change we also see it
          content: ClickableText(
              pensieve: widget.pensieve, time: time, text: text, keys: keys),
          // buttons
          actions: <Widget>[
            FlatButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text("Accept"),
              onPressed: () {
                setState(() {
                  // reset the text field
                  controller.text = "";
                });
                // error handling?
                widget.pensieve.commit(time, keys, text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // otherwise the textfield resizes to accommodate the keyboard
      resizeToAvoidBottomPadding: false,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: TextField(
          decoration: InputDecoration(hintText: "Put your thoughts here"),
          controller: controller,
          maxLines: 10,
          enabled: true,
          autofocus: true,
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            final time = DateTime.now();
            var keys = widget.pensieve.getKeywords(time, controller.text);
            _showDialog(context, time, controller.text, keys);
          },
          tooltip: "Submit!",
          child: Icon(Icons.check)),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}