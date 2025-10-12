# medicos/admin.py
from django.contrib import admin
from .models import Medico

@admin.register(Medico)
class MedicoAdmin(admin.ModelAdmin):
    # Exibe colunas com informações do perfil e do usuário associado
    list_display = (
        'get_full_name',
        'crm',
        'especialidade',
        'clinica',
        'get_email',
        'data_nascimento',  # Campo adicionado para visualização rápida
        'get_user_is_active'
    )

    # Adiciona filtros na lateral direita da tela (já otimizado)
    list_filter = ('especialidade', 'clinica', 'user__is_active')

    # Adiciona um campo de busca (já otimizado)
    search_fields = (
        'user__first_name',
        'user__last_name',
        'crm',
        'user__email'
    )

    # Melhora a performance de seleção de chaves estrangeiras
    raw_id_fields = ('user', 'clinica')
    
    # Adicionando campos que não devem ser editados diretamente aqui
    readonly_fields = ('user',)

    # Métodos para obter dados do modelo 'User' relacionado (já otimizados)
    @admin.display(description='Nome Completo', ordering='user__first_name')
    def get_full_name(self, obj):
        return obj.user.get_full_name()

    @admin.display(description='Email', ordering='user__email')
    def get_email(self, obj):
        return obj.user.email
    
    @admin.display(description='Usuário Ativo?', ordering='user__is_active', boolean=True)
    def get_user_is_active(self, obj):
        return obj.user.is_active