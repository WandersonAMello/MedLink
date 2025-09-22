import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // Adicione este import
import 'views/pages/login.dart';
import 'views/pages/register.dart';
import 'views/pages/dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null); // Inicializa a localização
  runApp(const MyApp());
}

// ...existing code...
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
      // ...existing code...
      routes: {
        '/': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => SecretaryDashboard(
          onLogout: () {
            Navigator.pushReplacementNamed(context, '/');
          }
        ),
      },
    );
  }
}
