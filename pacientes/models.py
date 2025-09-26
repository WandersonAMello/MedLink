# pacientes/models.py
from django.db import models
from users.models import User

# Modelo Paciente que herda do User
class Paciente(User):
    # Campos que já existem no User (email, etc)
    telefone = models.CharField(max_length=15)
    data_cadastro = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.get_full_name()

    def nome_completo(self):
        return f"{self.first_name} {self.last_name}"
    nome_completo.short_description = 'Nome Completo'

    class Meta:
        verbose_name = 'Paciente'
        verbose_name_plural = 'Pacientes'