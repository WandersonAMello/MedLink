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
    Key? key,
    this.onLogout,
    this.onNavigateToNewPatient,
  }) : super(key: key);

  @override
  State<SecretaryDashboard> createState() => _SecretaryDashboardState();
}

class _SecretaryDashboardState extends State<SecretaryDashboard> {
  bool _isNewAppointmentOpen = false;
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
                  Container(
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
