import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    } else if (width <= 992) {
      containerWidth = width * 0.6;
      containerHeight = height * 0.12;
      containerAlignment = Alignment.topRight;
      border = const Border(
        bottom: BorderSide(color: Color(0xFF1D4988), width: 4.0),
      );
      containerPadding = EdgeInsets.symmetric(vertical: containerHeight * 0.04);
      iconSize = containerHeight * 0.4;
      labelFontSize = containerHeight * 0.22;
      itemVerticalPadding = containerHeight * 0.08;
    } else {
      containerWidth = width * 0.4;
      containerHeight = height * 0.12;
      containerAlignment = Alignment.topRight;
      border = const Border(
        bottom: BorderSide(color: Color(0xFF1D4988), width: 4.0),
      );
      containerPadding = EdgeInsets.symmetric(vertical: containerHeight * 0.04);
      iconSize = containerHeight * 0.4;
      labelFontSize = containerHeight * 0.18;
      itemVerticalPadding = containerHeight * 0.08;
    }

    return Align(
      alignment: containerAlignment,
      child: Container(
        width: containerWidth < 320 ? 320 : containerWidth,
        height: containerHeight,
        constraints: const BoxConstraints(minWidth: 320),
        decoration: BoxDecoration(
          color: const Color(0xFFEBEBEB),
          border: border,
        ),
        padding: containerPadding,
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
              onTap: () {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null && user.emailVerified) {
                  // Usuário autenticado e email verificado: redireciona para perfil
                  Navigator.of(context).pushReplacementNamed('/perfil/adm');
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
