# administrador/serializers.py
from rest_framework import serializers
from users.models import User
from .models import LogEntry

class AdminUserSerializer(serializers.ModelSerializer):
    """
    Serializer para a listagem (READ) de utilizadores no painel de administração.
    Mostra os dados de forma legível.
    """
    user_type_display = serializers.CharField(source='get_user_type_display', read_only=True)

    class Meta:
        model = User
        fields = [
            'id', 'first_name', 'last_name', 'email', 'cpf', 
            'user_type', 'user_type_display', 'is_active', 'last_login'
        ]

class AdminUserCreateUpdateSerializer(serializers.ModelSerializer):
    """
    Serializer para a criação (CREATE) e atualização (UPDATE) de utilizadores.
    """
    class Meta:
        model = User
        fields = [
            'first_name', 'last_name', 'email', 'cpf', 
            'user_type', 'password', 'is_active'
        ]
        extra_kwargs = {
            'password': {'write_only': True}
        }

    def create(self, validated_data):
        # Chama o manager customizado para criar o utilizador com a senha hasheada
        user = User.objects.create_user(**validated_data)
        return user

    def update(self, instance, validated_data):
        password = validated_data.pop('password', None)
        user = super().update(instance, validated_data)

        if password:
            user.set_password(password)
            user.save()
            
        return user
    
class LogEntrySerializer(serializers.ModelSerializer):
    """
    Serializer para o modelo de LogEntry.
    """
    actor_name = serializers.CharField(source='actor.get_full_name', read_only=True)
    action_display = serializers.CharField(source='get_action_type_display', read_only=True)

    class Meta:
        model = LogEntry
        fields = ['id', 'timestamp', 'actor', 'actor_name', 'action_type', 'action_display', 'details']