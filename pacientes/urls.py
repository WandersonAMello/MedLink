# pacientes/urls.py

from django.urls import path
# 1. Importe a View para LISTAR pacientes (o nome pode ser diferente no seu projeto)
from .views import PacienteCreateView, PacienteListView
# 1. Importe a nova view que criamos
from .views import PacienteCreateView, PacientesDoDiaAPIView 

urlpatterns = [
    # Rota para registrar um novo paciente
    path('register/', PacienteCreateView.as_view(), name='paciente-register'),

    # 👇 ROTA FALTANTE ADICIONADA AQUI 👇
    # Esta rota responde ao GET em /api/pacientes/ e retorna a lista
    path('', PacienteListView.as_view(), name='paciente-list'),
    
    # 2. Adicione esta nova linha para a rota dos pacientes do dia
    path('hoje/', PacientesDoDiaAPIView.as_view(), name='pacientes-do-dia'),
]