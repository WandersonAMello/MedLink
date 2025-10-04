from rest_framework import serializers
from .models import Consulta, Pagamento
from users.models import User
from pacientes.models import Paciente
from clinicas.models import Clinica
from medicos.models import Medico # <-- Importação do modelo Medico

class PagamentoSerializer(serializers.ModelSerializer):
    class Meta:
        model = Pagamento
        fields = ['status', 'valor_pago', 'data_pagamento']

class ConsultaSerializer(serializers.ModelSerializer):
    # Serializador aninhado para o Pagamento.
    # O 'many=False' é o padrão, mas o incluímos por clareza em relações OneToOne.
    pagamento = PagamentoSerializer(read_only=True)
    
    # Adicionamos campos para exibir informações detalhadas dos objetos relacionados.
    paciente_detalhes = serializers.SerializerMethodField()
    medico_detalhes = serializers.SerializerMethodField()
    clinica_detalhes = serializers.SerializerMethodField()

    class Meta:
        model = Consulta
        fields = [
            'id', 'data_hora', 'status_atual', 'valor', 'paciente', 'medico', 'clinica',
            'paciente_detalhes', 'medico_detalhes', 'clinica_detalhes', 'pagamento'
        ]
        read_only_fields = ['pagamento']
    
    # Métodos para obter e serializar os detalhes dos objetos relacionados.
    def get_paciente_detalhes(self, obj):
        if obj.paciente and hasattr(obj.paciente, 'user'):
            return {
                'id': obj.paciente.user.id,
                'nome_completo': obj.paciente.nome_completo,
                'cpf': obj.paciente.user.cpf,
            }
        return None


    def get_medico_detalhes(self, obj):
        # O 'obj.medico' é a instância do User associado à consulta.
        if obj.medico:
            try:
                # Acessamos o perfil de médico através do related_name 'perfil_medico'
                perfil_medico = obj.medico.perfil_medico
                return {
                    'id': obj.medico.id,
                    'nome_completo': obj.medico.get_full_name(),
                    'email': obj.medico.email,
                    # Adicionando os dados específicos do modelo Medico
                    'crm': perfil_medico.crm,
                    'especialidade': perfil_medico.get_especialidade_display(),
                }
            except Medico.DoesNotExist:
                # Caso um User seja do tipo MÉDICO mas não tenha um perfil associado.
                return {
                    'id': obj.medico.id,
                    'nome_completo': obj.medico.get_full_name(),
                    'email': obj.medico.email,
                    'crm': None,
                    'especialidade': None,
                }
        return None

    def get_clinica_detalhes(self, obj):
        try:
            clinica = Clinica.objects.get(id=obj.clinica.id)
            return {
                'id': clinica.id,
                'nome_fantasia': clinica.nome_fantasia,
                'cnpj': clinica.cnpj,
            }
        except Clinica.DoesNotExist:
            return None

