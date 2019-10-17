import 'package:flutter/cupertino.dart';

class Subreddit extends ChangeNotifier {
  String _name = '/r/popular';

  String get name {
    if (_name.indexOf('/r/') != 0) {
      return '/r/' + _name;
    }
    return _name;
  }

  String get url => 'https://www.reddit.com/' + name + '/top.json';

  set name(String value) {
    _name = value;
    notifyListeners();
  }

  @override
  String toString() => name;
}
