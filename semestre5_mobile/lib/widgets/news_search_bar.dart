import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:semestre5_mobile/widgets/news_card.dart';

class NewsSearchBar extends StatefulWidget {
  const NewsSearchBar({super.key});

  @override
  State<NewsSearchBar> createState() => _NewsSearchBarState();
}

class _NewsSearchBarState extends State<NewsSearchBar> {
  final TextEditingController _controller = TextEditingController();
  bool _searchBarDisplay = false;
  String _searchTerm = '';
  String _debouncedSearchTerm = '';
  List<Map<String, dynamic>> _searchNews = [];
  bool _resultSearch = true;
  List<Map<String, dynamic>> _newsCategories = [];
  List<Map<String, dynamic>> _newsSubcategories = [];
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _fetchNewsCategories();
    _fetchNewsSubcategories();
    _controller.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchTerm = _controller.text;
    });
    _debounceSearch();
  }

  void _debounceSearch() {
    Future.delayed(const Duration(milliseconds: 750), () {
      if (_searchTerm == _controller.text) {
        setState(() {
          _debouncedSearchTerm = _searchTerm;
        });
        _fetchNews();
      }
    });
  }

  String _normalizeString(String str) {
    return str
        .toLowerCase()
        .replaceAll(RegExp(r'[áàãâä]'), 'a')
        .replaceAll(RegExp(r'[éèêë]'), 'e')
        .replaceAll(RegExp(r'[íìîï]'), 'i')
        .replaceAll(RegExp(r'[óòõôö]'), 'o')
        .replaceAll(RegExp(r'[úùûü]'), 'u')
        .replaceAll(RegExp(r'[ç]'), 'c')
        .replaceAll(RegExp(r'[^a-z0-9 ]'), '');
  }

  Future<void> _fetchNews() async {
    if (_debouncedSearchTerm.isEmpty) {
      setState(() {
        _searchNews = [];
        _resultSearch = true;
      });
      return;
    }
    final normalizedSearchTerm = _normalizeString(_debouncedSearchTerm);
    final query = FirebaseFirestore.instance
        .collection('News')
        .orderBy('normalized_title')
        .startAt([normalizedSearchTerm])
        .endAt(['$normalizedSearchTerm\uf8ff'])
        .limit(5);

    final snapshot = await query.get();
    final newsList =
        snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();

    setState(() {
      _searchNews = newsList;
      _resultSearch = newsList.isNotEmpty;
    });
  }

  Future<void> _fetchNewsCategories() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('NewsCategories').get();
    setState(() {
      _newsCategories =
          snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
    });
  }

  Future<void> _fetchNewsSubcategories() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('NewsSubcategories').get();
    setState(() {
      _newsSubcategories =
          snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
    });
  }

  String _verifyCategoryName(Map<String, dynamic> newsItem) {
    final category = _newsCategories.firstWhere(
      (cat) => cat['id'] == newsItem['news_category_id'],
      orElse: () => {},
    );
    return category['name'] ?? '';
  }

  List<String> _verifySubcategoriesNames(Map<String, dynamic> newsItem) {
    final List subcategoryIds = newsItem['news_subcategory_ids'] ?? [];
    List<String> names = [];
    for (final subId in subcategoryIds) {
      final sub = _newsSubcategories.firstWhere(
        (s) => s['id'] == subId,
        orElse: () => {},
      );
      if (sub['name'] != null) names.add(sub['name']);
    }
    return names;
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    const double closeButtonWidth = 56;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Botão de abrir/fechar barra de pesquisa
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (_searchBarDisplay)
              // 2. Barra de pesquisa (input) à esquerda do botão
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: _searchBarDisplay ? double.infinity : 0,
                  height: 56,
                  margin: const EdgeInsets.only(
                    bottom: 8,
                    right: 0,
                    left: 16,
                    top: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0xFF1D4988),
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12.0, right: 8.0),
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      autofocus: true,
                      maxLength: 75, // Limite de 75 caracteres
                      decoration: const InputDecoration(
                        hintText: 'Busque por Notícias...',
                        border: InputBorder.none,
                        isDense: true,
                        counterText: '', // Esconde o contador de caracteres
                      ),
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),
            // Botão de abrir/fechar
            Container(
              margin: const EdgeInsets.only(
                top: 16,
                bottom: 8,
                right: 16,
                left: 8,
              ),
              width: closeButtonWidth,
              height: 56,
              child: IconButton(
                icon: Icon(
                  _searchBarDisplay ? Icons.close : Icons.search,
                  color: const Color(0xFF1D4988),
                  size: _searchBarDisplay ? 28 : 32,
                ),
                onPressed: () {
                  setState(() {
                    _searchBarDisplay = !_searchBarDisplay;
                    if (!_searchBarDisplay) {
                      _controller.clear();
                      _searchNews = [];
                      _resultSearch = true;
                    } else {
                      _focusNode.requestFocus();
                    }
                  });
                },
                splashRadius: 28,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Color(0xFFF9F9F9)),
                  foregroundColor: MaterialStateProperty.all(Color(0xFF1D4988)),
                  shape: MaterialStateProperty.all(const CircleBorder()),
                  side: MaterialStateProperty.all(
                    const BorderSide(color: Color(0xFF1D4988)),
                  ),
                ),
              ),
            ),
          ],
        ),
        // 3. Resultados da busca abaixo dos elementos
        if (_searchBarDisplay && _debouncedSearchTerm.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
            child:
                _resultSearch
                    ? Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          _searchNews
                              .map(
                                (newsItem) => SizedBox(
                                  width: width < 600 ? width * 0.95 : 352,
                                  child: NewsCard(
                                    newsItem: newsItem,
                                    categoryName: _verifyCategoryName(newsItem),
                                    subcategoriesNames:
                                        _verifySubcategoriesNames(
                                          newsItem,
                                        ).join(', '),
                                    onTap: null,
                                  ),
                                ),
                              )
                              .toList(),
                    )
                    : const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'Nenhum Resultado Encontrado.',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF1D4988),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
          ),
      ],
    );
  }
}
