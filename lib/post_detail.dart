import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_reddit_test/entities/post.dart';
import 'package:http/http.dart' as http;

class PostDetail extends StatelessWidget {
  final Post post;

  PostDetail(this.post);

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
            leading: IconButton(icon:Icon(Icons.arrow_back),
              onPressed:() => Navigator.pop(context, false),
            )
          ),
          body: PostPage(post)
      ),
    );
  }

}


class PostPage extends StatelessWidget  {

  final Post post;

  PostPage(this.post);

  Widget _addImage() {
    if (post.source != null) {
      return Image.network(post.source, fit: BoxFit.fitWidth);
    }
    return Container();
  }

  Widget _addText() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: MarkdownBody(data: post.content),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
        children: <Widget>[
          _addImage(),
          _addText()
        ]
    );
  }


}