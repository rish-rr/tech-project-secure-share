#!/bin/bash
if [ "$#" -ne 3 ]; then
    echo "Wrong argument count"
    exit 1
fi

RECIPIENT="$1"
PUB_KEY="$2"
FILE="$3"
LOG_FILE="transfer.log"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
SENDER=$(whoami)

if [ ! -f "$FILE" ] || [ ! -f "$PUB_KEY" ]; then
    echo "Files not found"
    echo "$TIMESTAMP | $SENDER | $RECIPIENT | $FILE | N/A | FAILED" >> "$LOG_FILE"
    exit 1
fi

CHECKSUM=$(sha256sum "$FILE" | awk '{print $1}')
CHECKSUM_FILE="${FILE}.sha256"
echo "$CHECKSUM" > "$CHECKSUM_FILE"

ENC_FILE="${FILE}.age"
if ! age -R "$PUB_KEY" -o "$ENC_FILE" "$FILE"; then
    echo "Encryption failed"
    echo "$TIMESTAMP | $SENDER | $RECIPIENT | $FILE | sha256:$CHECKSUM | FAILED" >> "$LOG_FILE"
    rm -f "$CHECKSUM_FILE" "$ENC_FILE"
    exit 1
fi

if ! scp "$ENC_FILE" "$CHECKSUM_FILE" "${RECIPIENT}:~/"; then
    echo "Transfer failed"
    echo "$TIMESTAMP | $SENDER | $RECIPIENT | $FILE | sha256:$CHECKSUM | FAILED" >> "$LOG_FILE"
    rm -f "$CHECKSUM_FILE" "$ENC_FILE"
    exit 1
fi

echo "$TIMESTAMP | $SENDER | $RECIPIENT | $FILE | sha256:$CHECKSUM | SUCCESS" >> "$LOG_FILE"
rm -f "$ENC_FILE" "$CHECKSUM_FILE"
