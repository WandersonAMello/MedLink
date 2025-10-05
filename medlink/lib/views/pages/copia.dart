import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Model para consulta
class Appointment {
  final String id;
  final String time;
  final String patient;
  final String doctor;
  final String type;
  AppointmentStatus status;

  Appointment({
    required this.id,
    required this.time,
    required this.patient,
    required this.doctor,
    required this.type,
    required this.status,
  });
}

enum AppointmentStatus { confirmed, pending, cancelled }

class SecretaryDashboard extends StatefulWidget {
  final VoidCallback? onLogout;
  final VoidCallback? onNavigateToNewPatient;

  const SecretaryDashboard({
    super.key,
    this.onLogout,
    this.onNavigateToNewPatient,
  });

  @override
  State<SecretaryDashboard> createState() => _SecretaryDashboardState();
}

class _SecretaryDashboardState extends State<SecretaryDashboard> {
  final bool _isNewAppointmentOpen = false;
  String _cancelReason = '';
  Appointment? _selectedAppointment;

  // Mock data - consultas do dia
  final List<Appointment> _appointments = [
    Appointment(
      id: '1',
      time: '09:00',
      patient: 'Maria Silva',
      doctor: 'Dr. João Santos',
      type: 'Consulta Geral',
      status: AppointmentStatus.confirmed,
    ),
    Appointment(
      id: '2',
      time: '10:30',
      patient: 'Carlos Oliveira',
      doctor: 'Dra. Ana Costa',
      type: 'Retorno',
      status: AppointmentStatus.pending,
    ),
    Appointment(
      id: '3',
      time: '14:00',
      patient: 'Lucia Pereira',
      doctor: 'Dr. Pedro Lima',
      type: 'Primeira Consulta',
      status: AppointmentStatus.confirmed,
    ),
    Appointment(
      id: '4',
      time: '15:30',
      patient: 'Roberto Santos',
      doctor: 'Dra. Maria Fernandes',
      type: 'Exame',
      status: AppointmentStatus.pending,
    ),
  ];

  // Cores do tema médico
  static const Color primaryColor = Color(0xFF0891B2);
  static const Color secondaryColor = Color(0xFF67E8F9);
  static const Color accentColor = Color(0xFFE0F2FE);
  static const Color backgroundColor = Color(0xFFF8FAFC);

