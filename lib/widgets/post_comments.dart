import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_reddit_test/models/comment.dart';
import 'package:flutter_reddit_test/models/post.dart';
import 'package:http/http.dart' as http;
import 'package:timeago/timeago.dart' as timeago;


class PostCommentsWidget extends StatefulWidget {
  Post post;

  PostCommentsWidget(this.post);

  @override
  State<StatefulWidget> createState() => PostCommentsWidgetState(post);

}

class PostCommentsWidgetState extends State<PostCommentsWidget> {
  Post _post;
  Future<List<Comment>> _comments;

  PostCommentsWidgetState(this._post);

  Future<List<Comment>> fetchComments(Post post) async {
    final response = await http.get(post.fullPermalink);
    debugPrint(post.fullPermalink);

    return compute(parsePosts, response.body);
  }

  static List<Comment> parsePosts(String responseBody) {
    final List parsed = json.decode(responseBody);
    if (parsed.length > 1) {
      return parsed[1]['data']['children'].map<Comment>((json) => Comment.fromJson(json)).toList();
    }
    return new List<Comment>();
  }

  @override
  void initState() {
    _comments = fetchComments(this._post);
  }

  Widget _createCommentsWidget(List<Comment> comments, int level) {
    List<Widget> res = new List();

    for (Comment comment in comments) {
      if (comment != null) {

        res.add(
            Container(
              padding: const EdgeInsets.only(left: 8.0),
              decoration: BoxDecoration(border: Border(left: BorderSide(color: Colors.black26))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(comment.author, style: TextStyle(color: Colors.blue)),
                            Text(' • ${comment.score} points • ${timeago.format(comment.createdAt)}', style: TextStyle(color: Colors.black54))
                          ],
                        ),
                        MarkdownBody(data: comment.text),
                      ],
                    ),
                  ),
                  if (comment.replies.isNotEmpty)
                    _createCommentsWidget(comment.replies, level + 1),
                ],
              ),
            )
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: res,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Comment>>(
        future: _comments,
        builder: (BuildContext, AsyncSnapshot<List<Comment>> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.length > 0) {
              return _createCommentsWidget(snapshot.data, 0);
              // return Text(snapshot.data.first.text);
            } else {
              return Text("No comments");
            }
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }

          return Align(
            alignment: Alignment.center,
            child: Container(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(),
            ),
          );
        }
    );
  }

}