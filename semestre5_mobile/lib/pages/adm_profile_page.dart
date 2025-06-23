import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:semestre5_mobile/widgets/news_filter.dart';
import 'package:semestre5_mobile/widgets/navbar_user_utilities.dart';
import 'package:semestre5_mobile/widgets/navbar.dart';
import 'package:semestre5_mobile/widgets/header.dart';

class AdmProfilePage extends StatefulWidget {
  const AdmProfilePage({super.key});

  @override
  State<AdmProfilePage> createState() => _AdmProfilePageState();
}

class _AdmProfilePageState extends State<AdmProfilePage> {
  bool _showNewsFilter = false;
  bool _showUserUtilities = false;
  String? _completeName;

  @override
  void initState() {
    super.initState();
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

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    final double navbarHeight = height * 0.12;

    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.admin_panel_settings,
                    size: 120,
                    color: const Color(0xFF1D4988),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _completeName ?? user?.email ?? 'Usuário',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (user?.email != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 0),
                      child: Text(
                        user!.email!,
                        style: const TextStyle(
                          fontSize: 22,
                          color: Color(0xFF1D4988),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.newspaper),
                    label: const Text('Gerenciar Notícias'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1D4988), // Fundo azul
                      foregroundColor: Colors.white, // Fonte branca
                      side: const BorderSide(
                        color: Color(0xFF1D4988),
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).pushNamed('/perfil/adm/gerenciamento-noticias');
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.group),
                    label: const Text('Gerenciar Usuários'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1D4988), // Fundo azul
                      foregroundColor: Colors.white, // Fonte branca
                      side: const BorderSide(
                        color: Color(0xFF1D4988),
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).pushNamed('/perfil/adm/gerenciamento-usuarios');
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.logout, color: Color(0xFF1D4988)),
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
                ],
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
