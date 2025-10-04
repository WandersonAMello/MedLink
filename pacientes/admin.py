# pacientes/admin.py
from django.contrib import admin
from .models import Paciente

@admin.register(Paciente)
class PacienteAdmin(admin.ModelAdmin):
    # 1. Atualize o list_display para usar os nomes dos métodos que vamos criar
    list_display = ('get_nome_completo', 'get_cpf', 'telefone', 'get_email', 'data_cadastro')

    # 2. Atualize o search_fields para seguir a relação com o User
    search_fields = ('user__first_name', 'user__last_name', 'user__cpf', 'user__email')

    # 3. Crie métodos para obter os dados do modelo User relacionado
    @admin.display(description='Nome Completo', ordering='user__first_name')
    def get_nome_completo(self, obj):
        # obj é a instância de Paciente
        return obj.user.get_full_name()

    @admin.display(description='CPF', ordering='user__cpf')
    def get_cpf(self, obj):
        return obj.user.cpf

    @admin.display(description='Email', ordering='user__email')
    def get_email(self, obj):
        return obj.user.email