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

from rest_framework.generics import ListAPIView
from rest_framework.permissions import IsAuthenticated
from .models import Paciente
from .serializers import PacienteSerializer

# ... (sua PacienteCreateView continua aqui) ...


# 👇 ADICIONE ESTA NOVA VIEW 👇
class PacienteListView(ListAPIView):
    """
    View para listar todos os pacientes.
    Acessível apenas por usuários autenticados.
    """
    queryset = Paciente.objects.select_related('user').all()
    serializer_class = PacienteSerializer
    permission_classes = [IsAuthenticated]