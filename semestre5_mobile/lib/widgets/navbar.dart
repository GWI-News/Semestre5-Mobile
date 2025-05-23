import 'package:flutter/material.dart';

class Navbar extends StatelessWidget {
  const Navbar({super.key});

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
    double iconSize = 48;

    if (isMobile) {
      containerWidth = width;
      containerHeight = height * 0.10;
      containerAlignment = Alignment.bottomCenter;
      border = const Border(
        top: BorderSide(color: Color(0xFF1D4988), width: 8.0),
      );
      containerPadding = EdgeInsets.zero;
    } else if (width <= 992) {
      containerWidth = width * 0.6;
      containerHeight = height * 0.12;
      containerAlignment = Alignment.topRight;
      border = const Border(
        bottom: BorderSide(color: Color(0xFF1D4988), width: 8.0),
      );
      containerPadding = const EdgeInsets.symmetric(vertical: 10.0);
    } else {
      containerWidth = width * 0.4;
      containerHeight = height * 0.12;
      containerAlignment = Alignment.topRight;
      border = const Border(
        bottom: BorderSide(color: Color(0xFF1D4988), width: 8.0),
      );
      containerPadding = const EdgeInsets.symmetric(vertical: 10.0);
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
          children: [
            _NavbarIcon(
              icon: Icons.home_rounded,
              label: 'Home',
              onTap: () {},
              size: iconSize,
            ),
            _NavbarIcon(
              icon: Icons.filter_alt_rounded,
              label: 'Filtro',
              onTap: () {},
              size: iconSize,
            ),
            _NavbarIcon(
              icon: Icons.info_rounded,
              label: 'Sobre',
              onTap: () {},
              size: iconSize,
            ),
            _NavbarIcon(
              icon: Icons.person_rounded,
              label: 'Perfil',
              onTap: () {},
              size: iconSize,
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
  final double size;

  const _NavbarIcon({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.size,
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
          padding: _hovering ? const EdgeInsets.all(2.6) : EdgeInsets.zero,
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
                size: widget.size,
              ),
              const SizedBox(height: 4),
              Text(
                widget.label,
                style: const TextStyle(
                  color: Color(0xFF1D4988),
                  fontSize: 16,
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
