# users/admin.py

from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import User

@admin.register(User)
class CustomUserAdmin(UserAdmin):
    model = User
    # Campos a serem exibidos na lista de usuários
    list_display = ("cpf", "email", "first_name", "last_name", "user_type", "is_staff")
    list_filter = ("user_type", "is_staff", "is_superuser", "is_active", "groups")
    
    # Campos para a edição de um usuário
    fieldsets = (
        (None, {"fields": ("cpf", "email", "password", "user_type")}),
        ("Informações pessoais", {"fields": ("first_name", "last_name")}),
        ("Permissões", {"fields": ("is_active", "is_staff", "is_superuser", "groups", "user_permissions")}),
        ("Datas importantes", {"fields": ("last_login", "date_joined")}),
    )
    
    # Campos para a criação de um novo usuário
    add_fieldsets = (
        (None, {
            "classes": ("wide",),
            "fields": ("cpf", "email", "password", "password2", "user_type", "first_name", "last_name", "is_staff", "is_superuser", "is_active"),
        }),
    )
    
    # Campos de busca e ordenação
    search_fields = ("cpf", "email", "first_name", "last_name")
    ordering = ("cpf",)
    
    # Definindo os campos que são apenas para leitura
    readonly_fields = ('last_login', 'date_joined')