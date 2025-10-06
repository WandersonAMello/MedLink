// lib/services/api_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/paciente.dart';

class ApiService {
  final String baseUrl = kIsWeb ? "http://127.0.0.1:8000" : "http://10.0.2.2:8000";
  
  static String? _accessToken;

  // --- FUNÇÃO DE LOGIN ATUALIZADA ---
  // Agora retorna um Mapa com o tipo de usuário em caso de sucesso
  Future<Map<String, dynamic>?> login(String cpf, String password) async {
    final url = Uri.parse("$baseUrl/api/token/");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "cpf": cpf,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['access']; // Armazena o token de acesso

        // Decodifica o token para extrair o tipo de usuário
        final String? userType = _getUserTypeFromToken(_accessToken!);
        
        if (userType != null) {
          return {'success': true, 'user_type': userType};
        }
      }
      return null; // Retorna nulo em caso de falha
    } catch (e) {
      print('Erro na chamada de login: $e');
      return null;
    }
  }

  // --- NOVA FUNÇÃO HELPER PARA DECODIFICAR O TOKEN ---
  String? _getUserTypeFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        throw Exception('Token JWT inválido');
      }
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final resp = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(resp);
      return payloadMap['user_type'];
    } catch (e) {
      print('Erro ao decodificar token: $e');
      return null;
    }
  }

  // O resto do arquivo continua igual...
  Future<bool> register(User user) async {
    // ... (sem alterações)
    final response = await http.post(
      Uri.parse("$baseUrl/api/pacientes/register/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(user.toJson()),
    );
    return response.statusCode == 201;
  }

  Future<List<Paciente>> getPacientesDoDia() async {
    // ... (sem alterações)
    final url = Uri.parse("$baseUrl/api/pacientes/hoje/"); 

    if (_accessToken == null) {
      throw Exception('Token de acesso não encontrado. Faça o login novamente.');
    }

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $_accessToken",
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      
      List<Paciente> pacientes = body
          .map((dynamic item) => Paciente.fromJson(item as Map<String, dynamic>))
          .toList();
          
      return pacientes;
    } else {
      throw Exception('Falha ao carregar os pacientes do dia: ${response.statusCode}');
    }
  }
}