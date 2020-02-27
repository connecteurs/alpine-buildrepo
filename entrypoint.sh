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

# check if a private key is provided through the CI
if [ -f "$PRIVKEY" ]; then
  echo "Private key is defined, use it!"
  cp "$PRIVKEY" "$PRIVKEY_PATH"
fi

# generate a private key if it doesn't exist
if ! [ -f "$PRIVKEY_PATH" ]; then
  echo "Generating a new private key…"
  mkdir -p "$HOME/keys"
  openssl genrsa -out "$PRIVKEY_PATH" 2048
fi

# generate the public key in all cases using the private key
openssl rsa -in "$PRIVKEY_PATH" -pubout -out "$PUBKEY_PATH"

sudo cp -v "$PUBKEY_PATH" /etc/apk/keys/
cp "$PUBKEY_PATH" "$HOME/packages/"
sudo apk -U upgrade -a

exec "$(command -v buildrepo)" $@
