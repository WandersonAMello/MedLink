import 'package:flutter/material.dart';
import 'dart:convert'; // Import para o jsonDecode
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Import do Secure Storage
import '../../controllers/login_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _cpfController = TextEditingController();
  final _senhaController = TextEditingController();
  final LoginController _loginController = LoginController();

  // 1. Variável para controlar o estado de carregamento
  bool _isLoading = false;

  // 2. LÓGICA DE LOGIN ATUALIZADA
  void _onLoginPressed() async {
    final cpf = _cpfController.text;
    final senha = _senhaController.text;
    print("Tentando login com CPF: $cpf e Senha: $senha");

    if (!_loginController.validarCPF(cpf)) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("CPF inválido")));
      return;
    }

    // Ativa o loading na UI
    setState(() => _isLoading = true);

    // Chama o controller, que agora retorna um mapa com os dados ou nulo
    final loginData = await _loginController.login(cpf, senha);

    // Desativa o loading na UI
    setState(() => _isLoading = false);

    if (!mounted) return;

    if (loginData != null) {
      // Sucesso! Pega os dados do mapa
      final accessToken = loginData['access_token'];
      final userType = loginData['user_type'];

      // Salva o token de forma segura
      const storage = FlutterSecureStorage();
      await storage.write(key: 'access_token', value: accessToken);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login realizado com sucesso!")),
      );

      // 3. LÓGICA DE REDIRECIONAMENTO
      switch (userType) {
        case 'SECRETARIA':
          Navigator.pushReplacementNamed(context, '/secretary/dashboard');
          break;
        case 'MEDICO':
          Navigator.pushReplacementNamed(context, '/doctor/dashboard');
          break;
        case 'ADMIN':
          Navigator.pushReplacementNamed(context, '/admin/dashboard');
          break;
        // Adicione outros casos aqui (ex: 'PACIENTE', 'FINANCEIRO')
        default:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Tipo de usuário desconhecido!")),
          );
      }
    } else {
      // Falha no login (senha errada, usuário não existe ou erro de conexão)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Usuário ou senha incorretos")),
      );
    }
  }

  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5BBCDC),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 620),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo
                    SizedBox(
                      height: 80,
                      child: Image.asset(
                        'assets/images/Logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.broken_image, size: 80);
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Título
                    const Text(
                      "Realizar Login",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // CPF
                    const Text("CPF:"),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _cpfController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.badge),
                        hintText: "000.000.000-00",
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF5BBCDC),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF5BBCDC),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF5BBCDC),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Senha
                    const Text("Senha:"),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _senhaController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock),
                        hintText: "********",
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF5BBCDC),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF5BBCDC),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF5BBCDC),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),

                    // Esqueci minha senha
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text("Esqueci minha senha"),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Botão Entrar
                    ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : _onLoginPressed, // Desabilita durante o loading
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.resolveWith<Color?>((states) {
                              if (states.contains(WidgetState.hovered))
                                return const Color(0xFF166580);
                              return const Color(0xFF1D80A1);
                            }),
                        foregroundColor: WidgetStateProperty.all<Color>(
                          Colors.white,
                        ),
                        padding: WidgetStateProperty.all<EdgeInsets>(
                          const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 14,
                          ),
                        ),
                        shape: WidgetStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        textStyle: WidgetStateProperty.all<TextStyle>(
                          const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : const Text("Entrar"),
                    ),

                    const SizedBox(height: 16),
                    const Center(child: Text("OU")),
                    const SizedBox(height: 16),

                    // Botão Cadastrar-se
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.resolveWith<Color?>((states) {
                              if (states.contains(WidgetState.hovered))
                                return const Color(0xFF317714);
                              return const Color(0xFF42A01C);
                            }),
                        foregroundColor: WidgetStateProperty.all<Color>(
                          Colors.white,
                        ),
                        padding: WidgetStateProperty.all<EdgeInsets>(
                          const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 14,
                          ),
                        ),
                        shape: WidgetStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        textStyle: WidgetStateProperty.all<TextStyle>(
                          const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      child: const Text("Cadastrar-se"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
