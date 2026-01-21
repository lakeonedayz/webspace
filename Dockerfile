FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
      shellinabox \
      nginx \
      apache2-utils && \
    apt-get clean

# Remover site default
RUN rm /etc/nginx/sites-enabled/default

# Config NGINX com Basic Auth
RUN printf 'server {\n\
    listen 8080;\n\
\n\
    auth_basic "Acesso Restrito";\n\
    auth_basic_user_file /etc/nginx/.htpasswd;\n\
\n\
    location / {\n\
        proxy_pass http://127.0.0.1:4200;\n\
        proxy_set_header Host $host;\n\
        proxy_set_header X-Real-IP $remote_addr;\n\
    }\n\
}\n' > /etc/nginx/sites-enabled/shellinabox

# Script de startup
RUN printf '#!/bin/bash\n\
set -e\n\
\n\
if [ -z "$LOGIN_SEC" ] || [ -z "$SENHA_SEC" ]; then\n\
  echo "ERRO: LOGIN_SEC ou SENHA_SEC não definidos"\n\
  exit 1\n\
fi\n\
\n\
echo "Criando autenticação HTTP..."\n\
htpasswd -bc /etc/nginx/.htpasswd "$LOGIN_SEC" "$SENHA_SEC"\n\
\n\
echo "Iniciando ShellInABox..."\n\
/usr/bin/shellinaboxd --no-beep --disable-ssl --port=4200 &\n\
\n\
echo "Iniciando NGINX..."\n\
nginx -g "daemon off;"\n' > /start.sh && \
chmod +x /start.sh

EXPOSE 8080

CMD ["/start.sh"]
