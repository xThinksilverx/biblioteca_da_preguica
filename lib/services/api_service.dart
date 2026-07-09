import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';

enum SearchType { general, title, author, subject }

class ApiService {
  static const String _baseUrl = 'https://openlibrary.org';
  static const String _searchFields =
      'key,title,author_name,cover_i,first_publish_year,subject,publisher,language,first_sentence';
  static const int _pageSize = 20;

  static ApiService? _instance;
  ApiService._();

  static ApiService get instance {
    _instance ??= ApiService._();
    return _instance!;
  }

  Future<List<Book>> searchBooks(
    String query, {
    SearchType type = SearchType.general,
    int page = 1,
  }) async {
    final ptBooks = await _doSearch(query, type: type, page: page, language: 'por');
    if (ptBooks.isNotEmpty) return ptBooks;
    return _doSearch(query, type: type, page: page);
  }

  Future<List<Book>> _doSearch(
    String query, {
    SearchType type = SearchType.general,
    int page = 1,
    String? language,
  }) async {
    if (query.trim().isEmpty) return [];

    final offset = (page - 1) * _pageSize;
    final queryParam = Uri.encodeQueryComponent(query.trim());

    String paramKey;
    switch (type) {
      case SearchType.title:
        paramKey = 'title';
      case SearchType.author:
        paramKey = 'author';
      case SearchType.subject:
        paramKey = 'subject';
      case SearchType.general:
        paramKey = 'q';
    }

    var url = '$_baseUrl/search.json?$paramKey=$queryParam&fields=$_searchFields&limit=$_pageSize&offset=$offset';
    if (language != null) url += '&language=$language';

    final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Falha na busca. Codigo: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final docs = (data['docs'] as List<dynamic>?) ?? [];

    return docs
        .map((doc) => Book.fromSearchJson(doc as Map<String, dynamic>))
        .where((b) => b.key.isNotEmpty && b.title.isNotEmpty)
        .toList();
  }

  Future<Book> fetchBookDetails(Book book) async {
    final workId = book.workId;
    if (workId.isEmpty) return book;

    try {
      final uri = Uri.parse('$_baseUrl/works/$workId.json');
      final response =
          await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) return book;

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      String? description;
      final desc = data['description'];
      if (desc is Map<String, dynamic>) {
        description = desc['value'] as String?;
      } else if (desc is String) {
        description = desc;
      }

      final subjects = (data['subjects'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .take(8)
              .toList() ??
          book.subjects;

      return Book(
        key: book.key,
        title: book.title,
        authors: book.authors,
        coverId: book.coverId,
        firstPublishYear: book.firstPublishYear,
        subjects: subjects,
        publishers: book.publishers,
        languages: book.languages,
        description: description,
        firstSentence: book.firstSentence,
      );
    } catch (_) {
      return book;
    }
  }
}
