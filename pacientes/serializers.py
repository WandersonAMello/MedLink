# pacientes/serializers.py
from rest_framework import serializers
from .models import Paciente
from users.models import User
from django.db import transaction

class PacienteCreateSerializer(serializers.ModelSerializer):
    # Pega os campos do User que virão no JSON do Flutter
    cpf = serializers.CharField(write_only=True, required=True)
    email = serializers.EmailField(write_only=True, required=True)
    password = serializers.CharField(write_only=True, required=True)
    first_name = serializers.CharField(write_only=True, required=True)
    last_name = serializers.CharField(write_only=True, required=False, allow_blank=True)

    class Meta:
        model = Paciente
        # O serializer espera o 'telefone' do modelo Paciente. Os outros campos vêm do User.
        fields = ['cpf', 'email', 'password', 'first_name', 'last_name', 'telefone']
        # Adicione o 'data_nascimento' se o Flutter estiver enviando e seu modelo Paciente tiver esse campo

    @transaction.atomic # Garante que ou tudo é salvo, ou nada é salvo
    def create(self, validated_data):
        # 1. Separa os dados que são do User
        user_data = {
            'cpf': validated_data.pop('cpf'),
            'email': validated_data.pop('email'),
            'password': validated_data.pop('password'),
            'first_name': validated_data.pop('first_name'),
            'last_name': validated_data.pop('last_name', ''),
            'user_type': 'PACIENTE' # Define o tipo de usuário como PACIENTE
        }
        
        # 2. Cria o User primeiro, usando o manager customizado
        user = User.objects.create_user(**user_data)

        # 3. Cria o Paciente, vinculando o User recém-criado
        # validated_data agora só contém os campos do Paciente (ex: 'telefone')
        paciente = Paciente.objects.create(user=user, **validated_data)
        
        return paciente
    def to_representation(self, instance):
        """Modifica a representação de saída para incluir dados do User."""
        representation = super().to_representation(instance)
        user = instance.user
        representation['id'] = user.id
        representation['email'] = user.email
        representation['cpf'] = user.cpf
        representation['nome_completo'] = user.get_full_name()
        return representation
    


from rest_framework import serializers
from .models import Paciente
from users.models import User

class UserForPatientSerializer(serializers.ModelSerializer):
    nome_completo = serializers.CharField(source='get_full_name')

    class Meta:
        model = User
        fields = ['id', 'nome_completo', 'email', 'cpf']


class PacienteSerializer(serializers.ModelSerializer):
    user = UserForPatientSerializer(read_only=True)

    class Meta:
        model = Paciente
        fields = ['id', 'user', 'telefone']  # Adicione outros campos do Paciente conforme necessário
