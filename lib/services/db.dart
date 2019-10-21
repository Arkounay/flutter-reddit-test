import 'package:flutter_reddit_test/models/post.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Db {

  static final Db _instance = Db._internal();

  factory Db() => _instance;

  Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await _init();

    return _db;
  }

  Db._internal();


  _init() async {
      return openDatabase(
        join(await getDatabasesPath(), 'main.db'),
        version: 1,
        onCreate: (db, version) {
          return db.execute("""
            CREATE TABLE `post` (
              `id` varchar(255) NOT NULL,
              `subreddit` varchar(255) NOT NULL,
              `author` varchar(255) NOT NULL,
              `title` varchar(255) NOT NULL,
              `content` varchar(255) NOT NULL,
              `thumbnail` varchar(255),
              `url` varchar(255),
              `source` varchar(255),
              `permalink` varchar(255) NOT NULL,
              `createdAt` int(11),
              `savedAt` int(11),
              `score` int(11) NOT NULL,
              `numComments` int(11)
            )
            """);
        }
    );
  }

  Future<void> insertPost(Post post) async {
    final Database client = await db;
    post.savedAt = DateTime.now();
    await client.insert(
      'post',
      post.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Post>> posts() async {
    final Database client = await db;
    final List<Map<String, dynamic>> maps = await client.query('post');

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
        createdAt: DateTime.fromMicrosecondsSinceEpoch(maps[i]['createdAt']),
        savedAt: DateTime.fromMicrosecondsSinceEpoch(maps[i]['savedAt']),
        score: maps[i]['score'],
        numComments: maps[i]['numComments'],
      );
    });
  }

  Future<bool> isPostSaved(Post post) async {
    final Database client = await db;
    final List<Map<String, dynamic>> maps = await client.rawQuery('Select 1 from post where post.id = ?', [post.id]);
    return maps.isNotEmpty;
  }

  Future<int> removePost(Post post) async {
    final Database client = await db;
    return await client.delete('post', where: 'id = ?', whereArgs: [post.id]);
  }


}