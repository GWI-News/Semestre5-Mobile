import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:semestre5_mobile/widgets/header.dart';
import 'package:semestre5_mobile/widgets/navbar.dart';
import 'package:semestre5_mobile/widgets/news_card.dart';
import 'package:semestre5_mobile/widgets/news_search_bar.dart';
import 'package:semestre5_mobile/widgets/news_filter.dart';
import 'package:semestre5_mobile/widgets/news_carousel.dart';
import 'package:semestre5_mobile/widgets/navbar_user_utilities.dart';

class NewsDashboardPage extends StatefulWidget {
  const NewsDashboardPage({super.key});

  @override
  State<NewsDashboardPage> createState() => _NewsDashboardPageState();
}

class _NewsDashboardPageState extends State<NewsDashboardPage> {
  late Future<List<Map<String, dynamic>>> _newsFuture;
  bool _showNewsFilter = false;
  bool _showUserUtilities = false; // Novo controlador

  @override
  void initState() {
    super.initState();
    _newsFuture = fetchAllNews();
  }

  Future<List<Map<String, dynamic>>> fetchAllNews() async {
    final querySnapshot =
        await FirebaseFirestore.instance
            .collection('News')
            .orderBy('publication_date', descending: true)
            .get();
    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      final map = Map<String, dynamic>.from(data);
      map['id'] = doc.id;
      return map;
    }).toList();
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

                            // Separe os 5 primeiros para o carrossel e o restante para os cards
                            final carouselItems = newsList.take(5).toList();
                            final cardItems = newsList.skip(5).toList();

                            return Column(
                              children: [
                                // Renderiza o carrossel com os 5 primeiros documentos do Firestore
                                if (carouselItems.isNotEmpty)
                                  NewsCarousel(items: carouselItems),
                                const SizedBox(height: 16),
                                // Renderiza os cards com os demais documentos do Firestore
                                if (cardItems.isNotEmpty)
                                  Wrap(
                                    alignment: WrapAlignment.center,
                                    spacing: 8,
                                    runSpacing: 8,
                                    children:
                                        cardItems.map((newsItem) {
                                          return NewsCard(
                                            newsItem: newsItem,
                                            categoryName:
                                                newsItem['category'] ?? '',
                                            subcategoriesNames:
                                                newsItem['subcategories'] ?? '',
                                            onTap: () {},
                                          );
                                        }).toList(),
                                  ),
                              ],
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
          // Shadow fade para NewsFilter
          if (_showNewsFilter)
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
          // Shadow fade para User Utilities
          if (_showUserUtilities)
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
                    // _showUserUtilities permanece como está
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
                    // _showNewsFilter permanece como está
                  });
                },
              ),
            ),
          // Navbar e Header sempre interativos
          Navbar(
            onFilterTap: () {
              setState(() {
                _showNewsFilter = true;
                _showUserUtilities = false; // Fecha o outro offcanvas
              });
            },
            onUserTap: () {
              setState(() {
                _showUserUtilities = true;
                _showNewsFilter = false; // Fecha o outro offcanvas
              });
            },
          ),
          const Header(),
        ],
      ),
    );
  }
}
