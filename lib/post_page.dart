import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models/post.dart';
import 'widgets/post_detail_widget.dart';
import 'package:share/share.dart';

class PostPage extends StatelessWidget {
  final Post post;

  PostPage(this.post);

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
              IconButton(
                icon: Icon(Icons.share),
                onPressed: () {
                  final url = 'https://www.reddit.com' + post.permalink;
                  Share.share(url);
                }
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