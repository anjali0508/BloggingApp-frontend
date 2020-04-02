import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../screens/collection_screen.dart';

import '../providers/collection.dart';

class CollectionPreviewCard extends StatelessWidget {
  Widget build(BuildContext context) {
    final _collection = Provider.of<Collection>(context);

    print("COllection card");
    print(_collection.collection_id);
    print(_collection.collection_name);
    print(_collection.description);

    return new Card(
      elevation: 8.0,
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Container(
        decoration: BoxDecoration(),
        child: ListTile(
          contentPadding:
              EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          leading: ClipOval(
            child: CachedNetworkImage(
              imageUrl: _collection.image_url,
              placeholder: (context, url) => Image.network(
                "http://via.placeholder.com/640x360",
                fit: BoxFit.cover,
                height: 50.0,
                width: 50.0,
              ),
              errorWidget: (context, url, error) => Image.network(
                "http://via.placeholder.com/640x360",
                fit: BoxFit.cover,
                height: 50.0,
                width: 50.0,
              ),
              fit: BoxFit.cover,
              height: 50.0,
              width: 50.0,
            ),
          ),
          title: Text(
            _collection.collection_name,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 17.0,
            ),
          ),
          subtitle: Text(
            _collection.description,
            overflow: TextOverflow.ellipsis,
          ),
          // Is owner
          trailing: _collection.is_owner
              ? FlatButton(
                  color: Colors.purple,
                  disabledColor: Colors.deepOrange,
                  disabledTextColor: Colors.white,
                  textColor: Colors.white,
                  padding: EdgeInsets.all(10.0),
                  onPressed: null,
                  child: Text("Owner"),
                )
              // Is author
              : _collection.is_author
                  ? FlatButton(
                      color: Colors.purple,
                      disabledColor: Colors.purple,
                      disabledTextColor: Colors.white,
                      textColor: Colors.white,
                      padding: EdgeInsets.all(10.0),
                      onPressed: null,
                      child: Text("Author"),
                    )
                  : _collection.is_following
                      ?
                      // is following
                      FlatButton(
                          color: Colors.blue,
                          textColor: Colors.white,
                          padding: EdgeInsets.all(10.0),
                          onPressed: () {
                            _collection.followUnfollow();
                          },
                          child: Text("Following"),
                        )
                      // Follower
                      : OutlineButton(
                          color: Colors.blue,
                          borderSide: BorderSide(
                            color: Colors.blue,
                          ),
                          textColor: Colors.blue,
                          padding: EdgeInsets.all(10.0),
                          onPressed: () {
                            _collection.followUnfollow();
                          },
                          child: Text("Follow"),
                        ),
          onTap: () {
            Navigator.of(context).pushNamed(
              CollectionScreen.routeName,
              arguments: _collection.collection_id,
            );
          },
        ),
      ),
    );
  }
}
