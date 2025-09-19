# users/permissions.py
from rest_framework.permissions import BasePermission

class IsMedicoOrSecretaria(BasePermission):
    """
    Permissão customizada para permitir acesso apenas para usuários
    do tipo MÉDICO ou SECRETÁRIA.
    """

    def has_permission(self, request, view):
        # Verifica se o usuário está autenticado
        if not request.user or not request.user.is_authenticated:
            return False
        
        # Verifica se o tipo de usuário é Médico ou Secretária
        return request.user.user_type in ['MEDICO', 'SECRETARIA']