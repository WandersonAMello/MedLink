import 'package:flutter/material.dart';
import 'views/pages/login.dart'; // importa sua tela

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // tira o banner de debug
      title: 'MedLink | Login',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginPage(), // chama sua tela de login
    );
  }
}