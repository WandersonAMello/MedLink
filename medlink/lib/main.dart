import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

// Views
import 'views/pages/login.dart';
import 'views/pages/register.dart';
import 'views/pages/dashboard_page.dart';
import 'views/pages/admin.dart';
import 'views/pages/home_page.dart';
import 'views/pages/medico_dashboard_page.dart';

// Controllers
import 'controllers/paciente_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PacienteController()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MedLink',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/UserDashboardApp': (context) => const HomePage(),
        '/AdminDashboard': (context) => const AdminDashboard(),
        '/SecretariaDashboard': (context) => const SecretaryDashboard(), // já existia
        '/MedicoDashboard': (context) => const MedicoDashboardPage(), // NOVA rota do médico
      },
    );
  }
}