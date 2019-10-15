import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'entities/post.dart';
import 'widgets/post_item_widget.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reddit /r/popular',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: HomePage('Reddit /r/popular'),
    );
  }
}

class HomePage extends StatefulWidget {

  final String title;

  HomePage(this.title);

  @override
  _HomePageState createState() => _HomePageState();

}


class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
       body: PostsPage()
    );
  }
}
List<Post> parsePosts(String responseBody) {

  final List parsed = json.decode(responseBody)['data']['children'];

  return parsed.map<Post>((json) => Post.fromJson(json['data'])).toList();
}


class PostsPage extends StatefulWidget  {

  @override
  State<StatefulWidget> createState() => PostsPageState();

}

class PostsPageState extends State<PostsPage> {

  Future<List<Post>> _posts;
  ScrollController _scrollController = ScrollController();
  bool isLoadingExtra = false;

  @override
  void initState() {
    super.initState();
    _posts = fetchPosts();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        setState(() {
          isLoadingExtra = true;
          _posts.then((List<Post> posts) {
            Future<List<Post>> nextPosts = fetchPosts(lastPost: posts.last);
            nextPosts.then((List<Post> newPosts) {
              posts.addAll(newPosts);
              setState(() {
                isLoadingExtra = false;
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

  Future<List<Post>> fetchPosts({Post lastPost}) async {
    final response = await http.get('https://www.reddit.com/r/popular/.json' + (lastPost != null ? '?from:' + lastPost.id : ''));
    return compute(parsePosts, response.body);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Post>>(
      future: _posts,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return RefreshIndicator(
            child: PostsList(snapshot.data, _scrollController, isLoadingExtra),
            onRefresh: () {
              setState(() {
                _posts = fetchPosts();
              });
              return _posts;
            },
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }

        return CircularProgressIndicator();
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