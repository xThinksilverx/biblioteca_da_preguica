class Book {
  final String key;
  final String title;
  final List<String> authors;
  final int? coverId;
  final int? firstPublishYear;
  final List<String> subjects;
  final List<String> publishers;
  final List<String> languages;
  final String? description;
  final String? firstSentence;

  Book({
    required this.key,
    required this.title,
    required this.authors,
    this.coverId,
    this.firstPublishYear,
    this.subjects = const [],
    this.publishers = const [],
    this.languages = const [],
    this.description,
    this.firstSentence,
  });

  String get coverUrl {
    if (coverId != null) {
      return 'https://covers.openlibrary.org/b/id/$coverId-M.jpg';
    }
    return '';
  }

  String get coverUrlLarge {
    if (coverId != null) {
      return 'https://covers.openlibrary.org/b/id/$coverId-L.jpg';
    }
    return '';
  }

  String get authorsDisplay {
    if (authors.isEmpty) return 'Autor desconhecido';
    return authors.join(', ');
  }

  String get workId {
    return key.replaceAll('/works/', '');
  }

  factory Book.fromSearchJson(Map<String, dynamic> json) {
    final keyRaw = json['key'] as String? ?? '';
    final title = json['title'] as String? ?? 'Sem titulo';
    final authors = (json['author_name'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    final coverId = json['cover_i'] as int?;
    final year = json['first_publish_year'] as int?;
    final subjects = (json['subject'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .take(5)
            .toList() ??
        [];
    final publishers = (json['publisher'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .take(3)
            .toList() ??
        [];
    final languages = (json['language'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .take(3)
            .toList() ??
        [];

    String? firstSentence;
    final fs = json['first_sentence'];
    if (fs is Map<String, dynamic>) {
      firstSentence = fs['value'] as String?;
    } else if (fs is String) {
      firstSentence = fs;
    }

    return Book(
      key: keyRaw,
      title: title,
      authors: authors,
      coverId: coverId,
      firstPublishYear: year,
      subjects: subjects,
      publishers: publishers,
      languages: languages,
      firstSentence: firstSentence,
    );
  }

  Book copyWithDescription(String? desc) {
    return Book(
      key: key,
      title: title,
      authors: authors,
      coverId: coverId,
      firstPublishYear: firstPublishYear,
      subjects: subjects,
      publishers: publishers,
      languages: languages,
      description: desc,
      firstSentence: firstSentence,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'title': title,
      'authors': authors,
      'coverId': coverId,
      'firstPublishYear': firstPublishYear,
      'subjects': subjects,
      'publishers': publishers,
      'languages': languages,
      'description': description,
      'firstSentence': firstSentence,
    };
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      key: json['key'] as String? ?? '',
      title: json['title'] as String? ?? '',
      authors: (json['authors'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      coverId: json['coverId'] as int?,
      firstPublishYear: json['firstPublishYear'] as int?,
      subjects: (json['subjects'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      publishers: (json['publishers'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      languages: (json['languages'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      description: json['description'] as String?,
      firstSentence: json['firstSentence'] as String?,
    );
  }
}
