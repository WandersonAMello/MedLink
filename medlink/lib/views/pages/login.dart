import 'package:flutter/material.dart';
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

  void _onLoginPressed() async {
    final cpf = _cpfController.text;
    final senha = _senhaController.text;

    if (!_loginController.validarCPF(cpf)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("CPF inválido")),
      );
      return;
    }

    final sucesso = await _loginController.login(cpf, senha);

    if (!mounted) return; // 👈 garante que o widget ainda existe

    if (sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login realizado com sucesso!")),
      );
      // Navegação segura
      // Navigator.pushReplacementNamed(context, "/home");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Usuário ou senha incorretos")),
      );
    }
  }

  bool _obscurePassword = true; // controla o olho da senha

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5BBCDC), // 👈 cor de fundo
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 500,
              maxHeight: 620
            ),
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
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),

                    // CPF
                    const Text("CPF:"),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _cpfController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.badge),
                        hintText: "000.000.000-00",
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFF5BBCDC)), // cor padrão
                          borderRadius: BorderRadius.circular(8), // opcional: arredondar borda
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFF5BBCDC), width: 2), // quando selecionado
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFF5BBCDC)), // quando não selecionado
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
                          borderSide: const BorderSide(color: Color(0xFF5BBCDC)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFF5BBCDC)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFF5BBCDC), width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
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
                      onPressed: _onLoginPressed,
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                          (Set<WidgetState> states) {
                            if (states.contains(WidgetState.hovered)) {
                              return const Color(0xFF166580); // hover
                            }
                            return const Color(0xFF1D80A1); // normal
                          },
                        ),
                        foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                        padding: WidgetStateProperty.all<EdgeInsets>(
                          const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                        ),
                        shape: WidgetStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        textStyle: WidgetStateProperty.all<TextStyle>(
                          const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        mouseCursor: WidgetStateProperty.all<MouseCursor>(WidgetStateMouseCursor.clickable),
                      ),
                      child: const Text("Entrar"),
                    ),

                    const SizedBox(height: 16),
                    const Center(child: Text("OU")),
                    const SizedBox(height: 16),

                    // Botão Cadastrar-se
                    ElevatedButton(
                      onPressed: () {},
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                          (Set<WidgetState> states) {
                            if (states.contains(WidgetState.hovered)) {
                              return const Color(0xFF317714); // hover
                            }
                            return const Color(0xFF42A01C); // normal
                          },
                        ),
                        foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                        padding: WidgetStateProperty.all<EdgeInsets>(
                          const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                        ),
                        shape: WidgetStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        textStyle: WidgetStateProperty.all<TextStyle>(
                          const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        mouseCursor: WidgetStateProperty.all<MouseCursor>(WidgetStateMouseCursor.clickable),
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