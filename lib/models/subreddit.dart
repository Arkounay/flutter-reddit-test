import 'package:flutter/cupertino.dart';

class Subreddit extends ChangeNotifier {
  String _name = '/r/popular';

  String get name => _name;

  String get url => 'https://www.reddit.com/' + _name + '/top.json';

  set name(String value) {
    _name = value;
    notifyListeners();
  }

  @override
  String toString() => _name;
}
