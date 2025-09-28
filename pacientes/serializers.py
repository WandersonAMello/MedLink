# pacientes/serializers.py
from rest_framework import serializers
from .models import Paciente

class PacienteSerializer(serializers.ModelSerializer):
    # Campo personalizado para receber o nome completo e dividir
    username = serializers.CharField(write_only=True, required=True)
    password = serializers.CharField(write_only=True, required=True)

    class Meta:
        model = Paciente
        fields = [
            'id', 'email', 'password',
            'username',
            'first_name', 'last_name',
            'cpf', 'telefone', 'data_cadastro'
        ]
        extra_kwargs = {
            'first_name': {'write_only': True, 'required': False},
            'last_name': {'write_only': True, 'required': False},
        }

    def create(self, validated_data):
        # Extrai os campos necessários para o método create_user e para a lógica
        username = validated_data.pop('username')
        password = validated_data.pop('password')
        email = validated_data.pop('email')
        cpf = validated_data.pop('cpf')

        # Divide o username em nome e sobrenome
        nome_parts = username.split(' ', 1)
        first_name = nome_parts[0]
        last_name = nome_parts[1] if len(nome_parts) > 1 else ''

        # Adiciona os campos derivados ao restante dos dados validados (que agora contém 'telefone')
        validated_data['first_name'] = first_name
        validated_data['last_name'] = last_name
        validated_data['user_type'] = 'PACIENTE'

        # Chama o create_user do manager com os argumentos posicionais corretos (cpf, email, password)
        # e o resto dos dados (first_name, last_name, telefone, user_type) no **extra_fields
        paciente = Paciente.objects.create_user(
            cpf=cpf,
            email=email,
            password=password,
            **validated_data
        )
        return paciente