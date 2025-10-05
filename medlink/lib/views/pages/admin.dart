import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../services/api_service.dart'; // Garanta que este import está correto

// --- MODELO E SERVIÇO ---
// Em seu projeto, estes estarão em arquivos separados. O ApiService deve ser importado.

// Model para usuário admin
class AdminUser {
  final String id;
  final String name;
  final String cpf;
  final String email;
  final UserRole role;
  final String? specialty;
  final String? crm;
  bool isActive;
  final DateTime createdAt;
  final DateTime? lastLogin;

  AdminUser({
    required this.id,
    required this.name,
    required this.cpf,
    required this.email,
    required this.role,
    this.specialty,
    this.crm,
    required this.isActive,
    required this.createdAt,
    this.lastLogin,
  });

  // 👇 CONSTRUTOR "BLINDADO" CONTRA VALORES NULOS 👇
  factory AdminUser.fromJson(Map<String, dynamic> json) {
    // Tenta pegar o nome completo, se não vier, constrói a partir de first_name e last_name
    String fullName =
        json['full_name'] ??
        '${json['first_name'] ?? ''} ${json['last_name'] ?? ''}'.trim();
    if (fullName.isEmpty) {
      fullName = 'Nome não informado';
    }

    return AdminUser(
      id:
          json['id']?.toString() ??
          '0', // Usa '?' para ser seguro e dá um padrão '0'
      name: fullName,
      cpf: json['cpf'] ?? '', // Se for nulo, usa string vazia
      email: json['email'] ?? '', // Se for nulo, usa string vazia
      role: UserRole.values.firstWhere(
        // Converte para maiúsculo para bater com o enum
        (e) =>
            e.name.toUpperCase() ==
            (json['user_type'] as String? ?? '').toUpperCase(),
        orElse: () => UserRole.patient, // Padrão se o tipo não for reconhecido
      ),
      specialty: json['specialty'], // Já é anulável, então é seguro
      crm: json['crm'], // Já é anulável, então é seguro
      isActive: json['is_active'] ?? false, // Se for nulo, assume como 'false'
      // Usa tryParse que não quebra se o valor for nulo ou inválido
      createdAt: DateTime.tryParse(json['date_joined'] ?? '') ?? DateTime.now(),

      lastLogin: json['last_login'] != null
          ? DateTime.tryParse(json['last_login'])
          : null,
    );
  }
}

enum UserRole { secretary, doctor, admin, financial, patient }

// --- FIM DOS MODELOS ---

