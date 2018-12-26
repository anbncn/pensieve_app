import "dart:async";
import "dart:io";
import "dart:convert";
import 'package:flutter/services.dart' show rootBundle;

import "package:path_provider/path_provider.dart";

// Awesome data structure which provides add,search,remove of messages

// can potentially use FireBase to save data on google cloud
// for now we use local json files

class Message {
  DateTime time;
  Set<String> keys;
  String text;

  Message(this.time, this.keys, this.text);

  @override
  String toString() {
    String str = "Message is";
    str += " time:" + time.toString();
    str += " keys:" + keys.toString();
    str += " text:" + text;
    return str;
  }

  Message.fromJson(Map<String, dynamic> json) {
    if (json.length == 0) {
      return;
    }

    time = DateTime.tryParse(json["time"]);
    keys = Set<String>.from(json["keys"]);
    text = json["text"].trim();
  }

  Map<String, dynamic> toJson() {
    return {
      "time": time.toString(),
      "keys": keys.toList(),
      "text": text,
    };
  }
}

class FileManager {
  Future<String> get _localPath async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    print(path);
    return File("$path/messages.json");
  }

  Future<File> write(int index, Message msg) async {
    final file = await _localFile;
    final String comma = (index == 1) ? "" : ",";
    return file.writeAsString(comma + json.encode(msg),
        mode: FileMode.writeOnlyAppend);
  }

  Future<List<Message>> read() async {
    String staticContent = await rootBundle.loadString('assets/messages.json');
    List<Message> staticResult = _loadContent(staticContent);

    try {
      final file = await _localFile;
      String dynamicContent = await file.readAsString();
      print(dynamicContent);

      List<Message> dynamicResult = _loadContent(dynamicContent, hasBrackets: false);
      return (staticResult + dynamicResult);
    } catch (e) {
      // for some reason can't print stuff here
      return staticResult;
    }
  }

  List<Message> _loadContent(String content, {bool hasBrackets = true}) {
    if (content.isEmpty) {
      print("JSON is empty!");
      return [];
    }

    final jsonParse = json.decode(hasBrackets ? content : "[" + content + "]");
    if (jsonParse is Map) {
      print("JSON is not a list!");
      return [];
    }

    print("JSON read done, entries=${jsonParse.length}!");
    return List<Message>.from(jsonParse.map((i) => Message.fromJson(i)));
  }
}

class Pensieve {
  List<Message> messages = [];
  FileManager fileManager = FileManager();

  Pensieve() {
    fileManager.read().then((results) {
      messages = results;
    });
    for (final msg in messages) {
      print(msg.text);
    }
  }

  Set<String> getKeywords(DateTime time, String text) {
    var keys = Set<String>();
    // return by value?
    return keys;
  }

  bool commit(DateTime time, Set<String> keys, String text) {
    for (final msg in messages) {
      if (msg.time == time || msg.keys == keys || msg.text == text) {
        return true;
      }
    }

    final msg = Message(time, keys, text);
    // List::add returns void
    messages.add(msg);
    fileManager.write(messages.length, msg).then((file) {
      print("JSON write done!");
    });
    return true;
  }

  List<Message> find(DateTime time, List<String> keyList) {
    var keys = Set<String>();
    for (final k in keyList) {
      keys.add(_sanitizeKey(k));
    }

    List<Message> result = [];
    for (final msg in messages) {
      if (keys.intersection(msg.keys).isNotEmpty) {
        result.add(msg);
      }
    }
    return result;
  }

  bool remove(Message msg) {
    return messages.remove(msg);
  }

  // key utility functions
  bool keysContain(String word, Set<String> keys) {
    return keys.contains(_sanitizeKey(word));
  }

  void keysAdd(String word, Set<String> keys) {
    keys.add(_sanitizeKey(word));
  }

  void keysRemove(String word, Set<String> keys) {
    keys.remove(_sanitizeKey(word));
  }

  String _sanitizeKey(String word) {
    // ignore case, drop spaces and punctuation marks
    String key = word.toLowerCase();
    String temp = "";
    for (int i = 0; i < key.length; ++i) {
      var c = key.codeUnitAt(i);
      if ((c >= 97 && c <= 122) || (c >= 48 && c <= 57)) {
        temp += key[i];
      }
    }
    return temp;
  }
}
