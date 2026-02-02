#!/usr/bin/env bash
set -euo pipefail

source ./lib.sh

check --type cmd nix ssh git

SOURCE_HOSTNAME=$(hostname)
TARGET_HOSTNAME=""
TARGET_USER=${TARGET_USER:-"devon"}
TARGET_IP=""
AUTH_KEY=${AUTH_KEY:-"/run/secrets/keys/default/private"}
SSH_PORT=${SSH_PORT:-22}
ROOT=$(git rev-parse --show-toplevel)

# TODO: this will replace the original help command
help() {
    print -i "Usage: $0 [OPTIONS]"
    echo
    echo "Required:"
    echo "  -n, --target-host-name <name>  Target hostname"
    echo "  -a, --target-host-ip <ip>      Target IP address"
    echo
    echo "Optional:"
    echo "  -u, --target-user <username>   Default user login (default: '$TARGET_USER')"
    echo "  -i, --input-private-key <key>  Authentication key (default: $AUTH_KEY)"
    echo "  -p, --ssh-port <port>          SSH port (default: 22)"
    echo "  -h, --help                     Show this help"
}

while (("$#")); do
    case $1 in
    -n | --target-host-name)
        TARGET_HOSTNAME="$2"
        shift 2
        ;;
    -a | --target-host-ip)
        TARGET_IP="$2"
        shift 2
        ;;
    -u | --target-user)
        TARGET_USER="$2"
        shift 2
        ;;
    -i | --input-private-key)
        AUTH_KEY="$2"
        shift 2
        ;;
    -p | --ssh-port)
        SSH_PORT="$2"
        shift 2
        ;;
    -h | --help)
        help
        exit 0
        ;;
    *)
        echo "Unknow arg: $1. See $0 --help"
        exit 1
        ;;
    esac
done

check --type var TARGET_HOSTNAME TARGET_IP

echo
print -i "Current install options:"
print -i "  Hostname: $TARGET_HOSTNAME"
print -i "  Key: $AUTH_KEY"
print -i "  IP: $TARGET_IP"
print -i "  Port: $SSH_PORT"
echo

if ! confirm "Confirm deploying options?"; then
    exit 0
fi
echo

# --PROCESS FUNCTIONS--

# --PRE-INSTALL--
# print -i "Evaluating target host system state..."
# if target system already have it client ssh key then process
# to ask user for full flake deployment

TARGET_ADDRESS="nixos@${TARGET_IP}"
SSH_CMD=(ssh -p "$SSH_PORT" -i "$AUTH_KEY" -o ConnectTimeout=10 "$TARGET_ADDRESS")
if "${SSH_CMD[@]}" "echo 'SSH OK'" >/dev/null 2>&1; then
    print -d "Connection ready!"
fi

print -i "Checking authentication key..."
if [[ ! -f "$AUTH_KEY" ]]; then
    print -e "Authentication key not found: $AUTH_KEY"
    exit 1
else
    print -d "Found authentication key at $AUTH_KEY"
fi
echo

print -i "Cleaning known_hosts entries for $TARGET_IP"
ssh-keygen -R "$TARGET_IP" >/dev/null 2>&1 || true
ssh-keygen -R "[$TARGET_IP]:$SSH_PORT" >/dev/null 2>&1 || true
echo

print -i "Adding SSH host fingerprint"
ssh-keyscan -t ed25519 -p "$SSH_PORT" "$TARGET_IP" >>~/.ssh/known_hosts 2>/dev/null
echo

print -i "Testing SSH connection..."
TARGET_ADDRESS="root@${TARGET_IP}"
SSH_CMD=(ssh -p "$SSH_PORT" -i "$AUTH_KEY" -o ConnectTimeout=10 "$TARGET_ADDRESS")
if ! "${SSH_CMD[@]}" "echo 'SSH OK'" >/dev/null 2>&1; then
    print -e "Cannot connect to $TARGET_ADDRESS"
    exit 1
else
    print -d "Connection ready!"
fi
echo

