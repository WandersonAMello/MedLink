# users/admin.py

from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import User
from pacientes.models import Paciente
from medicos.models import Medico
from secretarias.models import Secretaria

# 1. Definição dos Inlines para os perfis
# Estes são os formulários que aparecerão na página de edição do User.

class MedicoInline(admin.StackedInline):
    model = Medico
    can_delete = False  # Não permitir que o perfil seja apagado
    verbose_name_plural = 'Perfil de Médico'
    fk_name = 'user'
    # Campos que aparecerão no inline
    fields = ('crm', 'especialidade', 'clinica', 'data_nascimento')

class SecretariaInline(admin.StackedInline):
    model = Secretaria
    can_delete = False
    verbose_name_plural = 'Perfil de Secretária'
    fk_name = 'user'
    # Campos que aparecerão no inline
    fields = ('clinica', 'data_nascimento')

@admin.register(User)
class CustomUserAdmin(UserAdmin):
    model = User
    
    # 2. Adicionar os inlines ao admin do User
    inlines = (MedicoInline, SecretariaInline,)

    list_display = ("cpf", "email", "get_full_name", "user_type", "is_staff", "is_active")
    list_filter = ("user_type", "is_staff", "is_superuser", "is_active", "groups")
    
    fieldsets = (
        (None, {"fields": ("cpf", "email", "password", "user_type")}),
        ("Informações pessoais", {"fields": ("first_name", "last_name")}),
        ("Permissões", {"fields": ("is_active", "is_staff", "is_superuser", "groups", "user_permissions")}),
        ("Datas importantes", {"fields": ("last_login", "date_joined")}),
    )
    
    add_fieldsets = (
        (None, {
            "classes": ("wide",),
            "fields": ("cpf", "email", "password", "password2", "user_type", "first_name", "last_name"),
        }),
    )
    
    search_fields = ("cpf", "email", "first_name", "last_name")
    ordering = ("cpf",)
    readonly_fields = ('last_login', 'date_joined')

    def get_inline_instances(self, request, obj=None):
        """
        Mostra os inlines apenas se o objeto User já existir e tiver o tipo correto.
        Isto evita mostrar os formulários de perfil na página de criação inicial.
        """
        if not obj:
            return list()
        
        # Mostra o inline correto com base no user_type
        if obj.user_type == 'MEDICO':
            return [inline(self.model, self.admin_site) for inline in [MedicoInline]]
        if obj.user_type == 'SECRETARIA':
            return [inline(self.model, self.admin_site) for inline in [SecretariaInline]]
            
        return super().get_inline_instances(request, obj)

    def save_model(self, request, obj, form, change):
        """
        Garante que, na criação (not change), um perfil vazio seja criado
        para que o inline possa ser exibido na página de edição.
        """
        super().save_model(request, obj, form, change)
        if not change: # Apenas na criação
            if obj.user_type == 'PACIENTE':
                Paciente.objects.get_or_create(user=obj)
            elif obj.user_type == 'MEDICO':
                Medico.objects.get_or_create(user=obj)
            elif obj.user_type == 'SECRETARIA':
                Secretaria.objects.get_or_create(user=obj)