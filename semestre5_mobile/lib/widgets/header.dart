import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

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
      containerWidth = width * 0.4;
      padding = const EdgeInsets.only(left: 16.0);
      rowAlignment = MainAxisAlignment.start;
      containerAlignment = Alignment.topLeft;
    } else {
      containerWidth = width * 0.6;
      padding = const EdgeInsets.only(left: 32.0);
      rowAlignment = MainAxisAlignment.start;
      containerAlignment = Alignment.topLeft;
    }

    final double headerHeight = MediaQuery.of(context).size.height * 0.12;
    final double logoMaxHeight =
        width <= 576
            ? headerHeight
            : width <= 992
            ? headerHeight * 0.9
            : 128.0;

    final double logoMaxWidth =
        containerWidth - (padding is EdgeInsets ? padding.left : 0);

    return Stack(
      children: [
        Align(
          alignment: containerAlignment,
          child: SizedBox(
            width: containerWidth < 320 ? 320 : containerWidth,
            height: headerHeight,
            child: Row(
              mainAxisAlignment: rowAlignment,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: padding,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: logoMaxHeight,
                      maxWidth:
                          logoMaxWidth > 0 ? logoMaxWidth : containerWidth,
                    ),
                    child: AspectRatio(
                      aspectRatio: 4,
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
        ),
        // Linha azul agora fica abaixo do header, ocupando 100% da largura da tela
        Positioned(
          left: 0,
          right: 0,
          top: headerHeight,
          child: Container(height: 4, color: const Color(0xFF1D4988)),
        ),
      ],
    );
  }
}
