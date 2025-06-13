import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:uuid/uuid.dart';

import 'package:semestre5_mobile/widgets/header.dart';
import 'package:semestre5_mobile/widgets/navbar.dart';
import 'package:semestre5_mobile/widgets/news_filter.dart';
import 'package:semestre5_mobile/widgets/navbar_user_utilities.dart';

class NewsUpdatePage extends StatefulWidget {
  final String newsId;
  const NewsUpdatePage({super.key, required this.newsId});

  @override
  State<NewsUpdatePage> createState() => _NewsUpdatePageState();
}

class _NewsUpdatePageState extends State<NewsUpdatePage> {
  final _formKey = GlobalKey<FormState>();

  // Form fields
  String? _categoriaId;
  List<String> _subcategoriasSelecionadas = [];
  String _titulo = '';
  String _subtitulo = '';
  String _texto = '';
  String _altImagem = '';
  String _autor = '';
  String _editor = '';
  File? _imageFile;
  String? _imageUrl;

  bool _loading = false;
  String? _errorMsg;

  // Categorias e subcategorias
  List<Map<String, dynamic>> _categorias = [];
  bool _categoriasLoading = true;
  List<Map<String, dynamic>> _subcategorias = [];
  bool _subcategoriasLoading = true;

  // Offcanvas controllers
  bool _showNewsFilter = false;
  bool _showUserUtilities = false;
  bool _showSubcats = true;

