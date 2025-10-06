# pacientes/views.py
from rest_framework import generics
from rest_framework.permissions import AllowAny # Importar a permissão
from .models import Paciente
from .serializers import PacienteSerializer

# View que permite criar pacientes
class PacienteCreateView(generics.CreateAPIView):
    queryset = Paciente.objects.all()
    serializer_class = PacienteSerializer
    permission_classes = [AllowAny] # Permite o cadastro sem autenticação

# pacientes/views.py

from rest_framework import generics, status
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.views import APIView
from rest_framework.response import Response
from django.utils import timezone
from .models import Paciente
from .serializers import PacienteSerializer
from agendamentos.models import Consulta # <-- 1. Importe o modelo Consulta
from users.permissions import IsMedicoOrSecretaria # <-- 2. Importe a permissão

# A sua view de criação continua a mesma
class PacienteCreateView(generics.CreateAPIView):
    queryset = Paciente.objects.all()
    serializer_class = PacienteSerializer
    permission_classes = [AllowAny]


# --- ADICIONE ESTA NOVA CLASSE ABAIXO ---

class PacientesDoDiaAPIView(APIView):
    """
    View para listar os pacientes que têm consulta no dia atual
    para o médico que está logado.
    """
    permission_classes = [IsAuthenticated, IsMedicoOrSecretaria] # Garante que apenas usuários logados (médicos/secretárias) acessem

    def get(self, request, *args, **kwargs):
        # Pega o usuário (médico) que fez a requisição
        medico = request.user
        
        # Define o início e o fim do dia atual
        hoje_inicio = timezone.now().replace(hour=0, minute=0, second=0, microsecond=0)
        hoje_fim = hoje_inicio + timezone.timedelta(days=1)
        
        # Filtra as consultas do médico logado que ocorrem hoje
        consultas_de_hoje = Consulta.objects.filter(
            medico=medico,
            data_hora__gte=hoje_inicio,
            data_hora__lt=hoje_fim
        ).order_by('data_hora')
        
        # Extrai os pacientes únicos dessas consultas
        # Usamos um dicionário para garantir que cada paciente apareça apenas uma vez,
        # mesmo que tenha mais de uma consulta no dia.
        pacientes_com_horario = {}
        for consulta in consultas_de_hoje:
            if consulta.paciente not in pacientes_com_horario:
                 # Armazena o paciente e os dados da sua primeira consulta do dia
                pacientes_com_horario[consulta.paciente] = {
                    "horario": consulta.data_hora,
                    "status": consulta.status_atual
                }

        # Prepara os dados para o serializador
        dados_serializaveis = []
        for paciente, dados_consulta in pacientes_com_horario.items():
            # Usa o serializer de Paciente para obter os dados básicos do paciente
            paciente_data = PacienteSerializer(paciente).data
            # Adiciona os dados específicos da consulta do dia
            paciente_data['horario'] = dados_consulta['horario']
            paciente_data['status'] = dados_consulta['status']
            dados_serializaveis.append(paciente_data)
            
        return Response(dados_serializaveis, status=status.HTTP_200_OK)