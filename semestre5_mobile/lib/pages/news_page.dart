import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:semestre5_mobile/widgets/header.dart';
import 'package:semestre5_mobile/widgets/navbar.dart';

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

  @override
  void initState() {
    super.initState();
    fetchNewsItem();
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

    final double topPadding = width > 576 ? headerHeight + 8 : headerHeight + 8;
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
              child: SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child:
                        isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : newsItem == null
                            ? const Center(
                              child: Text('Notícia não encontrada.'),
                            )
                            : Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  newsItem!['title'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
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
                                      textAlign: TextAlign.justify,
                                    ),
                                  ),
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
                                                (width >= 992 ? 20 : 16) * 1.2,
                                          ),
                                          textAlign: TextAlign.justify,
                                        ),
                                      ),
                                      if (index == 0 &&
                                          newsItem!['url_image'] != null)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                          child: Image.network(
                                            newsItem!['url_image'],
                                            semanticLabel:
                                                newsItem!['alt_image'] ?? '',
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
                                      if (newsItem!['publication_date'] != null)
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
                              ],
                            ),
                  ),
                ),
              ),
            ),
          ),
          const Header(),
          const Navbar(),
        ],
      ),
    );
  }
}
