import 'package:flutter/material.dart';

void main() {
  // better to use MaterialApp as it brings in some top level Widgets like
  // Navigator etc, and is recommended if we use Material Design
  runApp(
    MaterialApp(
      title: "PensieveApp",
      home: HomePage(),
    ),
  );
}

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('About'),);
  }
}

class FeedbackPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Feedback'),);
  }
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Settings'),);
  }
}

class BackupPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Backup'),);
  }
}

class AddPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Add'),);
  }
}

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Search'),);
  }
}

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  String state = "default";

  Widget _buildAppBar() {
    return AppBar(
      title: Text("Pensieve"),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final options = ["About", "Feedback", "Settings", "Backup"];

    // auto (i.e. var) does not work as dart is unable to identify the type as
    // List<Widget> later on
    List<Widget> drawerTiles = [];
    for (final opt in options) {
      drawerTiles.add(ListTile(
          title: Text(opt),
          onTap: () {
            _onSelection(opt);
            Navigator.pop(context);
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

  Widget _buildAddButton() {
    return FloatingActionButton(
        child: Icon(Icons.add), tooltip: 'Add', onPressed: _onAdd);
  }

  Widget _buildBody() {
    switch (state) {
      case "About":
        return AboutPage();
        break;
      case "Feedback":
        return FeedbackPage();
        break;
      case "Settings":
        return SettingsPage();
        break;
      case "Backup":
        return BackupPage();
        break;
      case "Add":
        return AddPage();
        break;
      case "Search":
        return SearchPage();
        break;
    }

    // default
    return Center(
      child: Text("Home"),
    );
  }

  void _onAdd() {
    _onSelection("Add");
  }

  void _onSearch() {
    _onSelection("Search");
  }

  void _onSelection(String option) {
    // causes to rerun the build
    setState(() {
      state = option;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: _buildDrawer(context),
      floatingActionButton: _buildAddButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _buildBody(),
    );
  }
}