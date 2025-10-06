// lib/services/api_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:medlink/views/pages/admin.dart';
import '../models/user_model.dart';
import '../models/appointment_model.dart';
import '../models/dashboard_stats_model.dart';

class ApiService {
  final String baseUrl = kIsWeb
      ? "http://127.0.0.1:8000/api"
      : "http://10.0.2.2:8000/api";

  Future<http.Response> login(String cpf, String password) async {
    final url = Uri.parse(
      "${kIsWeb ? 'http://127.0.0.1:8000' : 'http://10.0.2.2:8000'}/api/token/",
    );
    return await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"cpf": cpf, "password": password}),
    );
  }

  Future<bool> register(User user) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/pacientes/register/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

  Future<DashboardStats> getDashboardStats(String accessToken) async {
    final url = Uri.parse("$baseUrl/secretarias/dashboard/stats/");
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    if (response.statusCode == 200) {
      // Se a resposta estiver vazia, retorna um objeto de Stats zerado
      if (response.body.isEmpty || response.body == "{}") {
        return DashboardStats(
          today: 0,
          confirmed: 0,
          pending: 0,
          totalMonth: 0,
        );
      }
      return DashboardStats.fromJson(
        json.decode(utf8.decode(response.bodyBytes)),
      );
    } else {
      throw Exception('Falha ao carregar estatísticas do dashboard.');
    }
  }

  Future<List<Appointment>> getAppointments(String accessToken) async {
    final url = Uri.parse("$baseUrl/secretarias/dashboard/consultas-hoje/");
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      // Se a resposta estiver vazia, retorna uma lista vazia em vez de dar erro
      if (response.body == "[]" || response.body.isEmpty) {
        return [];
      }
      final List<dynamic> jsonList = json.decode(
        utf8.decode(response.bodyBytes),
      );
      return jsonList.map((json) => Appointment.fromJson(json)).toList();
    } else {
      throw Exception(
        'Falha ao carregar agendamentos (Status: ${response.statusCode})',
      );
    }
  }

  Future<http.Response> createAppointment(
    Appointment appointment,
    String accessToken,
  ) async {
    final url = Uri.parse("$baseUrl/agendamentos/");
    return await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(
        appointment.toJson(),
      ), // Usa o método toJson do novo modelo
    );
  }

  /// Envia uma requisição para confirmar uma consulta específica.
  /// O backend espera o status atualizado no corpo da requisição.
  Future<http.Response> confirmAppointment(
    int appointmentId,
    String accessToken,
  ) async {
    final url = Uri.parse("$baseUrl/consultas/$appointmentId/confirmar/");
    return await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({'status_atual': 'confirmada'}),
    );
  }

  /// Envia uma requisição para confirmar uma consulta específica.
  /// O backend espera o status atualizado no corpo da requisição.
  /// Este método aceita um objeto Appointment em vez de apenas o ID.
  Future<http.Response> confirmAppointmentByObject(
    Appointment appointment,
    String accessToken,
  ) async {
    final url = Uri.parse("$baseUrl/consultas/${appointment.id}/confirmar/");
    return await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(appointment.toJson()),
    );
  }

  // --- MÉTODOS DO ADMIN ---

  Future<List<AdminUser>> getClinicUsers(String accessToken) async {
    // 👇 CORREÇÃO: O caminho agora é relativo à baseUrl
    final url = Uri.parse("$baseUrl/admin/users/");

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(
        utf8.decode(response.bodyBytes),
      );
      return jsonList.map((json) => AdminUser.fromJson(json)).toList();
    } else {
      throw Exception(
        'Falha ao carregar usuários (Status: ${response.statusCode})',
      );
    }
  }

  Future<http.Response> updateUserStatus(
    String userId,
    bool isActive,
    String accessToken,
  ) async {
    final url = Uri.parse("$baseUrl/admin/users/$userId/");
    return await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({'is_active': isActive}),
    );
  }

  Future<http.Response> deleteUser(String userId, String accessToken) async {
    final url = Uri.parse("$baseUrl/admin/users/$userId/");
    return await http.delete(
      url,
      headers: {'Authorization': 'Bearer $accessToken'},
    );
  }

  // Em lib/services/api_service.dart

  // ... (seus métodos existentes: getClinicUsers, etc.)

  /// Cria um novo usuário da clínica (Secretária, Médico, etc.).
  Future<http.Response> createClinicUser(
    Map<String, dynamic> userData,
    String accessToken,
  ) async {
    final url = Uri.parse("$baseUrl/admin/users/");
    return await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(userData),
    );
  }
}
