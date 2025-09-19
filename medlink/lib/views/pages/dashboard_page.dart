import 'package:flutter/material.dart';

// Classe principal da tela, que constrói o layout geral
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold é a base para a maioria das telas no Material Design
    return const Scaffold(
      backgroundColor: Color(0xFFF5F5F5), // exemplo de cinza claro
      body: Row(
        children: [
          // A barra lateral ocupa uma largura fixa
          _Sidebar(),
          // O conteúdo principal ocupa o resto do espaço
          Expanded(child: MainContent()),
        ],
      ),
    );
  }
}

// Widget privado para a barra lateral de navegação
class _Sidebar extends StatelessWidget {
  const _Sidebar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: Colors.white,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.only(bottom: 32.0),
            child: Image.asset('assets/images/Logo.png', height: 40),
          ),

          // Itens de Navegação
          const _NavigationLink(
            icon: Icons.dashboard,
            label: 'Dashboard',
            isActive: true,
          ),
          const _NavigationLink(
            icon: Icons.calendar_today,
            label: 'Agendamentos',
          ),
          const _NavigationLink(icon: Icons.group, label: 'Pacientes'),
          const _NavigationLink(
            icon: Icons.medical_services,
            label: 'Profissionais',
          ),
          const _NavigationLink(icon: Icons.bar_chart, label: 'Relatórios'),

          // Espaçador para empurrar o rodapé para baixo
          const Spacer(),

          // Rodapé com informações do usuário
          const Divider(height: 32),
          const Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ana da Silva',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Secretária',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              Spacer(),
              Icon(Icons.logout, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }
}

// Widget privado para criar os links de navegação
class _NavigationLink extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;

  const _NavigationLink({
    required this.icon,
    required this.label,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF1D80A1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isActive ? Colors.white : Colors.grey.shade600,
            size: 24,
          ),
          const SizedBox(width: 16.0),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget para o conteúdo principal da página
class MainContent extends StatelessWidget {
  const MainContent({super.key});

  @override
  Widget build(BuildContext context) {
    // SingleChildScrollView permite que o conteúdo role se for maior que a tela
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header com a barra de pesquisa e botão
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Barra de Pesquisa
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Pesquisar por paciente...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24.0),
              // Botão Novo Agendamento
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Novo Agendamento',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D80A1),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32.0),

          // Cards de Estatísticas
          const Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Hoje',
                  value: '12',
                  icon: Icons.calendar_today,
                  iconColor: Color(0xFF1D80A1),
                  bgColor: Color(0xFFE6F7FF),
                ),
              ),
              SizedBox(width: 24.0),
              Expanded(
                child: _StatCard(
                  title: 'Confirmadas',
                  value: '8',
                  icon: Icons.check_circle,
                  iconColor: Color(0xFF00A97E),
                  bgColor: Color(0xFFE6FFFA),
                ),
              ),
              SizedBox(width: 24.0),
              Expanded(
                child: _StatCard(
                  title: 'Pendentes',
                  value: '2',
                  icon: Icons.hourglass_top,
                  iconColor: Color(0xFFFFC53D),
                  bgColor: Color(0xFFFFFBE6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32.0),

          // Widget da Agenda do Dia
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Agenda de Hoje',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'terça-feira, 16 de setembro de 2025',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24.0),
                // Exemplo de Agendamento Pendente
                _AppointmentItemCard(
                  time: '15:00',
                  patient: 'Ana Costa',
                  doctor: 'Dra. Maria Souza',
                  status: 'Pendente',
                ),
                const Divider(height: 24.0),
                // Exemplo de Agendamento Confirmado
                _AppointmentItemCard(
                  time: '14:00',
                  patient: 'Carlos Oliveira',
                  doctor: 'Dr. João Silva',
                  status: 'Confirmado',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget para os cards de estatísticas
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: bgColor,
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey)),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Widget para cada item da lista de agendamento
class _AppointmentItemCard extends StatelessWidget {
  final String time;
  final String patient;
  final String doctor;
  final String status;

  const _AppointmentItemCard({
    required this.time,
    required this.patient,
    required this.doctor,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = status == 'Pendente';
    final statusColor = isPending
        ? const Color(0xFFD4A017)
        : const Color(0xFF00A97E);
    final statusBgColor = isPending
        ? const Color(0xFFFFFBE6)
        : const Color(0xFFE6FFFA);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              time,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D80A1),
              ),
            ),
            const SizedBox(width: 24.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  doctor,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(width: 24.0),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: statusBgColor,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),

        // Botões de Ação
        Row(
          children: [
            if (isPending) ...[
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Confirmar',
                  style: TextStyle(color: Color(0xFF00A97E)),
                ),
              ),
              const SizedBox(width: 8),
            ],
            TextButton(
              onPressed: () {},
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.red),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.edit, color: Color(0xFF1D80A1)),
            ),
          ],
        ),
      ],
    );
  }
}
