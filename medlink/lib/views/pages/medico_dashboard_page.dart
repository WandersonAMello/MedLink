import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/paciente_controller.dart';
import '../../models/paciente.dart';
import '../widgets/paciente_card.dart';
import '../../controllers/consulta_controller.dart';
import '../../models/consultas.dart' as consultas_model;
import '../../models/relatorio.dart';

class MedicoDashboardPage extends StatelessWidget {
  const MedicoDashboardPage({super.key});

  static const Color primaryBlue = Color(0xFF5BBCDC);
  static const Color accentGreen = Color(0xFF42A01C);
  static const Color bg = Color(0xFFF3F6F8);
  static const Color hoverColor = Color(0xFF4AA0C9);

  @override
  Widget build(BuildContext context) {
    final pacienteController = Provider.of<PacienteController>(context);
    final pacienteSelecionado = pacienteController.pacienteSelecionado;
    final historico = pacienteSelecionado.consultasHistoricas ?? [];
    final consultaController = ConsultaController();

    // Lista de relatórios de teste
    final historicoRelatorios = [
      Relatorio(titulo: 'Relatório 1', conteudo: 'Detalhes do relatório 1...'),
      Relatorio(titulo: 'Relatório 2', conteudo: 'Detalhes do relatório 2...'),
    ];

    final consultas_model.Consulta consultaSelecionada = 
        pacienteSelecionado.consultasHistoricas.isNotEmpty
            ? consultaController.getConsultaPorPaciente(pacienteSelecionado.id)
            : consultaController.consultas[0]; // fallback

    final today = DateTime.now();
    final formattedDate = "${today.day}/${today.month}/${today.year}";

    // Função para definir a cor do menu ativo
    Color menuTextColor(String menu) {
      return menu == "Dashboard" ? Colors.yellowAccent : Colors.white;
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        toolbarHeight: 60,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Logo
            Image.asset('assets/images/Logo2.png', height: 40),

            // Menu centralizado
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () {},
                  child: Text(
                    "Dashboard",
                    style: TextStyle(color: menuTextColor("Dashboard")),
                  ),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    "Agenda",
                    style: TextStyle(color: menuTextColor("Agenda")),
                  ),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    "Estatísticas",
                    style: TextStyle(color: menuTextColor("Estatísticas")),
                  ),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    "Configurações",
                    style: TextStyle(color: menuTextColor("Configurações")),
                  ),
                ),
              ],
            ),

            // Lado direito: notificações, perfil e botão sair
            Row(
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none, color: Colors.white)),
                const SizedBox(width: 12),
                const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.person, color: primaryBlue)),
                const SizedBox(width: 12),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text("Sair", style: TextStyle(color: Colors.white)),
                  style: ButtonStyle(overlayColor: MaterialStateProperty.all(hoverColor)),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------- Coluna esquerda ----------------
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 0, 12),
                child: Container(
                  width: 270,
                  decoration: BoxDecoration(
                    color: primaryBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Text(
                          "Pacientes do dia - $formattedDate",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Divider(color: Colors.white70, thickness: 1, height: 0),
                      // Lista de pacientes
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          itemCount: pacienteController.pacientes.length,
                          itemBuilder: (context, index) {
                            final p = pacienteController.pacientes[index];
                            return PatientCard(
                              paciente: p,
                              selected: index == pacienteController.selectedIndex,
                              onTap: () => pacienteController.selecionarPaciente(index),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: SizedBox(
                            width: 210,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(accentGreen),
                                overlayColor: MaterialStateProperty.resolveWith<Color?>(
                                  (Set<MaterialState> states) {
                                    if (states.contains(MaterialState.hovered)) {
                                      return Colors.greenAccent.withOpacity(0.3);
                                    }
                                    return null;
                                  },
                                ),
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                              ),
                              child: const Text("Reagendar dia", style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 15),

              // ---------------- Coluna central ----------------
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Column(
                    children: [
                      // Linha 1 → 2 blocos
                      Expanded(
                        flex: 225,
                        child: Row(
                          children: [
                            // Bloco 1 → Informações básicas do paciente
                            Flexible(
                              flex: 2,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: MedicoDashboardPage.primaryBlue,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const CircleAvatar(
                                        radius: 30,
                                        child: Icon(Icons.person, size: 40, color: MedicoDashboardPage.primaryBlue),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(pacienteSelecionado.nome,
                                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 6),
                                      Text(pacienteSelecionado.telefone,
                                          style: const TextStyle(color: Colors.white70)),
                                      const SizedBox(height: 4),
                                      Text(pacienteSelecionado.email,
                                          style: const TextStyle(color: Colors.white70)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            // Bloco 2 → Informações da consulta
                            Flexible(
                              flex: 1,
                              child: SizedBox(
                                width: 300,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: MedicoDashboardPage.primaryBlue,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Informações da Consulta",
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        "Data/Hora: ${DateFormat('dd/MM/yyyy HH:mm').format(
                                          DateTime(
                                            consultaSelecionada.data.year,
                                            consultaSelecionada.data.month,
                                            consultaSelecionada.data.day,
                                            consultaSelecionada.horario.hour,
                                            consultaSelecionada.horario.minute,
                                          ),
                                        )}",
                                        style: const TextStyle(color: Colors.white70),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "Especialidade: ${consultaSelecionada.especialidade}",
                                        style: const TextStyle(color: Colors.white70),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "Profissional: ${consultaSelecionada.profissional}",
                                        style: const TextStyle(color: Colors.white70),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Linha 2 → Anotações e Histórico de relatórios
                      Expanded(
                        flex: 300,
                        child: Row(
                          children: [
                            // Bloco 1 → Anotações
                            Flexible(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: MedicoDashboardPage.primaryBlue,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Anotações",
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    const SizedBox(height: 12),
                                    Expanded(
                                      child: TextField(
                                        maxLines: null,
                                        expands: true,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          hintText: "Digite suas anotações...",
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                        textAlignVertical: TextAlignVertical.top,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: ElevatedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(backgroundColor: MedicoDashboardPage.accentGreen),
                                        child: const Text("Salvar"),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            // Bloco 2 → Histórico de relatórios
                            Flexible(
                              flex: 1,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: MedicoDashboardPage.primaryBlue,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Histórico de relatórios",
                                      style: TextStyle(
                                          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    const SizedBox(height: 12),
                                    Expanded(
                                      child: ListView.builder(
                                        itemCount: historicoRelatorios.length,
                                        itemBuilder: (context, index) {
                                          final relatorio = historicoRelatorios[index];
                                          return ListTile(
                                            title: Text(
                                              relatorio.titulo,
                                              style: const TextStyle(color: Colors.white70),
                                            ),
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: Text(relatorio.titulo),
                                                  content: SingleChildScrollView(
                                                    child: Text(relatorio.conteudo),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.pop(context),
                                                      child: const Text("Fechar"),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Linha 3 → Histórico de consultas e botões
                      Expanded(
                        flex: 250,
                        child: Row(
                          children: [
                            // Bloco 1 → Histórico de consultas
                            Flexible(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: MedicoDashboardPage.primaryBlue,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Histórico de consultas",
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    const SizedBox(height: 12),
                                    Expanded(
                                      child: historico.isEmpty
                                          ? const Center(
                                              child: Text(
                                                "Sem consultas anteriores...",
                                                style: TextStyle(color: Colors.white70),
                                              ),
                                            )
                                          : ListView.builder(
                                              itemCount: historico.length,
                                              itemBuilder: (context, index) {
                                                final consulta = historico[index];
                                                return ListTile(
                                                  title: Text(
                                                    "Data/Hora: ${DateFormat('dd/MM/yyyy HH:mm').format(
                                                      DateTime(
                                                        consulta.data.year,
                                                        consulta.data.month,
                                                        consulta.data.day,
                                                        consulta.horario.hour,
                                                        consulta.horario.minute,
                                                      ),
                                                    )}",
                                                    style: const TextStyle(color: Colors.white70),
                                                  ),
                                                  subtitle: Text(
                                                    "Especialidade: ${consulta.especialidade}\nProfissional: ${consulta.profissional}",
                                                    style: const TextStyle(color: Colors.white70),
                                                  ),
                                                );
                                              },
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            // Bloco 2 → Botões
                            Flexible(
                              flex: 1,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: MedicoDashboardPage.primaryBlue,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        // Lógica para reagendar consulta
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: MedicoDashboardPage.accentGreen,
                                        minimumSize: const Size(double.infinity, 40),
                                      ),
                                      child: const Text("Reagendar Consulta"),
                                    ),
                                    const SizedBox(height: 12),
                                    ElevatedButton(
                                      onPressed: () {
                                        // Lógica para finalizar consulta
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent,
                                        minimumSize: const Size(double.infinity, 40),
                                      ),
                                      child: const Text("Finalizar Consulta"),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}