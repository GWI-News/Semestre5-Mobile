import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:semestre5_mobile/widgets/header.dart';
import 'package:semestre5_mobile/widgets/navbar.dart';
import 'package:semestre5_mobile/widgets/news_filter.dart';
import 'package:semestre5_mobile/widgets/navbar_user_utilities.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  List<Map<String, dynamic>> _usersList = [];
  bool _loading = true;

  // Controladores de estado para offcanvas
  bool _showNewsFilter = false;
  bool _showUserUtilities = false;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _loading = true);
    final snapshot = await FirebaseFirestore.instance.collection('Users').get();
    setState(() {
      _usersList =
          snapshot.docs
              .map((doc) => {...doc.data(), 'id': doc.id})
              .cast<Map<String, dynamic>>()
              .toList();
      _loading = false;
    });
  }

  Future<void> _setUserInactive(String id) async {
    await FirebaseFirestore.instance.collection('Users').doc(id).update({
      'active': false,
    });
    _fetchUsers();
  }

  String _roleName(int? role) {
    switch (role) {
      case 0:
        return "Leitor";
      case 1:
        return "Administrador";
      case 2:
        return "Autor";
      default:
        return "Desconhecido";
    }
  }

  Future<void> _showEditUserDialog(Map<String, dynamic> user) async {
    final _formKey = GlobalKey<FormState>();
    String completeName = user['completeName'] ?? '';
    String email = user['email'] ?? '';
    int userRole =
        user['userRole'] is int
            ? user['userRole']
            : int.tryParse(user['userRole']?.toString() ?? '0') ?? 0;
    bool active = user['active'] == true;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: const Color(0xFFF9F9F9),
            title: const Text(
              'Editar Usuário',
              style: TextStyle(
                color: Color(0xFF1D4988),
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            content: Form(
              key: _formKey,
              child: SizedBox(
                width: 350,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      initialValue: completeName,
                      decoration: InputDecoration(
                        labelText: 'Nome Completo',
                        labelStyle: const TextStyle(
                          color: Color(0xFF1D4988),
                          fontWeight: FontWeight.w600,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFEBEBEB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF1D4988),
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF1D4988),
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF1D4988),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 12,
                        ),
                      ),
                      onChanged: (v) => completeName = v,
                      validator:
                          (v) =>
                              v == null || v.isEmpty
                                  ? 'Campo obrigatório'
                                  : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: email,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: const TextStyle(
                          color: Color(0xFF1D4988),
                          fontWeight: FontWeight.w600,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFEBEBEB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF1D4988),
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF1D4988),
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF1D4988),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 12,
                        ),
                      ),
                      onChanged: (v) => email = v,
                      validator:
                          (v) =>
                              v == null || v.isEmpty
                                  ? 'Campo obrigatório'
                                  : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: userRole,
                      decoration: InputDecoration(
                        labelText: 'Nível de acesso',
                        labelStyle: const TextStyle(
                          color: Color(0xFF1D4988),
                          fontWeight: FontWeight.w600,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFEBEBEB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF1D4988),
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF1D4988),
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF1D4988),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 12,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 0, child: Text('Leitor')),
                        DropdownMenuItem(
                          value: 1,
                          child: Text('Administrador'),
                        ),
                        DropdownMenuItem(value: 2, child: Text('Autor')),
                      ],
                      onChanged: (v) {
                        if (v != null) userRole = v;
                      },
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text(
                        'Usuário Ativo',
                        style: TextStyle(
                          color: Color(0xFF1D4988),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      value: active,
                      onChanged: (v) {
                        active = v;
                        (context as Element).markNeedsBuild();
                      },
                      activeColor: const Color(0xFF1D4988),
                    ),
                  ],
                ),
              ),
            ),
            actionsPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            actions: [
              SizedBox(
                width: 120,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1D4988),
                    side: const BorderSide(color: Color(0xFF1D4988), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
              ),
              SizedBox(
                width: 120,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D4988),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await FirebaseFirestore.instance
                          .collection('Users')
                          .doc(user['id'])
                          .update({
                            'completeName': completeName,
                            'email': email,
                            'userRole': userRole,
                            'active': active,
                          });
                      if (mounted) {
                        Navigator.of(context).pop();
                        _fetchUsers();
                      }
                    }
                  },
                  child: const Text('Salvar'),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _showCreateUserDialog() async {
    final _formKey = GlobalKey<FormState>();
    String completeName = '';
    String email = '';
    String password = '';
    String confirmPassword = '';
    int userRole = 0;
    bool active = true;
    String? error;
    bool loading = false;

    String passwordStrength(String password) {
      int score = 0;
      if (password.length >= 8) score++;
      if (password.length >= 12) score++;
      if (RegExp(r'[A-Z]').hasMatch(password)) score++;
      if (RegExp(r'[a-z]').hasMatch(password)) score++;
      if (RegExp(r'[0-9]').hasMatch(password)) score++;
      if (RegExp(
        r'''[!@#\$&*~%^()_+\-=\[\]{};'"\\:"|,.<>\/?]''',
      ).hasMatch(password))
        score++;
      if (score <= 2) return 'Fraca';
      if (score <= 4) return 'Média';
      return 'Forte';
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder:
              (context, setDialogState) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: const Color(0xFFF9F9F9),
                title: const Text(
                  'Criar Usuário',
                  style: TextStyle(
                    color: Color(0xFF1D4988),
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                content: Form(
                  key: _formKey,
                  child: SizedBox(
                    width: 350,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (error != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              error!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Nome Completo',
                            labelStyle: const TextStyle(
                              color: Color(0xFF1D4988),
                              fontWeight: FontWeight.w600,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFEBEBEB),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF1D4988),
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF1D4988),
                                width: 2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF1D4988),
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 12,
                            ),
                          ),
                          onChanged:
                              (v) => setDialogState(() => completeName = v),
                          validator:
                              (v) =>
                                  v == null || v.isEmpty
                                      ? 'Campo obrigatório'
                                      : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: const TextStyle(
                              color: Color(0xFF1D4988),
                              fontWeight: FontWeight.w600,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFEBEBEB),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF1D4988),
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF1D4988),
                                width: 2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF1D4988),
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 12,
                            ),
                          ),
                          onChanged: (v) => setDialogState(() => email = v),
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return 'Campo obrigatório';
                            if (!v.contains('@')) return 'E-mail inválido';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            labelStyle: const TextStyle(
                              color: Color(0xFF1D4988),
                              fontWeight: FontWeight.w600,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFEBEBEB),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF1D4988),
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF1D4988),
                                width: 2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF1D4988),
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 12,
                            ),
                          ),
                          onChanged: (v) => setDialogState(() => password = v),
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return 'Campo obrigatório';
                            if (v.length < 8)
                              return 'A senha deve ter pelo menos 8 caracteres';
                            if (v.length > 32)
                              return 'A senha deve ter no máximo 32 caracteres';
                            if (passwordStrength(v) == 'Fraca') {
                              return 'Senha fraca. Use letras maiúsculas, minúsculas, números e símbolos.';
                            }
                            return null;
                          },
                        ),
                        if (password.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 4),
                            child: Text(
                              'Força da senha: ${passwordStrength(password)}',
                              style: TextStyle(
                                color:
                                    passwordStrength(password) == 'Forte'
                                        ? Colors.green
                                        : passwordStrength(password) == 'Média'
                                        ? Colors.orange
                                        : Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                        TextFormField(
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Confirmar Senha',
                            labelStyle: const TextStyle(
                              color: Color(0xFF1D4988),
                              fontWeight: FontWeight.w600,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFEBEBEB),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF1D4988),
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF1D4988),
                                width: 2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF1D4988),
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 12,
                            ),
                          ),
                          onChanged:
                              (v) => setDialogState(() => confirmPassword = v),
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return 'Campo obrigatório';
                            if (v != password) return 'As senhas não conferem';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<int>(
                          value: userRole,
                          decoration: InputDecoration(
                            labelText: 'Nível de acesso',
                            labelStyle: const TextStyle(
                              color: Color(0xFF1D4988),
                              fontWeight: FontWeight.w600,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFEBEBEB),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF1D4988),
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF1D4988),
                                width: 2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF1D4988),
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 12,
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(value: 0, child: Text('Leitor')),
                            DropdownMenuItem(
                              value: 1,
                              child: Text('Administrador'),
                            ),
                            DropdownMenuItem(value: 2, child: Text('Autor')),
                          ],
                          onChanged: (v) {
                            if (v != null) setDialogState(() => userRole = v);
                          },
                        ),
                        const SizedBox(height: 12),
                        SwitchListTile(
                          title: const Text(
                            'Usuário Ativo',
                            style: TextStyle(
                              color: Color(0xFF1D4988),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          value: active,
                          onChanged: (v) => setDialogState(() => active = v),
                          activeColor: const Color(0xFF1D4988),
                        ),
                      ],
                    ),
                  ),
                ),
                actionsPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                actions: [
                  SizedBox(
                    width: 120,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1D4988),
                        side: const BorderSide(
                          color: Color(0xFF1D4988),
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1D4988),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed:
                          loading
                              ? null
                              : () async {
                                if (!_formKey.currentState!.validate()) return;
                                setDialogState(() {
                                  loading = true;
                                  error = null;
                                });
                                try {
                                  final String guid = const Uuid().v4();
                                  final userCredential = await FirebaseAuth
                                      .instance
                                      .createUserWithEmailAndPassword(
                                        email: email.trim(),
                                        password: password,
                                      );
                                  await userCredential.user!.updateDisplayName(
                                    completeName.trim(),
                                  );
                                  await FirebaseFirestore.instance
                                      .collection('Users')
                                      .doc(guid)
                                      .set({
                                        'id': guid,
                                        'userRole': userRole,
                                        'completeName': completeName.trim(),
                                        'email': email.trim(),
                                        'active': active,
                                      });
                                  await userCredential.user!
                                      .sendEmailVerification();
                                  if (mounted) {
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Usuário criado! Verifique o e-mail para ativar a conta.',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    _fetchUsers();
                                  }
                                } on FirebaseAuthException catch (e) {
                                  String msg =
                                      'Ocorreu um erro, tente novamente.';
                                  if (e.code == 'email-already-in-use') {
                                    msg = 'Este e-mail já está em uso.';
                                  } else if (e.code == 'invalid-email') {
                                    msg = 'E-mail inválido.';
                                  } else if (e.code == 'weak-password') {
                                    msg = 'A senha é muito fraca.';
                                  }
                                  setDialogState(() {
                                    error = msg;
                                    loading = false;
                                  });
                                } catch (_) {
                                  setDialogState(() {
                                    error = 'Ocorreu um erro, tente novamente.';
                                    loading = false;
                                  });
                                }
                              },
                      child:
                          loading
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Text('Criar'),
                    ),
                  ),
                ],
              ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    final double headerHeight = height * 0.12;
    final double navbarHeight = width <= 576 ? height * 0.10 : height * 0.12;
    final double topPadding = headerHeight;
    final double bottomPadding = width <= 576 ? navbarHeight : 0;

    return Scaffold(
      backgroundColor: const Color(0xFFEBEBEB),
      body: Stack(
        children: [
          // Conteúdo principal
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(
                top: topPadding,
                bottom: bottomPadding,
                left: 8,
                right: 8,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        'Gerenciamento de Usuários',
                        style: TextStyle(
                          fontSize: 32,
                          color: const Color(0xFF1D4988),
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      // Botão de cadastrar usuário
                      SizedBox(
                        width: width < 600 ? width * 0.9 : 400,
                        child: ElevatedButton(
                          onPressed: _showCreateUserDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF9F9F9),
                            foregroundColor: const Color(0xFF1D4988),
                            side: const BorderSide(
                              color: Color(0xFF1D4988),
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Criar Usuário',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child:
                            _loading
                                ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                                : _usersList.isEmpty
                                ? const Center(
                                  child: Text(
                                    'Nenhum usuário cadastrado.',
                                    style: TextStyle(
                                      color: Color(0xFF1D4988),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                )
                                : SingleChildScrollView(
                                  child: Center(
                                    child: Wrap(
                                      alignment: WrapAlignment.center,
                                      spacing: 8,
                                      runSpacing: 8,
                                      children:
                                          _usersList.map((user) {
                                            return ConstrainedBox(
                                              constraints: const BoxConstraints(
                                                maxWidth: 352,
                                                minWidth: 280,
                                              ),
                                              child: Card(
                                                elevation: 2,
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 8,
                                                        horizontal: 8,
                                                      ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .stretch,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            Icons.person,
                                                            color: Color(
                                                              0xFF1D4988,
                                                            ),
                                                            size: 32,
                                                          ),
                                                          const SizedBox(
                                                            width: 8,
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              user['completeName'] ??
                                                                  '',
                                                              style: const TextStyle(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                          Container(
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal: 8,
                                                                  vertical: 2,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color:
                                                                  user['active'] ==
                                                                          true
                                                                      ? Colors
                                                                          .green[100]
                                                                      : Colors
                                                                          .red[100],
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    8,
                                                                  ),
                                                            ),
                                                            child: Text(
                                                              user['active'] ==
                                                                      true
                                                                  ? 'Ativo'
                                                                  : 'Inativo',
                                                              style: TextStyle(
                                                                color:
                                                                    user['active'] ==
                                                                            true
                                                                        ? Colors
                                                                            .green[800]
                                                                        : Colors
                                                                            .red[800],
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Text(
                                                        user['email'] ?? '',
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.black87,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        'ID: ${user['id'] ?? ''}',
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        'Nível de acesso: ${_roleName(user['userRole'] is int ? user['userRole'] : int.tryParse(user['userRole']?.toString() ?? ''))}',
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          color: Color(
                                                            0xFF1D4988,
                                                          ),
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          TextButton.icon(
                                                            onPressed: () {
                                                              _showEditUserDialog(
                                                                user,
                                                              ); // Exibe o dialog de alteração
                                                            },
                                                            icon: const Icon(
                                                              Icons.edit,
                                                              color: Color(
                                                                0xFF1D4988,
                                                              ),
                                                            ),
                                                            label: const Text(
                                                              'Alterar',
                                                              style: TextStyle(
                                                                color: Color(
                                                                  0xFF1D4988,
                                                                ),
                                                              ),
                                                            ),
                                                            style: TextButton.styleFrom(
                                                              foregroundColor:
                                                                  const Color(
                                                                    0xFF1D4988,
                                                                  ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 8,
                                                          ),
                                                          TextButton.icon(
                                                            onPressed: () async {
                                                              final confirm = await showDialog<
                                                                bool
                                                              >(
                                                                context:
                                                                    context,
                                                                barrierDismissible:
                                                                    false,
                                                                builder:
                                                                    (
                                                                      context,
                                                                    ) => AlertDialog(
                                                                      shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              12,
                                                                            ),
                                                                      ),
                                                                      backgroundColor:
                                                                          const Color(
                                                                            0xFFF9F9F9,
                                                                          ),
                                                                      title: const Text(
                                                                        'Confirmar exclusão',
                                                                        style: TextStyle(
                                                                          color: Color(
                                                                            0xFF1D4988,
                                                                          ),
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          fontSize:
                                                                              22,
                                                                        ),
                                                                      ),
                                                                      content: const Text(
                                                                        'Tem certeza que deseja inativar este usuário? Esta ação pode ser revertida editando o usuário.',
                                                                        style: TextStyle(
                                                                          color: Color(
                                                                            0xFF1D4988,
                                                                          ),
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                        ),
                                                                      ),
                                                                      actionsPadding: const EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            16,
                                                                        vertical:
                                                                            8,
                                                                      ),
                                                                      actions: [
                                                                        SizedBox(
                                                                          width:
                                                                              120,
                                                                          child: OutlinedButton(
                                                                            style: OutlinedButton.styleFrom(
                                                                              foregroundColor: const Color(
                                                                                0xFF1D4988,
                                                                              ),
                                                                              side: const BorderSide(
                                                                                color: Color(
                                                                                  0xFF1D4988,
                                                                                ),
                                                                                width:
                                                                                    2,
                                                                              ),
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(
                                                                                  5,
                                                                                ),
                                                                              ),
                                                                              padding: const EdgeInsets.symmetric(
                                                                                vertical:
                                                                                    12,
                                                                              ),
                                                                              textStyle: const TextStyle(
                                                                                fontSize:
                                                                                    16,
                                                                                fontWeight:
                                                                                    FontWeight.w600,
                                                                              ),
                                                                            ),
                                                                            onPressed:
                                                                                () => Navigator.of(
                                                                                  context,
                                                                                ).pop(
                                                                                  false,
                                                                                ),
                                                                            child: const Text(
                                                                              'Cancelar',
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              120,
                                                                          child: ElevatedButton(
                                                                            style: ElevatedButton.styleFrom(
                                                                              backgroundColor: const Color(
                                                                                0xFF1D4988,
                                                                              ),
                                                                              foregroundColor:
                                                                                  Colors.white,
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(
                                                                                  5,
                                                                                ),
                                                                              ),
                                                                              padding: const EdgeInsets.symmetric(
                                                                                vertical:
                                                                                    12,
                                                                              ),
                                                                              textStyle: const TextStyle(
                                                                                fontSize:
                                                                                    16,
                                                                                fontWeight:
                                                                                    FontWeight.w600,
                                                                              ),
                                                                            ),
                                                                            onPressed:
                                                                                () => Navigator.of(
                                                                                  context,
                                                                                ).pop(
                                                                                  true,
                                                                                ),
                                                                            child: const Text(
                                                                              'Inativar',
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                              );
                                                              if (confirm ==
                                                                  true) {
                                                                _setUserInactive(
                                                                  user['id'],
                                                                );
                                                              }
                                                            },
                                                            icon: const Icon(
                                                              Icons.delete,
                                                              color: Colors.red,
                                                            ),
                                                            label: const Text(
                                                              'Excluir',
                                                              style: TextStyle(
                                                                color:
                                                                    Colors.red,
                                                              ),
                                                            ),
                                                            style:
                                                                TextButton.styleFrom(
                                                                  foregroundColor:
                                                                      Colors
                                                                          .red,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                    ),
                                  ),
                                ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Shadow fade para NewsFilter
          if (_showNewsFilter)
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
          // Shadow fade para User Utilities
          if (_showUserUtilities)
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
                    _showNewsFilter = false;
                  });
                },
              ),
            ),
          // Navbar e Header sempre interativos
          Navbar(
            onFilterTap: () {
              setState(() {
                _showNewsFilter = true;
                _showUserUtilities = false;
              });
            },
            onUserTap: () {
              setState(() {
                _showUserUtilities = true;
                _showNewsFilter = false;
              });
            },
          ),
          const Header(),
        ],
      ),
    );
  }
}
