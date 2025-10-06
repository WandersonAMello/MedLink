# pacientes/serializers.py
from rest_framework import serializers
from .models import Paciente
from users.models import User
from django.db import transaction

class PacienteSerializer(serializers.ModelSerializer):
    # Campos para receber dados que pertencem ao modelo User
    username = serializers.CharField(write_only=True, required=True, source="user.first_name") # Mapeia para o nome
    password = serializers.CharField(write_only=True, required=True)
    email = serializers.EmailField(required=True, source="user.email")
    cpf = serializers.CharField(required=True, source="user.cpf")

    class Meta:
        model = Paciente
        # 'user' não precisa estar nos fields se for a PK e for gerenciado internamente
        fields = [
            'email', 'password', 'username', 'cpf',
            'telefone', 'data_cadastro'
        ]
        read_only_fields = ['data_cadastro']

    # O método transaction.atomic garante que ou os dois objetos (User e Paciente)
    # são criados, ou nenhum deles é, mantendo a integridade do banco.
    @transaction.atomic
    def create(self, validated_data):
        # 1. Extrai os dados do usuário do dicionário validado
        user_data = validated_data.pop('user')
        password = validated_data.pop('password')
        
        # O username vem como 'first_name' devido ao 'source' no serializer
        full_name = user_data.pop('first_name')
        
        # Divide o nome completo em nome e sobrenome
        name_parts = full_name.split(' ', 1)
        first_name = name_parts[0]
        last_name = name_parts[1] if len(name_parts) > 1 else ''

        # 2. Cria a instância do User
        user = User.objects.create_user(
            cpf=user_data['cpf'],
            email=user_data['email'],
            password=password,
            first_name=first_name,
            last_name=last_name,
            user_type='PACIENTE' # Define o tipo de usuário
        )

        # 3. Cria a instância do Paciente, ligando-a ao User recém-criado
        # validated_data agora contém apenas o campo 'telefone'
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

# Um serializer auxiliar para os dados do usuário que queremos mostrar
class UserForPatientSerializer(serializers.ModelSerializer):
    full_name = serializers.CharField(source='get_full_name')

    class Meta:
        model = User
        fields = ['id', 'full_name', 'email', 'cpf']

# Em pacientes/serializers.py
class PacienteSerializer(serializers.ModelSerializer):
    user = UserForPatientSerializer(read_only=True)
    class Meta:
        model = Paciente
        fields = ['telefone', 'data_cadastro', 'user'] # <--- Correção: Removido 'user_ptr_id'