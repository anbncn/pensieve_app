// Awesome data structure which provides add,search,remove of messages

// can potentially use FireBase to save data on google cloud
// for now we use local json files

class Message {
  DateTime time;
  Set<String> keys;
  String text;

  Message(this.time, this.keys, this.text);
}

class Pensieve {
  List<Message> messages = [];

  Set<String> getKeywords(DateTime time, String text) {
    var keys = Set<String>();
    keys.add("hunter");
    // return by value?
    return keys;
  }

  bool commit(DateTime time, Set<String> keys, String text) {
    for(final msg in messages) {
      if (msg.time == time || msg.keys == keys || msg.text == text) {
        return true;
      }
    }

    // List::add returns void
    messages.add(Message(time, keys, text));
    return true;
  }

  List<Message> find(DateTime time, List<String> keyList) {
    var keys = Set<String>();
    for (final k in keyList) {
      keys.add(k);
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
  bool keysContain(String key, Set<String> keys) {
    return keys.contains(key);
  }

  void keysAdd(String key, Set<String> keys) {
    keys.add(key);
  }

  void keysRemove(String key, Set<String> keys) {
    keys.remove(key);
  }
}