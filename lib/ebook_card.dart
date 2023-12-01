import 'package:flutter/material.dart';
import 'ebook.dart';

class EBookCard extends StatelessWidget {
  final EBook ebook;
  final Function(EBook) onDownload;
  final Function(EBook) onOpen;
  final Function(EBook)? onFavoriteToggle;

  const EBookCard({
    required this.ebook,
    required this.onDownload,
    required this.onOpen,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(ebook.title),
        subtitle: Text(ebook.author),
        leading: Image.network(ebook.coverUrl),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.file_download),
              onPressed: () => onDownload(ebook),
            ),
            IconButton(
              icon: Icon(Icons.open_in_browser),
              onPressed: () => onOpen(ebook),
            ),
            IconButton(
              icon: Icon(
                ebook.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: ebook.isFavorite ? Colors.red : null,
              ),
              onPressed: () {
                if (onFavoriteToggle != null) {
                  onFavoriteToggle!(ebook);
                } else {
                  // Lógica adicional, se necessário, quando onFavoriteToggle é null
                  print('onFavoriteToggle is null! $onFavoriteToggle');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
