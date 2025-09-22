import 'package:flutter/material.dart';
import '../../controllers/register_controller.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _registerController = RegisterController();
  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  bool _senhaVisivel = false;
  bool _confirmarSenhaVisivel = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5BBCDC), // Fundo azul
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo
              Image.asset(
                'assets/images/Logo2.png',
                height: 100,
              ),
              const SizedBox(height: 20),

              // Título
              const Text(
                "Cadastrar-se",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),

              // Campos de input
              _buildTextField("Nome completo", Icons.person, _nomeController),
              const SizedBox(height: 15),

              _buildTextField("CPF", Icons.credit_card, _cpfController,
                  hintText: "000.000.000-00"),
              const SizedBox(height: 15),

              _buildTextField("E-mail", Icons.email, _emailController,
                  hintText: "exemplo@email.com"),
              const SizedBox(height: 15),

              _buildTextField("Telefone", Icons.phone, _telefoneController,
                  hintText: "(00) 00000-0000"),
              const SizedBox(height: 15),

              // Senha com ícone de olho
              _buildPasswordField("Senha", _senhaController, _senhaVisivel,
                  () => setState(() => _senhaVisivel = !_senhaVisivel)),
              const SizedBox(height: 15),

              _buildPasswordField(
                  "Confirmar senha",
                  _confirmarSenhaController,
                  _confirmarSenhaVisivel,
                  () => setState(
                      () => _confirmarSenhaVisivel = !_confirmarSenhaVisivel)),
              const SizedBox(height: 30),

              // Botão Cadastrar-se
              _buildButton("Cadastrar-se", const Color(0xFF42A01C), () {
                _registerController.register(
                  context,
                  nome: _nomeController.text,
                  cpf: _cpfController.text,
                  email: _emailController.text,
                  telefone: _telefoneController.text,
                  senha: _senhaController.text,
                  confirmarSenha: _confirmarSenhaController.text,
                );
              }),
              const SizedBox(height: 15),

              const Text("OU", style: TextStyle(color: Colors.white)),
              const SizedBox(height: 15),

              // Botão Entrar
              _buildButton("Entrar", const Color(0xFF1D80A1), () {
                Navigator.pushReplacementNamed(context, '/');
              }),
            ],
          ),
        ),
      ),
    );
  }

  // Função para criar campos de input
  Widget _buildTextField(String label, IconData icon,
      TextEditingController controller,
      {bool obscureText = false, String? hintText}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF5BBCDC)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF5BBCDC)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF1D80A1), width: 2),
        ),
      ),
    );
  }

  // Função para criar campos de senha com ícone de olho
  Widget _buildPasswordField(String label, TextEditingController controller,
      bool isVisible, VoidCallback toggleVisibility) {
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: label,
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: toggleVisibility,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF5BBCDC)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF5BBCDC)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF1D80A1), width: 2),
        ),
      ),
    );
  }

  // Função para criar botões atualizada para Flutter recente
  Widget _buildButton(String text, Color color, VoidCallback onPressed) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.pressed)) {
                return color.withOpacity(0.7);
              } else if (states.contains(WidgetState.hovered)) {
                return color.withOpacity(0.85);
              }
              return color; // cor padrão
            },
          ),
          minimumSize: WidgetStateProperty.resolveWith<Size>(
            (_) => const Size(double.infinity, 50),
          ),
          shape: WidgetStateProperty.resolveWith<OutlinedBorder>(
            (_) => RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}