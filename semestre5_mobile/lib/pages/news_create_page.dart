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

class NewsCreatePage extends StatefulWidget {
  const NewsCreatePage({super.key});

  @override
  State<NewsCreatePage> createState() => _NewsCreatePageState();
}

class _NewsCreatePageState extends State<NewsCreatePage> {
  final _formKey = GlobalKey<FormState>();

  // Form fields
  String? _categoriaId; // ID da categoria selecionada
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

  // Categorias carregadas do Firestore
  List<Map<String, dynamic>> _categorias = [];
  bool _categoriasLoading = true;

  // Subcategorias carregadas do Firestore
  List<Map<String, dynamic>> _subcategorias = [];
  bool _subcategoriasLoading = true;
  List<String> _subcategoriasSelecionadas = [];

  // Offcanvas controllers
  bool _showNewsFilter = false;
  bool _showUserUtilities = false;

  // Substitua o bloco de subcategorias dentro do build por este:
  bool _showSubcats = true;

  final Uuid _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _fetchCategorias();
    _fetchSubcategorias();
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

  Future<void> _pickImage() async {
    try {
      if (kIsWeb) {
        // Web: usar file_picker
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
        // Mobile/Desktop: usar image_picker
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
      final ref = FirebaseStorage.instance.ref().child(
        fileName,
      ); // Salva na raíz
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
      final ref = FirebaseStorage.instance.ref().child(
        fileName,
      ); // Salva na raíz
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

  Future<void> _handleCreateNews() async {
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
      final String newsId = _uuid.v4();
      await FirebaseFirestore.instance.collection('News').doc(newsId).set({
        'news_category_id': _categoriaId,
        'news_subcategory_ids': _subcategoriasSelecionadas,
        'title': _titulo,
        'subtitle': _subtitulo,
        'text_content': _texto,
        'url_image': _imageUrl,
        'alt_image': _altImagem,
        'author': _autor,
        'editor': _editor,
        'publication_date': FieldValue.serverTimestamp(), // alterado aqui
      });
      if (mounted) {
        Navigator.of(
          context,
        ).pushReplacementNamed('/perfil/adm/gerenciamento-noticias');
      }
    } catch (e) {
      setState(() {
        _errorMsg = 'Erro ao criar notícia.';
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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Criar Notícia',
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
                                padding: EdgeInsets.symmetric(vertical: 12),
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
                                          (cat) => DropdownMenuItem<String>(
                                            value: cat['id'],
                                            child: Text(
                                              _capitalizeWords(cat['name']),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Icon(
                                            _showSubcats
                                                ? Icons.arrow_drop_up
                                                : Icons.arrow_drop_down,
                                            color: const Color(0xFF1D4988),
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
                                      child: CircularProgressIndicator(),
                                    )
                                  else if (_showSubcats)
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 4,
                                      children:
                                          _subcategorias.map((subcat) {
                                            final id = subcat['id'] as String;
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
                                              selectedColor: const Color(
                                                0xFF1D4988,
                                              ).withOpacity(0.15),
                                              checkmarkColor: const Color(
                                                0xFF1D4988,
                                              ),
                                              labelStyle: TextStyle(
                                                color:
                                                    selected
                                                        ? const Color(
                                                          0xFF1D4988,
                                                        )
                                                        : Colors.black87,
                                                fontWeight:
                                                    selected
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                              ),
                                            );
                                          }).toList(),
                                    ),
                                  if (_subcategoriasSelecionadas.isEmpty)
                                    const Padding(
                                      padding: EdgeInsets.only(top: 4, left: 4),
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
                            decoration: _inputDecoration('Insira o Título'),
                            maxLength: 75,
                            onChanged: (v) => setState(() => _titulo = v),
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
                            decoration: _inputDecoration('Insira o Subtítulo'),
                            maxLength: 255,
                            onChanged: (v) => setState(() => _subtitulo = v),
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
                            decoration: _inputDecoration(
                              'Insira o Texto Corpo da Notícia',
                            ),
                            maxLength: 65335,
                            onChanged: (v) => setState(() => _texto = v),
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
                                    _imageFile == null
                                        ? 'Selecionar Imagem'
                                        : 'Imagem Selecionada',
                                  ),
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
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: _loading ? null : _pickImage,
                                ),
                              ),
                              if (_imageFile != null)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
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
                            decoration: _inputDecoration(
                              'Insira a Descrição da Imagem',
                            ),
                            maxLength: 100,
                            onChanged: (v) => setState(() => _altImagem = v),
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
                            decoration: _inputDecoration(
                              'Insira o Nome do Autor',
                            ),
                            onChanged: (v) => setState(() => _autor = v),
                            validator:
                                (v) =>
                                    v == null || v.isEmpty
                                        ? 'Campo obrigatório'
                                        : null,
                          ),
                          const SizedBox(height: 12),
                          _buildFormLabel('Nome do Editor:'),
                          TextFormField(
                            decoration: _inputDecoration(
                              'Insira o Nome do Editor',
                            ),
                            onChanged: (v) => setState(() => _editor = v),
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
                              onPressed: _loading ? null : _handleCreateNews,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1D4988),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              child:
                                  _loading
                                      ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : const Text('Criar Notícia'),
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
