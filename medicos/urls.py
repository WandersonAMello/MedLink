# medicos/urls.py

from django.urls import path
# 1. Importe a View para LISTAR médicos (o nome pode ser diferente)
from .views import MedicoAgendaAPIView, SolicitarReagendamentoAPIView, MedicoListView

urlpatterns = [
    # Suas rotas existentes
    path('agenda/', MedicoAgendaAPIView.as_view(), name='medico-agenda'),
    path('consultas/<int:pk>/solicitar-reagendamento/', SolicitarReagendamentoAPIView.as_view(), name='solicitar-reagendamento'),
    
    # 👇 ROTA FALTANTE ADICIONADA AQUI 👇
    # Esta rota responde ao GET em /api/medicos/ e retorna a lista
    path('', MedicoListView.as_view(), name='medico-list'),
]