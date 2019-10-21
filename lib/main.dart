import 'dart:convert';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_reddit_test/saved_page.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models/post.dart';
import 'models/subreddit.dart';
import 'widgets/post_item_widget.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {

  final Subreddit subreddit = Subreddit();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      builder: (context) => subreddit,
      child: MaterialApp(
        title: 'Reddit ' + subreddit.name,
        theme: ThemeData(primarySwatch: Colors.blue),
        home: HomePage(),
      ),
    );
  }

}

class HomePage extends StatefulWidget {

  HomePage();

  @override
  _HomePageState createState() => _HomePageState();

}


class _HomePageState extends State<HomePage> {
  TextEditingController _subredditAlertController = TextEditingController();

  _HomePageState();

  @override
  void dispose() {
    _subredditAlertController.dispose();
    super.dispose();
  }

  _changeSubreddit(Subreddit subreddit) {
    setState(() {
      subreddit.name = _subredditAlertController.text;
    });
    Navigator.of(context).pop();
  }

  void _changeSubredditDialog(Subreddit subreddit) {
    showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change subreddit'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: _subredditAlertController,
                  onSubmitted: (String str) {
                    _changeSubreddit(subreddit);
                  },
                  decoration: InputDecoration(
                      hintText: 'Enter a subreddit'
                  ),
                )
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Go to subreddit'),
              onPressed: () => _changeSubreddit(subreddit),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Subreddit>(
        builder: (context, subreddit, child) {
          return Scaffold(
              drawer: Drawer(
                  child: Column(
                    // Important: Remove any padding from the ListView.
                    children: <Widget>[
                      Expanded(
                        // ListView contains a group of widgets that scroll inside the drawer
                        child: ListView(
                          children: <Widget>[
                            DrawerHeader(
                              child: Text('Reddit Flutter Test', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                              ),
                            ),
                            ListTile(
                              title: Text('Change Subreddit'),
                              onTap: () {
                                Navigator.pop(context);
                                _changeSubredditDialog(subreddit);
                              },
                            ),
                            ListTile(
                              title: Text('Saved Posts'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => SavedPage()),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      ListTile(
                        title: Text('View on GitHub'),
                        onTap: () async {
                          final url = 'https://github.com/Arkounay/flutter-reddit-test';
                          if (await canLaunch(url)) {
                            await launch(url);
                          } else {
                            throw 'Could not launch $url';
                          }
                        },
                      ),
                    ],
                  ),
              ),
              appBar: AppBar(
                // Here we take the value from the MyHomePage object that was created by
                // the App.build method, and use it to set our appbar title.
                title: Text('Reddit ' + subreddit.toString()),
                actions: <Widget>[
                  Theme(
                    data: ThemeData.dark(),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Sort>(
                        value: subreddit.sort,
                        onChanged: (Sort newValue) {
                          subreddit.sort = newValue;
                        },
                        items: Sort.values.map<DropdownMenuItem<Sort>>((Sort value) {
                          return DropdownMenuItem<Sort>(
                            value: value,
                            child: Text(EnumToString.parse(value)),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  Tooltip(
                    message: 'Change subreddit',
                    child: IconButton(
                        icon: Icon(Icons.change_history),
                        onPressed: () async {
                          _changeSubredditDialog(subreddit);
                        }
                    ),
                  ),
                ],
              ),
              body: PostsPage(subreddit: subreddit)
          );
        }
    );
  }
}

List<Post> parsePosts(String responseBody) {
  try {
    final List parsed = json.decode(responseBody)['data']['children'];
    return parsed.map<Post>((json) => Post.fromJson(json['data'])).toList();
  } catch (e) {
    return null;
  }
}


class PostsPage extends StatefulWidget {

  final Subreddit subreddit;

  PostsPage({Key key, this.subreddit}) : super(key: key);

  @override
  State<StatefulWidget> createState() => PostsPageState();

}

class PostsPageState extends State<PostsPage> {

  Future<List<Post>> _posts;
  ScrollController _scrollController = ScrollController();
  bool _isLoadingExtra = false;
  bool _refreshing = false;

  /* // widget.subreddit.addListener seems nicer
  @override
  void didUpdateWidget(PostsPage oldWidget) {
    super.didUpdateWidget(oldWidget);

   _posts = null;
   _posts = fetchPosts(subreddit: widget.subreddit);
  }
  */

  void _init() {
    _posts = fetchPosts(subreddit: widget.subreddit);
  }

  @override
  void initState() {
    super.initState();
    widget.subreddit.addListener(() => _init());
    _init();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        setState(() {
          _isLoadingExtra = true;
          _posts.then((List<Post> posts) {
            Future<List<Post>> nextPosts = fetchPosts(lastPost: posts.last, subreddit: widget.subreddit);
            nextPosts.then((List<Post> newPosts) {
              posts.addAll(newPosts);
              setState(() {
                _isLoadingExtra = false;
              });
            });
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<List<Post>> fetchPosts({@required Subreddit subreddit, Post lastPost}) async {
    final response = await http.get(subreddit.url + (lastPost != null ? '?from:' + lastPost.id : ''));
    return compute(parsePosts, response.body);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Post>>(
      future: _posts,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.connectionState == ConnectionState.done || _isLoadingExtra || _refreshing) {
          if (snapshot.data.isNotEmpty) {
            return RefreshIndicator(
              child: PostsList(snapshot.data, _scrollController, _isLoadingExtra),
              onRefresh: () {
                setState(() {
                  _refreshing = true;
                  _posts = fetchPosts(subreddit: widget.subreddit);
                  _posts.then((_) {
                    setState(() {
                      _refreshing = false;
                    });
                  });
                });
                return _posts;
              },
            );
          } else {
            return Center(child: Text("No result"));
          }
        } else if (snapshot.hasError) {
          return Center(child: Text("${snapshot.error}"));
        }

        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

class PostsList extends StatelessWidget {
  final List<Post> _posts;
  final ScrollController _scrollController;
  final bool _isLoadingExtra;

  PostsList(this._posts, this._scrollController, this._isLoadingExtra);

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: ListView.builder(
          controller: _scrollController,
          itemCount: _posts.length,
          itemBuilder: (BuildContext context, int index) {
            Post post = _posts[index];
            return Column(
              children: <Widget>[
                PostItemWidget(post),
                if (index == _posts.length - 1)
                  if (_isLoadingExtra)
                    Padding(child: CircularProgressIndicator(), padding: EdgeInsets.all(10))
                  else
                    Padding(padding: EdgeInsets.all(30))
              ],
            );
          }
      ),
    );
  }


}