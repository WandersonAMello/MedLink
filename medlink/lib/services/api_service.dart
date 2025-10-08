import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:medlink/views/pages/admin.dart';
import '../models/user_model.dart';
import '../models/appointment_model.dart';
import '../models/dashboard_stats_model.dart';
import '../models/patient_model.dart';
import '../models/doctor_model.dart';
import '../models/paciente.dart';

class ApiService {
  // ✅ Base URL unificada
  final String baseUrl = kIsWeb
      ? "http://127.0.0.1:8000"
      : "http://10.0.2.2:8000";

  static String? _accessToken;

  Future<Map<String, dynamic>?> login(String cpf, String password) async {
    final url = Uri.parse("$baseUrl/api/token/");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"cpf": cpf, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['access'];
        final String? userType = _getUserTypeFromToken(_accessToken!);

        return {
          'success': true,
          'access_token': data['access'],
          'refresh_token': data['refresh'],
          'user_type': userType ?? 'unknown',
        };
      } else {
        return {
          'success': false,
          'status_code': response.statusCode,
          'body': response.body,
        };
      }
    } catch (e) {
      print('Erro na chamada de login: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // ✅ Helper para extrair o tipo de usuário do token JWT
  String? _getUserTypeFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) throw Exception('Token JWT inválido');
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

  // ✅ REGISTRO DE PACIENTE
  Future<bool> register(User user) async {
    // separa o nome completo
    final parts = user.username.split(' ');
    final firstName = parts.isNotEmpty ? parts.first : user.username;
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    final response = await http.post(
      Uri.parse("$baseUrl/api/pacientes/register/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "cpf": user.cpf,
        "email": user.email,
        "password": user.password,
        "first_name": firstName,
        "last_name": lastName,
        "telefone": user.telefone,
      }),
    );

    print("Status: ${response.statusCode}");
    print("Body: ${response.body}");

    return response.statusCode == 201;
  }

  // ✅ PACIENTES DO DIA
  Future<List<Paciente>> getPacientesDoDia() async {
    final url = Uri.parse("$baseUrl/api/pacientes/hoje/");

    if (_accessToken == null) {
      throw Exception(
        'Token de acesso não encontrado. Faça o login novamente.',
      );
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
      return body.map((e) => Paciente.fromJson(e)).toList();
    } else {
      throw Exception(
        'Falha ao carregar pacientes do dia: ${response.statusCode}',
      );
    }
  }

  // ✅ DASHBOARD STATS
  Future<DashboardStats> getDashboardStats(String accessToken) async {
    final url = Uri.parse("$baseUrl/api/secretarias/dashboard/stats/");
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
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

  // ✅ CONSULTAS / AGENDAMENTOS
  Future<List<Appointment>> getAppointments(String accessToken) async {
    final url = Uri.parse("$baseUrl/api/secretarias/dashboard/consultas-hoje/");
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      if (response.body.isEmpty || response.body == "[]") return [];
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
    final url = Uri.parse("$baseUrl/api/agendamentos/");
    return await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(appointment.toJson()),
    );
  }

  Future<http.Response> confirmAppointment(
    int appointmentId,
    String accessToken,
  ) async {
    final url = Uri.parse("$baseUrl/api/consultas/$appointmentId/confirmar/");
    return await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({'status_atual': 'confirmada'}),
    );
  }

  Future<http.Response> confirmAppointmentByObject(
    Appointment appointment,
    String accessToken,
  ) async {
    final url = Uri.parse(
      "$baseUrl/api/consultas/${appointment.id}/confirmar/",
    );
    return await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(appointment.toJson()),
    );
  }

  // ✅ ADMIN (Usuários da Clínica)
  Future<List<AdminUser>> getClinicUsers(String accessToken) async {
    // 👇 CORREÇÃO: O caminho completo /api/admin/users/ é construído aqui
    final url = Uri.parse("$baseUrl/api/admin/users/");

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
    final url = Uri.parse("$baseUrl/api/admin/users/$userId/");
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
    final url = Uri.parse("$baseUrl/api/admin/users/$userId/");
    return await http.delete(
      url,
      headers: {'Authorization': 'Bearer $accessToken'},
    );
  }

  Future<http.Response> createClinicUser(
    Map<String, dynamic> userData,
    String accessToken,
  ) async {
    final url = Uri.parse("$baseUrl/api/admin/users/");
    return await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(userData),
    );
  }

  Future<AdminUser> getSingleUser(String userId, String accessToken) async {
    final url = Uri.parse("$baseUrl/api/admin/users/$userId/");
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      return AdminUser.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Falha ao carregar dados do usuário.');
    }
  }

  Future<http.Response> updateUser(
    String userId,
    Map<String, dynamic> data,
    String accessToken,
  ) async {
    final url = Uri.parse("$baseUrl/admin/users/$userId/");
    return await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(data),
    );
  }

  // ✅ PACIENTES e MÉDICOS
  Future<List<Patient>> getPatients(String accessToken) async {
    final url = Uri.parse("$baseUrl/api/pacientes/");
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      if (response.body.isEmpty || response.body == "[]") return [];
      final List<dynamic> jsonList = json.decode(
        utf8.decode(response.bodyBytes),
      );
      return jsonList.map((json) => Patient.fromJson(json)).toList();
    } else {
      throw Exception(
        'Falha ao carregar pacientes (Status: ${response.statusCode})',
      );
    }
  }

  Future<List<Doctor>> getDoctors(String accessToken) async {
    final url = Uri.parse("$baseUrl/api/medicos/");
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      if (response.body.isEmpty || response.body == "[]") return [];
      final List<dynamic> jsonList = json.decode(
        utf8.decode(response.bodyBytes),
      );
      return jsonList.map((json) => Doctor.fromJson(json)).toList();
    } else {
      throw Exception(
        'Falha ao carregar médicos (Status: ${response.statusCode})',
      );
    }
  }

  Future<http.Response> createPatient(
    Map<String, dynamic> patientData,
    String accessToken,
  ) async {
    final url = Uri.parse("$baseUrl/api/pacientes/register/");
    return await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(patientData),
    );
  }
}
