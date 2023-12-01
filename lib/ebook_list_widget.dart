import 'package:flutter/material.dart';
import 'ebook_card.dart';
import 'ebook.dart';

class EBookListWidget extends StatelessWidget {
  final List<EBook> ebooks;
  final Function(EBook) onDownload;
  final List<EBook> favoriteEbooksList;
  final Function(EBook) onOpen;
  final Function(EBook)? onFavoriteToggle;

  const EBookListWidget({
    required this.ebooks,
    required this.onDownload,
    required this.onOpen,
    required this.favoriteEbooksList,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: ebooks.length, // Corrigir para usar todos os eBooks
      itemBuilder: (context, index) {
        return buildCardWidget(ebooks[index], onFavoriteToggle);
      },
    );
  }

  Widget buildCardWidget(EBook ebook, Function(EBook)? onFavoriteToggle) {
    return EBookCard(
      ebook: ebook,
      onDownload: onDownload,
      onOpen: onOpen,
      onFavoriteToggle: onFavoriteToggle ??
          (ebook) {
            // Lógica padrão ou vazia, se onFavoriteToggle não for fornecido
            print('onFavoriteToggle não foi fornecido!');
          },
    );
  }
}
