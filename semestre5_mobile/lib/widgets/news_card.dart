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
    final String? imageUrl = widget.newsItem['url_image'];
    final String? altImage = widget.newsItem['alt_image'];
    final String? title = widget.newsItem['title'];

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(
            maxWidth: 352,
            minHeight: 272,
            maxHeight: 272,
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
                child:
                    imageUrl != null && imageUrl.isNotEmpty
                        ? Container(
                          height: 180,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(imageUrl),
                              fit: BoxFit.cover,
                              onError: (error, stackTrace) {},
                            ),
                          ),
                          child: FutureBuilder(
                            future: precacheImage(
                              NetworkImage(imageUrl),
                              context,
                            ).then((_) => true).catchError((_) => false),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                      ConnectionState.done &&
                                  snapshot.hasData &&
                                  snapshot.data == false) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image_outlined,
                                        size: 48,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        altImage ?? 'Imagem não disponível',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        )
                        : Container(
                          height: 180,
                          color: Colors.grey[200],
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_outlined,
                                  size: 48,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  altImage ?? 'Imagem não disponível',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  title ?? '',
                  style: const TextStyle(
                    color: Color(0xFF141414),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
