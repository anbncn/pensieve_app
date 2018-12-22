import 'package:flutter/material.dart';

import 'Pensieve.dart';
import 'AboutPage.dart';
import 'AddPage.dart';
import 'BackupPage.dart';
import 'FeedbackPage.dart';
import 'SearchPage.dart';
import 'SettingsPage.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  Pensieve pensieve = Pensieve();

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text("Pensieve"),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final options = ["Home", "About", "Feedback", "Settings", "Backup"];

    // auto (i.e. var) does not work as dart is unable to identify the type as
    // List<Widget> later on
    List<Widget> drawerTiles = [];
    for (final opt in options) {
      drawerTiles.add(
        ListTile(
            title: Text(opt),
            onTap: () {
              Navigator.pop(context);
              _onSelection(context, opt);
            }),
      );
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            // TODO: put a logo here maybe
            child: Text('Pensieve'),
            decoration: BoxDecoration(color: Colors.blue),
          ),
          Column(children: drawerTiles),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.add),
      tooltip: 'Add',
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddPage(
                      pensieve: pensieve,
                    )));
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    return SearchPage(
      pensieve: pensieve,
    );
  }

  void _onSelection(BuildContext context, String option) {
    switch (option) {
      case "About":
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => AboutPage()));
        break;
      case "Feedback":
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => FeedbackPage()));
        break;
      case "Settings":
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SettingsPage()));
        break;
      case "Backup":
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => BackupPage()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      drawer: _buildDrawer(context),
      floatingActionButton: _buildAddButton(context),
      body: _buildBody(context),
    );
  }
}
