#!/bin/sh

set -e

# set some abuild defaults on first run
cat <<- EOF > "$HOME"/.abuild/abuild.conf
export JOBS=\$(nproc)
export MAKEFLAGS=-j\$JOBS
PACKAGER_PRIVKEY=$HOME/keys/signing.rsa
EOF

PRIVKEY_PATH="$HOME/keys/signing.rsa"
PUBKEY_PATH="$PRIVKEY_PATH.pub"

if ! [ -f "$PRIVKEY_PATH" ]; then
  mkdir -p "$HOME/keys"
  openssl genrsa -out "$PRIVKEY_PATH" 2048
  openssl rsa -in "$PRIVKEY_PATH" -pubout -out "$PUBKEY_PATH"
fi

sudo cp -v "$PUBKEY_PATH" /etc/apk/keys/
cp "$PUBKEY_PATH" "$HOME/packages/"
sudo apk -U upgrade -a

exec "$(command -v buildrepo)" $@
