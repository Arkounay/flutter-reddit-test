import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reddit_test/models/post.dart';
import 'package:flutter_reddit_test/services/db.dart';
import '../post_page.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostItemWidget extends StatefulWidget {
  final Post post;

  PostItemWidget(this.post);

  @override
  State<StatefulWidget> createState() => PostItemWidgetState();

}

class PostItemWidgetState extends State<PostItemWidget> {
  bool isSaved = false;
  Offset _tapPosition;

  @override
  void initState() {
    super.initState();
    Db().isPostSaved(widget.post).then((bool value) {
      setState(() {
        isSaved = value;
      });
    });
  }

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
            MaterialPageRoute(builder: (context) => PostPage(widget.post)),
          ),
          onTapDown: (TapDownDetails details) => _tapPosition = details.globalPosition,
          onLongPress: () {
            showMenu(context: context,
                position: RelativeRect.fromLTRB(_tapPosition.dx, _tapPosition.dy, 100.0, 100.0),
                items: <PopupMenuItem>[
                  if (!isSaved)
                    PopupMenuItem(
                        value: 1,
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.save),
                            Text(' Save post'),
                          ],
                        )
                    )
                  else
                    PopupMenuItem(
                        value: 2,
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.delete),
                            Text(' Delete post'),
                          ],
                        )
                    )
                ]
            ).then((val) async {
              if (val == 1) {
                Db().insertPost(widget.post).then((_) {
                  setState(() {
                    isSaved = true;
                  });
                });
              } else if (val == 2) {
                await Db().removePost(widget.post).then((int deleted) {
                  setState(() {
                    isSaved = (deleted == 0);
                  });
                });
                print (await Db().isPostSaved(widget.post));
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
                        widget.post.abbrScore,
                        style: TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        ' • ',
                        style: TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                      Text(
                        widget.post.subreddit,
                        style: TextStyle(color: Colors.black87, fontSize: 12),
                      ),
                      Text(
                        ' • ${widget.post.author} • ${timeago.format(widget.post.createdAt)}',
                        style: TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                      if (isSaved)
                        Text(
                          ' • saved',
                          style: TextStyle(color: Colors.black54, fontSize: 12),
                        ),
                    ],
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    if (widget.post.hasThumbnail)
                      Hero(
                        child: Padding(padding: EdgeInsets.only(right: 10), child: Image.network(widget.post.thumbnail, width: 50)),
                        tag: 'post_thumbnail_' + widget.post.id,
                      ),
                    Flexible(
                      child: Text(
                        widget.post.title,
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
