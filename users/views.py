# users/views.py
from rest_framework_simplejwt.views import TokenObtainPairView
from .serializers import MyTokenObtainPairSerializer
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import AllowAny
from django.contrib.auth import get_user_model
from django.contrib.auth.tokens import default_token_generator
from django.utils.http import urlsafe_base64_encode, urlsafe_base64_decode
from django.utils.encoding import force_bytes, force_str
from django.core.mail import send_mail
from django.conf import settings

User = get_user_model()

class MyTokenObtainPairView(TokenObtainPairView):
    serializer_class = MyTokenObtainPairSerializer

class PasswordResetRequestView(APIView):
    """
    View para solicitar a redefinição de senha.
    Aceita um POST com um 'email'.
    """
    permission_classes = [AllowAny]

    def post(self, request):
        email = request.data.get('email')
        if not email:
            return Response({'error': 'Email é obrigatório'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            # Busca o usuário pelo email
            user = User.objects.get(email=email)
        except User.DoesNotExist:
            return Response({'error': 'Usuário com este email não encontrado.'}, status=status.HTTP_404_NOT_FOUND)

        # Gerar token e UID
        token = default_token_generator.make_token(user)
        uid = urlsafe_base64_encode(force_bytes(user.pk))

        # 
        # ATENÇÃO AQUI: Verifique se a porta 3000 está correta
        # Nos prints anteriores, seu Flutter estava na porta 8080.
        # Coloque a porta correta do seu front-end aqui.
        #
        reset_url = f'http://localhost:3000/reset-password?uid={uid}&token={token}' 
        # Se o seu Flutter roda na 8080, mude para:
        # reset_url = f'http://localhost:8080/reset-password?uid={uid}&token={token}'

        # Enviar o e-mail
        try:
            send_mail(
                'Recuperação de Senha - MedLink',
                f'Olá,\n\nVocê solicitou a recuperação de senha. Clique no link abaixo para criar uma nova senha:\n\n{reset_url}\n\nSe você não solicitou isso, ignore este e-mail.',
                settings.DEFAULT_FROM_EMAIL,
                [user.email],
                fail_silently=False,
            )
            return Response({'message': 'Email de recuperação enviado.'}, status=status.HTTP_200_OK)
        except Exception as e:
            print(f"Erro ao enviar email: {e}")
            return Response({'error': 'Erro ao enviar o e-mail.'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

class PasswordResetConfirmView(APIView):
    """
    View para confirmar a redefinição de senha.
    Aceita POST com uid, token e password.
    """
    permission_classes = [AllowAny]

    def post(self, request):
        uidb64 = request.data.get('uid')
        token = request.data.get('token')
        password = request.data.get('password')

        if not uidb64 or not token or not password:
            return Response({'error': 'UID, token e nova senha são obrigatórios.'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            # Decodifica o UID
            uid = force_str(urlsafe_base64_decode(uidb64))
            user = User.objects.get(pk=uid)
        except (TypeError, ValueError, OverflowError, User.DoesNotExist):
            user = None

        # Verifica se o usuário existe e se o token é válido
        if user is not None and default_token_generator.check_token(user, token):
            if user.check_password(password):
                return Response(
                    {'error': 'A nova senha não pode ser igual à senha antiga.'}, 
                    status=status.HTTP_400_BAD_REQUEST
                )
            # Se tudo estiver OK, define a nova senha
            user.set_password(password)
            user.save()
            return Response({'message': 'Senha redefinida com sucesso.'}, status=status.HTTP_200_OK)
        else:
            # Se o token for inválido ou o UID estiver errado
            return Response({'error': 'O link de redefinição é inválido ou expirou.'}, status=status.HTTP_400_BAD_REQUEST)