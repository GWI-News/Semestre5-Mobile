import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:semestre5_mobile/pages/news_dashboard_page.dart';
import 'package:semestre5_mobile/pages/about_us_page.dart';
import 'package:semestre5_mobile/pages/faq_page.dart';
import 'package:semestre5_mobile/pages/adm_profile_page.dart';
import 'package:semestre5_mobile/pages/author_profile_page.dart';
import 'package:semestre5_mobile/pages/news_management_page.dart';
import 'package:semestre5_mobile/pages/news_create_page.dart';
import 'package:semestre5_mobile/pages/news_update_page.dart';
import 'package:semestre5_mobile/pages/reader_profile_page.dart';
import 'package:semestre5_mobile/pages/user_management_page.dart';
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
        '/perfil/leitor': (context) => const ReaderProfilePage(),
        '/perfil/adm/gerenciamento-noticias':
            (context) => const NewsManagementPage(),
        '/perfil/adm/gerenciamento-noticias/criacao-noticia':
            (context) => const NewsCreatePage(),
        '/perfil/adm/gerenciamento-noticias/edicao-noticia': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return NewsUpdatePage(newsId: args['newsId']);
        },
        '/perfil/adm/gerenciamento-usuarios':
            (context) => const UserManagementPage(),
      },
    );
  }
}
