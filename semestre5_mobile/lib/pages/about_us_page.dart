import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:semestre5_mobile/widgets/header.dart';
import 'package:semestre5_mobile/widgets/navbar.dart';
import 'package:semestre5_mobile/widgets/news_filter.dart'; // Import do filtro
import 'package:semestre5_mobile/widgets/navbar_user_utilities.dart'; // Adicione este import

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  bool _showNewsFilter = false;
  bool _showUserUtilities = false;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    double contentWidth;
    if (width >= 992) {
      contentWidth = width * 0.8;
    } else if (width >= 576) {
      contentWidth = width * 0.9;
    } else {
      contentWidth = width;
    }

    final double headerHeight = height * 0.12;
    final double navbarHeight = height * 0.12;

    double image1Width = width > 576 ? width * 0.35 : width * 0.65;
    double image2Width = width > 576 ? width * 0.20 : width * 0.50;

    TextStyle h1Style = const TextStyle(
      fontSize: 40,
      color: Color(0xFF1D4988),
      fontWeight: FontWeight.bold,
      height: 1.1,
    );
    TextStyle h2Style = const TextStyle(
      fontSize: 28,
      color: Color(0xFF1D4988),
      fontWeight: FontWeight.w600,
      height: 1.1,
    );
    TextStyle pStyle = const TextStyle(
      color: Color(0xFF141414),
      fontSize: 22,
      height: 1.4,
      fontWeight: FontWeight.w400,
    );
    TextStyle linkStyle = pStyle.copyWith(
      color: const Color(0xFF1D4988),
      decoration: TextDecoration.underline,
      fontWeight: FontWeight.w500,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFEBEBEB),
      body: Stack(
        children: [
          // Conteúdo principal com padding dinâmico para header/navbar
          SingleChildScrollView(
            child: Center(
              child: Container(
                // Adiciona espaçamento de 8px no topo e base do container principal
                padding: EdgeInsets.only(
                  left: 12,
                  right: 12,
                  top: headerHeight + 8,
                  bottom: (width < 576 ? navbarHeight : 0) + 8,
                ),
                width: contentWidth,
                child: Container(
                  color: const Color(0xFFF9F9F9),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // FAQ
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(top: 16),
                        child: Column(
                          children: [
                            Text('FAQ', style: h1Style),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/faq', // Rota para a página de FAQ
                                );
                              },
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: Text(
                                  'Clique Aqui para Acessar nosso Faq!',
                                  style: h2Style.copyWith(
                                    decoration: TextDecoration.underline,
                                    color: const Color(0xFF1D4988),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Nossos Serviços
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            Text('Nossos Serviços', style: h1Style),
                            const SizedBox(height: 12),
                            _ServiceSection(
                              title: 'Empregos',
                              description:
                                  'Mantenha-se atualizado com as últimas vagas de trabalho, oportunidades de carreira e '
                                  'tendências de mercado relevantes para profissionais em busca de novas oportunidades.',
                              imagePath: 'assets/art_empregos.svg',
                              imageWidth: image1Width,
                              pStyle: pStyle,
                              h2Style: h2Style,
                            ),
                            _ServiceSection(
                              title: 'Educação',
                              description:
                                  'Esteja atualizado sobre as tendências e novidades na área da educação, desde avanços na tecnologia educacional até '
                                  'programas educacionais inovadores.',
                              imagePath: 'assets/art_educacao.svg',
                              imageWidth: image1Width,
                              pStyle: pStyle,
                              h2Style: h2Style,
                            ),
                            _ServiceSection(
                              title: 'Esportes',
                              description:
                                  'Esteja no centro da ação esportiva com nosso serviço de divulgação de notícias esportivas e desfrute de uma experiência envolvente e informativa que o manterá à frente do jogo.',
                              imagePath: 'assets/art_esportes.svg',
                              imageWidth: image1Width,
                              pStyle: pStyle,
                              h2Style: h2Style,
                            ),
                            _ServiceSection(
                              title: 'Entretenimento',
                              description:
                                  'Mantenha-se atualizado sobre lançamentos de filmes e séries e até mesmo shows e concertos exibidos na região, trazemos informações exclusivas, entrevistas com artistas, críticas e recomendações para que você.',
                              imagePath: 'assets/art_entretenimento.svg',
                              imageWidth: image1Width,
                              pStyle: pStyle,
                              h2Style: h2Style,
                            ),
                            _ServiceSection(
                              title: 'Economia',
                              description:
                                  'Descubra insights valiosos e navegue pelo mundo dos negócios com confiança e conhecimento. '
                                  'Seja você um investidor, empreendedor ou profissional buscando compreender os desafios e oportunidades da economia atual, nosso serviço é a sua fonte confiável de informações.',
                              imagePath: 'assets/art_economia.svg',
                              imageWidth: image1Width,
                              pStyle: pStyle,
                              h2Style: h2Style,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Nossa Equipe
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            Text('Nossa Equipe', style: h1Style),
                            const SizedBox(height: 12),
                            _TeamMember(
                              name: 'Gabriel Fecchio - Arquiteto de Software',
                              imagePath: 'assets/gabriel.jpg',
                              imageWidth: image2Width,
                              description:
                                  'Tenho 19 anos, sou formado como técnico em administração e atualmente estou cursando faculdade de desenvolvimento de software.',
                              email: 'gabriellarocca0@gmail.com',
                              linkedin:
                                  'https://linkedin.com/in/gabriel-f-p-larocca/',
                              github: 'https://github.com/GabrielFePL',
                              pStyle: pStyle,
                              h2Style: h2Style,
                              linkStyle: linkStyle,
                            ),
                            _TeamMember(
                              name: 'Lucas Malachias - Engenheiro de Negócio',
                              imagePath: 'assets/lucas.jpg',
                              imageWidth: image2Width,
                              description:
                                  'Tenho 22 anos, estou cursando desenvolvimento de software multiplataforma na Fatec Matão.',
                              email: 'contato.lmvieira@gmail.com',
                              linkedin:
                                  'https://www.linkedin.com/in/lucas-malachias-vieira-066856288/',
                              github: 'https://github.com/LMVieira2',
                              pStyle: pStyle,
                              h2Style: h2Style,
                              linkStyle: linkStyle,
                            ),
                            _TeamMember(
                              name: 'Sophia Tavares - Desenvolvedora Backend',
                              imagePath: 'assets/sophia.jpg',
                              imageWidth: image2Width,
                              description:
                                  'Tenho 19 anos, sou formada como técnico em administração e atualmente estou cursando faculdade de desenvolvimento de software.',
                              email: 'contato.lmvieira@gmail.com',
                              linkedin:
                                  'https://www.linkedin.com/in/lucas-malachias-vieira-066856288/',
                              github: 'https://github.com/LMVieira2',
                              pStyle: pStyle,
                              h2Style: h2Style,
                              linkStyle: linkStyle,
                            ),
                            _TeamMember(
                              name:
                                  'Felipe Donizeti - Assegurador de Qualidade e Testador',
                              imagePath: 'assets/donizeti.jpg',
                              imageWidth: image2Width,
                              description:
                                  'Tenho 32 anos, estou cursando Desenvolvimento de Software Multilataforma na Fatec Matão, minha função no Projeto GWI News é QA e Tester.',
                              email: 'contato.lmvieira@gmail.com',
                              linkedin:
                                  'https://www.linkedin.com/in/lucas-malachias-vieira-066856288/',
                              github: 'https://github.com/LMVieira2',
                              pStyle: pStyle,
                              h2Style: h2Style,
                              linkStyle: linkStyle,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // NewsFilter sobre o conteúdo, com z-index elevado
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
                    // Garante que o outro offcanvas seja fechado
                    _showUserUtilities = false;
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
                    // Garante que o outro offcanvas seja fechado
                    _showNewsFilter = false;
                  });
                },
              ),
            ),
          // Passe os callbacks para o Navbar
          Navbar(
            onFilterTap: () {
              setState(() {
                _showNewsFilter = true;
                _showUserUtilities = false; // Fecha o outro offcanvas
              });
            },
            onUserTap: () {
              setState(() {
                _showUserUtilities = true;
                _showNewsFilter = false; // Fecha o outro offcanvas
              });
            },
          ),
          const Header(),
        ],
      ),
    );
  }
}

