import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:medlink/views/pages/home_page.dart';
import 'package:provider/provider.dart';

// Views
import 'views/pages/login.dart';
import 'views/pages/register.dart';
import 'views/pages/dashboard_page.dart';
import 'views/pages/admin.dart';
import 'views/pages/admin_edit_user_page.dart';
import 'views/pages/medico_dashboard_page.dart';

// Controllers
import 'controllers/paciente_controller.dart';

void main() async {
  // Garante que o Flutter está inicializado antes de qualquer outra coisa
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializa a formatação de datas para o português do Brasil
  await initializeDateFormatting('pt_BR', null);

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => PacienteController())],
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

      // A rota inicial, que aponta para a LoginPage
      initialRoute: '/',

      // 2. MAPA DE ROTAS ATUALIZADO E ORGANIZADO
      routes: {
        // Rotas Principais
        '/': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),

        // Rotas de Dashboards por Perfil de Usuário
        '/secretary/dashboard': (context) => const SecretaryDashboard(),
        '/admin/dashboard': (context) => const AdminDashboard(),
        '/doctor/dashboard': (context) => const MedicoDashboardPage(),
        // NOVA rota do médico
        '/admin/edit-user': (context) {
          // Pega o ID do usuário passado como argumento na navegação
          final userId = ModalRoute.of(context)?.settings.arguments as String;
          return AdminEditUserPage(userId: userId);
        },
        '/user/dashboard': (context) => const HomePage(),
        // TODO: Adicione as rotas para os outros perfis aqui quando as telas existirem
        // '/patient/dashboard': (context) => const PatientDashboard(),
      },
    );
  }
}
