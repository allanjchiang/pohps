#!/usr/bin/env bash
# Creates android/app/upload-keystore.jks and android/key.properties for Play Store uploads.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KEYSTORE="$SCRIPT_DIR/app/upload-keystore.jks"
PROPS="$SCRIPT_DIR/key.properties"

if [[ -f "$KEYSTORE" ]]; then
  echo "Keystore already exists: $KEYSTORE"
  echo "Delete it first if you need to create a new one."
  exit 1
fi

if [[ -f "$PROPS" ]]; then
  echo "key.properties already exists: $PROPS"
  exit 1
fi

echo "Create a upload keystore for POHPS (com.logicphile.pohps)"
echo "You will need these passwords for every future release — store them safely."
echo

read -rsp "Keystore password (storePassword): " STORE_PASS
echo
read -rsp "Key password (keyPassword, Enter to match store): " KEY_PASS
echo
if [[ -z "$KEY_PASS" ]]; then
  KEY_PASS="$STORE_PASS"
fi

read -rp "Country code (2 letters, e.g. NZ, GB, US) [NZ]: " COUNTRY
COUNTRY="${COUNTRY:-NZ}"

keytool -genkeypair -v \
  -storetype PKCS12 \
  -keystore "$KEYSTORE" \
  -alias upload \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -storepass "$STORE_PASS" \
  -keypass "$KEY_PASS" \
  -dname "CN=Logicphile Limited, OU=Mobile, O=Logicphile Limited, C=$COUNTRY"

cat > "$PROPS" <<EOF
storePassword=$STORE_PASS
keyPassword=$KEY_PASS
keyAlias=upload
storeFile=app/upload-keystore.jks
EOF

chmod 600 "$PROPS"

echo
echo "Created:"
echo "  $KEYSTORE"
echo "  $PROPS"
echo
echo "Back up both files somewhere safe (password manager + encrypted backup)."
echo "Then build a release bundle:"
echo "  flutter build appbundle --release"
