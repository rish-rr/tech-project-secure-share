#!/bin/bash
KEY_PATH="$HOME/.ssh/id_ed25519"

if [ ! -f "$KEY_PATH" ]; then
    if ! ssh-keygen -t ed25519 -N "" -f "$KEY_PATH"; then
        echo "Keygen failed"
        exit 1
    fi
fi

cat "${KEY_PATH}.pub"
