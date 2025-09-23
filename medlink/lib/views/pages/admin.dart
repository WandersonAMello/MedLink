import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
}

enum UserRole { secretary, doctor, admin, financial, patient }

class AdminDashboard extends StatefulWidget {
  final VoidCallback? onLogout;

  const AdminDashboard({Key? key, this.onLogout}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _searchTerm = '';
  UserRole? _filterRole;
  AdminUser? _selectedUser;

  // Mock data - usuários para demonstração
  final List<AdminUser> _users = [
    AdminUser(
      id: '1',
      name: 'Ana Silva',
      cpf: '111.444.777-35',
      email: 'ana.silva@medlink.com',
      role: UserRole.secretary,
      isActive: true,
      createdAt: DateTime(2024, 1, 10),
      lastLogin: DateTime(2024, 1, 20),
    ),
    AdminUser(
      id: '2',
      name: 'Dr. João Santos',
      cpf: '123.456.789-09',
      email: 'joao.santos@medlink.com',
      role: UserRole.doctor,
      specialty: 'Cardiologia',
      crm: 'CRM-SP 123456',
      isActive: true,
      createdAt: DateTime(2024, 1, 8),
      lastLogin: DateTime(2024, 1, 21),
    ),
    AdminUser(
      id: '3',
      name: 'Dra. Maria Costa',
      cpf: '987.654.321-00',
      email: 'maria.costa@medlink.com',
      role: UserRole.doctor,
      specialty: 'Dermatologia',
      crm: 'CRM-SP 654321',
      isActive: true,
      createdAt: DateTime(2024, 1, 12),
      lastLogin: DateTime(2024, 1, 19),
    ),
    AdminUser(
      id: '4',
      name: 'Carlos Admin',
      cpf: '222.333.444-56',
      email: 'admin@medlink.com',
      role: UserRole.admin,
      isActive: true,
      createdAt: DateTime(2024, 1, 14),
      lastLogin: DateTime(2024, 1, 21),
    ),
    AdminUser(
      id: '5',
      name: 'Paula Financeiro',
      cpf: '333.444.555-68',
      email: 'financeiro@medlink.com',
      role: UserRole.financial,
      isActive: true,
      createdAt: DateTime(2024, 1, 15),
      lastLogin: DateTime(2024, 1, 18),
    ),
    AdminUser(
      id: '6',
      name: 'Roberto Paciente',
      cpf: '444.555.666-79',
      email: 'roberto@email.com',
      role: UserRole.patient,
      isActive: false,
      createdAt: DateTime(2024, 1, 16),
      lastLogin: DateTime(2024, 1, 17),
    ),
  ];

  // Configurações do sistema
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
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Cores do tema médico
  static const Color primaryColor = Color(0xFF0891B2);
  static const Color secondaryColor = Color(0xFF67E8F9);
  static const Color accentColor = Color(0xFFE0F2FE);
  static const Color backgroundColor = Color(0xFFF8FAFC);

  // Filtrar usuários
  List<AdminUser> get _filteredUsers {
    return _users.where((user) {
      final matchesSearch =
          user.name.toLowerCase().contains(_searchTerm.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchTerm.toLowerCase()) ||
          user.cpf.contains(_searchTerm);
      final matchesRole = _filterRole == null || user.role == _filterRole;
      return matchesSearch && matchesRole;
    }).toList();
  }

  // Estatísticas
  Map<String, int> get _stats {
    return {
      'total': _users.length,
      'active': _users.where((u) => u.isActive).length,
      'doctors': _users.where((u) => u.role == UserRole.doctor).length,
      'secretaries': _users.where((u) => u.role == UserRole.secretary).length,
      'patients': _users.where((u) => u.role == UserRole.patient).length,
    };
  }

  // Configuração de badges por role
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

  // Toggle status do usuário
  void _toggleUserStatus(String userId) {
    setState(() {
      final userIndex = _users.indexWhere((u) => u.id == userId);
      if (userIndex != -1) {
        _users[userIndex].isActive = !_users[userIndex].isActive;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Status do usuário atualizado'),
        backgroundColor: primaryColor,
      ),
    );
  }

  // Confirmar exclusão
  void _showDeleteConfirmation(AdminUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red[600]),
            SizedBox(width: 8),
            Text('Confirmar Exclusão'),
          ],
        ),
        content: Text(
          'Tem certeza que deseja remover o usuário ${user.name}? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteUser(user.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              'Confirmar Exclusão',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Deletar usuário
  void _deleteUser(String userId) {
    setState(() {
      _users.removeWhere((u) => u.id == userId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Usuário removido com sucesso'),
        backgroundColor: primaryColor,
      ),
    );
  }

  // Formatar data
  String _formatDate(DateTime? date) {
    if (date == null) return 'Nunca';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
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
                Expanded(child: _buildTabSection()),
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
                  'Carlos Admin',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  'Administrador',
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
            'Total Usuários',
            _stats['total']!,
            Icons.people,
            primaryColor,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Ativos',
            _stats['active']!,
            Icons.check_circle,
            Colors.green,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Médicos',
            _stats['doctors']!,
            Icons.local_hospital,
            Colors.blue,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Secretárias',
            _stats['secretaries']!,
            Icons.admin_panel_settings,
            Colors.green,
          ),
        ),
        SizedBox(width: 16),
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

  // Seção de abas
  Widget _buildTabSection() {
    return Card(
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: primaryColor,
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: primaryColor,
            tabs: [
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

  // Aba de usuários
  Widget _buildUsersTab() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
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
                onPressed: () {
                  // Implementar novo usuário
                },
                icon: Icon(Icons.add),
                label: Text('Novo Usuário'),
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Filtros
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar por nome, email ou CPF...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchTerm = value;
                    });
                  },
                ),
              ),
              SizedBox(width: 16),
              SizedBox(
                width: 200,
                child: DropdownButtonFormField<UserRole?>(
                  value: _filterRole,
                  decoration: InputDecoration(
                    labelText: 'Filtrar por tipo',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text('Todos os tipos'),
                    ),
                    DropdownMenuItem(
                      value: UserRole.admin,
                      child: Text('Administrador'),
                    ),
                    DropdownMenuItem(
                      value: UserRole.doctor,
                      child: Text('Médico'),
                    ),
                    DropdownMenuItem(
                      value: UserRole.secretary,
                      child: Text('Secretária'),
                    ),
                    DropdownMenuItem(
                      value: UserRole.financial,
                      child: Text('Financeiro'),
                    ),
                    DropdownMenuItem(
                      value: UserRole.patient,
                      child: Text('Paciente'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _filterRole = value;
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Tabela
          Expanded(
            child: SingleChildScrollView(
              child: DataTable(
                columnSpacing: 16,
                columns: [
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
                              style: TextStyle(fontWeight: FontWeight.w500),
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
                          padding: EdgeInsets.symmetric(
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
                        Row(
                          children: [
                            Switch(
                              value: user.isActive,
                              onChanged: (value) => _toggleUserStatus(user.id),
                              activeColor: primaryColor,
                            ),
                            Text(
                              user.isActive ? 'Ativo' : 'Inativo',
                              style: TextStyle(
                                color: user.isActive
                                    ? Colors.green
                                    : Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      DataCell(Text(_formatDate(user.lastLogin))),
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                // Implementar edição
                              },
                              icon: Icon(Icons.edit, size: 18),
                            ),
                            IconButton(
                              onPressed: () => _showDeleteConfirmation(user),
                              icon: Icon(
                                Icons.delete,
                                color: Colors.red,
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

  // Aba de configurações
  Widget _buildSettingsTab() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.settings, color: primaryColor),
              SizedBox(width: 8),
              Text(
                'Configurações do Sistema',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 24),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Configurações Gerais
              Expanded(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Configurações Gerais',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        SizedBox(height: 16),
                        _buildSettingSwitch(
                          'Permitir auto-agendamento',
                          _generalSettings['autoScheduling']!,
                          (value) => setState(
                            () => _generalSettings['autoScheduling'] = value,
                          ),
                        ),
                        _buildSettingSwitch(
                          'Notificações por email',
                          _generalSettings['emailNotifications']!,
                          (value) => setState(
                            () =>
                                _generalSettings['emailNotifications'] = value,
                          ),
                        ),
                        _buildSettingSwitch(
                          'Backup automático',
                          _generalSettings['autoBackup']!,
                          (value) => setState(
                            () => _generalSettings['autoBackup'] = value,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(width: 16),

              // Configurações de Segurança
              Expanded(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Segurança',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        SizedBox(height: 16),
                        _buildSettingSwitch(
                          'Autenticação 2FA',
                          _securitySettings['twoFactor']!,
                          (value) => setState(
                            () => _securitySettings['twoFactor'] = value,
                          ),
                        ),
                        _buildSettingSwitch(
                          'Log de auditoria',
                          _securitySettings['auditLog']!,
                          (value) => setState(
                            () => _securitySettings['auditLog'] = value,
                          ),
                        ),
                        _buildSettingSwitch(
                          'Sessão automática',
                          _securitySettings['autoSession']!,
                          (value) => setState(
                            () => _securitySettings['autoSession'] = value,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Configurações salvas com sucesso'),
                  backgroundColor: primaryColor,
                ),
              );
            },
            child: Text('Salvar Configurações'),
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingSwitch(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Switch(value: value, onChanged: onChanged, activeColor: primaryColor),
        ],
      ),
    );
  }

  // Aba de relatórios
  Widget _buildReportsTab() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: primaryColor),
              SizedBox(width: 8),
              Text(
                'Relatórios do Sistema',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 24),

          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildReportCard('Relatório de Usuários', Icons.people, () {}),
              _buildReportCard('Atividade do Sistema', Icons.analytics, () {}),
              _buildReportCard('Log de Segurança', Icons.security, () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(String title, IconData icon, VoidCallback onTap) {
    return SizedBox(
      width: 200,
      height: 120,
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 32, color: primaryColor),
                SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
