import 'package:flutter/material.dart';
import 'package:semestre5_mobile/widgets/header.dart';
import 'package:semestre5_mobile/widgets/navbar.dart';
import 'package:semestre5_mobile/widgets/news_card.dart';
import 'package:semestre5_mobile/context/firestore_db_context.dart';

class NewsDashboardPage extends StatefulWidget {
  const NewsDashboardPage({super.key});

  @override
  State<NewsDashboardPage> createState() => _NewsDashboardPageState();
}

class _NewsDashboardPageState extends State<NewsDashboardPage> {
  late Future<List<Map<String, dynamic>>> _newsFuture;

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

    final double topPadding = headerHeight + 8;
    final double bottomPadding = width <= 576 ? navbarHeight + 16 : 0;

    return Scaffold(
      backgroundColor: const Color(0xFFEBEBEB),
      body: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(
                top: topPadding,
                bottom: bottomPadding,
                left: 8,
                right: 8,
              ),
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _newsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Erro ao carregar notícias'));
                  }
                  final newsList = snapshot.data ?? [];
                  if (newsList.isEmpty) {
                    return const Center(
                      child: Text('Nenhuma notícia encontrada.'),
                    );
                  }
                  return SingleChildScrollView(
                    child: Wrap(
                      alignment: WrapAlignment.center,
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
                    ),
                  );
                },
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