  // Configurações de status
  Map<String, dynamic> _getStatusConfig(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.confirmed:
        return {'label': 'Confirmada', 'color': Colors.green};
      case AppointmentStatus.pending:
        return {'label': 'Pendente', 'color': Colors.orange};
      case AppointmentStatus.cancelled:
        return {'label': 'Cancelada', 'color': Colors.red};
    }
  }

  // Estatísticas
  Map<String, int> get _stats {
    return {
      'today': _appointments.length,
      'confirmed': _appointments
          .where((a) => a.status == AppointmentStatus.confirmed)
          .length,
      'pending': _appointments
          .where((a) => a.status == AppointmentStatus.pending)
          .length,
      'totalMonth': 127, // Mock data
    };
  }

  // Confirmar consulta
  void _confirmAppointment(String appointmentId) {
    setState(() {
      final index = _appointments.indexWhere((a) => a.id == appointmentId);
      if (index != -1) {
        _appointments[index].status = AppointmentStatus.confirmed;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Consulta confirmada com sucesso!'),
        backgroundColor: primaryColor,
      ),
    );
  }

  // Mostrar dialog de cancelamento
  void _showCancelDialog(Appointment appointment) {
    setState(() {
      _selectedAppointment = appointment;
      _cancelReason = '';
    });

    showDialog(context: context, builder: (context) => _buildCancelDialog());
  }

  // Cancelar consulta
  void _cancelAppointment() {
    if (_selectedAppointment != null) {
      setState(() {
        final index = _appointments.indexWhere(
          (a) => a.id == _selectedAppointment!.id,
        );
        if (index != -1) {
          _appointments[index].status = AppointmentStatus.cancelled;
        }
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Consulta cancelada com sucesso!'),
          backgroundColor: primaryColor,
        ),
      );
    }
  }

  // Editar consulta
  void _editAppointment(String appointmentId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Funcionalidade de edição em desenvolvimento'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  // Formatar data de hoje
  String get _todayFormatted {
    final now = DateTime.now();
    return DateFormat('EEEE, d \'de\' MMMM \'de\' y', 'pt_BR').format(now);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              accentColor.withOpacity(0.3),
              backgroundColor,
              secondaryColor.withOpacity(0.2),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                _buildHeader(),
                SizedBox(height: 24),
                _buildStatsCards(),
                SizedBox(height: 24),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: _buildTodaySchedule()),
                      SizedBox(width: 16),
                      Expanded(flex: 1, child: _buildQuickActions()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Header
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.local_hospital, size: 32, color: primaryColor),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MedLink',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                Text(
                  'Painel da Secretária',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Bem-vindo, Ana Silva',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  'Secretária',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: widget.onLogout,
              icon: Icon(Icons.logout, size: 16),
              label: Text('Sair'),
            ),
          ],
        ),
      ],
    );
  }

  // Cards de estatísticas
  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Hoje',
            _stats['today']!,
            Icons.calendar_today,
            primaryColor,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Confirmadas',
            _stats['confirmed']!,
            Icons.check_circle,
            Colors.green,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Pendentes',
            _stats['pending']!,
            Icons.access_time,
            Colors.orange,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Total Mês',
            _stats['totalMonth']!,
            Icons.local_hospital,
            primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, int value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    value.toString(),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Agenda do dia
  Widget _buildTodaySchedule() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header da agenda
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today, color: primaryColor),
                        SizedBox(width: 8),
                        Text(
                          'Agenda de Hoje',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      _todayFormatted,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showNewAppointmentDialog(),
                  icon: Icon(Icons.add),
                  label: Text('Nova Consulta'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Lista de consultas
            Expanded(
              child: ListView.builder(
                itemCount: _appointments.length,
                itemBuilder: (context, index) {
                  final appointment = _appointments[index];
                  return _buildAppointmentCard(appointment);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Card de consulta
  Widget _buildAppointmentCard(Appointment appointment) {
    final statusConfig = _getStatusConfig(appointment.status);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Row(
        children: [
          // Horário
          Column(
            children: [
              Icon(Icons.access_time, color: primaryColor, size: 16),
              SizedBox(height: 4),
              Text(
                appointment.time,
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
              ),
            ],
          ),
          SizedBox(width: 16),

          // Informações da consulta
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.patient,
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                ),
                Text(
                  appointment.doctor,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  appointment.type,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          // Ações e status
          Column(
            children: [
              // Botões de ação
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (appointment.status == AppointmentStatus.pending)
                    Container(
                      width: 32,
                      height: 32,
                      margin: EdgeInsets.only(right: 4),
                      child: IconButton(
                        onPressed: () => _confirmAppointment(appointment.id),
                        icon: Icon(Icons.check, size: 16, color: Colors.green),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.green[50],
                          side: BorderSide(color: Colors.green[200]!),
                        ),
                      ),
                    ),
                  if (appointment.status != AppointmentStatus.cancelled)
                    Container(
                      width: 32,
                      height: 32,
                      margin: EdgeInsets.only(right: 4),
                      child: IconButton(
                        onPressed: () => _showCancelDialog(appointment),
                        icon: Icon(Icons.close, size: 16, color: Colors.red),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.red[50],
                          side: BorderSide(color: Colors.red[200]!),
                        ),
                      ),
                    ),
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: IconButton(
                      onPressed: () => _editAppointment(appointment.id),
                      icon: Icon(Icons.edit, size: 16, color: Colors.blue),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.blue[50],
                        side: BorderSide(color: Colors.blue[200]!),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),

              // Badge de status
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusConfig['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusConfig['label'],
                  style: TextStyle(
                    color: statusConfig['color'],
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Ações rápidas
  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ações Rápidas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            _buildActionButton(
              'Nova Consulta',
              Icons.add,
              primaryColor,
              () => _showNewAppointmentDialog(),
              isPrimary: true,
            ),
            SizedBox(height: 12),

            _buildActionButton(
              'Novo Paciente',
              Icons.person_add,
              Colors.grey[700]!,
              widget.onNavigateToNewPatient ?? () {},
            ),
            SizedBox(height: 12),

            _buildActionButton(
              'Ver Agenda Completa',
              Icons.calendar_view_day,
              Colors.grey[700]!,
              () {
                // Implementar navegação para agenda completa
              },
            ),
            SizedBox(height: 12),

            _buildActionButton(
              'Lista de Pacientes',
              Icons.people,
              Colors.grey[700]!,
              () {
                // Implementar navegação para lista de pacientes
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed, {
    bool isPrimary = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? color : Colors.white,
          foregroundColor: isPrimary ? Colors.white : color,
          side: isPrimary ? null : BorderSide(color: Colors.grey[300]!),
          alignment: Alignment.centerLeft,
        ),
      ),
    );
  }

  // Dialog de cancelamento
  Widget _buildCancelDialog() {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning, color: Colors.orange),
          SizedBox(width: 8),
          Text('Cancelar Consulta'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Você tem certeza que deseja cancelar esta consulta? Esta ação não pode ser desfeita.',
          ),
          SizedBox(height: 16),
          Text(
            'Motivo do cancelamento (opcional)',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8),
          TextField(
            onChanged: (value) => _cancelReason = value,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Descreva o motivo do cancelamento...',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _cancelAppointment,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: Text(
            'Confirmar Cancelamento',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  // Dialog de nova consulta (placeholder)
  void _showNewAppointmentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nova Consulta'),
        content: Text('Modal de nova consulta será implementado aqui.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fechar'),
          ),
        ],
      ),
    );
  }
}




/**?import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert'; // Necessário para tratar respostas da API
// Importe seus modelos e serviços. Ajuste o caminho se necessário.
// Lembre-se de ter o arquivo appointment_model.dart e api_service.dart criados.
// import '../../models/appointment_model.dart';
// import '../../services/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// --- Classes de Modelo e Serviço (Colocadas aqui para o exemplo ser autocontido) ---
// Em seu projeto, estes estarão em arquivos separados.

class Appointment {
  final int id;
  final DateTime dateTime;
  final String status;
  final double valor;
  final String patientName;
  final String doctorName;
  final int? patientId;
  final int? doctorId;
  final int? clinicId;

  Appointment({
    required this.id,
    required this.dateTime,
    required this.status,
    required this.valor,
    required this.patientName,
    required this.doctorName,
    this.patientId,
    this.doctorId,
    this.clinicId,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      dateTime: DateTime.parse(json['data_hora']),
      status: json['status_atual'],
      valor: double.tryParse(json['valor'].toString()) ?? 0.0,
      patientName:
          json['paciente_detalhes']?['nome_completo'] ??
          'Paciente não encontrado',
      doctorName:
          json['medico_detalhes']?['nome_completo'] ?? 'Médico não encontrado',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data_hora': dateTime.toIso8601String(),
      'status_atual': status,
      'valor': valor.toString(),
      'paciente': patientId,
      'medico': doctorId,
      'clinica': clinicId,
    };
  }
}

class ApiService {
  final String baseUrl = "http://10.0.2.2:8000/api";
  Future<List<Appointment>> getAppointments(String accessToken) async {
    final url = Uri.parse("$baseUrl/agendamentos/");
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(
        utf8.decode(response.bodyBytes),
      );
      return jsonList.map((json) => Appointment.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao carregar agendamentos');
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
      body: jsonEncode(appointment.toJson()),
    );
  }
}

// --- Fim das Classes de Exemplo ---

class SecretaryDashboard extends StatefulWidget {
  final VoidCallback? onLogout;
  final VoidCallback? onNavigateToNewPatient;

  const SecretaryDashboard({
    Key? key,
    this.onLogout,
    this.onNavigateToNewPatient,
  }) : super(key: key);

  @override
  State<SecretaryDashboard> createState() => _SecretaryDashboardState();
}

class _SecretaryDashboardState extends State<SecretaryDashboard> {
  final ApiService _apiService = ApiService();

  List<Appointment> _appointments = [];
  bool _isLoading = true;

  String _cancelReason = '';
  Appointment? _selectedAppointment;

  static const Color primaryColor = Color(0xFF0891B2);
  static const Color secondaryColor = Color(0xFF67E8F9);
  static const Color accentColor = Color(0xFFE0F2FE);
  static const Color backgroundColor = Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    setState(() => _isLoading = true);
    final storage = FlutterSecureStorage();

    try {
      // Lê o token salvo no dispositivo
      final accessToken = await storage.read(key: 'access_token');

      if (accessToken == null) {
        throw Exception('Token não encontrado. Faça o login novamente.');
      }

      // Usa o token real para buscar os dados
      final appointmentsFromApi = await _apiService.getAppointments(
        accessToken,
      );

      if (!mounted) return;
      setState(() {
        _appointments = appointmentsFromApi;
      });
    } catch (e) {
      // ... (tratamento de erro)
    } finally {
      // ...
    }
  }

  Map<String, int> get _stats {
    return {
      'today': _appointments.length,
      'confirmed': _appointments
          .where((a) => a.status.toLowerCase() == 'confirmado')
          .length,
      'pending': _appointments
          .where((a) => a.status.toLowerCase() == 'pendente')
          .length,
      'totalMonth': 127, // Mock data
    };
  }

  void _confirmAppointment(int appointmentId) {
    // TODO: Chamar API para confirmar e depois chamar _fetchAppointments()
    print("Confirmar consulta ID: $appointmentId");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Consulta confirmada com sucesso! (Localmente)'),
        backgroundColor: primaryColor,
      ),
    );
  }

  void _showCancelDialog(Appointment appointment) {
    _selectedAppointment = appointment;
    _cancelReason = '';
    showDialog(context: context, builder: (context) => _buildCancelDialog());
  }

  void _cancelAppointment() {
    // TODO: Chamar API para cancelar e depois chamar _fetchAppointments()
    if (_selectedAppointment != null) {
      print(
        "Cancelar consulta ID: ${_selectedAppointment!.id} com motivo: $_cancelReason",
      );
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Consulta cancelada com sucesso! (Localmente)'),
          backgroundColor: primaryColor,
        ),
      );
    }
  }

  void _editAppointment(int appointmentId) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade de edição em desenvolvimento'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  String get _todayFormatted {
    final now = DateTime.now();
    return DateFormat('EEEE, d \'de\' MMMM \'de\' y', 'pt_BR').format(now);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              accentColor.withOpacity(0.3),
              backgroundColor,
              secondaryColor.withOpacity(0.2),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildStatsCards(),
                const SizedBox(height: 24),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: _buildTodaySchedule()),
                      const SizedBox(width: 16),
                      Expanded(flex: 1, child: _buildQuickActions()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Row(
          children: [
            Icon(Icons.local_hospital, size: 32, color: primaryColor),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MedLink',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                Text(
                  'Painel da Secretária',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Bem-vindo, Ana Silva',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  'Secretária',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: widget.onLogout,
              icon: const Icon(Icons.logout, size: 16),
              label: const Text('Sair'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Hoje',
            _stats['today']!,
            Icons.calendar_today,
            primaryColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Confirmadas',
            _stats['confirmed']!,
            Icons.check_circle,
            Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Pendentes',
            _stats['pending']!,
            Icons.access_time,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Total Mês',
            _stats['totalMonth']!,
            Icons.local_hospital,
            primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, int value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    value.toString(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaySchedule() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.calendar_today, color: primaryColor),
                        SizedBox(width: 8),
                        Text(
                          'Agenda de Hoje',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _todayFormatted,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _showNewAppointmentDialog,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Nova Consulta',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _appointments.isEmpty
                  ? const Center(child: Text("Nenhum agendamento para hoje."))
                  : ListView.builder(
                      itemCount: _appointments.length,
                      itemBuilder: (context, index) {
                        final appointment = _appointments[index];
                        return _buildAppointmentCard(appointment);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    final statusLabel = appointment.status;
    final statusColor = statusLabel.toLowerCase() == 'confirmado'
        ? Colors.green
        : statusLabel.toLowerCase() == 'pendente'
        ? Colors.orange
        : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Column(
            children: [
              const Icon(Icons.access_time, color: primaryColor, size: 16),
              const SizedBox(height: 4),
              Text(
                DateFormat.Hm().format(appointment.dateTime),
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.patientName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  appointment.doctorName,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (appointment.status.toLowerCase() == 'pendente')
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: IconButton(
                        onPressed: () => _confirmAppointment(appointment.id),
                        icon: const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.green,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.green[50],
                          side: BorderSide(color: Colors.green[200]!),
                        ),
                      ),
                    ),
                  if (appointment.status.toLowerCase() != 'cancelada')
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: IconButton(
                        onPressed: () => _showCancelDialog(appointment),
                        icon: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.red,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.red[50],
                          side: BorderSide(color: Colors.red[200]!),
                        ),
                      ),
                    ),
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: IconButton(
                      onPressed: () => _editAppointment(appointment.id),
                      icon: const Icon(
                        Icons.edit,
                        size: 16,
                        color: Colors.blue,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.blue[50],
                        side: BorderSide(color: Colors.blue[200]!),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ações Rápidas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildActionButton(
              'Nova Consulta',
              Icons.add,
              primaryColor,
              () => _showNewAppointmentDialog(),
              isPrimary: true,
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              'Novo Paciente',
              Icons.person_add,
              Colors.grey[700]!,
              widget.onNavigateToNewPatient ?? () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed, {
    bool isPrimary = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? color : Colors.white,
          foregroundColor: isPrimary ? Colors.white : color,
          side: isPrimary ? null : BorderSide(color: Colors.grey[300]!),
          alignment: Alignment.centerLeft,
        ),
      ),
    );
  }

  Widget _buildCancelDialog() {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.warning, color: Colors.orange),
          SizedBox(width: 8),
          Text('Cancelar Consulta'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Você tem certeza que deseja cancelar esta consulta? Esta ação não pode ser desfeita.',
          ),
          const SizedBox(height: 16),
          const Text(
            'Motivo do cancelamento (opcional)',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          TextField(
            onChanged: (value) => _cancelReason = value,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Descreva o motivo...',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Voltar'),
        ),
        ElevatedButton(
          onPressed: _cancelAppointment,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text(
            'Confirmar Cancelamento',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  void _showNewAppointmentDialog() {
    final patientIdController = TextEditingController();
    final doctorIdController = TextEditingController();
    final valorController = TextEditingController();
    DateTime? selectedDate;
    TimeOfDay? selectedTime;
    bool isDialogLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Nova Consulta'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: patientIdController,
                      decoration: const InputDecoration(
                        labelText: 'ID do Paciente',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: doctorIdController,
                      decoration: const InputDecoration(
                        labelText: 'ID do Médico',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: valorController,
                      decoration: const InputDecoration(
                        labelText: 'Valor da Consulta',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton.icon(
                            icon: const Icon(Icons.calendar_today),
                            label: Text(
                              selectedDate == null
                                  ? 'Selecionar Data'
                                  : DateFormat(
                                      'dd/MM/yyyy',
                                    ).format(selectedDate!),
                            ),
                            onPressed: () async {
                              final pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365),
                                ),
                              );
                              if (pickedDate != null)
                                setDialogState(() => selectedDate = pickedDate);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextButton.icon(
                            icon: const Icon(Icons.access_time),
                            label: Text(
                              selectedTime == null
                                  ? 'Selecionar Hora'
                                  : selectedTime!.format(context),
                            ),
                            onPressed: () async {
                              final pickedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (pickedTime != null)
                                setDialogState(() => selectedTime = pickedTime);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                  ),
                  onPressed: isDialogLoading
                      ? null
                      : () async {
                          if (patientIdController.text.isEmpty ||
                              doctorIdController.text.isEmpty ||
                              valorController.text.isEmpty ||
                              selectedDate == null ||
                              selectedTime == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Por favor, preencha todos os campos.',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          setDialogState(() => isDialogLoading = true);

                          final appointmentDateTime = DateTime(
                            selectedDate!.year,
                            selectedDate!.month,
                            selectedDate!.day,
                            selectedTime!.hour,
                            selectedTime!.minute,
                          );

                          final newAppointment = Appointment(
                            id: 0,
                            dateTime: appointmentDateTime,
                            status: 'Pendente',
                            valor: double.tryParse(valorController.text) ?? 0.0,
                            patientName: '',
                            doctorName: '',
                            patientId: int.parse(patientIdController.text),
                            doctorId: int.parse(doctorIdController.text),
                            clinicId: 1,
                          );

                          try {
                            // TODO: Pegar o token do Secure Storage
                            const String fakeToken = "SEU_TOKEN_DE_ACESSO_AQUI";
                            final response = await _apiService
                                .createAppointment(newAppointment, fakeToken);

                            if (!context.mounted) return;

                            if (response.statusCode == 201) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Consulta agendada com sucesso!',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              _fetchAppointments();
                            } else {
                              final error =
                                  jsonDecode(
                                    utf8.decode(response.bodyBytes),
                                  )['detail'] ??
                                  'Erro no backend.';
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Falha: $error'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Erro de conexão: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } finally {
                            setDialogState(() => isDialogLoading = false);
                          }
                        },
                  child: isDialogLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Salvar Agendamento',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
 */