import '../models/user_model.dart';
import '../services/api_service.dart';

class LoginController {
  final ApiService _apiService = ApiService();

  bool validarCPF(String cpf) {
    cpf = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    if (cpf.length != 11) return false;
    if (RegExp(r'^(\d)\1{10}$').hasMatch(cpf)) return false;

    List<int> numbers = cpf.split('').map(int.parse).toList();

    int soma1 = 0;
    for (int i = 0; i < 9; i++) {
      soma1 += numbers[i] * (10 - i);
    }
    int digito1 = (soma1 * 10) % 11;
    if (digito1 == 10) digito1 = 0;
    if (digito1 != numbers[9]) return false;

    int soma2 = 0;
    for (int i = 0; i < 10; i++) {
      soma2 += numbers[i] * (11 - i);
    }
    int digito2 = (soma2 * 10) % 11;
    if (digito2 == 10) digito2 = 0;
    if (digito2 != numbers[10]) return false;

    return true;
  }
  // ####### Descomente a função abaixo quando a API estiver pronta ########/////
  // Future<bool> login(String cpf, String senha) async {
  //   final user = User(cpf: cpf, senha: senha);

  //   final response = await _apiService.login(user);
  //   if (response.statusCode == 200) {
  //     return true;
  //   } else {
  //     return false;
  //   }
  // }

  // Função de login "mockada" para desenvolvimento do frontend
  Future<bool> login(String cpf, String senha) async {
    // 1. Adicionamos um print para sabermos que a função foi chamada
    print("Tentando login com CPF: $cpf");

    // 2. Não chama mais a API real, pois ela não existe ainda.
    //    final user = User(cpf: cpf, senha: senha);
    //    final response = await _apiService.login(user);

    // 3. Simula uma espera de rede (como se estivesse falando com o servidor)
    //    Isso faz a experiência ser mais realista.
    await Future.delayed(const Duration(seconds: 1));

    // 4. Retorna 'true' diretamente, fingindo que o login foi um sucesso.
    return true;
  }
}
