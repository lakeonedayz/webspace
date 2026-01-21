FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y shellinabox sudo && \
    apt-get clean

# Variáveis que virão do GitHub Actions
ENV LOGIN_SEC=user
ENV SENHA_SEC=pass

# Script de inicialização
RUN printf '#!/bin/bash\n\
useradd -m -s /bin/bash "$LOGIN_SEC"\n\
echo "$LOGIN_SEC:$SENHA_SEC" | chpasswd\n\
usermod -aG sudo "$LOGIN_SEC"\n\
exec /usr/bin/shellinaboxd \\\n\
  --no-beep \\\n\
  --disable-ssl \\\n\
  --port=4200 \\\n\
  --service=/terminal:"$LOGIN_SEC":"$LOGIN_SEC":/home/"$LOGIN_SEC":/bin/bash\n' > /start.sh && \
    chmod +x /start.sh

EXPOSE 4200

CMD ["/start.sh"]