class _ServiceSection extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;
  final double imageWidth;
  final TextStyle pStyle;
  final TextStyle h2Style;

  const _ServiceSection({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.imageWidth,
    required this.pStyle,
    required this.h2Style,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Text(title, style: h2Style),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              description,
              style: pStyle,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          imagePath.endsWith('.svg')
              ? SizedBox(
                width: imageWidth,
                child: SvgPicture.asset(imagePath, fit: BoxFit.contain),
              )
              : SizedBox(
                width: imageWidth,
                child: Image.asset(imagePath, fit: BoxFit.cover),
              ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _TeamMember extends StatelessWidget {
  final String name;
  final String imagePath;
  final double imageWidth;
  final String description;
  final String email;
  final String linkedin;
  final String github;
  final TextStyle pStyle;
  final TextStyle h2Style;
  final TextStyle linkStyle;

  const _TeamMember({
    required this.name,
    required this.imagePath,
    required this.imageWidth,
    required this.description,
    required this.email,
    required this.linkedin,
    required this.github,
    required this.pStyle,
    required this.h2Style,
    required this.linkStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      // Removido o BoxDecoration com border
      child: Column(
        children: [
          Text(name, style: h2Style, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          ClipOval(
            child: Image.asset(
              imagePath,
              width: imageWidth,
              height: imageWidth,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 12),
          Text(description, style: pStyle, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            'Entre em Contato:',
            style: pStyle.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            children: [
              _ContactLink(
                url: 'mailto:$email',
                label: 'E-mail',
                style: linkStyle,
              ),
              _ContactLink(url: linkedin, label: 'Linkedin', style: linkStyle),
              _ContactLink(url: github, label: 'GitHub', style: linkStyle),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContactLink extends StatelessWidget {
  final String url;
  final String label;
  final TextStyle style;

  const _ContactLink({
    required this.url,
    required this.label,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () async {
          // Para links externos, use url_launcher
          // Exemplo: await launchUrl(Uri.parse(url));
        },
        child: Text(label, style: style),
      ),
    );
  }
}
