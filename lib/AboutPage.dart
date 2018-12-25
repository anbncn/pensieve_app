import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  Widget _buildText(BuildContext context, msg, author) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: msg, style: TextStyle(),),
          TextSpan(text: "\n\n",),
          TextSpan(text: author, style: TextStyle(fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final msg =
        "I use the Pensieve. One simply siphons the excess thoughts from one's mind, pours them into the basin, and examines them at one's leisure. It becomes easier to spot patterns and links, you understand, when they are in this form.";
    final author = "Albus Dumbledore";
    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(flex: 1, child: Container(),),
            Expanded(flex: 2, child: _buildText(context, msg, author),),
            Expanded(flex: 10, child: Container(),),
          ],
        ),
      ),
    );
  }
}
