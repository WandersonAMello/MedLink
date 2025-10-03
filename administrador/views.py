# administrador/views.py
from rest_framework import viewsets, filters, status
from users.permissions import IsAdmin
from rest_framework.response import Response
from rest_framework.views import APIView
from django_filters.rest_framework import DjangoFilterBackend
from users.models import User
from medicos.models import Medico
from pacientes.models import Paciente
from .models import LogEntry
from .serializers import (
    AdminUserSerializer,
    AdminUserCreateUpdateSerializer,
    LogEntrySerializer
    )

class AdminUserViewSet(viewsets.ModelViewSet):
    """
    Endpoint da API para administradores gerirem todos os utilizadores do sistema.
    """
    queryset = User.objects.all().order_by('first_name')
    permission_classes = [IsAdmin]  # Apenas administradores do Django podem aceder

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
        """ Sobrescreve para adicionar log na criação. """
        user = serializer.save()
        LogEntry.objects.create(
            actor=self.request.user,
            action_type=LogEntry.ActionType.CREATE,
            details=f"Criou o utilizador '{user.get_full_name()}' (CPF: {user.cpf}, Tipo: {user.get_user_type_display()})."
        )

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
    permission_classes = [IsAdmin]

    def get(self, request, *args, **kwargs):
        total_users = User.objects.count()
        active_users = User.objects.filter(is_active=True).count()
        
        # Considerando que Paciente herda de User e Medico é um tipo de User
        total_doctors = User.objects.filter(user_type='MEDICO').count()
        total_secretaries = User.objects.filter(user_type='SECRETARIA').count()
        total_patients = User.objects.filter(user_type='PACIENTE').count()

        
        stats = {
            'total_usuarios': total_users,
            'ativos': active_users,
            'medicos': total_doctors,
            'secretarias': total_secretaries,
            'pacientes': total_patients,
        }
        
        return Response(stats, status=status.HTTP_200_OK)

class LogEntryViewSet(viewsets.ReadOnlyModelViewSet):
    """
    Endpoint para visualizar os registos de log (auditoria).
    Apenas permite a leitura (listagem e detalhe).
    """
    queryset = LogEntry.objects.all()
    serializer_class = LogEntrySerializer
    permission_classes = [IsAdmin]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter]
    filterset_fields = ['action_type', 'actor']
    search_fields = ['details', 'actor__cpf', 'actor__first_name']