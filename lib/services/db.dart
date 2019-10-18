import 'package:flutter_reddit_test/models/post.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Db {

  static final Db _instance = Db._internal();
  factory Db() => _instance;

  Database _db;
  Database get db => _db;

  Db._internal() {
    _init();
  }

  _init() async {
    _db = await openDatabase(
        join(await getDatabasesPath(), 'main.db'),
        onCreate: (db, version) {
          return db.execute("""
            CREATE TABLE `post` (
              `id` varchar(255) NOT NULL,
              `subreddit` varchar(255) NOT NULL,
              `author` varchar(255) NOT NULL,
              `title` varchar(255) NOT NULL,
              `content` varchar(255) NOT NULL,
              `thumbnail` varchar(255) NOT NULL,
              `url` varchar(255) NOT NULL,
              `source` varchar(255) NOT NULL,
              `permalink` varchar(255) NOT NULL,
              `createdAt` int(11) NOT NULL,
              `savedAt` int(11) NOT NULL,
              `score` int(11) NOT NULL,
              `numComments` int(11) NOT NULL
            )
            """);
        }
    );
  }

  Future<void> insertPost(Post post) async {
    // Get a reference to the database.
    final db = _db;
    await db.insert(
      'post',
      post.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Post>> posts() async {
    final List<Map<String, dynamic>> maps = await db.query('dogs');

    return List.generate(maps.length, (i) {
      return Post(
        id: maps[i]['id'],
        subreddit: maps[i]['subreddit'],
        author: maps[i]['author'],
        title: maps[i]['title'],
        content: maps[i]['content'],
        thumbnail: maps[i]['thumbnail'],
        url: maps[i]['url'],
        source: maps[i]['source'],
        permalink: maps[i]['permalink'],
        createdAt: maps[i]['createdAt'],
        savedAt: maps[i]['savedAt'],
        score: maps[i]['score'],
        numComments: maps[i]['numComments'],
      );
    });
  }


}