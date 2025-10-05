import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../models/appointment_model.dart';
import '../../models/consulta_dashboard_model.dart';
import '../../services/api_service.dart';
import '../../models/dashboard_stats_model.dart';
import 'package:medlink/models/appointment_model.dart';

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
  // Estados da Tela
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final TextEditingController _searchController = TextEditingController();

  List<Appointment> _allAppointments = []; // Guarda a lista original da API
  List<Appointment> _filteredAppointments = []; // Lista exibida na tela
  DashboardStats? _stats;
  bool _isLoading = true;
  String _secretaryName = 'Secretária'; // Nome padrão
  String _searchTerm = '';

  // Constantes de Cor
  static const Color primaryColor = Color(0xFF0891B2);
  static const Color secondaryColor = Color(0xFF67E8F9);
  static const Color accentColor = Color(0xFFE0F2FE);
  static const Color backgroundColor = Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _searchController.addListener(() {
      setState(() {
        _searchTerm = _searchController.text;
        _filterAppointments();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Em _SecretaryDashboardState
  Map<String, int> get _summaryStats {
    return {
      'today': _allAppointments
          .where((a) => a.dateTime.day == DateTime.now().day)
          .length,
      'confirmed': _allAppointments
          .where((a) => a.status == 'confirmed')
          .length,
      'pending': _allAppointments.where((a) => a.status == 'pending').length,
      'totalMonth': _allAppointments
          .where(
            (a) =>
                a.dateTime.month == DateTime.now().month &&
                a.dateTime.year == DateTime.now().year,
          )
          .length,
    };
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final accessToken = await _storage.read(key: 'access_token');
      if (accessToken == null) {
        throw Exception('Token não encontrado. Faça o login novamente.');
      }

      // Decodifica o token para pegar o nome do usuário
      Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);

      // Busca os dados da API em paralelo
      final results = await Future.wait([
        _apiService.getDashboardStats(accessToken),
        _apiService.getAppointments(accessToken),
      ]);

      if (!mounted) return;
      setState(() {
        _secretaryName = decodedToken['full_name'] ?? 'Secretária';
        _stats = results[0] as DashboardStats;
        _allAppointments = results[1] as List<Appointment>;
        _filteredAppointments = _allAppointments;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar dados: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _filterAppointments() {
    if (_searchTerm.isEmpty) {
      _filteredAppointments = _allAppointments;
    } else {
      _filteredAppointments = _allAppointments.where((appointment) {
        final searchTermLower = _searchTerm.toLowerCase();
        final patientNameLower = appointment.patientName.toLowerCase();
        final doctorNameLower = appointment.doctorName.toLowerCase();
        return patientNameLower.contains(searchTermLower) ||
            doctorNameLower.contains(searchTermLower);
      }).toList();
    }
    setState(() {});
  }

  // ... (Suas funções _confirmAppointment, _cancelAppointment, _editAppointment, etc., viriam aqui)
  // ... (Elas devem chamar a API e, no final, chamar _loadInitialData() para atualizar a tela)

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
            padding: const EdgeInsets.all(24.0),
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
                      Expanded(flex: 3, child: _buildTodaySchedule()),
                      const SizedBox(width: 24),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // NOME REAL DA SECRETÁRIA
                Text(
                  'Bem-vinda, $_secretaryName',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const Text(
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
    if (_isLoading || _stats == null) {
      return const SizedBox(
        height: 80,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Hoje',
            _stats!.today,
            Icons.calendar_today,
            primaryColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Confirmadas',
            _stats!.confirmed,
            Icons.check_circle,
            Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Pendentes',
            _stats!.pending,
            Icons.access_time,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Total Mês',
            _stats!.totalMonth,
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
        padding: const EdgeInsets.all(24.0),
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
                // BARRA DE PESQUISA
                SizedBox(
                  width: 250,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar paciente ou médico...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredAppointments.isEmpty
                  ? const Center(child: Text("Nenhum agendamento encontrado."))
                  : ListView.builder(
                      itemCount: _filteredAppointments.length,
                      itemBuilder: (context, index) {
                        final appointment = _filteredAppointments[index];
                        return _buildAppointmentCard(appointment);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Em _SecretaryDashboardState
  Widget _buildAppointmentCard(Appointment appointment) {
    final statusColor = appointment.status == 'confirmed'
        ? Colors.green
        : Colors.orange;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      // ... (o resto do seu Container)
      child: Row(
        children: [
          Column(
            children: [
              const Icon(Icons.access_time, color: primaryColor, size: 16),
              const SizedBox(height: 4),
              // CORRIGIDO: Usa o novo campo `dateTime`
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
                // CORRIGIDO: Usa o novo campo `patientName`
                Text(
                  appointment.patientName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                // CORRIGIDO: Usa o novo campo `doctorName`
                Text(
                  appointment.doctorName,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  appointment.type,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          // ... (o resto do seu card com os botões e o badge de status)
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    // Este widget continua o mesmo
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
              _showNewAppointmentDialog,
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
    // Este widget continua o mesmo
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

  // A implementação do modal de nova consulta (_showNewAppointmentDialog) continua a mesma
  void _showNewAppointmentDialog() {
    // ... cole aqui o código funcional do modal que já fizemos
  }

  // As funções de confirmar e cancelar (_confirmAppointment, _cancelAppointment, etc.) continuam as mesmas
}
