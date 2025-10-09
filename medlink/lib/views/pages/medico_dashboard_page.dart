// lib/views/pages/medico_dashboard_page.dart (VERSÃO ATUALIZADA)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/paciente_controller.dart';
import '../../models/paciente.dart';
import '../widgets/paciente_card.dart';
import '../../models/relatorio.dart';
import '../widgets/medico_app_bar.dart'; // <-- 1. IMPORTE A NOSSA APPBAR

class MedicoDashboardPage extends StatelessWidget {
  const MedicoDashboardPage({super.key});

  static const Color primaryBlue = Color(0xFF5BBCDC);
  static const Color accentGreen = Color(0xFF42A01C);
  static const Color bg = Color(0xFFF3F6F8);
  static const Color hoverColor = Color(0xFF4AA0C9);

  @override
  Widget build(BuildContext context) {
    final pacienteController = context.watch<PacienteController>();
    final today = DateTime.now();
    final formattedDate = DateFormat('dd/MM/yyyy').format(today);

    return Scaffold(
      backgroundColor: bg,
      // 2. SUBSTITUA O APPBAR ANTIGO POR ESTE
      appBar: const MedicoAppBar(activePage: "Dashboard"),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Coluna da esquerda (lista de pacientes) - SEM ALTERAÇÕES
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Text(
                          "Pacientes do dia - $formattedDate",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Divider(
                        color: Colors.white70,
                        thickness: 1,
                        height: 0,
                      ),
                      Expanded(child: buildPacientesList(pacienteController)),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: SizedBox(
                            width: 210,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                  accentGreen,
                                ),
                                overlayColor:
                                    MaterialStateProperty.resolveWith<Color?>(
                                        (states) {
                                  if (states.contains(MaterialState.hovered))
                                    return Colors.greenAccent.withOpacity(0.3);
                                  return null;
                                }),
                                shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              child: const Text(
                                "Reagendar dia",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 15),

              // Coluna central (detalhes do paciente) - SEM ALTERAÇÕES
              Expanded(
                child: pacienteController.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : pacienteController.pacienteSelecionado == null
                        ? Center(
                            child: Text(
                              pacienteController.errorMessage ??
                                  'Nenhum paciente para exibir.',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : buildDashboardContent(
                            context,
                            pacienteController.pacienteSelecionado!,
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // O resto do ficheiro (buildPacientesList, buildDashboardContent) continua exatamente igual...
  Widget buildPacientesList(PacienteController controller) {
    // ... CÓDIGO SEM ALTERAÇÕES ...
    if (controller.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    if (controller.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            'Erro ao carregar: ${controller.errorMessage}',
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    if (controller.pacientes.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum paciente para hoje.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      itemCount: controller.pacientes.length,
      itemBuilder: (context, index) {
        final p = controller.pacientes[index];
        return PatientCard(
          paciente: p,
          selected: index == controller.selectedIndex,
          onTap: () => controller.selecionarPaciente(index),
        );
      },
    );
  }

  Widget buildDashboardContent(
    BuildContext context,
    Paciente pacienteSelecionado,
  ) {
    // ... CÓDIGO SEM ALTERAÇÕES ...
    final historico = pacienteSelecionado.consultasHistoricas;

    final historicoRelatorios = [
      Relatorio(
        titulo: 'Relatório Exemplo 1',
        conteudo: 'Conteúdo do relatório 1...',
      ),
      Relatorio(
        titulo: 'Relatório Exemplo 2',
        conteudo: 'Conteúdo do relatório 2...',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Column(
        children: [
          Expanded(
            flex: 225,
            child: Row(
              children: [
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
                            child: Icon(
                              Icons.person,
                              size: 40,
                              color: MedicoDashboardPage.primaryBlue,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            pacienteSelecionado.nome,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            pacienteSelecionado.telefone,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            pacienteSelecionado.email,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                SizedBox(
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
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Data/Hora: ${DateFormat('dd/MM/yyyy HH:mm').format(pacienteSelecionado.horario)}",
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Especialidade: ${pacienteSelecionado.especialidade}",
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Profissional: ${pacienteSelecionado.profissional}",
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
            flex: 300,
            child: Row(
              children: [
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
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Expanded(
                          child: TextField(
                            maxLines: null,
                            expands: true,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: "Digite suas anotações...",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8),
                                ),
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
                            style: ElevatedButton.styleFrom(
                              backgroundColor: MedicoDashboardPage.accentGreen,
                            ),
                            child: const Text("Salvar"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 15),
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
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
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
                                onTap: () => showDialog(
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
                                ),
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
          Expanded(
            flex: 250,
            child: Row(
              children: [
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
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
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
                                        "Data/Hora: ${DateFormat('dd/MM/yyyy HH:mm').format(consulta.horario)}",
                                        style: const TextStyle(
                                          color: Colors.white70,
                                        ),
                                      ),
                                      subtitle: Text(
                                        "Especialidade: ${consulta.especialidade}\nProfissional: ${consulta.profissional}",
                                        style: const TextStyle(
                                          color: Colors.white70,
                                        ),
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
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MedicoDashboardPage.accentGreen,
                            minimumSize: const Size(double.infinity, 40),
                          ),
                          child: const Text("Reagendar Consulta"),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {},
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
    );
  }
}