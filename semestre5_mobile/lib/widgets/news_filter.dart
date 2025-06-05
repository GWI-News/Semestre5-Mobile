import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:semestre5_mobile/widgets/news_card.dart';

class NewsFilter extends StatefulWidget {
  final bool showOffcanvas;
  final VoidCallback onClose;

  const NewsFilter({
    super.key,
    required this.showOffcanvas,
    required this.onClose,
  });

  @override
  State<NewsFilter> createState() => _NewsFilterState();
}

class _NewsFilterState extends State<NewsFilter> {
  static const int _pageSize = 5;
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _remainingCategories = [];
  List<Map<String, dynamic>> _displayedCategories = [];
  List<Map<String, dynamic>> _filteredNews = [];
  List<String> _selectedCategories = [];
  int _currentPage = 0;
  bool _loadingCategories = false;

  // --- Subcategories state ---
  List<Map<String, dynamic>> _subcategories = [];
  List<Map<String, dynamic>> _remainingSubcategories = [];
  List<Map<String, dynamic>> _displayedSubcategories = [];
  List<String> _selectedSubcategories = [];
  int _currentSubPage = 0;
  bool _loadingSubcategories = false;
  // --------------------------

  bool _loadingNews = false;

  @override
  void initState() {
    super.initState();
    if (widget.showOffcanvas) {
      _fetchCategories();
      _fetchSubcategories();
    }
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _loadingCategories = true;
    });
    final snapshot =
        await FirebaseFirestore.instance
            .collection('NewsCategories')
            .orderBy('number_visits', descending: true)
            .get();

    final allCategories =
        snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();

    setState(() {
      _categories = allCategories.take(_pageSize).toList();
      _remainingCategories = allCategories.skip(_pageSize).toList();
      _displayedCategories = _categories;
      _currentPage = 1;
      _loadingCategories = false;
    });
  }

  Future<void> _fetchSubcategories() async {
    setState(() {
      _loadingSubcategories = true;
    });

    final snapshot =
        await FirebaseFirestore.instance
            .collection('NewsSubcategories')
            .orderBy('number_visits', descending: true)
            .get();

    // Garante que cada documento seja convertido para Map<String, dynamic>
    final allSubcategories =
        snapshot.docs
            .map((doc) {
              final data = doc.data();
              if (data == null) return null;
              final map = Map<String, dynamic>.from(data);
              map['id'] = doc.id;
              return map;
            })
            .whereType<Map<String, dynamic>>() // Remove nulos
            .toList();

    setState(() {
      _subcategories = allSubcategories.take(_pageSize).toList();
      _remainingSubcategories = allSubcategories.skip(_pageSize).toList();
      _displayedSubcategories = _subcategories;
      _currentSubPage = 1;
      _loadingSubcategories = false;
    });
  }

  void _showNextCategories() {
    final nextCategories =
        _remainingCategories
            .skip((_currentPage - 1) * _pageSize)
            .take(_pageSize)
            .toList();
    setState(() {
      _displayedCategories.addAll(nextCategories);
      _currentPage += 1;
    });
  }

  void _showNextSubcategories() {
    final nextSubcategories =
        _remainingSubcategories
            .skip((_currentSubPage - 1) * _pageSize)
            .take(_pageSize)
            .toList();
    setState(() {
      _displayedSubcategories.addAll(nextSubcategories);
      _currentSubPage += 1;
    });
  }

  void _toggleCategory(String id) {
    setState(() {
      if (_selectedCategories.contains(id)) {
        _selectedCategories.remove(id);
      } else {
        _selectedCategories.add(id);
      }
    });
  }

  void _toggleSubcategory(String id) {
    setState(() {
      if (_selectedSubcategories.contains(id)) {
        _selectedSubcategories.remove(id);
      } else {
        _selectedSubcategories.add(id);
      }
    });
  }

  Future<void> _filterNews() async {
    if (_selectedCategories.isEmpty && _selectedSubcategories.isEmpty) return;
    setState(() {
      _loadingNews = true;
      _filteredNews = [];
    });

    Query query = FirebaseFirestore.instance.collection('News');
    if (_selectedCategories.isNotEmpty) {
      query = query.where('news_category_id', whereIn: _selectedCategories);
    }
    // Adaptação para array de subcategorias
    if (_selectedSubcategories.isNotEmpty) {
      query = query.where(
        'news_subcategory_ids',
        arrayContainsAny: _selectedSubcategories,
      );
    }

    final snapshot = await query.get();

    final newsList =
        snapshot.docs
            .map((doc) {
              final data = doc.data();
              if (data == null) return null;
              (data as Map<String, dynamic>)['id'] = doc.id;
              return data as Map<String, dynamic>;
            })
            .whereType<
              Map<String, dynamic>
            >() // Remove nulos do resultado final
            .toList();

    setState(() {
      _filteredNews = newsList;
      _loadingNews = false;
    });
  }

  @override
  void didUpdateWidget(covariant NewsFilter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showOffcanvas && !oldWidget.showOffcanvas) {
      _fetchCategories();
      _fetchSubcategories();
    }
    if (!widget.showOffcanvas && oldWidget.showOffcanvas) {
      setState(() {
        _filteredNews = [];
        _selectedCategories = [];
        _displayedCategories = [];
        _currentPage = 0;
        _selectedSubcategories = [];
        _displayedSubcategories = [];
        _currentSubPage = 0;
      });
    }
  }

  // Função para capitalizar a primeira letra de cada palavra
  String capitalize(String s) =>
      s.isEmpty
          ? s
          : s
              .split(' ')
              .map((word) {
                if (word.isEmpty) return word;
                return word[0].toUpperCase() + word.substring(1).toLowerCase();
              })
              .join(' ');

  @override
  Widget build(BuildContext context) {
    if (!widget.showOffcanvas) return const SizedBox.shrink();

    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    // Calcule a largura da navbar conforme o layout responsivo do projeto
    final double navbarWidth =
        width <= 576 ? width : (width <= 992 ? width * 0.6 : width * 0.4);

    // O filtro ocupa 90% da largura da navbar
    final double filterWidth = navbarWidth * 0.9;
    // O filtro fica centralizado em relação à navbar
    final double filterLeft = (width - filterWidth) / 2;

    // Espaço ocupado por header e navbar
    final double headerHeight = height * 0.12;
    final double navbarHeight = width <= 576 ? height * 0.10 : height * 0.12;
    final double availableHeight = height - headerHeight - navbarHeight;
    final double maxFilterHeight = availableHeight * 0.9;

    // Defina a cor padrão azul do site
    const Color borderColor = Color(0xFF1D4988);

    // Defina a borda conforme o tamanho da tela
    BorderSide borderSide = const BorderSide(color: borderColor, width: 2);

    Border filterBorder;
    if (width > 576) {
      // Em telas grandes, sem borda superior
      filterBorder = Border(
        left: borderSide,
        right: borderSide,
        bottom: borderSide,
        top: BorderSide.none,
      );
    } else {
      // Em telas pequenas, sem borda inferior
      filterBorder = Border(
        left: borderSide,
        right: borderSide,
        top: borderSide,
        bottom: BorderSide.none,
      );
    }

    return Positioned(
      left: filterLeft,
      width: filterWidth,
      top: width > 576 ? navbarHeight : null,
      bottom: width <= 576 ? navbarHeight : null,
      child: Material(
        color: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(minHeight: 0, maxHeight: maxFilterHeight),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: filterBorder, // Borda azul dinâmica
            borderRadius:
                width > 576
                    ? const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                      topLeft: Radius.circular(0),
                      topRight: Radius.circular(0),
                    )
                    : const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListView(
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              // Título e botão de fechar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text(
                      'Filtro',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D4988),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF1D4988),
                        width: 1.5,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF1D4988)),
                      onPressed: widget.onClose,
                      tooltip: 'Fechar filtro',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Categorias mais acessadas',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D4988),
                ),
              ),
              const SizedBox(height: 16),
              if (_loadingCategories)
                const Center(child: CircularProgressIndicator())
              else ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ..._displayedCategories.map((cat) {
                      final selected = _selectedCategories.contains(cat['id']);
                      return GestureDetector(
                        onTap: () => _toggleCategory(cat['id']),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color:
                                selected
                                    ? const Color(0xFF1D4988)
                                    : const Color(0xFFF9F9F9),
                            border: Border.all(
                              color: const Color(0xFF1D4988),
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                capitalize(cat['name'] ?? ''),
                                style: TextStyle(
                                  color:
                                      selected
                                          ? Colors.white
                                          : const Color(0xFF1D4988),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                              if (selected)
                                const Padding(
                                  padding: EdgeInsets.only(left: 6),
                                  child: Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    if (_displayedCategories.length <
                            _categories.length + _remainingCategories.length &&
                        _remainingCategories.length >
                            (_currentPage - 1) * _pageSize)
                      GestureDetector(
                        onTap: _showNextCategories,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9F9F9),
                            border: Border.all(
                              color: const Color(0xFF1D4988),
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.more_horiz, color: Color(0xFF1D4988)),
                              SizedBox(width: 8),
                              Text(
                                'Mais categorias',
                                style: TextStyle(
                                  color: Color(0xFF1D4988),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 24),

              // --- Subcategorias ---
              const Text(
                'Subcategorias mais acessadas',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D4988),
                ),
              ),
              const SizedBox(height: 16),
              if (_loadingSubcategories)
                const Center(child: CircularProgressIndicator())
              else ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ..._displayedSubcategories.map((sub) {
                      final selected = _selectedSubcategories.contains(
                        sub['id'],
                      );
                      return GestureDetector(
                        onTap: () => _toggleSubcategory(sub['id']),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color:
                                selected
                                    ? const Color(0xFF1D4988)
                                    : const Color(0xFFF9F9F9),
                            border: Border.all(
                              color: const Color(0xFF1D4988),
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                capitalize(sub['name'] ?? ''),
                                style: TextStyle(
                                  color:
                                      selected
                                          ? Colors.white
                                          : const Color(0xFF1D4988),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                              if (selected)
                                const Padding(
                                  padding: EdgeInsets.only(left: 6),
                                  child: Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    if (_displayedSubcategories.length <
                            _subcategories.length +
                                _remainingSubcategories.length &&
                        _remainingSubcategories.length >
                            (_currentSubPage - 1) * _pageSize)
                      GestureDetector(
                        onTap: _showNextSubcategories,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9F9F9),
                            border: Border.all(
                              color: const Color(0xFF1D4988),
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.more_horiz, color: Color(0xFF1D4988)),
                              SizedBox(width: 8),
                              Text(
                                'Mais subcategorias',
                                style: TextStyle(
                                  color: Color(0xFF1D4988),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 16),

              // --- Fim Subcategorias ---
              ElevatedButton(
                onPressed:
                    (_selectedCategories.isEmpty &&
                                _selectedSubcategories.isEmpty) ||
                            _loadingNews
                        ? null
                        : _filterNews,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D4988),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 24,
                  ),
                ),
                child:
                    _loadingNews
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Text('Filtrar', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 16),
              if (_filteredNews.isNotEmpty)
                ..._filteredNews.map(
                  (newsItem) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: NewsCard(
                      newsItem: newsItem,
                      categoryName: '',
                      subcategoriesNames: '',
                      onTap: null,
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
