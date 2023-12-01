import 'dart:io';

import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vocsy_epub_viewer/epub_viewer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  runApp(MaterialApp(
    home: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onAccept;

  WelcomeScreen({required this.onAccept});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bem-Vindo!'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Seja bem-vindo ao nosso aplicativo!'),
            Text(
              'Para aproveitar ao máximo, precisamos de algumas permissões.',
              textAlign: TextAlign.center,
            ),
            ElevatedButton(
              onPressed: onAccept,
              child: Text('Aceitar Permissões'),
            ),
          ],
        ),
      ),
    );
  }
}

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

class _MyAppState extends State<MyApp> {
  bool loading = false;
  Dio dio = Dio();
  String filePath = "";
  late List<EBook> ebooksList = [];
  late List<EBook> favoriteEbooksList = []; // Nova lista para favoritos
  bool acceptedPermissions = false;

  @override
  void initState() {
    super.initState();
    loadAcceptedPermissions(); // Verifique se as permissões já foram aceitas
    loadEBooks();
  }

  void toggleFavorite(EBook ebook) {
    setState(() {
      ebook.isFavorite = !ebook.isFavorite;

      if (ebook.isFavorite) {
        favoriteEbooksList.add(ebook);
      } else {
        favoriteEbooksList.removeWhere((favEbook) => favEbook.id == ebook.id);
      }

      // Salva os IDs dos ebooks favoritos no SharedPreferences
      List<String> favoriteIds =
          favoriteEbooksList.map((favEbook) => favEbook.id.toString()).toList();
      SharedPreferences.getInstance().then((prefs) {
        prefs.setStringList('favorite_ebook_ids', favoriteIds);
      });
    });
  }

  Future<void> loadFavoriteEBooks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? favoriteIds = prefs.getStringList('favorite_ebook_ids');

