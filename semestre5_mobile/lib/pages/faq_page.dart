import 'package:flutter/material.dart';
import 'package:semestre5_mobile/widgets/header.dart';
import 'package:semestre5_mobile/widgets/navbar.dart';
import 'package:semestre5_mobile/widgets/news_filter.dart';
import 'package:semestre5_mobile/widgets/navbar_user_utilities.dart';

class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  final TextEditingController _messageController = TextEditingController();
  bool _sending = false;
  String? _messageError;

  // Controladores dos offcanvas
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

    // Estilos
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
    TextStyle labelStyle = const TextStyle(
      fontSize: 24,
      color: Color(0xFF1D4988),
      fontWeight: FontWeight.w600,
    );
    TextStyle buttonStyle = const TextStyle(
      fontSize: 24,
      color: Color(0xFFF9F9F9),
      fontWeight: FontWeight.w600,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFEBEBEB),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Center(
              child: Container(
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
                      // FAQ Section Title
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(top: 24, bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'FAQ',
                              style: h1Style,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Veja aqui as dúvidas mais frequentes sobre nossos serviços.',
                              style: pStyle,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      // Perguntas e respostas
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _FaqQuestion(
                              question: 'O que é o GWI News?',
                              answer:
                                  'O GWI News é um Portal de Notícias que centraliza notícias de diversas fontes e temas da região de Araraquara em único lugar.',
                              h2Style: h2Style,
                              pStyle: pStyle,
                            ),
                            _FaqQuestion(
                              question: 'Como usar o GWI News?',
                              answer:
                                  'Simplesmente acesse o site https://gwinews-e715f.web.app ou baixe nosso app em htpps://link-imaginario-do-app.com e navegue pelas notícias. Você pode filtrar pelas nossas categorias ou buscar notícias específicas pela barra de pesquisa.',
                              h2Style: h2Style,
                              pStyle: pStyle,
                            ),
                            _FaqQuestion(
                              question: 'O GWI News é gratuito?',
                              answer:
                                  'Sim, o GWI News é 100% gratuito. Não temos nenhum plano de assinatura ou conteúdos exclusivamente pagos.',
                              h2Style: h2Style,
                              pStyle: pStyle,
                            ),
                            _FaqQuestion(
                              question:
                                  'Com que frequência o GWI News é atualizado?',
                              answer:
                                  'O GWI News é atualizado em tempo real, então você pode ter a certeza de que nós sempre teremos as mais recentes notícias.',
                              h2Style: h2Style,
                              pStyle: pStyle,
                            ),
                            _FaqQuestion(
                              question:
                                  'Eu posso compartilhar as notícias do GWI News?',
                              answer:
                                  'Sim, você pode. É possível compartilhar nossas notícias através dos botões de compartilhamento quando as abre.',
                              h2Style: h2Style,
                              pStyle: pStyle,
                            ),
                            _FaqQuestion(
                              question:
                                  'Como eu posso entrar em contato com o GWI News?',
                              answer:
                                  'Se você possuir qualquer dúvida ou feedback, você pode nos enviar uma mensagem através da caixa de perguntas nesta página.',
                              h2Style: h2Style,
                              pStyle: pStyle,
                            ),
                          ],
                        ),
                      ),
                      // Fale Conosco
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(top: 16, bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Fale Conosco Você Também!',
                              style: h2Style.copyWith(fontSize: 36),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              'Envie-nos uma mensagem com suas dúvidas, sugestões ou feedback.',
                              style: pStyle,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Form(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Mensagem:',
                                        style: labelStyle,
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: TextFormField(
                                      controller: _messageController,
                                      minLines: 3,
                                      maxLines: 5,
                                      maxLength:
                                          500, // Limite de 500 caracteres
                                      style: pStyle,
                                      decoration: InputDecoration(
                                        hintText: 'Digite sua mensagem...',
                                        hintStyle: pStyle.copyWith(
                                          color: const Color(0x80141414),
                                        ),
                                        filled: true,
                                        fillColor: const Color(0xFFF9F9F9),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFF1D4988),
                                            width: 1.5,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFF1D4988),
                                            width: 2,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              vertical: 12,
                                              horizontal: 12,
                                            ),
                                        errorText:
                                            _messageError, // Mostra o erro se houver
                                        counterText:
                                            '', // Oculta o contador padrão, se desejar
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: width * 0.46,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF1D4988,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 8,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        elevation: 2,
                                      ),
                                      onPressed:
                                          _sending
                                              ? null
                                              : () async {
                                                if (_messageController.text
                                                    .trim()
                                                    .isEmpty) {
                                                  setState(() {
                                                    _messageError =
                                                        'A mensagem não pode ser vazia.';
                                                  });
                                                  return;
                                                }
                                                setState(() {
                                                  _sending = true;
                                                  _messageError = null;
                                                });
                                                await Future.delayed(
                                                  const Duration(seconds: 1),
                                                );
                                                setState(() {
                                                  _sending = false;
                                                  _messageController.clear();
                                                });
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Mensagem enviada! Obrigado pelo contato.',
                                                    ),
                                                  ),
                                                );
                                              },
                                      child:
                                          _sending
                                              ? Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const SizedBox(
                                                    width: 18,
                                                    height: 18,
                                                    child:
                                                        CircularProgressIndicator(
                                                          color: Color(
                                                            0xFFF9F9F9,
                                                          ),
                                                          strokeWidth: 2.5,
                                                        ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'Enviando...',
                                                    style: buttonStyle,
                                                  ),
                                                ],
                                              )
                                              : Text(
                                                'Enviar',
                                                style: buttonStyle,
                                              ),
                                    ),
                                  ),
                                ],
                              ),
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

class _FaqQuestion extends StatelessWidget {
  final String question;
  final String answer;
  final TextStyle h2Style;
  final TextStyle pStyle;

  const _FaqQuestion({
    required this.question,
    required this.answer,
    required this.h2Style,
    required this.pStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(question, style: h2Style, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(answer, style: pStyle, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
