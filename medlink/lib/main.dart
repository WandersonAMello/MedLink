import 'package:flutter/material.dart';
import 'views/pages/login.dart';
import 'views/pages/dashboard_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MedLink',
      theme: ThemeData(primarySwatch: Colors.blue),

      // Define a tela inicial
      initialRoute: '/',

      // Define todas as rotas do seu app
      routes: {
        '/': (context) => const LoginPage(), // Rota inicial
        '/home': (context) => const HomeScreen(), // Rota do dashboard
      },
    );
  }
}