print -i "Generate target host client key..."
TEMP=$(mktemp -d)
chmod 700 "$TEMP"
cleanup() { rm -rf "$TEMP"; }
trap cleanup EXIT

install -d -m700 "$TEMP/home/nixos/.ssh"
ssh-keygen -t ed25519 -N "" \
    -C "host@${TARGET_HOSTNAME}" \
    -f "$TEMP/home/nixos/.ssh/host_$TARGET_HOSTNAME"
chmod 600 "$TEMP/home/nixos/.ssh/host_$TARGET_HOSTNAME"
echo

bootstrap=(
    nix run nixpkgs#nixos-anywhere --
    -i "$AUTH_KEY"
    --show-trace
    --extra-files "$TEMP"
    --ssh-port "$SSH_PORT"
    --flake "$ROOT/host#$TARGET_HOSTNAME"
    --target-host "$TARGET_ADDRESS"
)

if confirm "Run nixos-anywhere to install bootstrap system?"; then
    echo
    if confirm "Generate and copy target hardware-configuration.nix?"; then
        print -i "Detecting target architecture..."
        SSH_CMD=(ssh -p "$SSH_PORT" -i "$AUTH_KEY" "$TARGET_ADDRESS")
        if ARCH="$("${SSH_CMD[@]}" uname -m 2>/dev/null)-linux"; then
            print -d "Detected architecture: $ARCH"
            TARGET_HARDWARE="$ROOT/host/$ARCH/$TARGET_HOSTNAME"
            print -i "Adding hardware-configuration to $TARGET_HARDWARE"
            bootstrap+=(--generate-hardware-config nixos-generate-config "$TARGET_HARDWARE/hardware-configuration.nix")
        else
            print -w "Could not detect architecture, skipping..."
        fi
    fi

    "${bootstrap[@]}"
else
    echo
    print -d "Script terminated because user refused to bootstrap system."
    exit 0
fi
echo

print -d "Minimal state installation complete."
print -i "The following actions have been conducted:"
echo "  - Bootstrap system into minimal state"
echo "  - Change to flake default user"
echo "  - Generate target host client key for future deployment"
echo "  - Update default ISO ssh key to source host client key"
print -w "Current system is only suitable for testing purposes."
echo

# POST-BOOTSTRAP
if ! confirm "Continue the installation process?"; then
    exit 0
fi
echo

print -i "Update source known_hosts fingerprint."
ssh-keygen -R "$TARGET_IP" >/dev/null 2>&1 || true
[ "$SSH_PORT" != "22" ] && ssh-keygen -R "[${TARGET_IP}]:${SSH_PORT}" >/dev/null 2>&1 || true
ssh-keyscan -t ed25519 -p "$SSH_PORT" "$TARGET_IP" >>~/.ssh/known_hosts 2>/dev/null
echo

TARGET_ADDRESS="nixos@${TARGET_IP}"
SSH_CMD=(ssh -p "$SSH_PORT" -i ~/.ssh/host_wsl -o ConnectTimeout=10 "$TARGET_ADDRESS")
TARGET_KEY=$("${SSH_CMD[@]}" echo /home/nixos/.ssh/host_"$TARGET_HOSTNAME".pub)
while true; do
    if confirm "Added the given public key to secrets deployment key?" "y"; then
        break
    else
        print -w "Secrets ingestion is not possible without public key added to deployment key."
        if confirm "Cancel script?"; then
            exit 0
        else
            continue
        fi
    fi
done

if confirm "Copy public key to host config location?" "y"; then
    cat "$TARGET_KEY" "$ROOT/host/$ARCH/$TARGET_HOSTNAME/key.pub"
fi

# Fetch host SSH public key and convert it to age key
print -i "Copy and convert host server key to age format for secrets update."
scp -p "$SSH_PORT" -i "$AUTH_KEY" \
    "${TEMP}/${TARGET_HOSTNAME}_key.pub" \
    "$TARGET_ADDRESS:/etc/ssh/ssh_host_ed25519_key.pub"

TARGET_KEY=$(<"${TEMP}/${TARGET_HOSTNAME}_key.pub")
print -i "$TARGET_KEY"
