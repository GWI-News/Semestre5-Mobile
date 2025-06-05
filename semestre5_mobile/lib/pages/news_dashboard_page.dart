import 'package:flutter/material.dart';
import 'package:semestre5_mobile/widgets/header.dart';
import 'package:semestre5_mobile/widgets/navbar.dart';
import 'package:semestre5_mobile/widgets/news_card.dart';
import 'package:semestre5_mobile/widgets/news_search_bar.dart';
import 'package:semestre5_mobile/widgets/news_filter.dart'; // Adicione esta linha
import 'package:semestre5_mobile/context/firestore_db_context.dart';

class NewsDashboardPage extends StatefulWidget {
  const NewsDashboardPage({super.key});

  @override
  State<NewsDashboardPage> createState() => _NewsDashboardPageState();
}

class _NewsDashboardPageState extends State<NewsDashboardPage> {
  late Future<List<Map<String, dynamic>>> _newsFuture;
  bool _showNewsFilter = false;

  @override
  void initState() {
    super.initState();
    _newsFuture = FirestoreDbContext().fetchAllNews();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    final double headerHeight = height * 0.12;
    final double navbarHeight = width <= 576 ? height * 0.10 : height * 0.12;

    final double topPadding = headerHeight;
    final double bottomPadding = width <= 576 ? navbarHeight : 0;

    return Scaffold(
      backgroundColor: const Color(0xFFEBEBEB),
      body: Stack(
        children: [
          // Conteúdo principal
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(
                top: topPadding,
                bottom: bottomPadding,
                left: 8,
                right: 8,
              ),
              child: SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const NewsSearchBar(),
                        const SizedBox(height: 8),
                        FutureBuilder<List<Map<String, dynamic>>>(
                          future: _newsFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (snapshot.hasError) {
                              return Center(
                                child: Text('Erro ao carregar notícias'),
                              );
                            }
                            final newsList = snapshot.data ?? [];
                            if (newsList.isEmpty) {
                              return const Center(
                                child: Text('Nenhuma notícia encontrada.'),
                              );
                            }
                            return Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 8,
                              runSpacing: 8,
                              children:
                                  newsList.map((newsItem) {
                                    return NewsCard(
                                      newsItem: {
                                        ...newsItem,
                                        'url_image': newsItem['url_image'],
                                        'alt_image': newsItem['alt_image'],
                                        'title': newsItem['title'],
                                      },
                                      categoryName: newsItem['category'] ?? '',
                                      subcategoriesNames:
                                          newsItem['subcategories'] ?? '',
                                      onTap: () {},
                                    );
                                  }).toList(),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // NewsFilter sobre os cards, com z-index elevado
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
          // Passe o callback para o Navbar
          Navbar(
            onFilterTap: () {
              setState(() {
                _showNewsFilter = true;
              });
            },
          ),
          const Header(),
        ],
      ),
    );
  }
}
