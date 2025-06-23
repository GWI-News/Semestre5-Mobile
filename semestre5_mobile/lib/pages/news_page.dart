import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:semestre5_mobile/widgets/header.dart';
import 'package:semestre5_mobile/widgets/navbar.dart';
import 'package:semestre5_mobile/widgets/news_filter.dart';
import 'package:semestre5_mobile/widgets/navbar_user_utilities.dart';

class NewsPage extends StatefulWidget {
  final String newsCategory;
  final String newsSubcategories;
  final String newsId;

  const NewsPage({
    super.key,
    required this.newsCategory,
    required this.newsSubcategories,
    required this.newsId,
  });

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  Map<String, dynamic>? newsItem;
  bool isLoading = true;

  // Controladores dos offcanvas
  bool _showNewsFilter = false;
  bool _showUserUtilities = false;

  bool _isFavorite = false;
  bool _checkingFavorite = true;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    fetchNewsItem();
    _checkFavoriteStatus();
  }

  Future<void> fetchNewsItem() async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('News')
          .doc(widget.newsId);
      final docSnap = await docRef.get();
      if (docSnap.exists) {
        setState(() {
          newsItem = docSnap.data()!..['id'] = docSnap.id;
          isLoading = false;
        });
      } else {
        setState(() {
          newsItem = null;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        newsItem = null;
        isLoading = false;
      });
    }
  }

  Future<void> _checkFavoriteStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isFavorite = false;
        _checkingFavorite = false;
        _currentUserId = null;
      });
      return;
    }
    _currentUserId = user.uid;

    // Busca documento do usuário pelo campo "auth_uid"
    final query =
        await FirebaseFirestore.instance
            .collection('Users')
            .where('auth_uid', isEqualTo: user.uid)
            .limit(1)
            .get();

    if (query.docs.isEmpty) {
      setState(() {
        _isFavorite = false;
        _checkingFavorite = false;
      });
      return;
    }

    final userDoc = query.docs.first.data();
    final favList =
        (userDoc['favourite_news'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    setState(() {
      _isFavorite = favList.contains(widget.newsId.toString());
      _checkingFavorite = false;
    });
  }

  Future<void> _toggleFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _showUserUtilities = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'É necessário estar logado para favoritar uma notícia.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Busca documento do usuário pelo campo "auth_uid"
    final query =
        await FirebaseFirestore.instance
            .collection('Users')
            .where('auth_uid', isEqualTo: user.uid)
            .limit(1)
            .get();

    if (query.docs.isEmpty) return;

    final docRef = query.docs.first.reference;
    final data = query.docs.first.data();
    final favList =
        (data['favourite_news'] as List?)?.map((e) => e.toString()).toList() ??
        [];
    final newsIdStr = widget.newsId.toString();

    if (_isFavorite) {
      // Remove dos favoritos
      favList.remove(newsIdStr);
    } else {
      // Adiciona aos favoritos
      if (!favList.contains(newsIdStr)) {
        favList.add(newsIdStr);
      }
    }

    await docRef.update({'favourite_news': favList});
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  String formatDate(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    return "${date.day.toString().padLeft(2, '0')} de "
        "${_monthName(date.month)} de "
        "${date.year}";
  }

  String _monthName(int month) {
    const months = [
      '',
      'janeiro',
      'fevereiro',
      'março',
      'abril',
      'maio',
      'junho',
      'julho',
      'agosto',
      'setembro',
      'outubro',
      'novembro',
      'dezembro',
    ];
    return months[month];
  }

  List<String> splitTextContent(String? textContent) {
    if (textContent == null || textContent.isEmpty) return [];
    final sentences = textContent.split('. ');
    final paragraphs = <String>[];
    for (var i = 0; i < sentences.length; i += 3) {
      final paragraph = sentences.skip(i).take(3).join('. ');
      paragraphs.add(paragraph.endsWith('.') ? paragraph : '$paragraph.');
    }
    return paragraphs;
  }

  String _capitalize(String? text) {
    if (text == null || text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    final double headerHeight = height * 0.12;
    final double navbarHeight = width <= 576 ? height * 0.12 : height * 0.12;

    final double topPadding = headerHeight;
    final double bottomPadding = width > 576 ? 8 : navbarHeight;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(
                top: topPadding,
                bottom: bottomPadding,
                left: 12,
                right: 12,
              ),
              child: Stack(
                children: [
                  // Conteúdo principal da notícia
                  SingleChildScrollView(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child:
                            isLoading
                                ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                                : newsItem == null
                                ? const Center(
                                  child: Text('Notícia não encontrada.'),
                                )
                                : Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Título
                                    Text(
                                      newsItem!['title'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    // Subtítulo
                                    if (newsItem!['subtitle'] != null)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        child: Text(
                                          newsItem!['subtitle'],
                                          style: TextStyle(
                                            fontSize:
                                                (width >= 992 ? 24 : 18) * 1.2,
                                            fontWeight: FontWeight.w400,
                                            fontStyle: FontStyle.italic,
                                          ),
                                          textAlign:
                                              TextAlign
                                                  .left, // alterado de justify para left
                                        ),
                                      ),
                                    // Corpo da notícia (parágrafos)
                                    ...splitTextContent(
                                      newsItem!['text_content'],
                                    ).asMap().entries.map((entry) {
                                      final index = entry.key;
                                      final paragraph = entry.value;
                                      return Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 4,
                                            ),
                                            child: Text(
                                              paragraph,
                                              style: TextStyle(
                                                fontSize:
                                                    (width >= 992 ? 20 : 16) *
                                                    1.2,
                                              ),
                                              textAlign:
                                                  TextAlign
                                                      .left, // alterado de justify para left
                                            ),
                                          ),
                                          if (index == 0 &&
                                              newsItem!['url_image'] != null)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 16,
                                                  ),
                                              child: Image.network(
                                                newsItem!['url_image'],
                                                semanticLabel:
                                                    newsItem!['alt_image'] ??
                                                    '',
                                                width: width * 0.75,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                        ],
                                      );
                                    }),
                                    const SizedBox(height: 16),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Categoria: ${widget.newsCategory}.',
                                            style: const TextStyle(
                                              fontStyle: FontStyle.italic,
                                              fontSize: 16,
                                            ),
                                            textAlign: TextAlign.start,
                                          ),
                                          Text(
                                            'Subcategorias: ${widget.newsSubcategories}.',
                                            style: const TextStyle(
                                              fontStyle: FontStyle.italic,
                                              fontSize: 16,
                                            ),
                                            textAlign: TextAlign.start,
                                          ),
                                          if (newsItem!['author'] != null)
                                            Text(
                                              'Escrito por ${_capitalize(newsItem!['author'])}.',
                                              style: const TextStyle(
                                                fontStyle: FontStyle.italic,
                                                fontSize: 16,
                                              ),
                                              textAlign: TextAlign.start,
                                            ),
                                          if (newsItem!['editor'] != null)
                                            Text(
                                              'Editado e Publicado por ${_capitalize(newsItem!['editor'])}.',
                                              style: const TextStyle(
                                                fontStyle: FontStyle.italic,
                                                fontSize: 16,
                                              ),
                                              textAlign: TextAlign.start,
                                            ),
                                          if (newsItem!['publication_date'] !=
                                              null)
                                            Text(
                                              'Última atualização em ${formatDate(newsItem!['publication_date'])}.',
                                              style: const TextStyle(
                                                fontStyle: FontStyle.italic,
                                                fontSize: 16,
                                              ),
                                              textAlign: TextAlign.start,
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 64,
                                    ), // Espaço para o ícone não sobrepor conteúdo
                                  ],
                                ),
                      ),
                    ),
                  ),
                  // Ícone de estrela fixo no canto inferior direito do conteúdo principal
                  Positioned(
                    right: 0,
                    bottom: 8,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: _toggleFavorite,
                        child: Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9F9F9),
                            border: Border.all(
                              color: const Color(
                                0xFF1D4988,
                              ), // Sempre azul padrão
                              width: 2,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              (_currentUserId == null)
                                  ? Icons.star_border
                                  : (_isFavorite
                                      ? Icons.star
                                      : Icons.star_border),
                              color:
                                  (_currentUserId == null)
                                      ? const Color(0xFF1D4988)
                                      : (_isFavorite
                                          ? Colors.amber
                                          : const Color(0xFF1D4988)),
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Shadow fade para offcanvas
          if (_showNewsFilter || _showUserUtilities)
            Positioned.fill(
              child: IgnorePointer(
                ignoring: false,
                child: AnimatedOpacity(
                  opacity: 1,
                  duration: const Duration(milliseconds: 150),
                  child: Container(color: Colors.black.withOpacity(0.35)),
                ),
              ),
            ),
          // Offcanvas NewsFilter
          if (_showNewsFilter)
            Positioned(
              left: 0,
              right: 0,
              top: width > 576 ? navbarHeight : null,
              bottom: width <= 576 ? navbarHeight : null,
              child: NewsFilter(
                showOffcanvas: true,
                onClose: () {
                  setState(() {
                    _showNewsFilter = false;
                  });
                },
              ),
            ),
          // Offcanvas User Utilities
          if (_showUserUtilities)
            Positioned(
              left: 0,
              right: 0,
              top: width > 576 ? navbarHeight : null,
              bottom: width <= 576 ? navbarHeight : null,
              child: NavbarUserUtilities(
                showOffcanvas: true,
                onClose: () {
                  setState(() {
                    _showUserUtilities = false;
                  });
                },
              ),
            ),
          // Navbar e Header sempre interativos
          Navbar(
            onFilterTap: () {
              setState(() {
                _showNewsFilter = true;
              });
            },
            onUserTap: () {
              setState(() {
                _showUserUtilities = true;
              });
            },
          ),
          const Header(),
        ],
      ),
    );
  }
}