    if (favoriteIds != null) {
      List<EBook> favorites = ebooksList
          .where((ebook) => favoriteIds.contains(ebook.id.toString()))
          .toList();
      setState(() {
        favoriteEbooksList = favorites;
      });
    }
  }

  Future<void> loadAcceptedPermissions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? accepted = prefs.getBool('accepted_permissions');
    if (accepted != null) {
      setState(() {
        acceptedPermissions = accepted;
      });
    } else {
      // Solicite permissões
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
        // Adicione outras permissões conforme necessário
        // Exemplo: Permission.camera, Permission.location, etc.
      ].request();

      // Verifique se todas as permissões foram concedidas
      bool allGranted = statuses.values.every((status) => status.isGranted);

      if (allGranted) {
        // Todas as permissões foram concedidas
        await prefs.setBool('accepted_permissions', true);

        setState(() {
          acceptedPermissions = true;
        });
      } else {
        // Alguma permissão foi negada, você pode lidar com isso conforme necessário
        // Por exemplo, exibindo uma mensagem ao usuário ou encerrando o aplicativo
      }
    }
  }

  void onAcceptPermissions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('accepted_permissions', true);

    setState(() {
      acceptedPermissions = true;
    });
  }

  Future<void> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      // Adicione outras permissões necessárias aqui
    ].request();

    // Verifica se todas as permissões foram concedidas
    bool allGranted =
        statuses.values.every((status) => status == PermissionStatus.granted);

    if (allGranted) {
      // Todas as permissões foram concedidas, salve o estado
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('accepted_permissions', true);

      // Atualize o estado local
      setState(() {
        acceptedPermissions = true;
      });

      // Carregue eBooks após a aceitação das permissões
      loadEBooks();
    } else {
      // Alguma permissão foi negada, trate conforme necessário
      // Exiba uma mensagem para informar ao usuário
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Permissões Negadas'),
            content: Text(
              'Para usar o aplicativo, é necessário aceitar todas as permissões.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void loadEBooks() async {
    try {
      List<EBook> allEbooks = await fetchEBooks();
      await loadFavoriteEBooks(); // Carrega os ebooks favoritos
      setState(() {
        ebooksList = allEbooks;
      });
    } catch (e) {
      print('Error loading e-books: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: acceptedPermissions
          ? Scaffold(
              appBar: AppBar(
                title: const Text('E-book Reader'),
              ),
              body: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FavoriteEBooksScreen(
                            favoriteEbooksList: favoriteEbooksList,
                            onDownload: onDownload,
                            onOpen: onOpen,
                            onFavoriteToggle: toggleFavorite,
                          ),
                        ),
                      );
                    },
                    child: Text('Ver Favoritos'),
                  ),
                  Expanded(
                    child: EBookListWidget(
                      ebooks: ebooksList, // Corrigir para usar ebooksList
                      onDownload: onDownload,
                      onOpen: onOpen,
                      favoriteEbooksList: favoriteEbooksList,
                      onFavoriteToggle: toggleFavorite,
                    ),
                  ),
                ],
              ),
            )
          : WelcomeScreen(
              onAccept: requestPermissions,
            ),
    );
  }

  void onOpen(EBook ebook) async {
    if (Platform.isAndroid) {
      var status = await Permission.storage.request();
      if (status.isGranted) {
        if (ebook.localPath.isNotEmpty) {
          openEpub(ebook.localPath);
        } else {
          print('O arquivo não foi baixado. Iniciando o download...');
          await startDownload(ebook);
          if (ebook.localPath.isNotEmpty) {
            print('Download concluído. Abrindo o eBook...');
            openEpub(ebook.localPath);
          }
        }
      } else {
        print('Permissão de armazenamento negada.');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Permissão Negada'),
              content: Text(
                'A permissão de armazenamento é necessária para abrir o eBook.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  void onDownload(EBook ebook) async {
    print('Iniciando o download do eBook: $ebook');
    if (Platform.isAndroid || Platform.isIOS) {
      String? firstPart;
      final deviceInfoPlugin = DeviceInfoPlugin();
      final deviceInfo = await deviceInfoPlugin.deviceInfo;
      final allInfo = deviceInfo.data;
      if (allInfo['version']["release"].toString().contains(".")) {
        int indexOfFirstDot = allInfo['version']["release"].indexOf(".");
        firstPart = allInfo['version']["release"].substring(0, indexOfFirstDot);
      } else {
        firstPart = allInfo['version']["release"];
      }
      int intValue = int.parse(firstPart!);
      if (intValue >= 13) {
        print('Versão do iOS >= 13. Iniciando o download...');
        await startDownload(ebook);
      } else {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          // Permissão não concedida, solicita a permissão
          status = await Permission.storage.request();
        }

        if (status.isGranted) {
          print(
              'Permissão de armazenamento concedida. Iniciando o download...');
          await startDownload(ebook);
        } else {
          // A permissão foi negada. Trate isso adequadamente.
          print('Permissão de armazenamento negada.');
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Permissão Negada'),
                content: Text(
                  'A permissão de armazenamento é necessária para fazer o download.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      }
    } else {
      loading = false;
    }
  }

  Widget buildCardWidget(EBook ebook) {
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
          ],
        ),
      ),
    );
  }

  Future<void> startDownload(EBook ebook) async {
    if (Platform.isAndroid) {
      var status = await Permission.storage.request();
      if (status.isGranted) {
        Directory? appDocDir = Platform.isAndroid
            ? await getExternalStorageDirectory()
            : await getApplicationDocumentsDirectory();

        String originalFileName =
            Uri.parse(ebook.downloadUrl).pathSegments.last;
        String sanitizedFileName = originalFileName.replaceAll(
          RegExp(r'\.epub[0-9]*(\.images|\.noimages)?$'),
          '.epub',
        );

        String filePath = appDocDir!.path + '/$sanitizedFileName';

        File file = File(filePath);

        print('Start Download: ${ebook.downloadUrl}');
        print('File Path: $filePath');

        if (!file.existsSync()) {
          await file.create();
          await dio.download(
            ebook.downloadUrl,
            filePath,
            deleteOnError: true,
            onReceiveProgress: (receivedBytes, totalBytes) {
              setState(() {
                loading = true;
                print('Received $receivedBytes bytes out of $totalBytes');
              });
            },
          ).whenComplete(() {
            setState(() {
              loading = false;
              // Atualize o caminho do arquivo quando o download estiver completo.
              filePath = filePath.replaceAll(
                  RegExp(r'\.epub[0-9]*\.images$'), '.epub');
              ebook.localPath =
                  filePath; // Atualize a propriedade localPath do ebook
              print('Download Completed. Updated File Path: $filePath');
            });
          });
        } else {
          setState(() {
            loading = false;
            // Renomeia o arquivo para remover sufixos como .images ou .epub3.images
            String newFilePath =
                filePath.replaceAll(RegExp(r'\.epub[0-9]*\.images$'), '.epub');
            file.renameSync(newFilePath);
            filePath = newFilePath;
            ebook.localPath =
                newFilePath; // Atualize a propriedade localPath do ebook
            print('File Already Exists. Renamed File Path: $newFilePath');
          });
        }
      } else {
        // A permissão foi negada. Trate isso adequadamente.
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Permissão Negada'),
              content: Text(
                  'A permissão de armazenamento é necessária para fazer o download.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  Future<void> openEpub(String filePath) async {
    VocsyEpub.setConfig(
      themeColor: Theme.of(context).primaryColor,
      identifier: "iosBook",
      scrollDirection: EpubScrollDirection.ALLDIRECTIONS,
      allowSharing: true,
      enableTts: true,
      nightMode: true,
    );

    // get current locator
    VocsyEpub.locatorStream.listen((locator) {
      print('LOCATOR: $locator');
    });

    VocsyEpub.open(
      filePath,
      lastLocation: EpubLocator.fromJson({
        "bookId": "2239",
        "href": "/OEBPS/ch06.xhtml",
        "created": 1539934158390,
        "locations": {"cfi": "epubcfi(/0!/4/4[simple_book]/2/2/6)"},
      }),
    );
  }

  Future<List<EBook>> fetchEBooks() async {
    try {
      final response = await dio.get('https://escribo.com/books.json');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => EBook.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load e-books');
      }
    } catch (e) {
      throw Exception('Failed to load e-books');
    }
  }
}

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
