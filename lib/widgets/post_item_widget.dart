import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reddit_test/models/post.dart';
import 'package:flutter_reddit_test/services/db.dart';
import '../post_page.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostItemWidget extends StatelessWidget {
  final Post post;
  Offset _tapPosition;

  PostItemWidget(this.post);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0, 1),
              blurRadius: 2,
            ),
          ],
        ),
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PostPage(post)),
          ),
          onTapDown: (TapDownDetails details) => _tapPosition = details.globalPosition,
          onLongPress: () {
            showMenu(context: context,
                position: RelativeRect.fromLTRB(_tapPosition.dx, _tapPosition.dy, 100.0, 100.0),
                items: <PopupMenuItem>[
                  PopupMenuItem(
                      value: 1,
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.save),
                          Text(' Save post'),
                        ],
                      )
                  )
                ]
            ).then((val) async {
              if (val == 1) {
                await Db().insertPost(post);
              }
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Row(
                    children: <Widget>[
                      Text(
                        post.abbrScore,
                        style: TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        ' • ',
                        style: TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                      Text(
                        post.subreddit,
                        style: TextStyle(color: Colors.black87, fontSize: 12),
                      ),
                      Text(
                        ' • ${post.author} • ${timeago.format(post.createdAt)}',
                        style: TextStyle(color: Colors.black54, fontSize: 12),
                      )
                    ],
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    if (post.hasThumbnail)
                      Hero(
                        child: Padding(padding: EdgeInsets.only(right: 10), child: Image.network(post.thumbnail, width: 50)),
                        tag: 'post_thumbnail_' + post.id,
                      ),
                    Flexible(
                      child: Text(
                        post.title,
                        softWrap: true,
                        textAlign: TextAlign.left,
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
