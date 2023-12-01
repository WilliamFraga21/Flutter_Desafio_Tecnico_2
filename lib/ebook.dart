class EBook {
  final int id;
  final String title;
  final String author;
  final String coverUrl;
  final String downloadUrl;
  String localPath;
  bool isFavorite; // Nova propriedade para rastrear o status de favorito

  EBook({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.downloadUrl,
    required this.localPath,
    required this.isFavorite,
  });

  factory EBook.fromJson(Map<String, dynamic> json) {
    return EBook(
      id: json['id'] as int,
      title: json['title'] as String,
      author: json['author'] as String,
      coverUrl: json['cover_url'] as String,
      downloadUrl: json['download_url'] as String,
      localPath: "",
      isFavorite: false,
    );
  }
}
