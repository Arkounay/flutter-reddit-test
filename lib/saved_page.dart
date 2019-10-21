import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_reddit_test/main.dart';
import 'package:flutter_reddit_test/services/db.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models/post.dart';
import 'widgets/post_detail_widget.dart';
import 'package:share/share.dart';

class SavedPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Saved posts',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
          appBar: AppBar(
            title: Text('Saved posts'),
            leading: IconButton(icon:Icon(Icons.arrow_back),
              onPressed:() => Navigator.pop(context, false),
            )
          ),
          body: FutureBuilder<List<Post>>(
            future: Db().posts(),
            builder: (BuildContext context, AsyncSnapshot<List<Post>> snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data.isEmpty) {
                  return Center(child: Text('No saved posts'));
                }
                return PostsList(snapshot.data, null, false);
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
            },

          )
      ),
    );
  }

}