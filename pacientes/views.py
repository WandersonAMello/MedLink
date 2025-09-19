# pacientes/views.py (Versão Correta)

from rest_framework import generics
from .models import Paciente
from .serializers import PacienteSerializer # <-- Garanta que esta linha está correta
from users.permissions import IsMedicoOrSecretaria 

class PacienteListView(generics.ListAPIView):
    queryset = Paciente.objects.all()
    serializer_class = PacienteSerializer
    permission_classes = [IsMedicoOrSecretaria]