import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_reddit_test/models/post.dart';
import 'package:flutter_reddit_test/widgets/post_comments.dart';

class PostDetailWidget extends StatelessWidget  {

  final Post post;

  PostDetailWidget(this.post);

  Widget _addImage() {
    if (post.source != null) {
      return Hero(
          child: Image.network(post.source, fit: BoxFit.fitWidth),
          tag: 'post_thumbnail_' + post.id);
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
          _addText(),
          PostCommentsWidget(post)
        ]
    );
  }

}