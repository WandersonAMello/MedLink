# pacientes/urls.py

from django.urls import path
# 1. Importe a nova view que criamos
from .views import PacienteCreateView, PacientesDoDiaAPIView 

urlpatterns = [
    path('register/', PacienteCreateView.as_view(), name='paciente-register'),
    
    # 2. Adicione esta nova linha para a rota dos pacientes do dia
    path('hoje/', PacientesDoDiaAPIView.as_view(), name='pacientes-do-dia'),
]