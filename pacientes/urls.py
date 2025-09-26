# pacientes/urls.py
from django.urls import path
from .views import PacienteCreateView

urlpatterns = [
    path('register/', PacienteCreateView.as_view(), name='paciente-register'),
]