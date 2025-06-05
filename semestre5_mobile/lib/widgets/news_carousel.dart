import 'package:flutter/material.dart';
import 'package:semestre5_mobile/pages/news_page.dart';

class NewsCarousel extends StatefulWidget {
  final List<Map<String, dynamic>> items;

  const NewsCarousel({super.key, required this.items});

  @override
  State<NewsCarousel> createState() => _NewsCarouselState();
}

class _NewsCarouselState extends State<NewsCarousel> {
  int _current = 0;

  void _onPageChanged(int index) {
    setState(() {
      _current = index;
    });
  }

  void _goToNewsPage(BuildContext context, Map<String, dynamic> news) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => NewsPage(
              newsCategory: news['category'] ?? '',
              newsSubcategories: news['subcategories'] ?? '',
              newsId: news['id'],
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const Center(child: Text('Nenhuma notícia encontrada.'));
    }

    final pageController = PageController(
      viewportFraction: 0.85,
      initialPage: _current,
    );

    void goToPage(int index) {
      if (index >= 0 && index < widget.items.length) {
        pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
        setState(() {
          _current = index;
        });
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 400,
          child: Stack(
            children: [
              PageView.builder(
                itemCount: widget.items.length,
                controller: pageController,
                onPageChanged: (index) {
                  setState(() {
                    _current = index;
                  });
                },
                itemBuilder: (context, index) {
                  final news = widget.items[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.8,
                      vertical: 13.2,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(17.6),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          news['url_image'] != null &&
                                  news['url_image'].toString().isNotEmpty
                              ? Image.network(
                                news['url_image'],
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) =>
                                        Container(color: Colors.grey[300]),
                              )
                              : Container(color: Colors.grey[300]),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: GestureDetector(
                              onTap: () => _goToNewsPage(context, news),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 17.6,
                                  horizontal: 17.6,
                                ),
                                color: Colors.black.withOpacity(0.7),
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: Text(
                                    news['title'] ?? '',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 19.8,
                                      decoration: TextDecoration.underline,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              // Botão seta esquerda
              if (_current > 0)
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(
                          0xFF1D4988,
                        ).withOpacity(0.5), // azul com 50% transparência
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 32,
                          color: Colors.white, // ícone branco
                        ),
                        onPressed: () => goToPage(_current - 1),
                        tooltip: 'Anterior',
                        splashRadius: 28,
                      ),
                    ),
                  ),
                ),
              // Botão seta direita
              if (_current < widget.items.length - 1)
                Positioned(
                  top: 0,
                  bottom: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(
                          0xFF1D4988,
                        ).withOpacity(0.5), // azul com 50% transparência
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 32,
                          color: Colors.white, // ícone branco
                        ),
                        onPressed: () => goToPage(_current + 1),
                        tooltip: 'Próximo',
                        splashRadius: 28,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 13.2),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.items.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4.4),
              width: _current == index ? 19.8 : 8.8,
              height: 8.8,
              decoration: BoxDecoration(
                color:
                    _current == index
                        ? const Color(0xFF1D4988)
                        : Colors.grey[400],
                borderRadius: BorderRadius.circular(4.4),
              ),
            );
          }),
        ),
      ],
    );
  }
}
