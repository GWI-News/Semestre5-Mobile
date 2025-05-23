import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    // Definições responsivas
    double containerWidth;
    EdgeInsetsGeometry padding;
    MainAxisAlignment rowAlignment;
    Alignment containerAlignment;

    if (width <= 576) {
      containerWidth = width;
      padding = EdgeInsets.zero;
      rowAlignment = MainAxisAlignment.center;
      containerAlignment = Alignment.topCenter;
    } else if (width <= 992) {
      containerWidth = width * 0.5;
      padding = const EdgeInsets.only(left: 16.0);
      rowAlignment = MainAxisAlignment.start;
      containerAlignment = Alignment.topLeft;
    } else {
      containerWidth = width * 0.6;
      padding = const EdgeInsets.only(left: 32.0);
      rowAlignment = MainAxisAlignment.start;
      containerAlignment = Alignment.topLeft;
    }

    // Altura do header
    final double headerHeight = MediaQuery.of(context).size.height * 0.12;
    // Altura máxima do logo
    final double logoMaxHeight = width <= 576
        ? headerHeight
        : width <= 992
            ? headerHeight * 0.9
            : 128.0;

    final double logoMaxWidth = containerWidth - (padding is EdgeInsets ? (padding as EdgeInsets).left : 0);

    return Align(
      alignment: containerAlignment,
      child: Container(
        width: containerWidth < 320 ? 320 : containerWidth,
        constraints: const BoxConstraints(minWidth: 320),
        height: headerHeight,
        decoration: const BoxDecoration(
          color: Color(0xFFEBEBEB),
          border: Border(
            bottom: BorderSide(color: Color(0xFF1D4988), width: 8.0),
          ),
        ),
        child: Row(
          mainAxisAlignment: rowAlignment,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: padding,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: logoMaxHeight,
                  maxWidth: logoMaxWidth > 0 ? logoMaxWidth : containerWidth,
                ),
                child: AspectRatio(
                  aspectRatio: 4, // Ajuste conforme a proporção real do seu logo
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).maybePop();
                    },
                    child: SvgPicture.asset(
                      'assets/GwiNewsLogo.svg',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
