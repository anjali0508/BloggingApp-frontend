import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

import './article.dart';

class Articles with ChangeNotifier {
  static const baseUrl = "http://10.0.2.2:3000/api/v1/";
  final storage = FlutterSecureStorage();
  List<Article> _articles = [];

  Article findById(String article_id) {
    return _articles.firstWhere((article) => article.article_id == article_id);
  }

  List<Article> get articles {
    return [..._articles];
  }

  // Insert Article
  Future<void> addArticle(Map<String, dynamic> data, File image) async {
    String url = baseUrl + "articles";
    print(data);
    final token = await storage.read(key: "token");
    final userId = await storage.read(key: "userId");

    String articleId =
        userId.toString() + (DateTime.now().millisecondsSinceEpoch).toString();
    DateFormat dateFormatter = new DateFormat('yyyy-MM-dd');
    String dateCreated = dateFormatter.format(DateTime.now());

    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers["Authorization"] = token;
    if (image != null) {
      String filename = image.path;
      request.files.add(await http.MultipartFile.fromPath('image', filename));
    }
    request.fields["article_id"] = articleId;
    request.fields["collection_id"] = data["collectionId"];
    request.fields["user_id"] = userId;
    request.fields["title"] = data["title"];
    request.fields["content"] = data["content"];
    request.fields["image_path"] = "";
    request.fields["views_count"] = "0";
    request.fields["date_created"] = dateCreated;
    request.fields["date_updated"] = dateCreated;
    request.fields["tags"] = data["tags"];

    try {
      final response = await request.send();
      print(response);
    } catch (error) {
      throw error;
    }
  }

  // Get Feed Articles
  Future<void> getFeedArticles() async {
    List<Article> fetchedArticles = [];
    String url = baseUrl + "user/feed";
    final token = await storage.read(key: "token");
    print("Obtained token " + token);
    try {
      final response = await http.get(
        url,
        headers: {HttpHeaders.authorizationHeader: token},
      );
      final responseJson = json.decode(response.body);
      for (final article in responseJson) {
        fetchedArticles.add(Article(
          article_id: article["article_id"],
          user_id: article["user_id"],
          collection_id: article["collection_id"],
          title: article["title"],
          image_path: article["image_path"],
          is_bookmarked: article["is_bookmarked"] == 0 ? false : true,
          date_created: DateTime.parse(article["date_created"]),
        ));
      }
      _articles = [...fetchedArticles];
    } catch (error) {
      throw error;
    }
  }

  // Get User authored articles
  Future<void> getUserArticles() async {
    List<Article> fetchedArticles = [];

    final token = await storage.read(key: "token");
    print("Obtained token ");
    final userId = await storage.read(key: "userId");
    print("Obtained userId ");

    String url = baseUrl + "user/" + userId.toString() + "/articles";
    try {
      final response = await http.get(
        url,
        headers: {HttpHeaders.authorizationHeader: token},
      );
      final responseJson = json.decode(response.body);
      for (final article in responseJson) {
        fetchedArticles.add(Article(
          article_id: article["article_id"],
          user_id: article["user_id"],
          collection_id: article["collection_id"],
          title: article["title"],
          image_path: article["image_path"],
          is_bookmarked: article["is_bookmarked"] == 0 ? false : true,
          date_created: DateTime.parse(article["date_created"]),
        ));
      }
      _articles = [...fetchedArticles];
    } catch (error) {
      throw error;
    }
  }

// Get bookmarked articles
  Future<void> getBookmarkedArticles() async {
    List<Article> fetchedArticles = [];

    final token = await storage.read(key: "token");
    print("Obtained token ");

    String url = baseUrl + "user/bookmarks";
    try {
      final response = await http.get(
        url,
        headers: {HttpHeaders.authorizationHeader: token},
      );
      final responseJson = json.decode(response.body);
      for (final article in responseJson) {
        fetchedArticles.add(Article(
          article_id: article["article_id"],
          user_id: article["user_id"],
          collection_id: article["collection_id"],
          title: article["title"],
          image_path: article["image_path"],
          is_bookmarked: article["is_bookmarked"] == 0 ? false : true,
          date_created: DateTime.parse(article["date_created"]),
        ));
      }
      _articles = [...fetchedArticles];
    } catch (error) {
      throw error;
    }
  }

  // Get articles of a collection
  Future<void> getCollectionArticles(String collectionId) async {
    List<Article> fetchedArticles = [];

    final token = await storage.read(key: "token");
    print("Obtained token ");

    String url = baseUrl + "collections/" + collectionId + "/articles";
    try {
      final response = await http.get(
        url,
        headers: {HttpHeaders.authorizationHeader: token},
      );
      final responseJson = json.decode(response.body);
      for (final article in responseJson) {
        fetchedArticles.add(Article(
          article_id: article["article_id"],
          user_id: article["user_id"],
          collection_id: article["collection_id"],
          title: article["title"],
          image_path: article["image_path"],
          is_bookmarked: article["is_bookmarked"] == 0 ? false : true,
          date_created: DateTime.parse(article["date_created"]),
        ));
      }
      _articles = [...fetchedArticles];
    } catch (error) {
      throw error;
    }
  }

// Search Articles
  Future<void> searchArticles(String query) async {
    List<Article> fetchedArticles = [];
    final token = await storage.read(key: "token");

    String base = "10.0.2.2:3000";
    String path = "/api/v1/articles";
    var queryParams = {"q": query};
    var url = Uri.http(base, path, queryParams);
    try {
      final response = await http.get(
        url,
        headers: {HttpHeaders.authorizationHeader: token},
      );
      print(response.body);
      final responseJson = json.decode(response.body);
      for (final article in responseJson) {
        fetchedArticles.add(Article(
          article_id: article["article_id"],
          user_id: article["user_id"],
          collection_id: article["collection_id"],
          title: article["title"],
          image_path: article["image_path"],
          is_bookmarked: article["is_bookmarked"] == 0 ? false : true,
          date_created: DateTime.parse(article["date_created"]),
        ));
      }
      _articles = [...fetchedArticles];
    } catch (error) {
      throw error;
    }
  }

