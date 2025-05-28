import 'package:flutter/material.dart';

class NewsCard extends StatefulWidget {
  final Map<String, dynamic> newsItem;
  final String categoryName;
  final String subcategoriesNames;
  final VoidCallback? onTap;

  const NewsCard({
    super.key,
    required this.newsItem,
    required this.categoryName,
    required this.subcategoriesNames,
    this.onTap,
  });

  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(
            8,
          ), // Adicionado padding de 4px em todos os lados
          constraints: const BoxConstraints(
            maxWidth: 352, // 22rem ≈ 352px
            minHeight: 272, // Altura mínima/padrão para todos os cards
            maxHeight: 272, // Altura máxima/padrão para todos os cards
          ),
          transform: _hovering ? Matrix4.translationValues(0, -5, 0) : null,
          decoration: BoxDecoration(
            color: const Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(8),
            boxShadow:
                _hovering
                    ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ]
                    : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
                child: Image.network(
                  widget.newsItem['url_image'] ?? '',
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => Container(
                        height: 180,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.broken_image,
                          size: 48,
                          color: Colors.grey,
                        ),
                      ),
                ),
              ),
              Expanded(
                // Garante que o texto preencha o espaço restante
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    widget.newsItem['title'] ?? '',
                    style: const TextStyle(
                      color: Color(0xFF141414),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
