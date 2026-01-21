#!/bin/bash
set -e

# verifica se secrets vieram
if [ -z "$LOGIN_SEC" ] || [ -z "$SENHA_SEC" ]; then
  echo "ERRO: LOGIN_SEC ou SENHA_SEC não definidos"
  exit 1
fi

# cria usuário se não existir
if ! id "$LOGIN_SEC" &>/dev/null; then
  useradd -m "$LOGIN_SEC"
  echo "$LOGIN_SEC:$SENHA_SEC" | chpasswd
  adduser "$LOGIN_SEC" sudo
fi

exec shellinaboxd \
  --no-beep \
  --disable-ssl \
  --port=4200 \
  --service="/terminal:$LOGIN_SEC:$LOGIN_SEC:/home/$LOGIN_SEC:/bin/bash"
