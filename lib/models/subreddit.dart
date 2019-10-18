import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';

class Subreddit extends ChangeNotifier {
  String _name = '/r/popular';
  Sort _sort = Sort.Hot;

  Sort get sort => _sort;

  set sort(Sort value) {
    _sort = value;
    notifyListeners();
  }

  String get name {
    if (_name.indexOf('/r/') != 0) {
      return '/r/' + _name;
    }
    return _name;
  }

  String get url => 'https://www.reddit.com' + name + '/' + EnumToString.parse(sort).toLowerCase() + '.json';

  set name(String value) {
    _name = value;
    notifyListeners();
  }

  @override
  String toString() => name;
}

enum Sort {
  Best, Hot, New, Top, Rising
}