  final Uuid _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _fetchCategorias();
    _fetchSubcategorias();
    _fetchNewsData();
  }

  Future<void> _fetchCategorias() async {
    setState(() {
      _categoriasLoading = true;
    });
    final snapshot =
        await FirebaseFirestore.instance.collection('NewsCategories').get();
    setState(() {
      _categorias =
          snapshot.docs
              .map((doc) => {'id': doc.id, 'name': doc['name'] ?? ''})
              .toList();
      _categoriasLoading = false;
    });
  }

  Future<void> _fetchSubcategorias() async {
    setState(() {
      _subcategoriasLoading = true;
    });
    final snapshot =
        await FirebaseFirestore.instance.collection('NewsSubcategories').get();
    setState(() {
      _subcategorias =
          snapshot.docs
              .map((doc) => {'id': doc.id, 'name': doc['name'] ?? ''})
              .toList();
      _subcategoriasLoading = false;
    });
  }

  Future<void> _fetchNewsData() async {
    setState(() => _loading = true);
    final doc =
        await FirebaseFirestore.instance
            .collection('News')
            .doc(widget.newsId)
            .get();
    final data = doc.data();
    if (data != null) {
      setState(() {
        _categoriaId = data['news_category_id'];
        _subcategoriasSelecionadas = List<String>.from(
          data['news_subcategory_ids'] ?? [],
        );
        _titulo = data['title'] ?? '';
        _subtitulo = data['subtitle'] ?? '';
        _texto = data['text_content'] ?? '';
        _altImagem = data['alt_image'] ?? '';
        _autor = data['author'] ?? '';
        _editor = data['editor'] ?? '';
        _imageUrl = data['url_image'];
      });
    }
    setState(() => _loading = false);
  }

  Future<void> _pickImage() async {
    try {
      if (kIsWeb) {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
          withData: true,
        );
        if (result != null && result.files.single.bytes != null) {
          Uint8List fileBytes = result.files.single.bytes!;
          String fileName = result.files.single.name;
          await _uploadImageWeb(fileBytes, fileName);
        }
      } else {
        final picker = ImagePicker();
        final picked = await picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1200,
          maxHeight: 1200,
          imageQuality: 90,
        );
        if (picked != null) {
          setState(() {
            _imageFile = File(picked.path);
          });
          await _uploadImageMobile();
        }
      }
    } catch (e) {
      setState(() {
        _errorMsg = 'Erro ao selecionar imagem: $e';
      });
    }
  }

  Future<void> _uploadImageMobile() async {
    if (_imageFile == null) return;
    setState(() => _loading = true);
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = FirebaseStorage.instance.ref().child(fileName);
      final uploadTask = await ref.putFile(_imageFile!);
      final url = await uploadTask.ref.getDownloadURL();
      setState(() {
        _imageUrl = url;
      });
    } catch (e) {
      setState(() {
        _errorMsg = 'Erro ao fazer upload da imagem.';
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _uploadImageWeb(Uint8List fileBytes, String fileName) async {
    setState(() => _loading = true);
    try {
      final ref = FirebaseStorage.instance.ref().child(fileName);
      final uploadTask = await ref.putData(
        fileBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final url = await uploadTask.ref.getDownloadURL();
      setState(() {
        _imageUrl = url;
      });
    } catch (e) {
      setState(() {
        _errorMsg = 'Erro ao fazer upload da imagem.';
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _handleUpdateNews() async {
    if (!_formKey.currentState!.validate() ||
        _imageUrl == null ||
        _categoriaId == null) {
      setState(() {
        _errorMsg =
            _imageUrl == null
                ? 'Selecione e envie uma imagem.'
                : _categoriaId == null
                ? 'Selecione uma categoria.'
                : null;
      });
      return;
    }
    setState(() {
      _loading = true;
      _errorMsg = null;
    });

    try {
      await FirebaseFirestore.instance
          .collection('News')
          .doc(widget.newsId)
          .update({
            'news_category_id': _categoriaId,
            'news_subcategory_ids': _subcategoriasSelecionadas,
            'title': _titulo,
            'subtitle': _subtitulo,
            'text_content': _texto,
            'url_image': _imageUrl,
            'alt_image': _altImagem,
            'author': _autor,
            'editor': _editor,
            // Não atualiza publication_date para manter a data original
          });
      if (mounted) {
        final confirm = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: const Color(0xFFF9F9F9),
                title: const Text(
                  'Notícia atualizada!',
                  style: TextStyle(
                    color: Color(0xFF1D4988),
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                content: const Text(
                  'A notícia foi atualizada com sucesso.',
                  style: TextStyle(
                    color: Color(0xFF1D4988),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                actionsPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                actions: [
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
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('OK'),
                    ),
                  ),
                ],
              ),
        );
        if (confirm == true) {
          Navigator.of(context).pop(); // Volta para a tela anterior
        }
      }
    } catch (e) {
      setState(() {
        _errorMsg = 'Erro ao atualizar notícia.';
      });
    } finally {
      setState(() => _loading = false);
    }
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
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(
                top: topPadding,
                bottom: bottomPadding,
                left: 8,
                right: 8,
              ),
              child: SingleChildScrollView(
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 500),
                    padding: const EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBEBEB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child:
                        _loading && _titulo.isEmpty
                            ? const Center(child: CircularProgressIndicator())
                            : Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Editar Notícia',
                                    style: TextStyle(
                                      fontSize: 32,
                                      color: const Color(0xFF1D4988),
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildFormLabel('Categoria:'),
                                  _categoriasLoading
                                      ? const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        child: CircularProgressIndicator(),
                                      )
                                      : DropdownButtonFormField<String>(
                                        value: _categoriaId,
                                        isExpanded: true,
                                        decoration: _inputDecoration(
                                          'Selecione a Categoria',
                                        ),
                                        items:
                                            _categorias
                                                .map(
                                                  (cat) =>
                                                      DropdownMenuItem<String>(
                                                        value: cat['id'],
                                                        child: Text(
                                                          _capitalizeWords(
                                                            cat['name'],
                                                          ),
                                                        ),
                                                      ),
                                                )
                                                .toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            _categoriaId = value;
                                          });
                                        },
                                        validator:
                                            (v) =>
                                                v == null || v.isEmpty
                                                    ? 'Selecione uma categoria'
                                                    : null,
                                      ),
                                  const SizedBox(height: 12),
                                  _buildFormLabel('Subcategorias:'),
                                  StatefulBuilder(
                                    builder: (context, setInnerState) {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          MouseRegion(
                                            cursor: SystemMouseCursors.click,
                                            child: GestureDetector(
                                              onTap: () {
                                                setInnerState(() {
                                                  _showSubcats = !_showSubcats;
                                                });
                                              },
                                              child: Row(
                                                children: [
                                                  Text(
                                                    _showSubcats
                                                        ? 'Ocultar opções'
                                                        : 'Exibir opções',
                                                    style: const TextStyle(
                                                      color: Color(0xFF1D4988),
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  Icon(
                                                    _showSubcats
                                                        ? Icons.arrow_drop_up
                                                        : Icons.arrow_drop_down,
                                                    color: const Color(
                                                      0xFF1D4988,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          if (_subcategoriasLoading)
                                            const Padding(
                                              padding: EdgeInsets.symmetric(
                                                vertical: 12,
                                              ),
                                              child:
                                                  CircularProgressIndicator(),
                                            )
                                          else if (_showSubcats)
                                            Wrap(
                                              spacing: 8,
                                              runSpacing: 4,
                                              children:
                                                  _subcategorias.map((subcat) {
                                                    final id =
                                                        subcat['id'] as String;
                                                    final selected =
                                                        _subcategoriasSelecionadas
                                                            .contains(id);
                                                    return FilterChip(
                                                      label: Text(
                                                        _capitalizeWords(
                                                          subcat['name'],
                                                        ),
                                                      ),
                                                      selected: selected,
                                                      onSelected: (bool value) {
                                                        setState(() {
                                                          if (value) {
                                                            _subcategoriasSelecionadas
                                                                .add(id);
                                                          } else {
                                                            _subcategoriasSelecionadas
                                                                .remove(id);
                                                          }
                                                        });
                                                      },
                                                      selectedColor:
                                                          const Color(
                                                            0xFF1D4988,
                                                          ).withOpacity(0.15),
                                                      checkmarkColor:
                                                          const Color(
                                                            0xFF1D4988,
                                                          ),
                                                      labelStyle: TextStyle(
                                                        color:
                                                            selected
                                                                ? const Color(
                                                                  0xFF1D4988,
                                                                )
                                                                : Colors
                                                                    .black87,
                                                        fontWeight:
                                                            selected
                                                                ? FontWeight
                                                                    .bold
                                                                : FontWeight
                                                                    .normal,
                                                      ),
                                                    );
                                                  }).toList(),
                                            ),
                                          if (_subcategoriasSelecionadas
                                              .isEmpty)
                                            const Padding(
                                              padding: EdgeInsets.only(
                                                top: 4,
                                                left: 4,
                                              ),
                                              child: Text(
                                                'Selecione pelo menos uma subcategoria (opcional)',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  _buildFormLabel('Título:'),
                                  TextFormField(
                                    initialValue: _titulo,
                                    decoration: _inputDecoration(
                                      'Insira o Título',
                                    ),
                                    maxLength: 75,
                                    onChanged:
                                        (v) => setState(() => _titulo = v),
                                    validator: (v) {
                                      if (v == null || v.isEmpty)
                                        return 'Campo obrigatório';
                                      if (v.length > 75)
                                        return 'Máximo de 75 caracteres';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  _buildFormLabel('Subtítulo:'),
                                  TextFormField(
                                    initialValue: _subtitulo,
                                    decoration: _inputDecoration(
                                      'Insira o Subtítulo',
                                    ),
                                    maxLength: 255,
                                    onChanged:
                                        (v) => setState(() => _subtitulo = v),
                                    validator: (v) {
                                      if (v == null || v.isEmpty)
                                        return 'Campo obrigatório';
                                      if (v.length > 255)
                                        return 'Máximo de 255 caracteres';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  _buildFormLabel('Corpo da Notícia:'),
                                  TextFormField(
                                    initialValue: _texto,
                                    decoration: _inputDecoration(
                                      'Insira o Texto Corpo da Notícia',
                                    ),
                                    maxLength: 65335,
                                    onChanged:
                                        (v) => setState(() => _texto = v),
                                    validator: (v) {
                                      if (v == null || v.isEmpty)
                                        return 'Campo obrigatório';
                                      if (v.length > 65335)
                                        return 'Máximo de 65335 caracteres';
                                      return null;
                                    },
                                    maxLines: 4,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildFormLabel('Upload de Imagem:'),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          icon: const Icon(Icons.upload_file),
                                          label: Text(
                                            _imageFile == null &&
                                                    _imageUrl == null
                                                ? 'Selecionar Imagem'
                                                : 'Imagem Selecionada',
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFFF9F9F9,
                                            ),
                                            foregroundColor: const Color(
                                              0xFF1D4988,
                                            ),
                                            side: const BorderSide(
                                              color: Color(0xFF1D4988),
                                              width: 2,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            elevation: 0,
                                          ),
                                          onPressed:
                                              _loading ? null : _pickImage,
                                        ),
                                      ),
                                      if (_imageFile != null ||
                                          _imageUrl != null)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 8,
                                          ),
                                          child: Icon(
                                            Icons.check_circle,
                                            color: Colors.green[700],
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  _buildFormLabel('Descrição da Imagem:'),
                                  TextFormField(
                                    initialValue: _altImagem,
                                    decoration: _inputDecoration(
                                      'Insira a Descrição da Imagem',
                                    ),
                                    maxLength: 100,
                                    onChanged:
                                        (v) => setState(() => _altImagem = v),
                                    validator: (v) {
                                      if (v == null || v.isEmpty)
                                        return 'Campo obrigatório';
                                      if (v.length > 100)
                                        return 'Máximo de 100 caracteres';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  _buildFormLabel('Nome do Autor:'),
                                  TextFormField(
                                    initialValue: _autor,
                                    decoration: _inputDecoration(
                                      'Insira o Nome do Autor',
                                    ),
                                    onChanged:
                                        (v) => setState(() => _autor = v),
                                    validator:
                                        (v) =>
                                            v == null || v.isEmpty
                                                ? 'Campo obrigatório'
                                                : null,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildFormLabel('Nome do Editor:'),
                                  TextFormField(
                                    initialValue: _editor,
                                    decoration: _inputDecoration(
                                      'Insira o Nome do Editor',
                                    ),
                                    onChanged:
                                        (v) => setState(() => _editor = v),
                                    validator:
                                        (v) =>
                                            v == null || v.isEmpty
                                                ? 'Campo obrigatório'
                                                : null,
                                  ),
                                  const SizedBox(height: 20),
                                  if (_errorMsg != null)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Text(
                                        _errorMsg!,
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  SizedBox(
                                    width: width < 600 ? width * 0.9 : 220,
                                    child: ElevatedButton(
                                      onPressed:
                                          _loading ? null : _handleUpdateNews,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF1D4988,
                                        ),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        textStyle: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                        ),
                                      ),
                                      child:
                                          _loading
                                              ? const SizedBox(
                                                width: 24,
                                                height: 24,
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                              : const Text('Atualizar Notícia'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
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

  Widget _buildFormLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 20,
          color: Color(0xFF1D4988),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF9F9F9),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(color: Color(0xFF1D4988)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(color: Color(0xFF1D4988), width: 2),
      ),
      hintStyle: const TextStyle(color: Color.fromRGBO(20, 20, 20, 0.5)),
    );
  }

  String _capitalizeWords(String text) {
    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }
}
