import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models/post.dart';
import 'widgets/post_detail_widget.dart';

class PostPage extends StatelessWidget {
  final Post post;

  PostPage(this.post);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: post.title,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
          appBar: AppBar(
            title: Text(post.title),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.open_in_browser),
                onPressed: () async {
                  final url = 'https://www.reddit.com' + post.permalink;
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    throw 'Could not launch $url';
                  }
                },
              ),
            ],
            leading: IconButton(icon:Icon(Icons.arrow_back),
              onPressed:() => Navigator.pop(context, false),
            )
          ),
          body: PostDetailWidget(post)
      ),
    );
  }

}