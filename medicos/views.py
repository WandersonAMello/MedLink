# medicos/views.py

from rest_framework.generics import ListAPIView, UpdateAPIView
from rest_framework.permissions import IsAuthenticated
from agendamentos.models import Consulta
from agendamentos.serializers import ConsultaSerializer
from users.permissions import IsMedicoUser

class MedicoAgendaAPIView(ListAPIView):
    """
    API view para o médico visualizar a sua própria agenda de consultas.
    A agenda é retornada em formato de lista. O frontend será responsável
    por exibir em formato de calendário.
    """
    serializer_class = ConsultaSerializer
    permission_classes = [IsAuthenticated, IsMedicoUser]

    def get_queryset(self):
        # Filtra as consultas para retornar apenas as do médico logado.
        return Consulta.objects.filter(medico=self.request.user).order_by('data_hora')
    
class SolicitarReagendamentoAPIView(UpdateAPIView):
    """
    Endpoint para um médico solicitar o reagendamento de uma consulta.
    Altera o status da consulta para 'REAGENDAMENTO_SOLICITADO'.
    Utiliza o método PATCH ou PUT.
    """
    permission_classes = [IsAuthenticated, IsMedicoUser]
    queryset = Consulta.objects.all()
    serializer_class = ConsultaSerializer

    def update(self, request, *args, **kwargs):
        consulta = self.get_object()

        # Validação de segurança: o médico só pode alterar as suas próprias consultas
        if consulta.medico != request.user:
            return Response(
                {"detail": "Não autorizado a alterar esta consulta."},
                status=status.HTTP_403_FORBIDDEN
            )

        novo_status = STATUS_CONSULTA_REAGENDAMENTO_SOLICITADO

        # Altera o status da consulta
        consulta.status_atual = novo_status
        consulta.save()

        # Cria um registo no histórico de status para auditoria
        ConsultaStatusLog.objects.create(
            consulta=consulta,
            status_novo=novo_status,
            pessoa=request.user
        )

        # TODO (Lembrete para o futuro): Implementar a lógica para notificar a secretária.

        serializer = self.get_serializer(consulta)
        return Response(serializer.data)
