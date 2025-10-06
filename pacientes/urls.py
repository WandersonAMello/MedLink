# pacientes/urls.py

from django.urls import path
# 1. Importe a View para LISTAR pacientes (o nome pode ser diferente no seu projeto)
from .views import PacienteCreateView, PacienteListView

urlpatterns = [
    # Rota para registrar um novo paciente
    path('register/', PacienteCreateView.as_view(), name='paciente-register'),

    # 👇 ROTA FALTANTE ADICIONADA AQUI 👇
    # Esta rota responde ao GET em /api/pacientes/ e retorna a lista
    path('', PacienteListView.as_view(), name='paciente-list'),
]