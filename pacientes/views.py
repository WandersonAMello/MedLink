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