# pacientes/serializers.py
from rest_framework import serializers
from .models import Paciente

class PacienteSerializer(serializers.ModelSerializer):
    # Campo personalizado para receber o nome completo e dividir
    nome_completo = serializers.CharField(write_only=True, required=True)
    password = serializers.CharField(write_only=True, required=True)

    class Meta:
        model = Paciente
        fields = [
            'id', 'email', 'password',
            'nome_completo',
            'first_name', 'last_name',
            'cpf', 'telefone', 'data_cadastro'
        ]
        extra_kwargs = {
            'first_name': {'write_only': True, 'required': False},
            'last_name': {'write_only': True, 'required': False},
        }

    def create(self, validated_data):
        nome_completo = validated_data.pop('nome_completo')
        password = validated_data.pop('password')
        
        nome_parts = nome_completo.split(' ', 1)
        first_name = nome_parts[0]
        last_name = nome_parts[1] if len(nome_parts) > 1 else ''

        paciente = Paciente.objects.create_user(
            first_name=first_name,
            last_name=last_name,
            password=password,
            user_type='PACIENTE', # Tipo padrão para pacientes
            **validated_data
        )
        return paciente