import 'package:flutter/material.dart';
import 'ebook_list_widget.dart';
import 'ebook.dart';

class FavoriteEBooksScreen extends StatelessWidget {
  final List<EBook> favoriteEbooksList;
  final Function(EBook) onDownload;
  final Function(EBook) onOpen;
  final Function(EBook) onFavoriteToggle;

  const FavoriteEBooksScreen({
    required this.favoriteEbooksList,
    required this.onDownload,
    required this.onOpen,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-books Favoritos'),
      ),
      body: EBookListWidget(
        ebooks: favoriteEbooksList,
        onDownload: onDownload,
        onOpen: onOpen,
        favoriteEbooksList: favoriteEbooksList,
        onFavoriteToggle: onFavoriteToggle,
      ),
    );
  }
}
