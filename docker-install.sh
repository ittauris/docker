#!/bin/bash
# Autor: Marek Findrik
# Verzia: 2.2
# Popis: Opravena instalacia Docker s fallbackom a kontrolou sluzby

LOG_FILE="/var/log/docker_setup.log"
echo "=== DOCKER SETUP SCRIPT v2.2 ===" | tee -a "$LOG_FILE"
echo "Cas spustenia: $(date)" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

if [ "$EUID" -ne 0 ]; then
  echo "Tento skript musi byt spusteny ako root. Pouzi sudo." | tee -a "$LOG_FILE"
  exit 1
fi

# Zistenie verzie Ubuntu
CODENAME=$(lsb_release -cs 2>/dev/null || echo "unknown")
SUPPORTED=$(curl -fsSL https://download.docker.com/linux/ubuntu/dists/ | grep -oP '(?<=href=")[^/]+(?=/")' | tr '\n' ' ')
if ! echo "$SUPPORTED" | grep -qw "$CODENAME"; then
  echo "Upozornenie: Verzia '$CODENAME' nie je podporovana Dockerom. Pouzijem 'jammy'." | tee -a "$LOG_FILE"
  CODENAME="jammy"
fi

# Aktualizacia systemu
echo "Aktualizujem system..." | tee -a "$LOG_FILE"
apt update -y && apt upgrade -y >> "$LOG_FILE" 2>&1

# Zavislosti
apt install -y ca-certificates curl gnupg lsb-release >> "$LOG_FILE" 2>&1

# GPG kluc
mkdir -p /etc/apt/keyrings
if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg
fi

# Repo
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu $CODENAME stable" > /etc/apt/sources.list.d/docker.list

# Instalacia Docker Engine
apt update -y >> "$LOG_FILE" 2>&1
if ! apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin >> "$LOG_FILE" 2>&1; then
  echo "CHYBA: Nepodarilo sa nainstalovat Docker. Skontroluj repozitar." | tee -a "$LOG_FILE"
  exit 1
fi

# Vytvor skupinu docker ak chyba
if ! getent group docker >/dev/null; then
  echo "Skupina docker neexistuje, vytvaram..." | tee -a "$LOG_FILE"
  groupadd docker
fi

# Pridanie pouzivatela
if [ -n "$SUDO_USER" ] && ! groups $SUDO_USER | grep -qw docker; then
  usermod -aG docker $SUDO_USER
  echo "Pouzivatel $SUDO_USER bol pridany do skupiny docker." | tee -a "$LOG_FILE"
fi

# Spustenie sluzby
systemctl enable docker >> "$LOG_FILE" 2>&1
systemctl start docker >> "$LOG_FILE" 2>&1

if ! systemctl is-active --quiet docker; then
  echo "CHYBA: Docker sluzba sa nespustila. Skontroluj log: journalctl -u docker" | tee -a "$LOG_FILE"
  exit 1
fi

# Portainer
if ! docker ps -a --format '{{.Names}}' | grep -qw portainer; then
  docker volume create portainer_data
  docker run -d -p 9000:9000 --name=portainer \
    --restart=always \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v portainer_data:/data \
    portainer/portainer-ce:latest
fi

# Watchtower
if ! docker ps -a --format '{{.Names}}' | grep -qw watchtower; then
  docker run -d --name watchtower \
    --restart=always \
    -v /var/run/docker.sock:/var/run/docker.sock \
    containrrr/watchtower --interval 3600
fi

echo "Docker, Compose, Portainer a Watchtower su nainstalovane." | tee -a "$LOG_FILE"
echo "Odhlas sa a prihlas spat, aby sa aktivovali prava skupiny docker." | tee -a "$LOG_FILE"

