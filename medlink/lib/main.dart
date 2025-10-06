// lib/main.dart

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'views/pages/login.dart';
import 'views/pages/register.dart';
import 'views/pages/dashboard_page.dart';
import 'views/pages/admin.dart';
import 'views/pages/home_page.dart'; // 1. ADICIONE ESTA IMPORTAÇÃO
import 'views/pages/admin_edit_user_page.dart'; // 2. ADICIONE ESTA IMPORTAÇÃO
// lib/main.dart

// 1. IMPORTE TODAS AS SUAS PÁGINAS PRINCIPAIS
import 'views/pages/login.dart';
import 'views/pages/register.dart';
import 'views/pages/dashboard_page.dart';

// Tela de Novo Paciente
// Tela da Secretária
// import 'views/pages/admin_dashboard_screen.dart'; // Tela do Admin da Clínica
// TODO: Adicione os imports para as telas do Médico, Paciente, etc. quando criá-las
// import 'views/pages/doctor_dashboard_page.dart';
// import 'views/pages/patient_dashboard_page.dart';

void main() async {
  // Garante que o Flutter está inicializado antes de qualquer outra coisa
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializa a formatação de datas para o português do Brasil
  await initializeDateFormatting('pt_BR', null);
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
        '/admin/edit-user': (context) {
          // Pega o ID do usuário passado como argumento na navegação
          final userId = ModalRoute.of(context)?.settings.arguments as String;
          return AdminEditUserPage(userId: userId);
        },

        // TODO: Adicione as rotas para os outros perfis aqui quando as telas existirem
        // '/doctor/dashboard': (context) => const DoctorDashboard(),
        // '/patient/dashboard': (context) => const PatientDashboard(),

        // A rota '/home' foi removida para evitar confusão, já que agora
        // cada perfil tem seu próprio dashboard específico.
      },
    );
  }
}
