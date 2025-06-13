import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:semestre5_mobile/widgets/news_card.dart';
import 'package:semestre5_mobile/widgets/header.dart';
import 'package:semestre5_mobile/widgets/navbar.dart';
import 'package:semestre5_mobile/widgets/news_filter.dart';
import 'package:semestre5_mobile/widgets/navbar_user_utilities.dart';

class NewsCrudPage extends StatefulWidget {
  const NewsCrudPage({super.key});

  @override
  State<NewsCrudPage> createState() => _NewsCrudPageState();
}

class _NewsCrudPageState extends State<NewsCrudPage> {
  List<Map<String, dynamic>> _newsList = [];
  bool _loading = true;

  // Controladores de estado para offcanvas
  bool _showNewsFilter = false;
  bool _showUserUtilities = false;

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  Future<void> _fetchNews() async {
    setState(() => _loading = true);
    final snapshot = await FirebaseFirestore.instance.collection('News').get();
    setState(() {
      _newsList =
          snapshot.docs
              .map((doc) => {...doc.data(), 'id': doc.id})
              .cast<Map<String, dynamic>>()
              .toList();
      _loading = false;
    });
  }

  Future<void> _deleteNews(String id) async {
    await FirebaseFirestore.instance.collection('News').doc(id).delete();
    _fetchNews();
  }

