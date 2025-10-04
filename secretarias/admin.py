# secretarias/admin.py
from django.contrib import admin
from .models import Secretaria

@admin.register(Secretaria)
class SecretariaAdmin(admin.ModelAdmin):
    """
    Configuração da interface de administração para o perfil de Secretária.
    """
    
    # Colunas exibidas na lista de secretárias
    list_display = (
        'get_full_name', 
        'clinica',
        'get_email',
        'get_user_is_active'
    )

    # Filtro por clínica
    list_filter = ('clinica',)

    # Campos de busca
    search_fields = (
        'user__first_name', 
        'user__last_name', 
        'user__email',
        'clinica__nome_fantasia'
    )

    # Campo de busca para chaves estrangeiras
    raw_id_fields = ('user', 'clinica')

    # Métodos para buscar dados do modelo User
    @admin.display(description='Nome Completo', ordering='user__first_name')
    def get_full_name(self, obj):
        return obj.user.get_full_name()

    @admin.display(description='Email', ordering='user__email')
    def get_email(self, obj):
        return obj.user.email

    @admin.display(description='Usuário Ativo?', ordering='user__is_active', boolean=True)
    def get_user_is_active(self, obj):
        return obj.user.is_active
