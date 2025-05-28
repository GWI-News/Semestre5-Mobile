import 'package:flutter/material.dart';
import 'package:semestre5_mobile/widgets/header.dart';
import 'package:semestre5_mobile/widgets/navbar.dart';
import 'package:semestre5_mobile/widgets/news_card.dart';

class NewsDashboardPage extends StatelessWidget {
  const NewsDashboardPage({super.key});

  // Lista simulada de notícias
  static final List<Map<String, dynamic>> newsList = [
    {
      'id': 1,
      'title': 'Flutter 3.0 lançado: veja as novidades!',
      'url_image': 'https://picsum.photos/400/200?random=1',
      'category': 'tecnologia',
      'subcategories': 'mobile',
    },
    {
      'id': 2,
      'title': 'Mercado de trabalho em alta para desenvolvedores',
      'url_image': 'https://picsum.photos/400/200?random=2',
      'category': 'carreira',
      'subcategories': 'empregos',
    },
    {
      'id': 3,
      'title': 'Como criar apps responsivos com Flutter',
      'url_image': 'https://picsum.photos/400/200?random=3',
      'category': 'tecnologia',
      'subcategories': 'mobile',
    },
    {
      'id': 4,
      'title': 'Flutter 3.0 lançado: veja as novidades!',
      'url_image': 'https://picsum.photos/400/200?random=1',
      'category': 'tecnologia',
      'subcategories': 'mobile',
    },
    {
      'id': 5,
      'title': 'Mercado de trabalho em alta para desenvolvedores',
      'url_image': 'https://picsum.photos/400/200?random=2',
      'category': 'carreira',
      'subcategories': 'empregos',
    },
    {
      'id': 6,
      'title': 'Como criar apps responsivos com Flutter',
      'url_image': 'https://picsum.photos/400/200?random=3',
      'category': 'tecnologia',
      'subcategories': 'mobile',
    },
    {
      'id': 7,
      'title':
          'Esta é uma notícia de exemplo com um título propositalmente longo para testar o layout do card no Flutter e garantir que tudo funcione corretamente.',
      'url_image': 'https://picsum.photos/400/200?random=4',
      'category': 'testes',
      'subcategories': 'layout',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    // Definindo altura dos widgets fixos
    final double headerHeight = height * 0.12;
    final double navbarHeight = width <= 576 ? height * 0.10 : height * 0.12;

    // Espaçamento superior e inferior para não encobrir conteúdo
    final double topPadding = headerHeight + 8; // 8px extra para espaçamento
    final double bottomPadding = width <= 576 ? navbarHeight + 8 : 8;

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
              child: SingleChildScrollView(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children:
                      newsList.map((newsItem) {
                        return NewsCard(
                          newsItem: newsItem,
                          categoryName: newsItem['category'],
                          subcategoriesNames: newsItem['subcategories'],
                          onTap: () {
                            // Exemplo de navegação ou ação ao clicar
                            // Navigator.pushNamed(context, '/noticia', arguments: newsItem);
                          },
                        );
                      }).toList(),
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
