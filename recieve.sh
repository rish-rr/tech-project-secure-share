#!/bin/bash
if [ "$#" -ne 2 ]; then
    echo "Wrong argument count"
    exit 1
fi

ENC_FILE="$1"
ORIG_FILE="$2"
CHECKSUM_FILE="${ORIG_FILE}.sha256"
PRIV_KEY="$HOME/.ssh/id_ed25519"

if [ ! -f "$ENC_FILE" ] || [ ! -f "$CHECKSUM_FILE" ]; then
    echo "Files not found"
    exit 1
fi

if ! age -d -i "$PRIV_KEY" -o "$ORIG_FILE" "$ENC_FILE"; then
    echo "Decryption failed"
    exit 1
fi

EXPECTED_CHECKSUM=$(cat "$CHECKSUM_FILE")
ACTUAL_CHECKSUM=$(sha256sum "$ORIG_FILE" | awk '{print $1}')

if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]; then
    echo "Checksum mismatch"
    exit 1
fi