  void getArticles() {
    List<Article> fetchedData = [];

    _articles = fetchedData;
  }

  // void getCollectionArticles(String collectionId) {
  //   List<Article> fetchedData = [];
  //   fetchedData.add(Article(
  //       article_id: "4",
  //       collection_id: "2",
  //       user_id: 1,
  //       title: "I am happy - collection 1",
  //       content: "bjhcbjhgfhgdfhvds",
  //       published: true,
  //       image_path:
  //           "https://images.pexels.com/photos/531602/pexels-photo-531602.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260",
  //       views_count: 0,
  //       kudos_count: 0,
  //       date_created: DateTime.parse("1969-07-20 20:18:04Z"),
  //       date_updated: DateTime.parse("1969-07-20 20:18:04Z"),
  //       is_bookmarked: false));
  //   fetchedData.add(Article(
  //     article_id: "4",
  //     collection_id: "2",
  //     user_id: 1,
  //     title: "I am Collection 1",
  //     content: "bjhcbjhgfhgdfhvds",
  //     published: true,
  //     image_path:
  //         "https://images.pexels.com/photos/531602/pexels-photo-531602.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260",
  //     views_count: 0,
  //     kudos_count: 0,
  //     date_created: DateTime.parse("1969-07-20 20:18:04Z"),
  //     date_updated: DateTime.parse("1969-07-20 20:18:04Z"),
  //     is_bookmarked: false,
  //   ));
  //   fetchedData;
  // }

  void editArticles() {}

  Future<void> addarticle(Article newArticle) async {
    List<Article> fetchedData = [];
    fetchedData.add(Article(
      article_id: "11",
      collection_id: "2",
      user_id: 1,
      title: "Article11",
      content: "bjhcbjhgfhgdfhvds",
      published: true,
      image_path:
          "https://images.pexels.com/photos/531602/pexels-photo-531602.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260",
      views_count: 0,
      kudos_count: 0,
      date_created: DateTime.parse("1969-07-20 20:18:04Z"),
      date_updated: DateTime.parse("1969-07-20 20:18:04Z"),
      is_bookmarked: false,
    ));

    fetchedData.add(Article(
      article_id: "12",
      collection_id: "2",
      user_id: 1,
      title: "Article12",
      content: "bjhcbjhgfhgdfhvds",
      published: true,
      image_path:
          "https://images.pexels.com/photos/531602/pexels-photo-531602.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260",
      views_count: 0,
      kudos_count: 0,
      date_created: DateTime.parse("1969-07-20 20:18:04Z"),
      date_updated: DateTime.parse("1969-07-20 20:18:04Z"),
      is_bookmarked: false,
    ));
    _articles = fetchedData;
    notifyListeners();
  }

  Future<void> updateArticle(String id) async {
    List<Article> fetchedData = [];
    fetchedData.add(Article(
      article_id: "1",
      collection_id: "2",
      user_id: 1,
      title: "HEllo there",
      content: "bjhcbjhgfhgdfhvds",
      published: true,
      image_path:
          "https://images.pexels.com/photos/818252/pexels-photo-818252.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260",
      views_count: 0,
      kudos_count: 0,
      date_created: DateTime.parse("1969-07-20 20:18:04Z"),
      date_updated: DateTime.parse("1969-07-20 20:18:04Z"),
      is_bookmarked: false,
    ));

    fetchedData.add(Article(
        article_id: "1",
        collection_id: "2",
        user_id: 1,
        title: "HEllo there",
        content: "bjhcbjhgfhgdfhvds",
        published: true,
        image_path:
            "https://images.pexels.com/photos/818252/pexels-photo-818252.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260",
        views_count: 0,
        kudos_count: 0,
        date_created: DateTime.parse("1969-07-20 20:18:04Z"),
        date_updated: DateTime.parse("1969-07-20 20:18:04Z"),
        is_bookmarked: false));
    _articles = fetchedData;
    notifyListeners();
  }

  Future<void> deleteArticle(String id) async {
    List<Article> fetchedData = [];
    fetchedData.add(Article(
      article_id: "1",
      collection_id: "2",
      user_id: 1,
      title: "HEllo there",
      content: "bjhcbjhgfhgdfhvds",
      published: true,
      image_path:
          "https://images.pexels.com/photos/818252/pexels-photo-818252.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260",
      views_count: 0,
      kudos_count: 0,
      date_created: DateTime.parse("1969-07-20 20:18:04Z"),
      date_updated: DateTime.parse("1969-07-20 20:18:04Z"),
      is_bookmarked: false,
    ));

    fetchedData.add(Article(
        article_id: "1",
        collection_id: "2",
        user_id: 1,
        title: "HEllo there",
        content: "bjhcbjhgfhgdfhvds",
        published: true,
        image_path:
            "https://images.pexels.com/photos/818252/pexels-photo-818252.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260",
        views_count: 0,
        kudos_count: 0,
        date_created: DateTime.parse("1969-07-20 20:18:04Z"),
        date_updated: DateTime.parse("1969-07-20 20:18:04Z"),
        is_bookmarked: false));
    _articles = fetchedData;
    notifyListeners();
  }
}
