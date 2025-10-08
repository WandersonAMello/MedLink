# pacientes/urls.py (VERSÃO CORRIGIDA)

from django.urls import path
from .views import PacienteCreateView, PacienteListView, PacientesDoDiaAPIView 

urlpatterns = [
    # Rota para registrar um novo paciente
    path('register/', PacienteCreateView.as_view(), name='paciente-register'),

    # Rota que retorna a lista de TODOS os pacientes
    path('', PacienteListView.as_view(), name='paciente-list'),
    
    # Rota que retorna a lista de pacientes do DIA para o médico
    path('hoje/', PacientesDoDiaAPIView.as_view(), name='pacientes-do-dia'),
]