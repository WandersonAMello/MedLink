# pacientes/models.py
from django.db import models

class Paciente(models.Model):
    # Campos básicos do paciente
    nome_completo = models.CharField(max_length=255)
    data_nascimento = models.DateField()
    cpf = models.CharField(max_length=11, unique=True)
    telefone = models.CharField(max_length=15, blank=True)
    
    # Campo para registrar quando o paciente foi cadastrado
    data_cadastro = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.nome_completo