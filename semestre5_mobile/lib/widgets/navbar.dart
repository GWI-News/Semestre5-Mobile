import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Navbar extends StatelessWidget {
  final VoidCallback? onFilterTap;
  final VoidCallback? onUserTap;

  const Navbar({super.key, this.onFilterTap, this.onUserTap});

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    final bool isMobile = width <= 576;

    double containerWidth;
    double containerHeight;
    Alignment containerAlignment;
    BoxBorder? border;
    EdgeInsetsGeometry containerPadding;
    double iconSize;
    double labelFontSize;
    double itemVerticalPadding;

    if (isMobile) {
      containerWidth = width;
      containerHeight = height * 0.12;
      containerAlignment = Alignment.bottomCenter;
      border = const Border(
        top: BorderSide(color: Color(0xFF1D4988), width: 4.0),
      );
      containerPadding = EdgeInsets.zero;
      iconSize = containerHeight * 0.45;
      labelFontSize = containerHeight * 0.22;
      itemVerticalPadding = containerHeight * 0.08;
    } else {
      // Para breakpoints maiores que 576px, não aplica border bottom
      if (width <= 992) {
        containerWidth = width * 0.6;
        containerHeight = height * 0.12;
        containerAlignment = Alignment.topRight;
      } else {
        containerWidth = width * 0.4;
        containerHeight = height * 0.12;
        containerAlignment = Alignment.topRight;
      }
      border = null; // Remove border bottom
      containerPadding = EdgeInsets.symmetric(vertical: containerHeight * 0.04);
      iconSize = containerHeight * 0.4;
      labelFontSize = containerHeight * 0.22;
      itemVerticalPadding = containerHeight * 0.08;
    }

    // Adicione um Material com tipo 'transparency' e um Stack com Positioned.fill para garantir z-index alto
    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            ignoring: true,
            child: Container(), // camada base transparente
          ),
        ),
        Positioned(
          top: containerAlignment == Alignment.bottomCenter ? null : 0,
          bottom: containerAlignment == Alignment.bottomCenter ? 0 : null,
          left: 0,
          right: 0,
          child: Material(
            type: MaterialType.transparency,
            elevation: 20, // z-index alto
            child: Align(
              alignment: containerAlignment,
              child: Container(
                width: containerWidth < 320 ? 320 : containerWidth,
                height: containerHeight,
                constraints: const BoxConstraints(minWidth: 320),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBEBEB),
                  border: border,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _NavbarIcon(
                      icon: Icons.home_rounded,
                      label: 'Home',
                      onTap: () {
                        Navigator.of(context).pushNamed('/home');
                      },
                      iconSize: iconSize,
                      labelFontSize: labelFontSize,
                      verticalPadding: itemVerticalPadding,
                    ),
                    _NavbarIcon(
                      icon: Icons.filter_alt_rounded,
                      label: 'Filtro',
                      onTap: onFilterTap ?? () {},
                      iconSize: iconSize,
                      labelFontSize: labelFontSize,
                      verticalPadding: itemVerticalPadding,
                    ),
                    _NavbarIcon(
                      icon: Icons.info_rounded,
                      label: 'Sobre',
                      onTap: () {
                        Navigator.of(context).pushNamed('/sobre');
                      },
                      iconSize: iconSize,
                      labelFontSize: labelFontSize,
                      verticalPadding: itemVerticalPadding,
                    ),
                    _NavbarIcon(
                      icon: Icons.person_rounded,
                      label: 'Perfil',
                      onTap: () async {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null && user.emailVerified) {
                          // Busca robusta do userRole
                          QuerySnapshot<Map<String, dynamic>> userDoc =
                              await FirebaseFirestore.instance
                                  .collection('Users')
                                  .where('auth_uid', isEqualTo: user.uid)
                                  .limit(1)
                                  .get();

                          if (userDoc.docs.isEmpty) {
                            userDoc =
                                await FirebaseFirestore.instance
                                    .collection('Users')
                                    .where('id', isEqualTo: user.uid)
                                    .limit(1)
                                    .get();
                          }
                          if (userDoc.docs.isEmpty) {
                            userDoc =
                                await FirebaseFirestore.instance
                                    .collection('Users')
                                    .where('email', isEqualTo: user.email)
                                    .limit(1)
                                    .get();
                          }

                          int userRole = 0; // padrão leitor
                          if (userDoc.docs.isNotEmpty &&
                              userDoc.docs.first.data().containsKey(
                                'userRole',
                              )) {
                            userRole = userDoc.docs.first['userRole'] ?? 0;
                          }

                          if (userRole == 1) {
                            Navigator.of(
                              context,
                            ).pushReplacementNamed('/perfil/adm');
                          } else if (userRole == 2) {
                            Navigator.of(
                              context,
                            ).pushReplacementNamed('/perfil/autor');
                          } else {
                            Navigator.of(
                              context,
                            ).pushReplacementNamed('/perfil/leitor');
                          }
                        } else {
                          // Usuário não autenticado: abre o offcanvas de login
                          if (onUserTap != null) onUserTap!();
                        }
                      },
                      iconSize: iconSize,
                      labelFontSize: labelFontSize,
                      verticalPadding: itemVerticalPadding,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NavbarIcon extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final double iconSize;
  final double labelFontSize;
  final double verticalPadding;

  const _NavbarIcon({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.iconSize,
    required this.labelFontSize,
    required this.verticalPadding,
  });

  @override
  State<_NavbarIcon> createState() => _NavbarIconState();
}

class _NavbarIconState extends State<_NavbarIcon> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: EdgeInsets.symmetric(
            vertical: widget.verticalPadding,
          ).add(_hovering ? const EdgeInsets.all(2.6) : EdgeInsets.zero),
          decoration: BoxDecoration(
            color: _hovering ? const Color(0xFFEBEBEB) : Colors.transparent,
            borderRadius: BorderRadius.circular(_hovering ? 8 : 0),
            border:
                _hovering
                    ? Border.all(color: const Color(0xFF1D4988), width: 1)
                    : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                color: const Color(0xFF1D4988),
                size: widget.iconSize,
              ),
              const SizedBox(height: 2),
              Text(
                widget.label,
                style: TextStyle(
                  color: const Color(0xFF1D4988),
                  fontSize: widget.labelFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
