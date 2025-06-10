import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NavbarUserUtilities extends StatefulWidget {
  final bool showOffcanvas;
  final VoidCallback onClose;

  const NavbarUserUtilities({
    super.key,
    required this.showOffcanvas,
    required this.onClose,
  });

  @override
  State<NavbarUserUtilities> createState() => _NavbarUserUtilitiesState();
}

class _NavbarUserUtilitiesState extends State<NavbarUserUtilities> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _loading = false;
  String? _error;

  // Responsividade
  double _getOffcanvasWidth(double width) {
    if (width <= 576) return width * 0.9;
    if (width <= 992) return width * 0.6;
    return width * 0.4;
  }

  double _getOffcanvasLeft(double width) {
    final w = _getOffcanvasWidth(width);
    return (width - w) / 2;
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // Realiza o login com email e senha usando Firebase Authentication
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _email.trim(),
            password: _password,
          );

      // Verifica se o email está verificado
      if (!userCredential.user!.emailVerified) {
        await FirebaseAuth.instance.signOut();
        setState(() {
          _error = 'Verifique seu E-mail para Confirmar o Cadastro.';
          _loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verifique seu E-mail para Confirmar o Cadastro.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _loading = false;
      });
      widget.onClose();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login realizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        // Redireciona para a página de perfil do administrador
        Navigator.of(context).pushReplacementNamed('/perfil/adm');
      }
    } on FirebaseAuthException catch (e) {
      String msg = 'Ocorreu um erro, tente novamente.';
      if (e.code == 'user-not-found') {
        msg = 'Este usuário não está cadastrado.';
      } else if (e.code == 'wrong-password') {
        msg = 'Há um erro com suas credenciais de acesso.';
      } else if (e.code == 'invalid-email') {
        msg = 'E-mail inválido.';
      }
      setState(() {
        _error = msg;
        _loading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
    } catch (_) {
      setState(() {
        _error = 'Ocorreu um erro, tente novamente.';
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ocorreu um erro, tente novamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showOffcanvas) return const SizedBox.shrink();

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    // Mesma lógica de largura e posicionamento do NewsFilter
    final double navbarWidth =
        width <= 576 ? width : (width <= 992 ? width * 0.6 : width * 0.4);
    final double offcanvasWidth =
        width > 576 ? width * 0.75 : navbarWidth * 0.9;
    final double offcanvasLeft = (width - offcanvasWidth) / 2;

    // Espaço ocupado por header e navbar
    final double headerHeight = height * 0.12;
    final double navbarHeight = width <= 576 ? height * 0.10 : height * 0.12;
    final double availableHeight = height - headerHeight - navbarHeight;
    final double maxOffcanvasHeight = availableHeight * 0.95;

    // Defina a cor padrão azul do site
    const Color borderColor = Color(0xFF1D4988);
    BorderSide borderSide = const BorderSide(color: borderColor, width: 2);

    // Defina a borda conforme o tamanho da tela (igual ao NewsFilter)
    Border offcanvasBorder;
    if (width > 576) {
      // Em telas grandes, sem borda superior
      offcanvasBorder = Border(
        left: borderSide,
        right: borderSide,
        bottom: borderSide,
        top: BorderSide.none,
      );
    } else {
      // Em telas pequenas, sem borda inferior
      offcanvasBorder = Border(
        left: borderSide,
        right: borderSide,
        top: borderSide,
        bottom: BorderSide.none,
      );
    }

    return Positioned(
      left: offcanvasLeft,
      width: offcanvasWidth,
      top: width > 576 ? navbarHeight : null,
      bottom: width <= 576 ? navbarHeight : null,
      child: Material(
        color: Colors.transparent,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: 0,
              maxHeight: maxOffcanvasHeight,
              minWidth: offcanvasWidth,
              maxWidth: offcanvasWidth,
            ),
            child: Container(
              width: offcanvasWidth, // Garante largura correta desde o início
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                border: offcanvasBorder,
                borderRadius:
                    width > 576
                        ? const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                          topLeft: Radius.circular(0),
                          topRight: Radius.circular(0),
                        )
                        : const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListView(
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  // Título e botão de fechar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1D4988),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFF1D4988),
                            width: 1.5,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Color(0xFF1D4988),
                          ),
                          onPressed: widget.onClose,
                          tooltip: 'Fechar',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        _error!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Email
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: TextFormField(
                            enabled: !_loading,
                            keyboardType: TextInputType.emailAddress,
                            maxLength: 510, // Limite máximo de caracteres
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: const TextStyle(
                                fontSize: 18,
                                color: Color(0xFF1D4988),
                                fontWeight: FontWeight.w600,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFEBEBEB),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 12,
                              ),
                              counterText:
                                  '', // Esconde o contador de caracteres
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Digite seu e-mail';
                              if (value.length < 5)
                                return 'O e-mail deve ter pelo menos 5 caracteres';
                              if (value.length > 100)
                                return 'O e-mail deve ter no máximo 100 caracteres';
                              if (!value.contains('@'))
                                return 'E-mail inválido';
                              return null;
                            },
                            onChanged: (v) => setState(() => _email = v),
                          ),
                        ),
                        // Senha
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: TextFormField(
                            enabled: !_loading,
                            obscureText: true,
                            maxLength: 32, // Limite máximo de caracteres
                            decoration: InputDecoration(
                              labelText: 'Senha',
                              labelStyle: const TextStyle(
                                fontSize: 18,
                                color: Color(0xFF1D4988),
                                fontWeight: FontWeight.w600,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFEBEBEB),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 12,
                              ),
                              counterText:
                                  '', // Esconde o contador de caracteres
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Digite sua senha';
                              if (value.length < 8)
                                return 'A senha deve ter pelo menos 8 caracteres';
                              if (value.length > 32)
                                return 'A senha deve ter no máximo 32 caracteres';
                              return null;
                            },
                            onChanged: (v) => setState(() => _password = v),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Botão Login centralizado e com largura de 30%
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: offcanvasWidth * 0.3, // 30% da largura do offcanvas
                              child: ElevatedButton(
                                onPressed: _loading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1D4988),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  textStyle: const TextStyle(fontSize: 18),
                                ),
                                child: _loading
                                    ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                    : const Text('Entrar'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // TODO: Adicionar botões para cadastro e recuperação de senha
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