  void _navigateToCreateNews() {
    Navigator.of(context).pushNamed('/Perfil/Adm/CreateNoticia');
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
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        'Painel de Notícias',
                        style: TextStyle(
                          fontSize: 32,
                          color: const Color(0xFF1D4988),
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: width < 600 ? width * 0.9 : 400,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                              '/perfil/adm/gerenciamento-noticias/criacao-noticia',
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF9F9F9),
                            foregroundColor: const Color(0xFF1D4988),
                            side: const BorderSide(
                              color: Color(0xFF1D4988),
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Criar Notícia',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child:
                            _loading
                                ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                                : _newsList.isEmpty
                                ? const Center(
                                  child: Text(
                                    'Nenhuma notícia cadastrada.',
                                    style: TextStyle(
                                      color: Color(0xFF1D4988),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                )
                                : SingleChildScrollView(
                                  child: Center(
                                    child: Wrap(
                                      alignment: WrapAlignment.center,
                                      spacing: 8,
                                      runSpacing: 8,
                                      children:
                                          _newsList.map((news) {
                                            return ConstrainedBox(
                                              constraints: const BoxConstraints(
                                                maxWidth:
                                                    352, // igual ao NewsCard do dashboard
                                                minWidth: 280,
                                              ),
                                              child: Card(
                                                elevation: 2,
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 8,
                                                        horizontal: 8,
                                                      ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .stretch,
                                                    children: [
                                                      NewsCard(
                                                        newsItem: news,
                                                        categoryName:
                                                            news['category'] ??
                                                            '',
                                                        subcategoriesNames:
                                                            news['subcategories'] ??
                                                            '',
                                                        onTap: () {
                                                          // Navegar para detalhes se desejar
                                                        },
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          // Botão de edição
                                                          TextButton.icon(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                context,
                                                              ).pushNamed(
                                                                '/perfil/adm/gerenciamento-noticias/edicao-noticia',
                                                                arguments: {
                                                                  'newsId':
                                                                      news['id'],
                                                                },
                                                              );
                                                            },
                                                            icon: const Icon(
                                                              Icons.edit,
                                                              color: Color(
                                                                0xFF1D4988,
                                                              ),
                                                            ),
                                                            label: const Text(
                                                              'Alterar',
                                                              style: TextStyle(
                                                                color: Color(
                                                                  0xFF1D4988,
                                                                ),
                                                              ),
                                                            ),
                                                            style: TextButton.styleFrom(
                                                              foregroundColor:
                                                                  const Color(
                                                                    0xFF1D4988,
                                                                  ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 8,
                                                          ),
                                                          // Botão de exclusão (já existente)
                                                          TextButton.icon(
                                                            onPressed: () async {
                                                              final confirm = await showDialog<
                                                                bool
                                                              >(
                                                                context:
                                                                    context,
                                                                barrierDismissible:
                                                                    false,
                                                                builder:
                                                                    (
                                                                      context,
                                                                    ) => AlertDialog(
                                                                      shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              12,
                                                                            ),
                                                                      ),
                                                                      backgroundColor:
                                                                          const Color(
                                                                            0xFFF9F9F9,
                                                                          ),
                                                                      title: const Text(
                                                                        'Confirmar exclusão',
                                                                        style: TextStyle(
                                                                          color: Color(
                                                                            0xFF1D4988,
                                                                          ),
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          fontSize:
                                                                              22,
                                                                        ),
                                                                      ),
                                                                      content: const Text(
                                                                        'Tem certeza que deseja excluir esta notícia? Esta ação não pode ser desfeita.',
                                                                        style: TextStyle(
                                                                          color: Color(
                                                                            0xFF1D4988,
                                                                          ),
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                        ),
                                                                      ),
                                                                      actionsPadding: const EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            16,
                                                                        vertical:
                                                                            8,
                                                                      ),
                                                                      actions: [
                                                                        SizedBox(
                                                                          width:
                                                                              120,
                                                                          child: OutlinedButton(
                                                                            style: OutlinedButton.styleFrom(
                                                                              foregroundColor: const Color(
                                                                                0xFF1D4988,
                                                                              ),
                                                                              side: const BorderSide(
                                                                                color: Color(
                                                                                  0xFF1D4988,
                                                                                ),
                                                                                width:
                                                                                    2,
                                                                              ),
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(
                                                                                  5,
                                                                                ),
                                                                              ),
                                                                              padding: const EdgeInsets.symmetric(
                                                                                vertical:
                                                                                    12,
                                                                              ),
                                                                              textStyle: const TextStyle(
                                                                                fontSize:
                                                                                    16,
                                                                                fontWeight:
                                                                                    FontWeight.w600,
                                                                              ),
                                                                            ),
                                                                            onPressed:
                                                                                () => Navigator.of(
                                                                                  context,
                                                                                ).pop(
                                                                                  false,
                                                                                ),
                                                                            child: const Text(
                                                                              'Cancelar',
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              120,
                                                                          child: ElevatedButton(
                                                                            style: ElevatedButton.styleFrom(
                                                                              backgroundColor: const Color(
                                                                                0xFF1D4988,
                                                                              ),
                                                                              foregroundColor:
                                                                                  Colors.white,
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(
                                                                                  5,
                                                                                ),
                                                                              ),
                                                                              padding: const EdgeInsets.symmetric(
                                                                                vertical:
                                                                                    12,
                                                                              ),
                                                                              textStyle: const TextStyle(
                                                                                fontSize:
                                                                                    16,
                                                                                fontWeight:
                                                                                    FontWeight.w600,
                                                                              ),
                                                                            ),
                                                                            onPressed:
                                                                                () => Navigator.of(
                                                                                  context,
                                                                                ).pop(
                                                                                  true,
                                                                                ),
                                                                            child: const Text(
                                                                              'Excluir',
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                              );
                                                              if (confirm ==
                                                                  true) {
                                                                _deleteNews(
                                                                  news['id'],
                                                                );
                                                              }
                                                            },
                                                            icon: const Icon(
                                                              Icons.delete,
                                                              color: Colors.red,
                                                            ),
                                                            label: const Text(
                                                              'Excluir',
                                                              style: TextStyle(
                                                                color:
                                                                    Colors.red,
                                                              ),
                                                            ),
                                                            style:
                                                                TextButton.styleFrom(
                                                                  foregroundColor:
                                                                      Colors
                                                                          .red,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                    ),
                                  ),
                                ),
                      ),
                      const SizedBox(height: 24),
                    ],
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
                  });
                },
              ),
            ),
          // Navbar e Header sempre interativos
          Navbar(
            onFilterTap: () {
              setState(() {
                _showNewsFilter = true;
                _showUserUtilities = false;
              });
            },
            onUserTap: () {
              setState(() {
                _showUserUtilities = true;
                _showNewsFilter = false;
              });
            },
          ),
          const Header(),
        ],
      ),
    );
  }
}
