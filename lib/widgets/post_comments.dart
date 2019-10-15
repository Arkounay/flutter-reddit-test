import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_reddit_test/entities/post.dart';
import 'package:http/http.dart' as http;

class PostCommentsWidget extends StatefulWidget  {
  Post post;

  PostCommentsWidget(this.post);

  @override
  State<StatefulWidget> createState() => PostCommentsWidgetState(post);

}

class Comment {
  String text;
  List<Comment> replies;

  Comment({this.text, this.replies});
  
  factory Comment.fromJson(Map<String, dynamic> json) {
    if (json['kind'] == 'more') {
      return null;
    }

    List<Comment> replies = List();
   /* for (var value in json['replies']) {
      Comment reply = Comment.fromJson(value);
      if (reply != null) {
        replies.add(reply);
      }
    }*/

    return Comment(
      text: json['body'],
      replies: replies
    );
  }
}

class PostCommentsWidgetState extends State<PostCommentsWidget> {
  Post _post;
  Future<List<Comment>> _comments;

  PostCommentsWidgetState(this._post);

  Future<List<Comment>> fetchComments(Post post) async {
    final response = await http.get(post.post_url);
    debugPrint(response.body);
    return compute(parsePosts, response.body);
  }

  static List<Comment> parsePosts(String responseBody) {
    final List parsed = json.decode(responseBody);
    return parsed.map<Comment>((json) => Comment.fromJson(parsed[0]['data']['children'])).toList();
  }

  @override
  void initState() {
    _comments = fetchComments(this._post);
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Comment>>(
      future: _comments,
      builder: (BuildContext, AsyncSnapshot<List<Comment>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length > 0) {
            return Text(snapshot.data.first.text);
          } else {
            return Text("PAS DE COMMENTAIRES LOL");
          }
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }

        return CircularProgressIndicator();
      }
    );
  }

}