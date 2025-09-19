# users/models.py
from django.contrib.auth.models import AbstractUser, BaseUserManager
from django.db import models
from django.utils.translation import gettext_lazy as _

class CustomUserManager(BaseUserManager):
    """
    Manager customizado para o nosso modelo de User onde o CPF é o identificador
    único para autenticação em vez de usernames.
    """
    def create_user(self, cpf, email, password, **extra_fields):
        if not cpf:
            raise ValueError(_('O CPF deve ser fornecido'))
        if not email:
            raise ValueError(_('O Email deve ser fornecido'))
        
        email = self.normalize_email(email)
        user = self.model(cpf=cpf, email=email, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, cpf, email, password, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        extra_fields.setdefault('is_active', True)
        extra_fields.setdefault('user_type', 'ADMIN')

        if extra_fields.get('is_staff') is not True:
            raise ValueError(_('Superuser must have is_staff=True.'))
        if extra_fields.get('is_superuser') is not True:
            raise ValueError(_('Superuser must have is_superuser=True.'))
        return self.create_user(cpf, email, password, **extra_fields)

class User(AbstractUser):
    # Remove o campo username do modelo padrão
    username = None

    # Enumeração para os tipos de usuário (nossos papéis)
    class UserType(models.TextChoices):
        ADMIN = 'ADMIN', 'Admin'
        MEDICO = 'MEDICO', 'Médico'
        SECRETARIA = 'SECRETARIA', 'Secretária'
        PACIENTE = 'PACIENTE', 'Paciente'

    # Campos do nosso modelo
    cpf = models.CharField(_('CPF'), max_length=11, unique=True)
    email = models.EmailField(_('endereço de email'), unique=True)
    user_type = models.CharField(max_length=20, choices=UserType.choices)

    # Configurações do modelo
    USERNAME_FIELD = 'cpf'
    REQUIRED_FIELDS = ['email', 'first_name', 'last_name']

    objects = CustomUserManager()

    def __str__(self):
        return self.get_full_name() or self.cpf