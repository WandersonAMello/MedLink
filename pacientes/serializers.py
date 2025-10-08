# pacientes/serializers.py (VERSÃO CORRIGIDA E SIMPLIFICADA)

from rest_framework import serializers
from .models import Paciente
from users.models import User
from django.db import transaction

class PacienteCreateSerializer(serializers.ModelSerializer):
    cpf = serializers.CharField(write_only=True, required=True)
    email = serializers.EmailField(write_only=True, required=True)
    password = serializers.CharField(write_only=True, required=True)
    first_name = serializers.CharField(write_only=True, required=True)
    last_name = serializers.CharField(write_only=True, required=False, allow_blank=True)

    class Meta:
        model = Paciente
        fields = ['cpf', 'email', 'password', 'first_name', 'last_name', 'telefone']

    @transaction.atomic
    def create(self, validated_data):
        user_data = {
            'cpf': validated_data.pop('cpf'),
            'email': validated_data.pop('email'),
            'password': validated_data.pop('password'),
            'first_name': validated_data.pop('first_name'),
            'last_name': validated_data.pop('last_name', ''),
            'user_type': 'PACIENTE'
        }
        user = User.objects.create_user(**user_data)
        paciente = Paciente.objects.create(user=user, **validated_data)
        return paciente

    def to_representation(self, instance):
        """Modifica a representação de saída para incluir os dados do User no formato plano."""
        # Não chama o super() para ter controlo total sobre a saída
        representation = {}
        user = instance.user
        representation['id'] = user.id
        representation['email'] = user.email
        representation['cpf'] = user.cpf
        representation['nome_completo'] = user.get_full_name()
        representation['telefone'] = instance.telefone # Pega o telefone do modelo Paciente
        return representation