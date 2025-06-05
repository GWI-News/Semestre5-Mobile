import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:semestre5_mobile/widgets/header.dart';
import 'package:semestre5_mobile/widgets/navbar.dart';
import 'package:semestre5_mobile/widgets/news_card.dart';
import 'package:semestre5_mobile/widgets/news_search_bar.dart';
import 'package:semestre5_mobile/widgets/news_filter.dart';
import 'package:semestre5_mobile/widgets/news_carousel.dart';

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

                            final carouselItems = newsList.take(5).toList();
                            final cardItems = newsList.skip(5).toList();

                            return Column(
                              children: [
                                // Renderiza o carrossel com as notícias simuladas
                                NewsCarousel(items: simulatedCarouselNews),
                                const SizedBox(height: 16),
                                // Renderiza os cards com as notícias reais do Firestore
                                if (newsList.isNotEmpty)
                                  Wrap(
                                    alignment: WrapAlignment.center,
                                    spacing: 8,
                                    runSpacing: 8,
                                    children:
                                        newsList.map((newsItem) {
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

// Simulação de 5 notícias para o carrossel
final List<Map<String, dynamic>> simulatedCarouselNews = [
  {
    'id': '1',
    'title': 'Banco do Brasil Anuncia Abertura de Novas Vagas',
    'url_image':
        'https://firebasestorage.googleapis.com/v0/b/gwinews-development.appspot.com/o/banco.jpg?alt=media&token=01b0d435-2107-480c-9ee2-ea0f74daffd9',
    'category': 'Empregos',
    'subcategories': 'Bancos',
    'alt_image': 'Imagem do Banco do Brasil',
  },
  {
    'id': '2',
    'title': 'Caixa Econômica Lança Programa de Estágio',
    'url_image': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb',
    'category': 'Educação',
    'subcategories': 'Estágios',
    'alt_image': 'Imagem da Caixa Econômica',
  },
  {
    'id': '3',
    'title': 'Santander Investe em Tecnologia para Atendimento',
    'url_image': 'https://images.unsplash.com/photo-1464983953574-0892a716854b',
    'category': 'Tecnologia',
    'subcategories': 'Bancos',
    'alt_image': 'Imagem do Santander',
  },
  {
    'id': '4',
    'title': 'Bradesco Abre Vagas para Jovem Aprendiz',
    'url_image': 'https://images.unsplash.com/photo-1519125323398-675f0ddb6308',
    'category': 'Empregos',
    'subcategories': 'Jovem Aprendiz',
    'alt_image': 'Imagem do Bradesco',
  },
  {
    'id': '5',
    'title': 'Itaú Promove Diversidade em Novo Processo Seletivo',
    'url_image': 'https://images.unsplash.com/photo-1522202176988-66273c2fd55f',
    'category': 'Diversidade',
    'subcategories': 'RH',
    'alt_image': 'Imagem do Itaú',
  },
];
