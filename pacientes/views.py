# pacientes/views.py (VERSÃO CORRIGIDA E SIMPLIFICADA)

from rest_framework import generics, status
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.views import APIView
from rest_framework.response import Response
from django.utils import timezone
from .models import Paciente
from agendamentos.models import Consulta
from users.permissions import IsMedicoOrSecretaria
from .serializers import PacienteCreateSerializer # <--- Importa o serializer correto

# View para CRIAR pacientes (não muda)
class PacienteCreateView(generics.CreateAPIView):
    queryset = Paciente.objects.all()
    serializer_class = PacienteCreateSerializer
    permission_classes = [AllowAny]

# View para LISTAR todos os pacientes (não muda)
class PacienteListView(generics.ListAPIView):
    queryset = Paciente.objects.select_related('user').all()
    serializer_class = PacienteCreateSerializer
    permission_classes = [IsAuthenticated]


# --- VIEW DOS PACIENTES DO DIA (CORRIGIDA) ---

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
        ).select_related('paciente__user', 'medico__perfil_medico').order_by('data_hora')
        
        # Extrai a lista de pacientes a partir das consultas
        pacientes_de_hoje = [consulta.paciente for consulta in consultas_de_hoje]

        # Usa o PacienteCreateSerializer para formatar a resposta
        # O método to_representation dele já cria o JSON "plano" que o Flutter espera
        serializer = PacienteCreateSerializer(pacientes_de_hoje, many=True)
            
        # Adiciona manualmente os dados da consulta que não estão no serializer
        dados_finais = []
        for i, paciente_data in enumerate(serializer.data):
            consulta_correspondente = consultas_de_hoje[i]
            paciente_data['horario'] = consulta_correspondente.data_hora
            paciente_data['status'] = consulta_correspondente.status_atual
            paciente_data['profissional'] = consulta_correspondente.medico.get_full_name()
            paciente_data['especialidade'] = consulta_correspondente.medico.perfil_medico.get_especialidade_display()
            dados_finais.append(paciente_data)

        return Response(dados_finais, status=status.HTTP_200_OK)