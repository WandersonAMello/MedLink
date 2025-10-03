# secretarias/serializers.py

from rest_framework import serializers
from agendamentos.models import Consulta

class DashboardStatsSerializer(serializers.Serializer):
    """
    Serializer para as estatísticas dos cards do dashboard.
    Não é baseado em um model, apenas define os campos que vamos enviar.
    """
    today = serializers.IntegerField()
    confirmed = serializers.IntegerField()
    pending = serializers.IntegerField()
    totalMonth = serializers.IntegerField()


class ConsultaHojeSerializer(serializers.ModelSerializer):
    """
    Serializer para a lista de "Consultas de Hoje".
    Ele vai mapear os campos do nosso modelo `Consulta` para os nomes
    que o front-end espera (`time`, `patient`, `doctor`, etc.).
    """
    # Aqui renomeamos e formatamos os campos para bater com o front-end
    time = serializers.TimeField(source='data_hora.time', format='%H:%M')
    patient = serializers.CharField(source='paciente_pessoa.nome_completo')
    doctor = serializers.CharField(source='medico_pessoa.pessoa.nome_completo')

    # O front-end espera um campo 'type'. Usaremos o status_atual para isso por enquanto.
    # Você pode adaptar para outro campo se tiver, como 'tipo_consulta'.
    type = serializers.CharField(source='get_status_atual_display')

    # O front-end espera o status em minúsculo (e.g., 'confirmed').
    # O SerializerMethodField nos dá flexibilidade para formatar.
    status = serializers.SerializerMethodField()

    class Meta:
        model = Consulta
        # Lista de campos que o JSON final terá
        fields = ['id', 'time', 'patient', 'doctor', 'type', 'status']

    def get_status(self, obj):
        # O front-end usa 'pending', 'confirmed', 'cancelled'.
        # Nosso banco usa 'AGENDADA', 'CONFIRMADA', 'CANCELADA'.
        # Esta função faz a tradução.
        if obj.status_atual == 'AGENDADA':
            return 'pending'
        elif obj.status_atual == 'CONFIRMADA':
            return 'confirmed'
        elif obj.status_atual == 'CANCELADA':
            return 'cancelled'
        return obj.status_atual.lower()