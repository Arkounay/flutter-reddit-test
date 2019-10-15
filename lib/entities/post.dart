class Post {
  final String id, subreddit, author, title, content, thumbnail, url, source;
  final DateTime createdAt;
  final int score, numComments;

  Post({this.id, this.subreddit, this.author, this.title, this.score, this.createdAt, this.thumbnail, this.url, this.source, this.content, this.numComments});

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
    );
  }

  bool get hasThumbnail => thumbnail.contains('http');

  String get post_url => 'https://www.reddit.com/' + subreddit + 'comments/' + id + '/.json';

}