class AdminDashboard extends StatefulWidget {
  final VoidCallback? onLogout;
  const AdminDashboard({Key? key, this.onLogout}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Variáveis de Estado para dados da API
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  List<AdminUser> _allUsers = [];
  bool _isLoading = true;
  String _adminName = "Admin";

  // Filtros
  String _searchTerm = '';
  UserRole? _filterRole;

  // Configurações (mantidas no estado da tela)
  final Map<String, bool> _generalSettings = {
    'autoScheduling': true,
    'emailNotifications': true,
    'autoBackup': true,
  };
  final Map<String, bool> _securitySettings = {
    'twoFactor': false,
    'auditLog': true,
    'autoSession': true,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  static const Color primaryColor = Color(0xFF0891B2);
  static const Color secondaryColor = Color(0xFF67E8F9);
  static const Color accentColor = Color(0xFFE0F2FE);
  static const Color backgroundColor = Color(0xFFF8FAFC);

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final accessToken = await _storage.read(key: 'access_token');
      if (accessToken == null)
        throw Exception('Token não encontrado. Faça o login novamente.');

      final decodedToken = JwtDecoder.decode(accessToken);
      final usersFromApi = await _apiService.getClinicUsers(accessToken);

      if (!mounted) return;
      setState(() {
        _adminName = decodedToken['full_name'] ?? 'Admin';
        _allUsers = usersFromApi;
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<AdminUser> get _filteredUsers {
    return _allUsers.where((user) {
      final matchesSearch =
          _searchTerm.isEmpty ||
          user.name.toLowerCase().contains(_searchTerm.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchTerm.toLowerCase()) ||
          user.cpf.contains(_searchTerm);
      final matchesRole = _filterRole == null || user.role == _filterRole;
      return matchesSearch && matchesRole;
    }).toList();
  }

  Map<String, int> get _stats {
    return {
      'total': _allUsers.length,
      'active': _allUsers.where((u) => u.isActive).length,
      'doctors': _allUsers.where((u) => u.role == UserRole.doctor).length,
      'secretaries': _allUsers
          .where((u) => u.role == UserRole.secretary)
          .length,
      'patients': _allUsers.where((u) => u.role == UserRole.patient).length,
    };
  }

  Map<String, dynamic> _getRoleConfig(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return {'label': 'Admin', 'color': Colors.purple};
      case UserRole.doctor:
        return {'label': 'Médico', 'color': Colors.blue};
      case UserRole.secretary:
        return {'label': 'Secretária', 'color': Colors.green};
      case UserRole.financial:
        return {'label': 'Financeiro', 'color': Colors.orange};
      case UserRole.patient:
        return {'label': 'Paciente', 'color': Colors.grey};
    }
  }

  Future<void> _toggleUserStatus(String userId) async {
    final userIndex = _allUsers.indexWhere((u) => u.id == userId);
    if (userIndex == -1) return;
    final originalStatus = _allUsers[userIndex].isActive;
    final newStatus = !originalStatus;

    setState(() => _allUsers[userIndex].isActive = newStatus);

    try {
      final accessToken = await _storage.read(key: 'access_token');
      if (accessToken == null) throw Exception('Token não encontrado');
      await _apiService.updateUserStatus(userId, newStatus, accessToken);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Status do usuário atualizado'),
          backgroundColor: primaryColor,
        ),
      );
    } catch (e) {
      setState(
        () => _allUsers[userIndex].isActive = originalStatus,
      ); // Reverte em caso de erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteConfirmation(AdminUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red[600]),
            const SizedBox(width: 8),
            const Text('Confirmar Exclusão'),
          ],
        ),
        content: Text(
          'Tem certeza que deseja remover o usuário ${user.name}? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteUser(user.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Confirmar Exclusão',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUser(String userId) async {
    try {
      final accessToken = await _storage.read(key: 'access_token');
      if (accessToken == null) throw Exception('Token não encontrado');
      await _apiService.deleteUser(userId, accessToken);
      setState(
        () => _allUsers.removeWhere((u) => u.id == userId),
      ); // Remove da lista local
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuário removido com sucesso'),
          backgroundColor: primaryColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao remover usuário: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Nunca';
    return DateFormat('dd/MM/yyyy').format(date);
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
                Expanded(child: _buildTabSection()),
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
        Row(
          children: [
            const Icon(Icons.monitor_heart, size: 32, color: primaryColor),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MedLink',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                Text(
                  'Painel Administrativo',
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
                  _adminName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  'Administrador',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
    return _isLoading
        ? const SizedBox(height: 60)
        : Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Usuários',
                  _stats['total']!,
                  Icons.people,
                  primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Ativos',
                  _stats['active']!,
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Médicos',
                  _stats['doctors']!,
                  Icons.local_hospital,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Secretárias',
                  _stats['secretaries']!,
                  Icons.admin_panel_settings,
                  Colors.teal,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Pacientes',
                  _stats['patients']!,
                  Icons.people,
                  Colors.grey,
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

  Widget _buildTabSection() {
    return Card(
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: primaryColor,
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: primaryColor,
            tabs: const [
              Tab(text: 'Usuários'),
              Tab(text: 'Configurações'),
              Tab(text: 'Relatórios'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUsersTab(),
                _buildSettingsTab(),
                _buildReportsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.people, color: primaryColor),
                  SizedBox(width: 8),
                  Text(
                    'Gerenciamento de Usuários',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Novo Usuário',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Buscar por nome, email ou CPF...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => setState(() => _searchTerm = value),
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 200,
                child: DropdownButtonFormField<UserRole?>(
                  value: _filterRole,
                  decoration: const InputDecoration(
                    labelText: 'Filtrar por tipo',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Todos os tipos'),
                    ),
                    ...UserRole.values.map(
                      (role) => DropdownMenuItem(
                        value: role,
                        child: Text(_getRoleConfig(role)['label']),
                      ),
                    ),
                  ],
                  onChanged: (value) => setState(() => _filterRole = value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 16,
                      columns: const [
                        DataColumn(label: Text('Nome')),
                        DataColumn(label: Text('CPF')),
                        DataColumn(label: Text('E-mail')),
                        DataColumn(label: Text('Tipo')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Último Login')),
                        DataColumn(label: Text('Ações')),
                      ],
                      rows: _filteredUsers.map((user) {
                        final roleConfig = _getRoleConfig(user.role);
                        return DataRow(
                          cells: [
                            DataCell(
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    user.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (user.specialty != null)
                                    Text(
                                      user.specialty!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            DataCell(Text(user.cpf)),
                            DataCell(Text(user.email)),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: roleConfig['color'].withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  roleConfig['label'],
                                  style: TextStyle(
                                    color: roleConfig['color'],
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Switch(
                                value: user.isActive,
                                onChanged: (value) =>
                                    _toggleUserStatus(user.id),
                                activeColor: primaryColor,
                              ),
                            ),
                            DataCell(Text(_formatDate(user.lastLogin))),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {},
                                    icon: const Icon(Icons.edit, size: 18),
                                  ),
                                  IconButton(
                                    onPressed: () =>
                                        _showDeleteConfirmation(user),
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.red[600],
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configurações Gerais',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            _buildSettingSwitch(
              'Agendamento Automático',
              _generalSettings['autoScheduling']!,
              (val) => setState(() => _generalSettings['autoScheduling'] = val),
            ),
            _buildSettingSwitch(
              'Notificações por E-mail',
              _generalSettings['emailNotifications']!,
              (val) =>
                  setState(() => _generalSettings['emailNotifications'] = val),
            ),
            _buildSettingSwitch(
              'Backup Automático',
              _generalSettings['autoBackup']!,
              (val) => setState(() => _generalSettings['autoBackup'] = val),
            ),
            const Divider(height: 32),
            const Text(
              'Configurações de Segurança',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            _buildSettingSwitch(
              'Autenticação de Dois Fatores',
              _securitySettings['twoFactor']!,
              (val) => setState(() => _securitySettings['twoFactor'] = val),
            ),
            _buildSettingSwitch(
              'Registro de Auditoria',
              _securitySettings['auditLog']!,
              (val) => setState(() => _securitySettings['auditLog'] = val),
            ),
            _buildSettingSwitch(
              'Sessão Automática',
              _securitySettings['autoSession']!,
              (val) => setState(() => _securitySettings['autoSession'] = val),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingSwitch(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
      activeColor: primaryColor,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildReportsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Relatórios',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildReportCard('Relatório de Usuários', Icons.people, () {}),
                _buildReportCard(
                  'Relatório de Consultas',
                  Icons.event_note,
                  () {},
                ),
                _buildReportCard(
                  'Relatório Financeiro',
                  Icons.attach_money,
                  () {},
                ),
                _buildReportCard(
                  'Relatório de Atividades',
                  Icons.timeline,
                  () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        child: Container(
          width: 200,
          height: 120,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: primaryColor),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
