#!/bin/bash

clear

# ===============================
#        Z R A C K  B A N N E R
# ===============================

echo "███████╗██████╗  █████╗  ██████╗██╗  ██╗"
echo "╚══███╔╝██╔══██╗██╔══██╗██╔════╝██║ ██╔╝"
echo "  ███╔╝ ██████╔╝███████║██║     █████╔╝ "
echo " ███╔╝  ██╔══██╗██╔══██║██║     ██╔═██╗ "
echo "███████╗██║  ██║██║  ██║╚██████╗██║  ██╗"
echo "╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝"
echo ""
echo "▓▓▓  ZRACK SSH Passphrase Deconstruction Engine  ▓▓▓"
echo "------------------------------------------------------"
echo ""

# ===============================
#      DEPENDENCY CHECK
# ===============================

if ! command -v ssh2john &> /dev/null || ! command -v john &> /dev/null; then
    echo "[!] Error: ssh2john or john not installed."
    exit 1
fi

# ===============================
#      INTERACTIVE INPUT
# ===============================

echo "[1] Enter path to RSA Private Key file:"
read -e SSH_KEY_FILE   # <-- enables TAB completion

if [ ! -f "$SSH_KEY_FILE" ]; then
    echo "[!] File not found."
    exit 1
fi

echo ""
echo "[2] Enter path to Wordlist file:"
read -e WORDLIST_FILE  # <-- enables TAB completion

if [ ! -f "$WORDLIST_FILE" ]; then
    echo "[!] Wordlist not found."
    exit 1
fi

HASH_FILE="zrack_temp_hash"

echo ""
echo "[*] Extracting hash..."
ssh2john "$SSH_KEY_FILE" > "$HASH_FILE"

if [ $? -ne 0 ]; then
    echo "[!] Failed extracting hash."
    rm -f "$HASH_FILE"
    exit 1
fi

echo "[*] Launching dictionary attack..."
john --wordlist="$WORDLIST_FILE" "$HASH_FILE"

echo ""
echo "[*] Checking result..."

CRACKED_OUTPUT=$(john --show "$HASH_FILE")

# Extract only password (format: filename:password)
PASSWORD=$(echo "$CRACKED_OUTPUT" | grep ":" | cut -d ':' -f2)

if [ -n "$PASSWORD" ]; then
    echo ""
    echo "████████████████████████████████████████"
    echo "        PASSWORD FOUND"
    echo "----------------------------------------"
    echo "Passphrase: $PASSWORD"
    echo "████████████████████████████████████████"
else
    echo ""
    echo "[!] No password cracked."
fi

rm -f "$HASH_FILE"

echo ""
echo "[✓] Operation completed."