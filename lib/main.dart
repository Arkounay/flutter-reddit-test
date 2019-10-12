import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_reddit_test/post.dart';
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
Future<List<Post>> fetchPosts() async {
  final response = await http.get('https://www.reddit.com/r/popular/.json');
  return compute(parsePosts, response.body);
}

class PostsPage extends StatelessWidget  {



  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Post>>(
      future: fetchPosts(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return PostsList(snapshot.data);
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }

        return CircularProgressIndicator();
      },
    );
  }
}

class PostsList extends StatelessWidget {
  final List<Post> posts;

  PostsList(this.posts);

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: ListView.builder(
          itemCount: posts.length,
          itemBuilder: (BuildContext context, int index) {
            Post post = posts[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
              child: Ink(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow (
                      color: Colors.black12,
                      offset: Offset(0,  1),
                      blurRadius: 2,
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () => print('todo'),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Row(
                            children: <Widget>[
                              Text(post.subreddit,
                                style: TextStyle(color: Colors.black54, fontSize: 12),
                              )
                            ],
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            if (post.thumbnail.contains('http'))
                              Padding(
                                  padding: EdgeInsets.only(right: 10),
                                  child: Image.network(post.thumbnail, width: 50)
                              ),
                            Flexible(
                              child: Text(post.title, softWrap: true, textAlign: TextAlign.left,),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
      ),
    );
  }


}