import 'package:flutter/material.dart';
import 'package:semestre5_mobile/widgets/header.dart';
import 'package:semestre5_mobile/widgets/navbar.dart';

class NewsDashboardPage extends StatelessWidget {
  const NewsDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              const Header(),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[const Text('Você acessou o GWI News!')],
                  ),
                ),
              ),
            ],
          ),
          const Navbar(),
        ],
      ),
    );
  }
}
