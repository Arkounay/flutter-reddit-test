class Comment {
  final String text, author;
  final int score;
  final List<Comment> replies;
  final DateTime createdAt;

  Comment({this.text, this.replies, this.author, this.score, this.createdAt});

  factory Comment.fromJson(Map<String, dynamic> json) {
    if (json['data'] == null || json['kind'] == 'more') {
      return null;
    }

    List<Comment> replies = List();
    try {
      for (var value in json['data']['replies']['data']['children']) {
        Comment reply = Comment.fromJson(value);
        if (reply != null) {
          replies.add(reply);
        }
      }
    } catch (e) {}

    return Comment(
      text: json['data']['body'] ?? '',
      author: json['data']['author'] ?? '',
      createdAt: DateTime.fromMicrosecondsSinceEpoch((json['data']['created'] * 1000000).round()),
      replies: replies,
      score: json['data']['score'] ?? 0,
    );
  }

}
