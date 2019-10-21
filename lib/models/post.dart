import 'package:flutter/cupertino.dart';

class Post {
  final String id, subreddit, author, title, content, thumbnail, url, source, permalink;
  final DateTime createdAt;
  DateTime savedAt;
  final int score, numComments;

  Post({this.id, this.subreddit, this.author, this.title, this.score, this.createdAt, this.savedAt, this.thumbnail, this.url, this.source, this.content, this.numComments, this.permalink});

  factory Post.fromJson(Map<String, dynamic> json) {
    String source;
    try {
      source = Uri.decodeComponent(json['preview']['images'][0]['source']['url']).replaceAll('&amp;', '&');
    } catch (e) {}

    return Post(
      id: json['name'],
      subreddit: json['subreddit_name_prefixed'],
      author: json['author_fullname'],
      title: json['title'],
      score: json['score'],
      thumbnail: json['thumbnail'],
      url: json['url'].replaceAll('&amp;', '&'),
      createdAt: DateTime.fromMicrosecondsSinceEpoch((json['created'] * 1000000).round()),
      source: source,
      content: json['selftext'] ?? '',
      numComments: json['numComments'],
      permalink: json['permalink'],
    );
  }

  bool get hasThumbnail => thumbnail.contains('http');

  String get fullPermalink => 'https://www.reddit.com/' + permalink + '.json';

  String get abbrScore {
    if (score > 1000) {
      return (score / 1000).round().toString() + 'k';
    }

    return score.toString();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subreddit': subreddit,
      'author': author,
      'title': title,
      'content': content,
      'thumbnail': thumbnail,
      'url': url,
      'source': source,
      'permalink': permalink,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'savedAt': savedAt?.millisecondsSinceEpoch,
      'score': score,
      'numComments': numComments,
    };
  }

}
