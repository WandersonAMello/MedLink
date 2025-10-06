# pacientes/views.py (VERSÃO CORRIGIDA)

from rest_framework import generics, status
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.views import APIView
from rest_framework.response import Response
from django.utils import timezone
from .models import Paciente
from .serializers import PacienteSerializer
from agendamentos.models import Consulta
from users.permissions import IsMedicoOrSecretaria

# View para criar pacientes
class PacienteCreateView(generics.CreateAPIView):
    queryset = Paciente.objects.all()
    serializer_class = PacienteSerializer
    permission_classes = [AllowAny]


# --- CLASSE ATUALIZADA PARA INCLUIR DADOS DA CONSULTA ---

class PacientesDoDiaAPIView(APIView):
    """
    View para listar os pacientes que têm consulta no dia atual
    para o médico que está logado.
    """
    permission_classes = [IsAuthenticated, IsMedicoOrSecretaria]

    def get(self, request, *args, **kwargs):
        medico = request.user
        hoje = timezone.now().date()
        
        consultas_de_hoje = Consulta.objects.filter(
            medico=medico,
            data_hora__date=hoje
        ).select_related('paciente__user', 'medico__perfil_medico').order_by('data_hora') # Otimização da query
        
        pacientes_com_horario = {}
        for consulta in consultas_de_hoje:
            if consulta.paciente not in pacientes_com_horario:
                # Armazena o paciente e os dados da sua primeira consulta do dia
                pacientes_com_horario[consulta.paciente] = {
                    "horario": consulta.data_hora,
                    "status": consulta.status_atual,
                    # --- NOVOS CAMPOS ADICIONADOS ---
                    "profissional": consulta.medico.get_full_name(),
                    "especialidade": consulta.medico.perfil_medico.get_especialidade_display()
                }

        dados_serializaveis = []
        for paciente, dados_consulta in pacientes_com_horario.items():
            paciente_data = PacienteSerializer(paciente).data
            # Adiciona os dados específicos da consulta do dia
            paciente_data['horario'] = dados_consulta['horario']
            paciente_data['status'] = dados_consulta['status']
            # --- NOVOS CAMPOS ADICIONADOS ---
            paciente_data['profissional'] = dados_consulta['profissional']
            paciente_data['especialidade'] = dados_consulta['especialidade']
            dados_serializaveis.append(paciente_data)
            
        return Response(dados_serializaveis, status=status.HTTP_200_OK)