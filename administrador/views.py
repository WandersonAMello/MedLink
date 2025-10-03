# administrador/views.py
from rest_framework import viewsets, filters, status, permissions, serializers
from rest_framework.response import Response
from rest_framework.views import APIView
from django_filters.rest_framework import DjangoFilterBackend
from django.db import transaction

# Modelos do projeto
from users.models import User
from pacientes.models import Paciente
# from medicos.models import Medico # Futuramente, importar o modelo de Medico
# from secretarias.models import Secretaria # Futuramente, importar o modelo de Secretaria
from .models import LogEntry

# Serializers do app
from .serializers import (
    AdminUserSerializer,
    AdminUserCreateUpdateSerializer,
    LogEntrySerializer
)

# Permissões
from users.permissions import IsAdmin # Assumindo que esta permissão existe em users/permissions.py


class AdminUserViewSet(viewsets.ModelViewSet):
    """
    Endpoint da API para administradores gerirem todos os utilizadores do sistema.
    """
    queryset = User.objects.all().order_by('first_name')
    permission_classes = [permissions.IsAdminUser]

    # Filtros para a UI (busca e dropdown de tipo)
    filter_backends = [DjangoFilterBackend, filters.SearchFilter]
    filterset_fields = ['user_type', 'is_active']
    search_fields = ['first_name', 'last_name', 'email', 'cpf']

    def get_serializer_class(self):
        # Usa um serializer diferente para ler vs. escrever
        if self.action in ['create', 'update', 'partial_update']:
            return AdminUserCreateUpdateSerializer
        return AdminUserSerializer

    def perform_create(self, serializer):
        """
        Sobrescreve o método padrão para criar perfis associados
        após a criação do usuário, garantindo a integridade dos dados.
        """
        # 1. Primeiro, o serializer.save() cria a instância do User.
        user = serializer.save()

        # 2. Em seguida, verifica o user_type para criar o perfil correspondente.
        try:
            with transaction.atomic():
                if user.user_type == 'PACIENTE':
                    # Dados específicos do perfil (ex: telefone) são pegos do request.
                    telefone = self.request.data.get('telefone', '')
                    Paciente.objects.create(user=user, telefone=telefone)
                
                # Exemplo para futuros perfis:
                # elif user.user_type == 'MEDICO':
                #     crm = self.request.data.get('crm', '')
                #     Medico.objects.create(user=user, crm=crm)
                
                # elif user.user_type == 'SECRETARIA':
                #     # Exemplo para quando o modelo Secretaria existir
                #     clinica_id = self.request.data.get('clinica_id')
                #     Secretaria.objects.create(user=user, clinica_id=clinica_id)
                
                # 3. Cria o log de auditoria se tudo correu bem.
                LogEntry.objects.create(
                    actor=self.request.user,
                    action_type=LogEntry.ActionType.CREATE,
                    details=f"Criou o utilizador '{user.get_full_name()}' (CPF: {user.cpf}, Tipo: {user.get_user_type_display()})."
                )
        except Exception as e:
            # Se a criação do perfil falhar, o usuário recém-criado é deletado
            # para evitar inconsistência no banco de dados.
            user.delete()
            # Lança um erro claro para a API.
            raise serializers.ValidationError({"detail": f"Falha ao criar perfil associado: {str(e)}"})


    def perform_update(self, serializer):
        """ Sobrescreve para adicionar log na atualização. """
        user = serializer.save()
        LogEntry.objects.create(
            actor=self.request.user,
            action_type=LogEntry.ActionType.UPDATE,
            details=f"Atualizou o utilizador '{user.get_full_name()}' (CPF: {user.cpf})."
        )

    def perform_destroy(self, instance):
        """ Sobrescreve para adicionar log na remoção. """
        details = f"Removeu o utilizador '{instance.get_full_name()}' (CPF: {instance.cpf})."
        # A exclusão do User irá remover o perfil associado devido ao on_delete=models.CASCADE
        instance.delete()
        LogEntry.objects.create(
            actor=self.request.user,
            action_type=LogEntry.ActionType.DELETE,
            details=details
        )


class AdminDashboardStatsAPIView(APIView):
    """
    Endpoint para fornecer as estatísticas agregadas para o painel de administração.
    """
    permission_classes = [permissions.IsAdminUser]

    def get(self, request, *args, **kwargs):
        total_users = User.objects.count()
        active_users = User.objects.filter(is_active=True).count()
        
        total_doctors = User.objects.filter(user_type='MEDICO').count()
        total_secretaries = User.objects.filter(user_type='SECRETARIA').count()
        total_patients = User.objects.filter(user_type='PACIENTE').count()

        stats = {
            'total': total_users,
            'active': active_users,
            'doctors': total_doctors,
            'secretaries': total_secretaries,
            'patients': total_patients,
        }
        
        return Response(stats, status=status.HTTP_200_OK)


class LogEntryViewSet(viewsets.ReadOnlyModelViewSet):
    """
    Endpoint para visualizar os registos de log (auditoria).
    Apenas permite a leitura (listagem e detalhe).
    """
    queryset = LogEntry.objects.all()
    serializer_class = LogEntrySerializer
    permission_classes = [permissions.IsAdminUser]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter]
    filterset_fields = ['action_type', 'actor']
    search_fields = ['details', 'actor__cpf', 'actor__first_name']