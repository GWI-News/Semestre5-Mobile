import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:semestre5_mobile/pages/news_dashboard_page.dart';
import 'package:semestre5_mobile/pages/about_us_page.dart'; // Adicione este import
import 'package:semestre5_mobile/pages/faq_page.dart'; // Adicione este import
import 'package:semestre5_mobile/pages/adm_profile_page.dart'; // Adicione este import
import 'package:semestre5_mobile/pages/author_profile_page.dart'; // Adicione este import
import 'package:semestre5_mobile/pages/news_crud_page.dart'; // Adicione este import
import 'package:semestre5_mobile/pages/news_create_page.dart'; // Adicione este import
import 'package:semestre5_mobile/pages/news_update_page.dart'; // Adicione este import
import 'package:semestre5_mobile/pages/reader_profile_page.dart'; // Adicione este import
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GWI News',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const NewsDashboardPage(),
        '/home': (context) => const NewsDashboardPage(),
        '/sobre': (context) => const AboutUsPage(),
        '/faq': (context) => const FaqPage(),
        '/perfil/adm': (context) => const AdmProfilePage(),
        '/perfil/autor': (context) => const AuthorProfilePage(),
        '/perfil/leitor':
            (context) => const ReaderProfilePage(), // Nova rota adicionada
        '/perfil/adm/gerenciamento-noticias': (context) => const NewsCrudPage(),
        '/perfil/adm/gerenciamento-noticias/criacao-noticia':
            (context) => const NewsCreatePage(), // Nova rota adicionada
        '/perfil/adm/gerenciamento-noticias/edicao-noticia': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return NewsUpdatePage(newsId: args['newsId']);
        },
      },
    );
  }
}
