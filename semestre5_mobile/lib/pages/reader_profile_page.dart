import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:semestre5_mobile/widgets/news_filter.dart';
import 'package:semestre5_mobile/widgets/navbar_user_utilities.dart';
import 'package:semestre5_mobile/widgets/navbar.dart';
import 'package:semestre5_mobile/widgets/header.dart';
import 'package:semestre5_mobile/widgets/news_card.dart';

class ReaderProfilePage extends StatefulWidget {
  const ReaderProfilePage({super.key});

  @override
  State<ReaderProfilePage> createState() => _ReaderProfilePageState();
}

class _ReaderProfilePageState extends State<ReaderProfilePage> {
  bool _showNewsFilter = false;
  bool _showUserUtilities = false;

  List<Map<String, dynamic>> _favoriteNews = [];
  bool _loadingFavorites = true;
  String? _completeName;

  @override
  void initState() {
    super.initState();
    _fetchFavoriteNews();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _completeName = null;
      });
      return;
    }
    QuerySnapshot<Map<String, dynamic>> query =
        await FirebaseFirestore.instance
            .collection('Users')
            .where('auth_uid', isEqualTo: user.uid)
            .limit(1)
            .get();

    if (query.docs.isNotEmpty) {
      setState(() {
        _completeName = query.docs.first.data()['completeName'] ?? null;
      });
    } else {
      setState(() {
        _completeName = null;
      });
    }
  }

  Future<void> _fetchFavoriteNews() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _favoriteNews = [];
        _loadingFavorites = false;
      });
      return;
    }

    // Busca documento do usuário pelo campo "auth_uid"
    QuerySnapshot<Map<String, dynamic>> query =
        await FirebaseFirestore.instance
            .collection('Users')
            .where('auth_uid', isEqualTo: user.uid)
            .limit(1)
            .get();

    if (query.docs.isEmpty) {
      setState(() {
        _favoriteNews = [];
        _loadingFavorites = false;
      });
      return;
    }

    final userDoc = query.docs.first.data();
    final favList =
        (userDoc['favourite_news'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    if (favList.isEmpty) {
      setState(() {
        _favoriteNews = [];
        _loadingFavorites = false;
      });
      return;
    }

    // Busca as notícias favoritas
    final newsQuery =
        await FirebaseFirestore.instance
            .collection('News')
            .where(FieldPath.documentId, whereIn: favList)
            .get();

    setState(() {
      _favoriteNews =
          newsQuery.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
      _loadingFavorites = false;
    });
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
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
                        const SizedBox(height: 24),
                        Icon(
                          Icons.person,
                          size: 120, // Aumentado de 80 para 120
                          color: const Color(0xFF1D4988),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _completeName ?? user?.email ?? 'Usuário',
                          style: const TextStyle(
                            fontSize: 32, // Aumentado de 22 para 32
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (user?.email != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0, bottom: 0),
                            child: Text(
                              user!.email!,
                              style: const TextStyle(
                                fontSize: 22, // Aumentado de 16 para 22
                                color: Color(0xFF1D4988),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          icon: const Icon(
                            Icons.logout,
                            color: Color(0xFF1D4988),
                          ),
                          label: const Text('Logout'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF1D4988),
                            side: const BorderSide(
                              color: Color(0xFF1D4988),
                              width: 2,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            textStyle: const TextStyle(fontSize: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () => _logout(context),
                        ),
                        const SizedBox(height: 32),
                        // Sessão de notícias favoritas
                        Center(
                          child: Text(
                            'Notícias Favoritas',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1D4988),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_loadingFavorites)
                          const Center(child: CircularProgressIndicator())
                        else if (_favoriteNews.isEmpty)
                          const Text(
                            'Nenhuma notícia favoritada.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF1D4988),
                            ),
                          )
                        else
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                _favoriteNews.map((news) {
                                  return NewsCard(
                                    newsItem: news,
                                    categoryName:
                                        news['news_category_name'] ?? '',
                                    subcategoriesNames:
                                        (news['news_subcategories']
                                                    as List<dynamic>? ??
                                                [])
                                            .cast<String>()
                                            .join(', '),
                                    onTap: () {
                                      Navigator.of(context).pushNamed(
                                        '/noticia',
                                        arguments: {
                                          'newsCategory':
                                              news['news_category_id'] ?? '',
                                          'newsSubcategories':
                                              news['news_subcategories'] ?? '',
                                          'newsId': news['id'],
                                        },
                                      );
                                    },
                                  );
                                }).toList(),
                          ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Shadow fade para offcanvas
          if (_showNewsFilter || _showUserUtilities)
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
              });
            },
            onUserTap: () {
              setState(() {
                _showUserUtilities = true;
              });
            },
          ),
          const Header(),
        ],
      ),
    );
  }
}
