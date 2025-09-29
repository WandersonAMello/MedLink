# medicos/urls.py

from django.urls import path
from .views import MedicoAgendaAPIView, SolicitarReagendamentoAPIView

urlpatterns = [
    # Rota para a US005
    path('agenda/', MedicoAgendaAPIView.as_view(), name='medico-agenda'),

    # Rota para a US006
    path('consultas/<int:pk>/solicitar-reagendamento/', SolicitarReagendamentoAPIView.as_view(), name='solicitar-reagendamento'),
]