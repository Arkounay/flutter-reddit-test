class Post {
  final String subreddit;
  final String author;
  final String title;
  final int score;
  final DateTime createdAt;
  final String thumbnail;


  Post({this.subreddit, this.author, this.title, this.score, this.createdAt, this.thumbnail});

  factory Post.fromJson(Map<String, dynamic> json) {

    return Post(
      subreddit: json['subreddit'],
      author: json['author_fullname'],
      title: json['title'],
      score: json['score'],
      thumbnail: json['thumbnail']
    );
  }

}
