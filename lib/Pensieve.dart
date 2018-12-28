import "dart:async";
import "dart:io";
import "dart:convert";

import "package:path_provider/path_provider.dart";

// Awesome data structure which provides add,search,remove of messages

class Message {
  DateTime time;
  Set<String> keys;
  String text;

  Message(this.time, this.keys, this.text);

  @override
  String toString() {
    String str = "Message =";
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
  // hack as its sort of impossible to get file size synchronously
  int _fileSize = 0;
  int get fileSize {
    return _fileSize;
  }

  Future<String> get localPath async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  Future<File> get localFile async {
    final path = await localPath;
    final file = File("$path/messages.json");
    final exists = await file.exists();
    if (!exists) {
      print("JSON creating!");
      await file.writeAsString('[\n]');
      _fileSize = 0;
    }
    return file;
  }

  Future<bool> reset() async {
    try {
      final file = await localFile;
      await file.delete();
      _fileSize = 0;
    } catch (e) {
      print(e.toString());
      return false;
    }
    print("JSON reset!");
    return true;
  }

  Future<bool> write(int index, Message msg) async {
    try {
      final file = await localFile;
      RandomAccessFile rafile = await file.open(mode: FileMode.append);
      print(rafile.lengthSync());
      sleep(const Duration(seconds: 1));

      final pos = rafile.positionSync() - 1;
      rafile.setPositionSync(pos);

      // for some reason readByteSync throws upon unpause if you just hot reload
      // maybe because somehow the app still uses an older code when unpausing
      // reload after wiping data to make sure the app uses "consistent" code
      if (rafile.readByteSync() != 93) {
        print("JSON last byte not ]!");
        rafile.close();
        return false;
      }
      rafile.setPositionSync(pos);

      final String comma = (index == 1) ? "" : ",";
      await rafile.writeString(comma + json.encode(msg) + "\n]");
      rafile.close();

      _fileSize = file.lengthSync();
    } catch (e) {
      print(e.toString());
      return false;
    }

    return true;
  }

  Future<List<Message>> read() async {
    try {
      final file = await localFile;
      String content = await file.readAsString();
      //print(content);
      _fileSize = file.lengthSync();
      return _loadContent(content);
    } catch (e) {
      // for some reason can't print other stuff here
      print("Exception" + e.toString());
      return [];
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
  FileManager fileManager = FileManager();
  List<Message> _messages = [];

  Pensieve() {
    loadFile();
  }

  int get numMessages {
    return _messages.length;
  }

  DateTime get lastModified {
    final time = (numMessages > 0) ? _messages[numMessages - 1].time : null;
    return time;
  }

  // can be called from outside (for ex. when file changes externally)
  void loadFile() {
    _messages = [];
    fileManager.read().then((results) {
      _messages = results;
      for (final msg in _messages) {
        //print(msg.toString());
      }
    });
  }

  Set<String> getKeywords(DateTime time, String text) {
    var keys = Set<String>();
    // return by value?
    return keys;
  }

  bool commit(DateTime time, Set<String> keys, String text) {
    for (final msg in _messages) {
      if (msg.time == time || msg.keys == keys || msg.text == text) {
        return true;
      }
    }

    final msg = Message(time, keys, text);
    // List::add returns void
    _messages.add(msg);
    fileManager.write(_messages.length, msg).then((status) {
      print("JSON write done=$status!");
    });
    return true;
  }

  List<Message> find(DateTime time, List<String> keyList) {
    var keys = Set<String>();
    for (final k in keyList) {
      keys.add(_sanitizeKey(k));
    }

    List<Message> result = [];
    for (final msg in _messages) {
      if (keys.intersection(msg.keys).isNotEmpty) {
        result.add(msg);
      }
    }
    return result;
  }

  bool remove(Message msg) {
    return _messages.remove(msg);
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
