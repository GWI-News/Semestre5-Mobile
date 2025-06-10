import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:semestre5_mobile/pages/news_dashboard_page.dart';
import 'package:semestre5_mobile/pages/about_us_page.dart'; // Adicione este import
import 'package:semestre5_mobile/pages/faq_page.dart'; // Adicione este import
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
        '/about': (context) => const AboutUsPage(), // Adicione esta linha
        '/faq': (context) => const FaqPage(),
      },
    );
  }
}
