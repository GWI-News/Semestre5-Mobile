import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final _registerFormKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _loading = false;
  String? _error;

  // Cadastro
  bool _showRegister = false;
  String _registerEmail = '';
  String _registerPassword = '';
  String _registerConfirmPassword = '';
  String _registerName = '';
  String? _registerError;
  bool _registerLoading = false;

  // Responsividade e layout (mantém igual)
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
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _email.trim(),
            password: _password,
          );

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

      // Buscar userRole no Firestore
      final userDoc =
          await FirebaseFirestore.instance
              .collection('Users')
              .where('email', isEqualTo: _email.trim())
              .limit(1)
              .get();

      int userRole = 0; // padrão admin
      if (userDoc.docs.isNotEmpty &&
          userDoc.docs.first.data().containsKey('userRole')) {
        userRole = userDoc.docs.first['userRole'] ?? 1;
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
        if (userRole == 1) {
          Navigator.of(context).pushReplacementNamed('/perfil/adm');
        } else if (userRole == 2) {
          Navigator.of(context).pushReplacementNamed('/perfil/autor');
        } else if (userRole == 0) {
          Navigator.of(context).pushReplacementNamed('/perfil/leitor');
        } else {
          Navigator.of(context).pushReplacementNamed('/perfil/leitor');
        }
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

  Future<void> _handleRegister() async {
    if (!_registerFormKey.currentState!.validate()) return;
    setState(() {
      _registerLoading = true;
      _registerError = null;
    });
    try {
      if (_registerPassword != _registerConfirmPassword) {
        setState(() {
          _registerError = 'As senhas não conferem.';
          _registerLoading = false;
        });
        return;
      }
      // Gera GUID
      final String guid = const Uuid().v4();
      // Cria usuário no Firebase Auth
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _registerEmail.trim(),
            password: _registerPassword,
          );
      // Atualiza displayName (opcional)
      await userCredential.user!.updateDisplayName(_registerName.trim());
      // Cria documento na collection Users
      await FirebaseFirestore.instance.collection('Users').doc(guid).set({
        'id': guid,
        'userRole': 0, // padrão agora é 0
        'completeName': _registerName.trim(),
        'email': _registerEmail.trim(),
        'active': true,
      });
      // Envia email de verificação
      await userCredential.user!.sendEmailVerification();

      setState(() {
        _registerLoading = false;
        _showRegister = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cadastro realizado! Verifique seu e-mail para ativar a conta.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseAuthException catch (e) {
      String msg = 'Ocorreu um erro, tente novamente.';
      if (e.code == 'email-already-in-use') {
        msg = 'Este e-mail já está em uso.';
      } else if (e.code == 'invalid-email') {
        msg = 'E-mail inválido.';
      } else if (e.code == 'weak-password') {
        msg = 'A senha é muito fraca.';
      }
      setState(() {
        _registerError = msg;
        _registerLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
    } catch (_) {
      setState(() {
        _registerError = 'Ocorreu um erro, tente novamente.';
        _registerLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ocorreu um erro, tente novamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _passwordStrength(String password) {
    int score = 0;
    if (password.length >= 8) score++; // mínimo para ser considerada razoável
    if (password.length >= 12) score++; // mais longa é melhor
    if (RegExp(r'[A-Z]').hasMatch(password)) score++; // letra maiúscula
    if (RegExp(r'[a-z]').hasMatch(password)) score++; // letra minúscula
    if (RegExp(r'[0-9]').hasMatch(password)) score++; // número
    if (RegExp(
      r'''[!@#\$&*~%^()_+\-=\[\]{};'"\\:"|,.<>\/?]''',
    ).hasMatch(password))
      score++; // caractere especial

    // Corrigido: ajuste os limites para refletir melhor a força
    if (score <= 2) return 'Fraca';
    if (score <= 4) return 'Média';
    return 'Forte';
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showOffcanvas) return const SizedBox.shrink();

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    final double navbarWidth =
        width <= 576 ? width : (width <= 992 ? width * 0.6 : width * 0.4);
    final double offcanvasWidth =
        width > 576 ? width * 0.75 : navbarWidth * 0.9;
    final double offcanvasLeft = (width - offcanvasWidth) / 2;

    final double headerHeight = height * 0.12;
    final double navbarHeight = width <= 576 ? height * 0.10 : height * 0.12;
    final double availableHeight = height - headerHeight - navbarHeight;
    final double maxOffcanvasHeight = availableHeight * 0.95;

    const Color borderColor = Color(0xFF1D4988);
    BorderSide borderSide = const BorderSide(color: borderColor, width: 2);

    Border offcanvasBorder;
    if (width > 576) {
      offcanvasBorder = Border(
        left: borderSide,
        right: borderSide,
        bottom: borderSide,
        top: BorderSide.none,
      );
    } else {
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
              width: offcanvasWidth,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          _showRegister ? 'Cadastro' : 'Login',
                          style: const TextStyle(
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
                  if (!_showRegister && _error != null)
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
                  if (_showRegister && _registerError != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        _registerError!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (!_showRegister)
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
                              maxLength: 100,
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
                                  borderSide: const BorderSide(
                                    color: Color(0xFF1D4988), // Azul padrão do app
                                    width: 2,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF1D4988), // Azul padrão do app
                                    width: 2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF1D4988), // Azul padrão do app
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 12,
                                ),
                                counterText: '',
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
                              maxLength: 32,
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
                                  borderSide: const BorderSide(
                                    color: Color(0xFF1D4988), // Azul padrão do app
                                    width: 2,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF1D4988), // Azul padrão do app
                                    width: 2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF1D4988), // Azul padrão do app
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 12,
                                ),
                                counterText: '',
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
                          // Botões Login e Cadastro lado a lado
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: offcanvasWidth * 0.3,
                                child: ElevatedButton(
                                  onPressed: _loading ? null : _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1D4988),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    textStyle: const TextStyle(fontSize: 18),
                                  ),
                                  child:
                                      _loading
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
                              const SizedBox(width: 16),
                              SizedBox(
                                width: offcanvasWidth * 0.3,
                                child: OutlinedButton(
                                  onPressed:
                                      _loading
                                          ? null
                                          : () {
                                            setState(() {
                                              _showRegister = true;
                                              _registerError = null;
                                              _registerEmail = '';
                                              _registerPassword = '';
                                              _registerConfirmPassword = '';
                                              _registerName = '';
                                            });
                                          },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF1D4988),
                                    side: const BorderSide(
                                      color: Color(0xFF1D4988),
                                      width: 2,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    textStyle: const TextStyle(fontSize: 18),
                                  ),
                                  child: const Text('Cadastro'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  if (_showRegister)
                    Form(
                      key: _registerFormKey,
                      child: Column(
                        children: [
                          // Nome completo
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: TextFormField(
                              enabled: !_registerLoading,
                              maxLength: 255,
                              decoration: InputDecoration(
                                labelText: 'Nome completo',
                                labelStyle: const TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFF1D4988),
                                  fontWeight: FontWeight.w600,
                                ),
                                filled: true,
                                fillColor: const Color(0xFFEBEBEB),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF1D4988), // Azul padrão do app
                                    width: 2,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF1D4988), // Azul padrão do app
                                    width: 2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF1D4988), // Azul padrão do app
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 12,
                                ),
                                counterText: '',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Digite seu nome completo';
                                if (value.length > 255)
                                  return 'O nome deve ter no máximo 255 caracteres';
                                return null;
                              },
                              onChanged:
                                  (v) => setState(() => _registerName = v),
                            ),
                          ),
                          // Email
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: TextFormField(
                              enabled: !_registerLoading,
                              keyboardType: TextInputType.emailAddress,
                              maxLength: 100,
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
                                  borderSide: const BorderSide(
                                    color: Color(0xFF1D4988), // Azul padrão do app
                                    width: 2,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF1D4988), // Azul padrão do app
                                    width: 2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF1D4988), // Azul padrão do app
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 12,
                                ),
                                counterText: '',
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
                              onChanged:
                                  (v) => setState(() => _registerEmail = v),
                            ),
                          ),
                          // Senha
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFormField(
                                  enabled: !_registerLoading,
                                  obscureText: true,
                                  maxLength: 32,
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
                                      borderSide: const BorderSide(
                                        color: Color(0xFF1D4988), // Azul padrão do app
                                        width: 2,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF1D4988), // Azul padrão do app
                                        width: 2,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF1D4988), // Azul padrão do app
                                        width: 2,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 12,
                                    ),
                                    counterText: '',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty)
                                      return 'Digite sua senha';
                                    if (value.length < 8)
                                      return 'A senha deve ter pelo menos 8 caracteres';
                                    if (value.length > 32)
                                      return 'A senha deve ter no máximo 32 caracteres';
                                    final strength = _passwordStrength(value);
                                    if (strength == 'Fraca') {
                                      return 'Senha fraca. Use letras maiúsculas, minúsculas, números e símbolos.';
                                    }
                                    return null;
                                  },
                                  onChanged:
                                      (v) =>
                                          setState(() => _registerPassword = v),
                                ),
                                if (_registerPassword.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 4,
                                      left: 4,
                                    ),
                                    child: Text(
                                      'Força da senha: ${_passwordStrength(_registerPassword)}',
                                      style: TextStyle(
                                        color:
                                            _passwordStrength(
                                                      _registerPassword,
                                                    ) ==
                                                    'Forte'
                                                ? Colors.green
                                                : _passwordStrength(
                                                      _registerPassword,
                                                    ) ==
                                                    'Média'
                                                ? Colors.orange
                                                : Colors.red,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          // Confirmar senha
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: TextFormField(
                              enabled: !_registerLoading,
                              obscureText: true,
                              maxLength: 32,
                              decoration: InputDecoration(
                                labelText: 'Confirmar senha',
                                labelStyle: const TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFF1D4988),
                                  fontWeight: FontWeight.w600,
                                ),
                                filled: true,
                                fillColor: const Color(0xFFEBEBEB),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF1D4988), // Azul padrão do app
                                    width: 2,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF1D4988), // Azul padrão do app
                                    width: 2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF1D4988), // Azul padrão do app
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 12,
                                ),
                                counterText: '',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Confirme sua senha';
                                if (value != _registerPassword)
                                  return 'As senhas não conferem';
                                return null;
                              },
                              onChanged:
                                  (v) => setState(
                                    () => _registerConfirmPassword = v,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Botão de cadastro e voltar
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: offcanvasWidth * 0.3,
                                child: ElevatedButton(
                                  onPressed:
                                      _registerLoading ? null : _handleRegister,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1D4988),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    textStyle: const TextStyle(fontSize: 18),
                                  ),
                                  child:
                                      _registerLoading
                                          ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                          : const Text('Cadastrar'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              SizedBox(
                                width: offcanvasWidth * 0.3,
                                child: OutlinedButton(
                                  onPressed:
                                      _registerLoading
                                          ? null
                                          : () {
                                            setState(() {
                                              _showRegister = false;
                                              _registerError = null;
                                            });
                                          },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF1D4988),
                                    side: const BorderSide(
                                      color: Color(0xFF1D4988),
                                      width: 2,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    textStyle: const TextStyle(fontSize: 18),
                                  ),
                                  child: const Text('Voltar'),
                                ),
                              ),
                            ],
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
    );
  }
}
